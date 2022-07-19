import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internship_app/jobs/jobs_screan.dart';
import 'package:internship_app/services/global_methods.dart';
import 'package:internship_app/services/global_variables.dart';
import 'package:internship_app/widgets/comments.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';


class JobDetailsScreen extends StatefulWidget {

  final String uploadBy;
  final String jobId;

  const JobDetailsScreen({
    required this.jobId,
    required this.uploadBy,
});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {

  TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimestamp;
  Timestamp? deadlineDateTimestamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = "";
  String? emailCompany = "";
  int applicants = 0;
  bool isDeadlineAvailable = true;
  bool showComments = false;



  applyForjob(){
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject=Applying for $jobTitle&body=Hello, please attach your CV file'
    );
    final url = params.toString();
    launch(url);
    addNewApplicant();
  }

  void addNewApplicant() async{
    var docRef = FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);
    
    docRef.update({
      "applicants": applicants + 1,
    });
    Navigator.pop(context);
  }

// with this function i can get all data from the database
  void getJobData() async{

    final docUser = FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);
    final snapshot= await docUser.get();
    Map<String,dynamic> json=snapshot.data()!;
    if(snapshot == null){
      return;
    }else{
      setState((){
        authorName = json['name'];
        userImageUrl = json['userImage'];

      });
    }


    if(snapshot == null){
      return;
    }else{


      setState((){
        name= json['name'];
        userImage = json['userImage'];
        location = json['location'];
        jobTitle = json['jobTitle'];
        jobDescription = json['jobDescription'];
        recruitment = json['recruitment'];
        emailCompany = json['email'];
        locationCompany = json['location'];
        applicants = json['applicants'];
        postedDateTimestamp = json['createAt'];
        deadlineDateTimestamp = json['deadlineDateTimeStamp'];
        deadlineDate = json['deadlineDate'];
        var postDate = postedDateTimestamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });

      var date = deadlineDateTimestamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState(){
    getJobData();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close,size: 40,color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobScrean()));
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(4.0),
            child: Card(
              color: Colors.white38,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 4),
                    child: Text(
                      jobTitle == null ? '' : jobTitle!,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 8,
                              color: Colors.white,
                            ),
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: NetworkImage(
                                userImageUrl == null
                                ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
                                    : userImageUrl!,
                              ),
                              fit: BoxFit.fill
                            )
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName == null ? '' : authorName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              locationCompany!,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        ),
                      ],
                    ),
                    dividerWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          applicants.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 6,),
                        Text(
                          'Applicants',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Icon(Icons.how_to_reg_sharp,
                        color: Colors.white,
                        ),
                      ],
                    ),
                    FirebaseAuth.instance.currentUser!.uid != widget.uploadBy ? Container() :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dividerWidget(),
                            Text(
                              'Recruitment:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadBy){
                                      try{
                                        FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(widget.jobId)
                                            .update({'recruitment': true});
                                      }catch(err){
                                        GlobalMethod.showErrorDialog(
                                            error: 'Action cant be performed',
                                            ctx: context
                                        );
                                      }
                                    }else{
                                      GlobalMethod.showErrorDialog(
                                          error: 'You can perform this action',
                                          ctx: context
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: Text(
                                    'ON',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                    ),
                                  ),

                                ),
                                Opacity(
                                    opacity: recruitment == true? 1 : 0,
                                  child: Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 40,),
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadBy){
                                      try{
                                        FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(widget.jobId)
                                            .update({'recruitment': false});
                                      }catch(err){
                                        GlobalMethod.showErrorDialog(
                                            error: 'Action cant be performed',
                                            ctx: context
                                        );
                                      }
                                    }else{
                                      GlobalMethod.showErrorDialog(
                                          error: 'You can perform this action',
                                          ctx: context
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),

                                ),
                                Opacity(
                                  opacity: recruitment == false ? 1 : 0,
                                  child: Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                    dividerWidget(),
                    Text(
                      'Job Description:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 40,),
                    Text(
                      jobDescription == null ? '' : jobDescription!,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    dividerWidget(),
                  ],
                ),
              ),
            ),
            ),
            Padding(padding: EdgeInsets.all(4.0),
            child: Card(
              color: Colors.white38,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Center(
                      child: Text(
                        isDeadlineAvailable ? 'Actively Recruiting, Send CV:'
                            : 'Deadline Passed away',
                        style: TextStyle(
                          color: isDeadlineAvailable ? Colors.green
                              :Colors.red,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6,),
                    Center(
                      child: MaterialButton(
                        onPressed: (){
                          applyForjob();
                        },
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Apply Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    dividerWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Uploaded on:',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          postedDate== null ? '' :postedDate!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deadline date:',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          deadlineDate == null ? '' :
                          deadlineDate!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    dividerWidget(),

                  ],
                ),
              ),
            ),
            ),
            Padding(padding: EdgeInsets.all(4.0),
            child: Card(
              color: Colors.white38,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 500,
                        ),
                      child:  _isCommenting
                          ?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                  flex: 3,
                                  child: TextField(
                                    controller: _commentController,
                                    style: TextStyle(color: Colors.white,),
                                    maxLength: 200,
                                    keyboardType: TextInputType.text,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.pink),
                                      ),
                                    ),
                                  ),
                              ),
                              Flexible(
                                  child: Column(
                                    children: [
                                      Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: MaterialButton(
                                        onPressed: () async{
                                          if(_commentController.text.length < 7){
                                            GlobalMethod.showErrorDialog(
                                                error: 'Comment cant be less than 7 characters',
                                                ctx: context);
                                          }else{
                                            final _generatedId = Uuid().v4();
                                            await FirebaseFirestore.instance
                                            .collection('jobs')
                                            .doc(widget.jobId)
                                            .update({
                                              'jobComments':
                                                  FieldValue.arrayUnion([
                                                    {
                                                      'userId': FirebaseAuth.instance.currentUser!.uid,
                                                      'commentId': _generatedId,
                                                      'name':name,
                                                      'userImageUrl': userImage,
                                                      'commentBody': _commentController.text,
                                                      'time': Timestamp.now(),
                                                    }
                                                  ])
                                            });
                                            await Fluttertoast.showToast(
                                                msg: "Your comment has been added",
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor: Colors.grey,
                                                fontSize: 18.0,
                                            );
                                            _commentController.clear();
                                          }
                                          setState((){
                                            showComments = true;
                                          });
                                        },
                                        color: Colors.blueAccent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Text(
                                          'Post',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),

                                        ),
                                      ),
                                      ),
                                      TextButton(
                                          onPressed: (){
                                            setState((){
                                              _isCommenting = !_isCommenting;
                                              showComments = false;
                                            });
                                          },
                                          child: Text('Cancel'),
                                      ),
                                    ],
                                  ),
                              )
                            ],
                          )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: (){
                                setState((){
                                  _isCommenting = !_isCommenting;
                                });
                              },
                              icon: Icon(Icons.add_comment,
                                  color: Colors.blueAccent,
                                size: 40,
                              ),
                          ),
                          SizedBox(width: 10,),
                          IconButton(
                            onPressed: (){
                              setState((){
                                showComments = true;
                              });
                            },
                            icon: Icon(Icons.arrow_drop_down_circle,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    showComments == false ? Container() :
                        Padding(padding: EdgeInsets.all(16.0),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('jobs')
                              .doc(widget.jobId)
                              .get(),
                          builder: (context, snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator());
                            }else{
                              if(snapshot.data == null){
                                Center(child: Text('No Comment for this job'));
                              }
                            }
                            return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index){
                                  return Comments(
                                      commentId: snapshot.data!['jobComments'] [index]['commentId'],
                                      commenterId: snapshot.data!['jobComments'] [index]['userId'],
                                      commenterName: snapshot.data!['jobComments'] [index]['name'],
                                      commentBody: snapshot.data!['jobComments'] [index]['commentBody'],
                                      commenterImageUrl: snapshot.data!['jobComments'] [index]['userImageUrl'],
                                      );
                                },
                                separatorBuilder: (context, index){
                                  return Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  );
                                },
                                itemCount: snapshot.data!['jobComments'].length
                            );
                          },
                        )
                        ),
                  ],
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  Widget dividerWidget(){
    return Column(
      children: [
          SizedBox(height: 10,),
        Divider(
          thickness: 1,
          color: Colors.white,
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}



















