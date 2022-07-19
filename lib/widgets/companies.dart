import 'package:flutter/material.dart';
import 'package:internship_app/search/company_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class Workers extends StatefulWidget {

  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageUrl;

  const Workers({Key? key,
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.phoneNumber,
    required this.userImageUrl,
  });



  @override
  State<Workers> createState() => _WorkersState();
}

class _WorkersState extends State<Workers> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.yellow,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScrean(
              userID: widget.userID,
          )));
        },

        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading:Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(border: Border(
            right: BorderSide(width: 1),
          )),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.userImageUrl == null
            ?'https://w7.pngwing.com/pngs/831/88/png-transparent-user-profile-computer-icons-user-interface-mystique-miscellaneous-user-interface-design-smile-thumbnail.png'
            : widget.userImageUrl,
            ),
          ),
        ) ,
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Visit Profile',
               maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.mail,
            size: 30,
            color: Colors.amber,
          ),
          onPressed: _mailto,
        ),

      ),
    );
  }
  
  void _mailto() async{
    var mailUrl = 'mainto : ${widget.userEmail}';
    print('widget.userEmail ${widget.userEmail}');
    if(await canLaunch(mailUrl)){
     await launch(mailUrl);
    } else{
      print('There Are An Error');
      throw ' Error occured';
    }
  }
}
