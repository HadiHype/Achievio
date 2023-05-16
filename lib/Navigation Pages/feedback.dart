import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:emailjs/emailjs.dart';

class FeedbackForm extends StatefulWidget {
  FeedbackForm({Key? key}) : super(key: key);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();

  Future<void> sendFeedback() async {
    // var url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    // var response = await http.post(
    //   url,
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode({
    //     'service_id': 'service_hadi_hoteit',
    //     'template_id': 'template_4qs69y8',
    //     'user_id': 'Ihze7z7Aj5J__Ypi2',
    //     'template_params': {
    // 'user_name': _nameController.text,
    // 'user_email': _emailController.text,
    // 'user_feedback': _feedbackController.text,
    //     },
    //   }),
    // );

    // if (response.statusCode == 200) {
    //   print('Feedback sent successfully');
    // } else {
    //   print('Failed to send feedback');
    // }
    Map<String, dynamic> templateParams = {
      'from_name': _nameController.text,
      'user_email': _emailController.text,
      'message': _feedbackController.text,
    };

    try {
      await EmailJS.send(
        'service_hadi_hoteit',
        'template_4qs69y8',
        templateParams,
        const Options(
          publicKey: 'Ihze7z7Aj5J__Ypi2',
          privateKey: '_RbMF5bzmeecIOEb41MHU',
        ),
      );
      print('SUCCESS!');
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Form'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _feedbackController,
              decoration: InputDecoration(labelText: 'Feedback'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  sendFeedback();
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
