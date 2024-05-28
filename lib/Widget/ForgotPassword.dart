import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginScreen.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailErrorText;
  String? _resetPasswordError;
  bool _isSendingResetEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.teal, // Đặt màu của AppBar là xanh
        leading: IconButton( // Thêm nút back về màn hình đăng nhập
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); // Quay lại màn hình trước đó
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailErrorText,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isSendingResetEmail ? null : _sendResetEmail,
              child: _isSendingResetEmail ? CircularProgressIndicator() : Text('Send Reset Email'),
            ),
            if (_resetPasswordError != null) ...[
              SizedBox(height: 20.0),
              Text(
                _resetPasswordError!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendResetEmail() async {
    String email = _emailController.text;
    bool emailValid = _validateEmail(email);

    setState(() {
      _emailErrorText = emailValid ? null : 'Invalid email';
      _resetPasswordError = null;
    });

    if (emailValid) {
      setState(() {
        _isSendingResetEmail = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showResetEmailSentDialog();
      } catch (e) {
        setState(() {
          _resetPasswordError = 'Failed to send reset email. Please try again later.';
          _isSendingResetEmail = false;
        });
      }
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showResetEmailSentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Email Sent'),
          content: Text('An email with instructions to reset your password has been sent'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
