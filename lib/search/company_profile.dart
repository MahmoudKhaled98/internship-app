import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:internship_app/user_state.dart';
import 'package:internship_app/widgets/bottomNavBar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScrean extends StatefulWidget {

  final String userID;

  const ProfileScrean({Key? key, required this.userID}) : super(key: key);


  @override
  State<ProfileScrean> createState() => _ProfileScreanState();
}

class _ProfileScreanState extends State<ProfileScrean> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String phoneNumber = "";
  String email = "";
  String? name;
  String imageUrl = "";
  String joinedAt = "";
  bool _isSameUser = false;


  void getUserData() async{
    try{
      _isLoading = true;
      final docUser = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      final snapshot= await docUser.get();
      Map<String,dynamic> json=snapshot.data()!;
      if(snapshot == null){
        return;
      }else{
        setState((){
          email = json['email'];
          name = json['name'];
          phoneNumber = json['phoneNumber'];
          imageUrl = json['userImage'];
          Timestamp joinedAtTimeStamp =json['createAt'];
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState((){
          _isSameUser = _uid == widget.userID;
        });
      }
    }catch(error){} finally{
      _isLoading = false;
    }
  }

  void initState(){
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavForApp(indexNum: 3),
      body: Center(
        child: _isLoading ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: Stack(
              children: [
                Card(
                  color: Colors.white10,
                  margin: EdgeInsets.all(30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 100,),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            name == null ? 'Name here' : name!,
                            style: TextStyle(color: Colors.white,fontSize: 22.0)
                          ),
                        ),
                        SizedBox(height: 15,),
                        Divider(
                          thickness: 1,
                          color: Colors.white,
                        ),
                        SizedBox(height: 30,),
                        Padding(padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Account Information :',
                            style: TextStyle(color: Colors.grey,fontSize: 22.0)
                        ),
                        ),
                        SizedBox(height: 30,),
                        Padding(padding: EdgeInsets.only(left: 10.0),
                          child: userInfo(
                              icon: Icons.email,
                              content: email),
                        ),
                        Padding(padding: EdgeInsets.only(left: 10.0),
                        child: userInfo(
                            icon: Icons.phone_iphone,
                            content: phoneNumber),
                        ),
                        SizedBox(height: 35,),
                        Divider(
                          thickness: 1,
                          color: Colors.white,
                        ),
                        _isSameUser
                            ? Container()
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _contactBy(
                                color: Colors.green,
                                fct: (){
                                  _openWhatsAppChat();
                                },
                                icon: FontAwesome.whatsapp,
                            ),
                            _contactBy(
                                color: Colors.red,
                                fct: (){
                                  _mailTo();
                                },
                                icon: Icons.mail_outline),
                            _contactBy(
                                color: Colors.purple,
                                fct: (){
                                  _mailTo();
                                },
                                icon: Icons.call_outlined),
                          ],
                        ),
                        SizedBox(height: 25,),
                        Divider(
                          thickness: 1,
                          color: Colors.white,
                        ),
                        SizedBox(height: 25,),
                        !_isSameUser
                        ? Container()
                            : Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 30),
                            child: MaterialButton(
                              onPressed: (){
                                _auth.signOut();
                                Navigator.push(
                                  context, MaterialPageRoute(
                                    builder: (context) => UserState(),
                                ),
                                );
                              },
                              color: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 25,),
                                    Icon(Icons.logout,
                                    color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.26,
                      height: MediaQuery.of(context).size.width * 0.26,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 8,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            imageUrl == null
                                ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
                                : imageUrl
                          ),
                          fit: BoxFit.fill
                        )
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }

  void _openWhatsAppChat() async{
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launch(url);
  }

  void _mailTo() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Write subject here, Please&body=Hello, Please write details here',
    );
    final url = params.toString();
    launch(url);
  }

  void _callPhoneNumber() async{
    var url = 'tel://$phoneNumber';
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw'Error occured';
    }
  }

  Widget _contactBy({required Color color, required Function fct, required IconData icon}){
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon,
          color: color,),
          onPressed: (){
            fct();
          },
        ),
      ),
    );
  }

  Widget userInfo({required IconData icon, required String content}){
    return Row(
      children: [
        Icon(icon,
        color: Colors.white,
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey),
            ),
        )
      ],
    );
  }
}





















