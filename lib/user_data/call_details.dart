import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallDetails extends StatefulWidget {
  String? docId;
  int duration;
  CallDetails({Key? key, required this.docId, required this.duration}) : super(key: key);

  @override
  State<CallDetails> createState() => _CallDetailsState();
}

class _CallDetailsState extends State<CallDetails> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    callTimeController = TextEditingController();
    latestTopicController = TextEditingController();
    todayTopicController = TextEditingController();
    dayCountController = TextEditingController();
    remarkController = TextEditingController();
    studentDetails();
  }

  int val = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController callTimeController = TextEditingController();
  TextEditingController dayCountController = TextEditingController();
  TextEditingController latestTopicController = TextEditingController();
  TextEditingController todayTopicController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  List<Color> boxColors = List.generate(11, (index) => Colors.transparent);
  List<String> boxContent = [
    "Travelling", "Favorite type of music", "Favourite hobbies",
    "Pet", "Favorite book", "Traveled to another country",
    "dream job", "your favorite places", "favorite foods",
    "favorite childhood memories", "Cooking"
  ];


  Future<void> studentDetails() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .get();
    setState(() {
      nameController.text = documentSnapshot['Name'];
      latestTopicController.text = documentSnapshot['lastTopic'];
      callTimeController.text = widget.duration.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4AA8EE),
                    Color(0xFF04F0D6)
                  ]
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: Row(
                      children: [
                        const Text("Add Today's Call details", style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16
                        )),
                        const Spacer(),
                        InkWell(
                          onTap: ()
                          {
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                              backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.31),
                              radius: 15,
                              child: const Center(child: Icon(Icons.close, color: Color(0xFFFFFFFF), size: 18))),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              )
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Student Name", style: TextStyle(
                color: Color(0xFF000000).withOpacity(0.42),
                fontWeight: FontWeight.w600,
                fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: nameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Call Time", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.42),
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: callTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Day Count According to call with expert", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.42),
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: dayCountController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Latest Topics Discussion", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.42),
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: latestTopicController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Today Topic", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.42),
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  readOnly: true,
                  controller: todayTopicController,
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                        onTap: ()
                        {
                          showTopics();
                        },
                        child: const Icon(Icons.arrow_drop_down)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Remarks", style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(0.42),
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: remarkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF000000).withOpacity(0.42)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF000000).withOpacity(0.42)), // Change the color here
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2664F5), // Set the desired background color
                    ),
                    onPressed: ()
                    {
                      FirebaseFirestore.instance.collection('users').doc(widget.docId).update({
                        'lastTopic': todayTopicController.text
                      });
                      Navigator.pop(context);
                      debugPrint("Hello World");
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text("Save"),
                    )),
              ),
            )
          ],
        ),
      )
    );
  }
  void showTopics()
  {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Topics',
                      style: TextStyle(
                        color: const Color(0xFF000000).withOpacity(0.72),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: ()
                        {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 5,
                  children: [
                    boxWidget("Travelling", 0),
                    boxWidget("Favorite type of music", 1),
                    boxWidget("Favourite hobbies", 2),
                    boxWidget("Pet", 3),
                    boxWidget("Favorite book", 4),
                    boxWidget("Traveled to another country", 5),
                    boxWidget("dream job", 6),
                    boxWidget("your favorite places", 7),
                    boxWidget("favorite foods", 8),
                    boxWidget("favorite childhood memories", 9),
                    boxWidget("Cooking", 10)
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

  }
  Color boxColor = Colors.transparent;

  Widget boxWidget(String data, int index)
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: ()
        {
          setState(() {
            for(int i = 0; i < 11; i++)
            {
              if(boxColors[i] == const Color(0xFF2664F5))
              {
                boxColors[i] = Colors.transparent;
              }
            }
            boxColors[index] = const Color(0xFF2664F5);
            setState(() {
              todayTopicController.text = boxContent[index];
            });

            Navigator.pop(context);
            showTopics();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: boxColors[index],
           border: Border.all(
             width: 1,
             color: boxColors[index] == const Color(0xFF2664F5) ? const Color(0xFF2664F5) : const Color(0xFF000000).withOpacity(0.42)
           ),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(data, style: TextStyle(
              color: boxColors[index] == const Color(0xFF2664F5) ? Colors.white : const Color(0xFF000000).withOpacity(0.72),
              fontSize: 16,
              fontWeight: FontWeight.w400
            )),
          )
        ),
      ),
    );
  }
}
