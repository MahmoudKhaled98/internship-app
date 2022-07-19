import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:internship_app/jobs/jobs_screan.dart';
import 'package:internship_app/jobs/upload_job.dart';
import 'package:internship_app/search/company_profile.dart';
import 'package:internship_app/search/search_companis.dart';
import 'package:internship_app/user_state.dart';

class BottomNavForApp extends StatelessWidget {

  int indexNum = 0;
   BottomNavForApp({required this.indexNum});

   void _logout(context){
     final FirebaseAuth _auth = FirebaseAuth.instance;

     showDialog(
         context: context,
         builder: (context){
           return AlertDialog(
             backgroundColor: Colors.black,
             title: Row(
               children: [
                 Padding(padding: EdgeInsets.all(8.0),
                 child: Icon(
                   Icons.logout,
                   color: Colors.red,
                   size: 36,
                 ),
                 ),
                 // Padding(padding: EdgeInsets.all(8.0),
                 //   child: Icon(
                 //     Icons.logout,
                 //     color: Colors.red,
                 //     size: 36,
                 //   ),
                 // ),
               ],
             ),
             content: Text(
               'Are you Sure for logout from the app?',
                   style:
                   TextStyle(
                     color: Colors.deepOrange,
                     fontSize: 20,
             ),
             ),
             actions: [
               TextButton(
                 onPressed: (){
                   Navigator.canPop(context) ? Navigator.pop(context) : null;
                 },

               child: Text('No',
                 style: TextStyle(
                   color: Colors.green,
                   fontSize: 18,
                 ),

               ),
               ),

               TextButton(
                   onPressed: (){
                     _auth.signOut();
                     Navigator.canPop(context) ? Navigator.pop(context): null;
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context) => UserState()));
                   },
                   child: Text('Yes',
                     style: TextStyle(
                       color: Colors.red,
                       fontSize: 18,
                     ),

                   ),)


             ],
           );
         }

         );
   }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.white,
      backgroundColor: Colors.orange,
      buttonBackgroundColor: Colors.white,
      height: 52,
      index: indexNum,
      items: <Widget>[
        Icon(Icons.list, size: 18, color: Colors.orange,),
        Icon(Icons.search, size: 18, color: Colors.orange,),
        Icon(Icons.add, size: 18, color: Colors.orange,),
        Icon(Icons.person_pin, size: 18, color: Colors.orange,),
        Icon(Icons.exit_to_app, size: 18, color: Colors.orange,),
      ],
      animationDuration: Duration(
        milliseconds: 300,
      ),
      animationCurve: Curves.bounceInOut,
      onTap: (index){
        if(index == 0){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context) => JobScrean()));
        }
        else if(index == 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context) => AllWorkersScreen()));

        }
        else if (index == 2){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context) => UploadJob()));
        }
        else if (index == 3){
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context) => ProfileScrean(
              userID: uid,
          )));

        }
        else if(index == 4){

          _logout(context);

        }
      },
    );
  }
}
