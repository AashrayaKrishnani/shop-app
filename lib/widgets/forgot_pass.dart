import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/auth_screen.dart';

import '../models/auth.dart';
import '../models/http_exception.dart';
import 'error_dialog.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({Key? key, required this.callback}) : super(key: key);

  final Function callback;

  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  String? _email;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Future<dynamic> showErrorDialog(
      String title, String content, String buttonText) {
    return showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
              title: title,
              content: content,
              buttonMessage: buttonText,
            ));
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    // For Error Handling
    String title = 'Oopsies! 😅';
    String content =
        'Something went Wrong, chance for you to let us know (at loveaash3@gmail.com 😳) and help us out! 🥳';
    String buttonText = 'Alright Bud! 😼';

    // Sending Data to Server.
    try {
      await Provider.of<Auth>(context, listen: false).postData(
          'sendOobCode', {"email": _email, "requestType": "PASSWORD_RESET"});

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(
            seconds: 5,
          ),
          content: Text('Link sent Successfully! 🤭'),
          backgroundColor: Colors.green,
        ),
      );

      widget.callback(); // To Get back To Login :)
    } on HttpException catch (httpException) {
      if (httpException.message.contains('EMAIL_NOT_FOUND')) {
        title = 'You seem New here! 🎉';
        content =
            'It\'s our first meeting with that email. Let\'s get you signed up so we are officially Friends! 🙏';
        buttonText = 'Let\'s Sign Up! 🥳';

        final answer = await showErrorDialog(title, content, buttonText);
        if (answer != null && answer == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(
                seconds: 3,
              ),
              content: const Text('Time To Sign Up!! 🥳'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          widget.callback(authMode: AuthMode.signup);
        }
      } else {
        showErrorDialog(title, content, buttonText);
      }
    } catch (error) {
      showErrorDialog(title, content, buttonText);
    }

    setState(() {
      _formKey.currentState?.reset();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      constraints: const BoxConstraints(minHeight: 160),
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _email = value!;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  child: const Text('Send Code'),
                  onPressed: () {
                    _sendCode();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button?.color,
                      )),
                ),
              if (!_isLoading)
                ElevatedButton(
                  child: const Text('Go Back'),
                  onPressed: () {
                    widget.callback();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      primary: Theme.of(context).errorColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button?.color,
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
