import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../user_data/call_details.dart';
import 'duration_formatter.dart';
import 'firebase_services.dart';
import 'join_services.dart';

class MeetingPage extends StatefulWidget {
  String roomUrl;
  String roomId;
  String? callerName;
  String? docId;
  String? messageToken;
  MeetingPage({super.key, required this.roomUrl, required this.roomId, required this.callerName, required this.docId, required this.messageToken});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener, HMSActionResultListener {
  late HMSSDK _hmsSDK;

  // String userName = "user2";
  // String authToken =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2NTQyMzIwNGNhNTg0OGYwZTNkNDcxMmUiLCJyb2xlIjoic3BlYWtlciIsInJvb21faWQiOiI2NTQyMzIyZTZjNGZjM2FhOTI1Y2I3YjAiLCJ1c2VyX2lkIjoiZTdlYzA4M2ItMDNhZS00NTBhLTkyNWYtYTRjZjA5OGYzZDVmIiwiZXhwIjoxNjk4OTI0NDY1LCJqdGkiOiJkYTY5MTE5My1iMzFiLTRkNmYtOTU2Mi05ZmYxYjE1NTI0NDgiLCJpYXQiOjE2OTg4MzgwNjUsImlzcyI6IjY1NDIzMjA0Y2E1ODQ4ZjBlM2Q0NzEyYyIsIm5iZiI6MTY5ODgzODA2NSwic3ViIjoiYXBpIn0.ihRY49HxJdOOIqafbw3pwsvPyZENJnrdpFNJm_ZGXF0";
  Offset position = const Offset(5, 5);
  bool isJoinSuccessful = false;
  final List<PeerTrackNode> _listeners = [];
  final List<PeerTrackNode> _speakers = [];
  bool _isMicrophoneMuted = false;
  bool _isLoading = false;
  HMSPeer? _localPeer;

  CollectionReference expertCollRef =
              FirebaseFirestore.instance.collection('experts').doc(FirebaseAuth.instance.currentUser?.uid).collection('call_history');

  bool is_userCount2 = false;

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       print("app in resumed");
  //       break;
  //     case AppLifecycleState.inactive:
  //       print("app in inactive");
  //       break;
  //     case AppLifecycleState.paused:
  //       // dispose();
  //       print("app in paused");
  //       break;
  //     case AppLifecycleState.detached:
  //       print("app in detached");
  //       break;
  //   }
  // }

  void updateCoins() async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(widget.docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        int currentCoins = userSnapshot['coins'] ?? 0;

        int newCoins = currentCoins - 1;
        if (newCoins >= 0) {
          transaction.update(userRef, {'coins': newCoins});
        } else {
          print('Insufficient coins!');
        }
      });
    } catch (error) {
      print('Error updating coins: $error');
    }
  }

  Future<bool> joinRoom() async {
    setState(() {
      _isLoading = true;
    });
    JoinService.join(widget.roomUrl, _hmsSDK, widget.roomId);
    await Future.delayed(const Duration(seconds: 2));
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('expert_rooms')
        .doc(widget.roomId)
        .get();

    if (documentSnapshot.exists) {
      var count = documentSnapshot['users'];
      print("Count $count");
      if(count == 2){
        setState(() {
          is_userCount2 = true;
        });
      }
    }
    _hmsSDK.addUpdateListener(listener: this);
    setState(() {
      _isLoading = false;
    });
    return true;
  }
  late StreamSubscription<DateTime> timerSubscription;
  Stream<DateTime> createTimerStream() {
    return Stream.periodic(const Duration(minutes: 1), (count) {
      return DateTime.now();
    });
  }
  @override
  void initState() {
    super.initState();
    getPermissions();
    initHMSSDK();
    Stream<DateTime> timer = createTimerStream();
    timerSubscription = timer.listen((currentTime) {
      updateCoins();
    });
    callStartTime = DateTime.now();
    timerStream = Stream.periodic(const Duration(seconds: 1), (int i) {
      final currentTime = DateTime.now();
      final callDuration = currentTime.difference(callStartTime);
      return currentTime;
    });
  }

