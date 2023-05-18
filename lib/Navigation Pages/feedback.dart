import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emailjs/emailjs.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();

  Future<void> sendFeedback() async {
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
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  sendFeedback();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
