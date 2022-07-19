import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:internship_app/services/global_methods.dart';
import 'package:internship_app/services/global_variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _fullNameController = TextEditingController(text: '');
  late TextEditingController _emailTextController = TextEditingController(text: '');
  late TextEditingController _passTextController = TextEditingController(text: '');
  late TextEditingController  _locationController= TextEditingController(text: '');
  late TextEditingController _phoneNumberController = TextEditingController(text: '');


  FocusNode _emailFocasNode = FocusNode();
  FocusNode _passFocasNode = FocusNode();
  FocusNode _postitionCPFocusNode = FocusNode();
  FocusNode _phoneNumberFocusNode = FocusNode();
  bool _obscureText = true;
 final _signUpFormKey = GlobalKey<FormState>();
 File? imageFile;
 final FirebaseAuth _auth = FirebaseAuth.instance;
 bool _isLoading = false;
 String? imageUrl;


 @override
 void dispose(){
   _animationController.dispose();
   _fullNameController.dispose();
   _emailTextController.dispose();
   _passTextController.dispose();
   _emailFocasNode.dispose();
   _passFocasNode.dispose();
   _postitionCPFocusNode.dispose();
   _phoneNumberFocusNode.dispose();
   _phoneNumberController.dispose();
   super.dispose();
 }




  @override
 void initState(){

   _animationController = AnimationController(vsync: this, duration: Duration(seconds: 20));
   _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
   ..addListener(() {

     setState((){});

   })..addStatusListener((animationStatus){
     if(animationStatus == AnimationStatus.completed){
       _animationController.reset();
       _animationController.forward();
     }
   });
   _animationController.forward();

   super.initState();
 }

void _submitFormOnRegister() async{
   final isValid = _signUpFormKey.currentState!.validate();
   if(isValid){
     // if(imageFile == null){
     //   GlobalMethod.showErrorDialog(error: 'Please pick user image', ctx: context);
     //   return;
     // }
     setState((){
       _isLoading = true;
     });
     try{
       await _auth.createUserWithEmailAndPassword(
           email: _emailTextController.text.trim().toLowerCase(),
           password: _passTextController.text.trim()
       );
       final User? user = _auth.currentUser;
       final _uid = user!.uid;
       final ref = FirebaseStorage.instance.ref().child('userImage').child(_uid + '.jpg');
       await ref.putFile(File(imageFile!.path));
       imageUrl = await ref.getDownloadURL();

       DocumentReference fireStoreRef = FirebaseFirestore.instance.collection('users').doc(_uid);
       Map<String, dynamic> toMap(){
         return {
           'id': _uid,
           'name': _fullNameController.text,
           'email': _emailTextController.text,
           'userImage': imageUrl,
           'phoneNumber': _phoneNumberController.text,
           'location': _locationController.text,
           'createAt': Timestamp.now(),
         };
       }
       await fireStoreRef.set(toMap());
       Navigator.canPop(context)? Navigator.pop(context) : null;
     }catch(error){
       setState((){
         _isLoading = false;
       });
       GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
     }
   }
   setState((){
     _isLoading = false;
   });
}


  @override
  Widget build(BuildContext context) {
   Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signUpUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/internship1.jpeg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value,0),
          ),
          Container(
            color: Colors.black45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                      child:Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                             _showImageDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? Icon(Icons.camera_enhance, color: Colors.deepOrangeAccent, size: 30,)
                                      : Image.file(imageFile!, fit: BoxFit.fill),
                                ),
                              ),
                            ),

                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocasNode),
                            keyboardType: TextInputType.name,
                            controller: _fullNameController,
                            validator: (value){
                              if (value!.isEmpty){
                                return "This Field is missing";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                              color: Colors.white,),
                              decoration: InputDecoration(
                                hintText: 'Full Name / Company Name',
                                hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocasNode),
                            focusNode: _emailFocasNode,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            validator: (value){
                              if (value!.isEmpty || !value.contains("@")){
                                return "Please Enter a valid Email";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                              color: Colors.white,),
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneNumberFocusNode),
                            focusNode: _passFocasNode,
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passTextController,
                            obscureText: _obscureText,
                            validator: (value){
                              if (value!.isEmpty || value.length < 7){
                                return "Please Enter a valid password";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                              color: Colors.white,),
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: (){
                                  setState((){
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText ?
                                      Icons.visibility : Icons.visibility_off,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                              hintText: 'password',
                              hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_postitionCPFocusNode),
                            focusNode: _phoneNumberFocusNode,
                            keyboardType: TextInputType.phone,
                            controller: _phoneNumberController,
                            validator: (value){
                              if (value!.isEmpty){
                                return "This Filed is Missing";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                              color: Colors.white,),
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_postitionCPFocusNode),
                            focusNode: _postitionCPFocusNode,
                            keyboardType: TextInputType.text,
                            controller: _locationController,
                            validator: (value){
                              if (value!.isEmpty){
                                return "This Filed is Missing";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                              color: Colors.white,),
                            decoration: InputDecoration(
                              hintText: 'Company Address',
                              hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          _isLoading
                              ?Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(),
                            ),
                          ) : MaterialButton(
                            onPressed: _submitFormOnRegister,
                            color: Colors.deepOrangeAccent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SignUp',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 40,),

                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,),
                                  ),
                                  TextSpan(text: '     '),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.canPop(context)
                                    ? Navigator.pop(context) : null,
                                    text: 'Login Here',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,),
                                  ),
                                ],
                              ),

                            ),
                          ),

                        ],
                      )
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  void _showImageDialog(){
   showDialog(
       context: context,
       builder: (context){
         return AlertDialog(
           title: Text('Please choose an option'),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               InkWell(
                 onTap: (){
                   _getFromCamera();
                 },
                 child: Row(
                   children: [
                     Padding(
                         padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.camera,
                          color: Colors.deepOrangeAccent,
                          ),
                     ),
                     Text('Camera',
                     style: TextStyle(color: Colors.deepOrangeAccent),
                     ),
                   ],
                 ),
               ),
               InkWell(
                 onTap: (){
                    _getFromGallery();
                 },
                 child: Row(
                   children: [
                     Padding(
                       padding: EdgeInsets.all(4.0),
                       child: Icon(Icons.image,
                         color: Colors.deepOrangeAccent,
                       ),
                     ),
                     Text('Gallery',
                       style: TextStyle(color: Colors.deepOrangeAccent),
                     ),
                   ],
                 ),
               )
             ],
           ),
         );
       });
  }


  Future _getFromGallery()async{
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
     maxHeight: 1080,
     maxWidth: 1080);

    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

Future  _getFromCamera() async{
   PickedFile? pickedFile = await ImagePicker().getImage(
     source: ImageSource.camera,
     maxHeight: 1080,
     maxWidth: 1080,
   );
   _cropImage(pickedFile!.path);
   Navigator.pop(context);
}

  Future _cropImage (filePath) async{
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath, maxHeight: 1080, maxWidth: 1080,
    );

      setState((){
        imageFile = File(croppedFile!.path); /// Here you must put croppedFile!.path inside File not as File
      });

  }
}













