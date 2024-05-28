import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FireBaseServices {
  static final _db = FirebaseFirestore.instance;

  static leaveRoom(String docId) async {
    int userCount = 0;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('expert_rooms').doc(docId).get();
    userCount = documentSnapshot['users'];
    if(userCount == 2) {
      await _db
          .collection('expert_rooms')
          .doc(docId)
          .update({'users': FieldValue.increment(-1)});
    }
    else if(userCount == 1) {
      String token = generateToken();
      String apiUrl = 'https://api.100ms.live/v2/rooms/$docId';
      Map<String, dynamic> requestBody = {
        "enabled": false,
      };
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> roomInfo = json.decode(response.body);
        } else {
          print('Failed to get room info. Status code: ${response.statusCode}');
        }
      }catch (error) {
        print('Error: $error');
      }
      await _db.collection('expert_rooms').doc(docId).delete();
    }
  }

  static String generateToken() {
    String appAccessKey = "654688e0ca5848f0e3d471c0";
    String appSecret = "GZzkUzQxb44L6zmoxQnLc06dJKBMDtxqwm_XHj30-nVejehzvfpIIT6ZpK-gCiBjTgISWnf2LnEh25MKuPiAXJmDiqdZLiTVxpKBWR1TVIR3ejmeXbNVvxuZhAReme1On2-pU55MZJ_TMlCnvvLOouL_4-N6NpFfs9QlNFUBOKs=";

    var issuedAt = DateTime.now();
    var expire = issuedAt.add(const Duration(hours: 24));

    final jwt = JWT(
        {
          'access_key': appAccessKey,
          'type': 'management',
          'version': 2,
          'jti': const Uuid().v4(),
          'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
          'nbf': issuedAt.millisecondsSinceEpoch ~/ 1000,
          'exp': expire.millisecondsSinceEpoch ~/ 1000,
        }
    );

    final token = jwt.sign(SecretKey(appSecret), expiresIn: const Duration(hours: 24), algorithm: JWTAlgorithm.HS256);
    return token;
  }
}