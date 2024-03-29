import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:internship_app/auth/register.dart';
import 'package:internship_app/services/global_methods.dart';
import 'package:internship_app/services/global_variables.dart';

import 'forget_password.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextEditingController _emailTextController = TextEditingController(text: '');
  late TextEditingController _passTextController = TextEditingController(text: '');

  FocusNode _passFocasNode = FocusNode();
  bool _isLoading = false;
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose(){
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocasNode.dispose();
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

  void _submitLoginForm() async{
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid) {
      setState((){
        _isLoading = true;
      });
      try{
        await _auth.signInWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextController.text.trim(),
        );
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }catch (error){
        setState((){
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print('reeor occured $error');
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

              Padding(padding: EdgeInsets.only(left: 80.0, right: 80.0,),
              child: Image.asset("assets/images/signup.png"),),

                  Form(
                      key: _loginFormKey,
                      child:Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocasNode),
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
                          TextFormField(
                            textInputAction: TextInputAction.next,
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
                          SizedBox(height: 15,),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgotPassword()));
                              },
                              child: Text(
                                'Forget Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),

                          MaterialButton(
                            onPressed: _submitLoginForm,
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
                                    'Login',
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
                                    text: 'Don\'t have an account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,),
                                  ),
                                  TextSpan(text: '     '),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup())),

                                    text: 'Register Here',
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
}
