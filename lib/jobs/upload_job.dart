

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internship_app/persistent/persistent.dart';
import 'package:internship_app/services/global_methods.dart';
import 'package:internship_app/services/global_variables.dart';
import 'package:internship_app/widgets/bottomNavBar.dart';
import 'package:uuid/uuid.dart';

class UploadJob extends StatefulWidget {

  @override
  State<UploadJob> createState() => _UploadJobState();
}

class _UploadJobState extends State<UploadJob> {
  TextEditingController _jobCategoryController = TextEditingController(text: 'Select Job Category');

  TextEditingController _jobTitleController = TextEditingController();

  TextEditingController _jobDescriptionController = TextEditingController();

  TextEditingController _deadLineDataController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  DateTime? picked;

  Timestamp? deadlineDateTimeStamp;

  bool _isLoading = false;

void dispose(){
  super.dispose();
  _jobCategoryController.dispose();
  _jobTitleController.dispose();
  _jobDescriptionController.dispose();
  _deadLineDataController.dispose();
}

void _uploadTask() async{
  final jobId = Uuid().v4();
  User? user = FirebaseAuth.instance.currentUser;
  final _uid = user!.uid;
  final isValid = _formkey.currentState!.validate();

  if(isValid){
    if(_deadLineDataController.text == 'Choose task Deadline date' || _jobCategoryController.text == 'Choose task category'){
      GlobalMethod.showErrorDialog(
          error: 'Please pick everything',
          ctx: context);
      return;
    }
    setState((){
      _isLoading = true;
    });
    try{
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
        'jobId' : jobId,
        'uploadedBy' : _uid,
        'email' : user.email,
        'jobTitle' : _jobTitleController.text,
        'jobDescription' : _jobDescriptionController.text,
        'deadlineDate' : _deadLineDataController.text,
        'deadlineDateTimeStamp' : deadlineDateTimeStamp,
        'jobCategory' : _jobCategoryController.text,
        'jobComment' : [],
        'recruitment' : true,
        'createAt' : Timestamp.now(),
        'name' : name,
        'userImage' : userImage,
        'location' : location,
        'applicants' : 0,
      });
      await Fluttertoast.showToast(
          msg:"The task has been uploaded",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
      );
      _jobTitleController.clear();
      _jobDescriptionController.clear();
      setState((){
        _jobCategoryController.text = 'Choose job category';
        _deadLineDataController.text = 'Choose job Deadline date';
      });
    }catch(error){} finally{
      setState((){
        _isLoading = false;
      });
    }
  }else{
    print('it is not valid');
  }
}
@override
  void initState() {
    _uploadTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavForApp(indexNum: 2,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            color: Colors.orange,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5,),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text('Please fill all Fields',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  Divider(thickness: 1,),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: 'Job category: '),
                          _textFormFields(
                              valueKey: 'JobCategory',
                              controller: _jobCategoryController,
                              enabled: false,
                              fct: (){
                                _showTaskCategoriesDialog(size: size);
                              },
                              maxLength: 100,
                          ),
                          _textTitles(label: 'Job Title:'),
                          _textFormFields(
                              valueKey: 'JobTitle',
                              controller: _jobTitleController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100,
                          ),
                          _textTitles(label: 'Job Description:'),
                          _textFormFields(
                            valueKey: 'JobDescription',
                            controller: _jobDescriptionController,
                            enabled: true,
                            fct: (){},
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Dateline Date:'),
                          _textFormFields(
                            valueKey: 'JobDateline',
                            controller: _deadLineDataController,
                            enabled: false,
                            fct: (){
                              _pickDateDialoge();
                            },
                            maxLength: 100,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(padding: EdgeInsets.only(bottom: 30),
                    child: _isLoading ? CircularProgressIndicator() : 
                    MaterialButton(onPressed: _uploadTask,
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Post Now',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            SizedBox(width: 8,),
                            Icon(Icons.upload_file,
                            color: Colors.orange,
                            ),

                          ],
                        ),
                      ),
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFormFields({

    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
}){
  return Padding(padding: EdgeInsets.all(5.0),
  child: InkWell(
    onTap: (){
      fct();
    },
    child: TextFormField(
      validator: (value){
        if (value!.isEmpty){
          return "Value is missing";
        }
        return null;
      },
      controller: controller,
      enabled: enabled,
      key: ValueKey(valueKey),
      style: TextStyle(
        color: Colors.white,
      ),
      maxLines: valueKey == 'TaskDescription' ? 3 : 1,
      maxLength: maxLength,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    ),
  ),
  );
  }

  _showTaskCategoriesDialog({required Size size}){
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'job Category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
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
                          _jobCategoryController.text = Persistent.jobCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_right_outlined,
                            color: Colors.deepOrange,
                          ),
                          Padding(padding: EdgeInsets.all(8.0),
                          child: Text(
                           Persistent.jobCategoryList[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          ),
                        ],
                      ),
                    );
              }
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
                child: Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16),),
              ),
            ],
          );
        }
    );
  }
  
  void _pickDateDialoge() async{
  picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now().subtract(Duration(days: 0),),
      lastDate: DateTime(2100)
  );

    if(picked != null){
     setState((){
       _deadLineDataController.text = '${picked!.year}-${picked!.month}-${picked!.day}';
       deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
     });

    }

  }

  Widget _textTitles({required String label}){

  return Padding(padding: EdgeInsets.all(5.0),
  child: Text(
    label,
    style: TextStyle(
      color: Colors.grey,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  );
  }
}
