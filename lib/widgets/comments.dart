import 'package:flutter/material.dart';
import 'package:internship_app/search/company_profile.dart';


class Comments extends StatefulWidget {

  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commentBody;
  final String commenterImageUrl;


  const Comments ({
    required this.commentBody,
    required this.commenterId,
    required this.commenterImageUrl,
    required this.commenterName,
    required this.commentId,
});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {

  List<Color> _colors = [
    Colors.yellowAccent,
    Colors.tealAccent,
    Colors.pink,
    Colors.lightGreenAccent,
    Colors.purpleAccent,
    Colors.deepOrangeAccent,
    Colors.green,

  ];

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScrean(userID: widget.commenterId)));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: _colors[1],
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(widget.commenterImageUrl),
                fit: BoxFit.fill
              )
            ),
          ),
          ),
          SizedBox(
            width: 6,
          ),
          Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.commenterName,
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 16,
                  ),
                  ),
                  Text(widget.commentBody,
                    maxLines: 5,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              )

          ),
        ],
      ),
    );
  }
}
