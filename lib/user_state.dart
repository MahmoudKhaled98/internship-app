import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internship_app/jobs/jobs_screan.dart';
import 'package:internship_app/jobs/upload_job.dart';

import 'auth/login.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot){
          if(userSnapshot.data == null){
            print('User is not logged in yet');
            return Login();
    }
          else if(userSnapshot.hasData){
            print('user is already logged in');
            return JobScrean();
          }

          else if(userSnapshot.hasError){
            return Scaffold(
              body: Center(
                child: Text('Try again later'),
              ),
            );
          }
          else if(userSnapshot.connectionState == ConnectionState.waiting){
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: Text('Something went wrong'),
            ),
          );
    }
    );
  }
}