//To know more about HMSSDK setup and initialization checkout the docs here: https://www.100ms.live/docs/flutter/v2/how--to-guides/install-the-sdk/hmssdk
  void initHMSSDK() async {
    _hmsSDK = HMSSDK();
    await _hmsSDK.build();
    joinRoom();
  }

  @override
  Future<void> dispose() async {
    //We are clearing the room state here
    _speakers.clear();
    _listeners.clear();
    timerSubscription.cancel();
    super.dispose();
  }

  //Here we will be getting updates about peer join, leave, role changed, name changed etc.
  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      _localPeer = peer;
    }
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.peerLeft:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers.removeAt(index);
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners.removeAt(index);
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.roleUpdated:
        if (peer.role.name == "speaker") {
          //This means previously the user must be a listener earlier in our case
          //So we remove the peer from listener and add it to speaker list
          int index = _listeners
              .indexWhere((node) => node.uid == "${peer.peerId}listener");
          if (index != -1) {
            _listeners.removeAt(index);
          }
          _speakers.add(PeerTrackNode(
            uid: "${peer.peerId}speaker",
            peer: peer,
          ));
          if (peer.isLocal) {
            _isMicrophoneMuted = peer.audioTrack?.isMute ?? true;
          }
          setState(() {});
        } else if (peer.role.name == "listener") {
          //This means previously the user must be a speaker earlier in our case
          //So we remove the peer from speaker and add it to listener list
          int index = _speakers
              .indexWhere((node) => node.uid == "${peer.peerId}speaker");
          if (index != -1) {
            _speakers.removeAt(index);
          }
          _listeners.add(PeerTrackNode(
            uid: "${peer.peerId}listener",
            peer: peer,
          ));
          setState(() {});
        }
        break;
      case HMSPeerUpdate.metadataChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.nameChanged:
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
        break;
      case HMSPeerUpdate.defaultUpdate:
      // TODO: Handle this case.
        break;
      case HMSPeerUpdate.networkQualityUpdated:
      // TODO: Handle this case.
        break;
      default:
        break;
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
        required HMSTrackUpdate trackUpdate,
        required HMSPeer peer}) {
    switch (peer.role.name) {
      case "speaker":
        int index =
        _speakers.indexWhere((node) => node.uid == "${peer.peerId}speaker");
        if (index != -1) {
          _speakers[index].audioTrack = track;
        } else {
          _speakers.add(PeerTrackNode(
              uid: "${peer.peerId}speaker", peer: peer, audioTrack: track));
        }
        if (peer.isLocal) {
          _isMicrophoneMuted = track.isMute;
        }
        setState(() {});
        break;
      case "listener":
        int index = _listeners
            .indexWhere((node) => node.uid == "${peer.peerId}listener");
        if (index != -1) {
          _listeners[index].audioTrack = track;
        } else {
          _listeners.add(PeerTrackNode(
              uid: "${peer.peerId}listener", peer: peer, audioTrack: track));
        }
        setState(() {});
        break;
      default:
      //Handle the case if you have other roles in the room
        break;
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    //Checkout the docs about handling onJoin here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/join#join-a-room
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        _localPeer = peer;
        switch (peer.role.name) {
          case "speaker":
            int index = _speakers
                .indexWhere((node) => node.uid == "${peer.peerId}speaker");
            if (index != -1) {
              _speakers[index].peer = peer;
            } else {
              _speakers.add(PeerTrackNode(
                uid: "${peer.peerId}speaker",
                peer: peer,
              ));
            }
            setState(() {});
            break;
          case "listener":
            int index = _listeners
                .indexWhere((node) => node.uid == "${peer.peerId}listener");
            if (index != -1) {
              _listeners[index].peer = peer;
            } else {
              _listeners.add(
                  PeerTrackNode(uid: "${peer.peerId}listener", peer: peer));
            }
            setState(() {});
            break;
          default:
          //Handle the case if you have other roles in the room
            break;
        }
      }
    });
  }
  bool speaker = false;
  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
        List<HMSAudioDevice>? availableAudioDevice}) {
    _hmsSDK.switchAudioOutput(audioDevice: speaker ? HMSAudioDevice.SPEAKER_PHONE : HMSAudioDevice.EARPIECE);
    // currentAudioDevice : audio device to which audio is curently being routed to
    // availableAudioDevice : all other available audio devices
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // Checkout the docs for handling the unmute request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/track/remote-mute-unmute
  }

  @override
  void onHMSError({required HMSException error}) {
    // To know more about handling errors please checkout the docs here: https://www.100ms.live/docs/flutter/v2/how--to-guides/debugging/error-handling
  }

  @override
  void onMessage({required HMSMessage message}) {
    // Checkout the docs for chat messaging here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/chat
  }

  @override
  void onReconnected() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onReconnecting() {
    // Checkout the docs for reconnection handling here: https://www.100ms.live/docs/flutter/v2/how--to-guides/handle-interruptions/reconnection-handling
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // Checkout the docs for handling the peer removal here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/remove-peer
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // Checkout the docs for handling the role change request here: https://www.100ms.live/docs/flutter/v2/how--to-guides/interact-with-room/peer/change-role#accept-role-change-request
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // Checkout the docs for room updates here: https://www.100ms.live/docs/flutter/v2/how--to-guides/listen-to-room-updates/update-listeners
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // Checkout the docs for handling the updates regarding who is currently speaking here: https://www.100ms.live/docs/flutter/v2/how--to-guides/set-up-video-conferencing/render-video/show-audio-level
  }

  /// ******************************************************************************************************************************************************
  /// Action result listener methods

  @override
  void onException(
      {required HMSActionResultListenerMethod methodType,
        Map<String, dynamic>? arguments,
        required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        log("Not able to leave error occured");
        break;
      default:
        break;
    }
  }

  @override
  void onSuccess(
      {required HMSActionResultListenerMethod methodType,
        Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        _hmsSDK.removeUpdateListener(listener: this);
        _hmsSDK.destroy();
        break;
      default:
        break;
    }
  }

  /// ******************************************************************************************************************************************************
  /// Functions

  final List<Color> _colors = [
    Colors.amber,
    Colors.blue.shade600,
    Colors.purple,
    Colors.lightGreen,
    Colors.redAccent
  ];

  final RegExp _REGEX_EMOJI = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  String _getAvatarTitle(String name) {
    if (name.contains(_REGEX_EMOJI)) {
      name = name.replaceAll(_REGEX_EMOJI, '');
      if (name.trim().isEmpty) {
        return '😄';
      }
    }
    List<String>? parts = name.trim().split(" ");
    if (parts.length == 1) {
      name = parts[0][0];
    } else if (parts.length >= 2) {
      name = parts[0][0];
      if (parts[1] == "" || parts[1] == " ") {
        name += parts[0][1];
      } else {
        name += parts[1][0];
      }
    }
    return name.toUpperCase();
  }

  Color _getBackgroundColour(String name) {
    if (name.isEmpty) return Colors.blue.shade600;
    if (name.contains(_REGEX_EMOJI)) {
      name = name.replaceAll(_REGEX_EMOJI, '');
      if (name.trim().isEmpty) {
        return Colors.blue.shade600;
      }
    }
    return _colors[name.toUpperCase().codeUnitAt(0) % _colors.length];
  }
  Future<bool> leaveRoom() async {
    _hmsSDK.leave(hmsActionResultListener: this);
    final currentTime = DateTime.now();
    final callDuration = currentTime.difference(callStartTime);
    int durationInMinutes = callDuration.inMinutes;
    print(durationInMinutes);
    CollectionReference userCollRef =
              FirebaseFirestore.instance.collection('users').doc(widget.docId).collection('expert_history');
    if(is_userCount2) {
      await userCollRef.add({
        'expert_name': FirebaseAuth.instance.currentUser?.displayName,
        'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
        'duration': durationInMinutes
      });
    }
    if(is_userCount2) {
      await expertCollRef.add({
        'caller_name': widget.callerName,
        'duration': durationInMinutes
      });
    }
    await FireBaseServices.leaveRoom(widget.roomId);
    Navigator.pop(context);
    if(is_userCount2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CallDetails(docId: widget.docId, duration: durationInMinutes,),
        ),
      );
    }
    return false;
  }

  late Stream<DateTime> timerStream;
  late DateTime callStartTime;

  @override
  Widget build(BuildContext context) {
    var expertDocId = FirebaseAuth.instance.currentUser?.uid;
    return  StreamBuilder(
        stream: FirebaseFirestore.instance.collection('expert_rooms').doc(widget.roomId).snapshots(),
        builder: (context, snapshot) {
          try{
            if(snapshot.hasData){
              return WillPopScope(
                  onWillPop: () async {
                    return leaveRoom();
                  },
                  child : Scaffold(
                      body: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : snapshot.data?['users'] < 2
                          ? noPeerScreen()
                          : callUiExpert()
                  ));
            }
            else{
              return const CircularProgressIndicator(color: Colors.black,);
            }
          }
          catch (error) {
            print("Catch error: $error");
            return const Text("");
          }
        }
    );
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
        required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }

  Widget noPeerScreen()
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("You're the only one here", style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w800
            )),
            SizedBox(height: 15),
            Text("Please wait for the Peers to join", style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),),
          ],
        ),
      ),
    );
  }

  Widget callUiExpert()
  {
    var expertDocId = FirebaseAuth.instance.currentUser?.uid;
    return Column(
      children: [
        Expanded(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        'images/ic_user.png',
                        fit: BoxFit.cover,
                      )),
                  StreamBuilder<DateTime>(
                    stream: timerStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final currentTime = snapshot.data;
                        final callDuration =
                        currentTime?.difference(callStartTime);
                        final formattedDuration =
                        DurationFormatter.format(callDuration!);
                        return Text(
                          formattedDuration,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        );
                      } else {
                        return const Text(
                          '00:00',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text("In a call",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20.0),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: const Color(0xFF607D8B)
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('experts').doc(expertDocId).collection('quiz').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: Text("Fetching..."));
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(child: Text('No quiz questions available.'));
                            }

                            return ListView(
                              children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: ListTile(
                                    title: Expanded(
                                      child: Text(
                                        doc['question'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        await JoinService.sendQuiz(widget.messageToken!, doc);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Quiz sent successfully'),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                        FirebaseFirestore.instance.collection('expert_rooms').doc(widget.roomId).update({
                                          'quizAvailable': true,
                                        });
                                      },
                                      child: const Text('Send'),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        )
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: ()
                          {
                            // JoinService.sendQuiz(widget.messageToken!);
                            // FirebaseFirestore.instance.collection('expert_rooms').doc(widget.roomId).update({
                            //   'quizAvailable': true
                            // });
                            setState(() {
                              speaker = !speaker;
                            });
                            onAudioDeviceChanged();
                          },
                          child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(speaker ? Icons.volume_up : Icons.volume_down, color: Colors.white, size: 45)
                          )
                      ),
                      InkWell(
                        onTap: () {
                          onAudioDeviceChanged();
                          setState(() {
                            _isMicrophoneMuted = !_isMicrophoneMuted;
                          });
                        },
                        child: Icon(
                          _isMicrophoneMuted
                              ? Icons.mic_off
                              : Icons.mic,
                          color: _isMicrophoneMuted
                              ? Colors.white
                              : Colors.white,
                          size: 45,
                        ),
                      ),
                      InkWell(
                        onTap: ()
                        {
                          _hmsSDK.leave(hmsActionResultListener: this);
                          leaveRoom();
                          final currentTime = DateTime.now();
                          final callDuration = currentTime.difference(callStartTime);
                          int durationInMinutes = callDuration.inMinutes;
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CallDetails(docId: widget.docId, duration: durationInMinutes,),
                            ),
                          );

                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFFE91D42),
                          child: Icon(Icons.call_end, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35.0),
                ],
              )),
        ),
      ],
    );
  }
}

class PeerTrackNode {
  String uid;
  HMSPeer peer;
  bool isRaiseHand;
  HMSTrack? audioTrack;

  PeerTrackNode(
      {required this.uid,
        required this.peer,
        this.audioTrack,
        this.isRaiseHand = false});

  @override
  String toString() {
    return 'PeerTrackNode{uid: $uid, peerId: ${peer.peerId},track: $audioTrack}';
  }
}