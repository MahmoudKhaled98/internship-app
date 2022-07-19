import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internship_app/persistent/persistent.dart';
import 'package:internship_app/services/global_variables.dart';
import 'package:internship_app/widgets/bottomNavBar.dart';
import 'package:internship_app/widgets/job_widget.dart';

import '../search/search_job.dart';

class JobScrean extends StatefulWidget {



  @override
  State<JobScrean> createState() => _JobScreanState();
}

class _JobScreanState extends State<JobScrean> {

  String? jobCategoryFilter;


  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection('users');
  void getData() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot= await docUser.get();
Map<String,dynamic> json=snapshot.data()!;
    setState((){
      name= json['name'];
      userImage = json['userImage'];
      location = json['location'];
    });
  }


  @override
  void initState(){
    getData();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
   bool isDescending=false;
   String type="all";
    return Scaffold(
      bottomNavigationBar: BottomNavForApp(indexNum: 0,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // leading:
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     PopupMenuButton(
        //       itemBuilder: (context)=>[
        //         PopupMenuItem(
        //
        //           child:
        //             Text("Developer",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Developer';});
        //           },
        //             ),
        //         PopupMenuItem(
        //           child:
        //           Text("Programing",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Programing';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Information Technology",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Information Technology';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Software Engineering",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Software Engineering';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Software Developer",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Software Developer';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("BlockChain",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type="BlockChain";});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Cyber Security",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Cyber Security';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Data Science",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Data Science';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Computer Science",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Computer Science';});
        //           },
        //         ),
        //         PopupMenuItem(
        //           child:
        //           Text("Ui Designer",style:TextStyle(color:Colors.orange,fontWeight: FontWeight.bold)),
        //           onTap: (){
        //             setState((){type='Ui Designer';});
        //           },
        //         ),
        //
        //       ],
        //
        //       icon: Icon(Icons.filter_list_outlined,
        //       color: Colors.orange,
        //       ),
        //
        //
        //     ),
        //
        //   ],
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined, color: Colors.orange,),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SearchScreen()));
            },
          ),
        ],
      ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('jobCategory', isEqualTo: jobCategoryFilter)
              .where('recruitment', isEqualTo: true)
              .orderBy('createAt', descending: isDescending)
              .snapshots(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.data?.docs.isNotEmpty == true){

                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return JobWidget(
                          jobTitle: snapshot.data?.docs[index]['jobTitle'],
                          jobDescription: snapshot.data!.docs[index]['jobDescription'],
                          jobId: snapshot.data?.docs[index]['jobId'],
                          uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                          userImage: snapshot.data?.docs[index]['userImage'],
                          name: snapshot.data?.docs[index]['name'],
                          recruitment: snapshot.data?.docs[index]['recruitment'],
                          email: snapshot.data?.docs[index]['email'],
                          location: snapshot.data?.docs[index]['location'],

                      );
                    }
                );
              }else{
                return Center(
                  child: Text('There is no jobs',
                  ),
                );
              }
            }
            return Center(
              child: Text('Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              ),
            );
          },
        ),
    );

  }
   _showTaskCategoriesDialog({required Size size}){

    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white,),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
                itemBuilder: (ctxx, index){
                  return InkWell(
                    onTap: (){
                      setState((){
                        jobCategoryFilter = Persistent.jobCategoryList[index];
                      });
                      Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                      print(
                          'jobCategoryList[index], ${Persistent.jobCategoryList[index]}'
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right_outlined,
                          color: Colors.orange,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
              },
                child: Text(
                  'Close',
                    style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              TextButton(onPressed: (){
                setState((){
                  jobCategoryFilter = null;
                });
                Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
              },
                child: Text(
                  'Cancel Filter',
                    style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }

    );
  }
}



















