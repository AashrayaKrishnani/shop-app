import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../models/http_exception.dart';
import '../screens/auth_screen.dart';
import 'error_dialog.dart';
import 'forgot_pass.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  // ignore: prefer_final_fields
  var _authData = {
    'email': '',
    'password': '',
    'returnSecureToken': true,
  };
  var _isLoading = false;
  var _showForgotPass = false;
  final _passwordController = TextEditingController();

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

  Future<void> _submit() async {
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
      await Provider.of<Auth>(context, listen: false)
          .auth(_authMode, _authData);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(
            seconds: 2,
          ),
          content: Text('Yay We In! 🥳'),
          backgroundColor: Colors.green,
        ),
      );
    } on HttpException catch (httpException) {
      if (httpException.message.contains('EMAIL_EXISTS')) {
        title = 'We Already Know You! 💗';
        content =
            'Looks like that Email Already Exists, you remember the password again don\'t  ya? 😛';
        buttonText = 'Maybe! 😂';
      } else if (httpException.message.contains('EMAIL_NOT_FOUND')) {
        title = 'Honored to Meet Ya! 💖';
        content =
            'It\'s our first time seeing that Email, please Sign Up so we can officially be Buddies! 🥳';
        buttonText = 'Yesss!! 😎';

        final decision = await showErrorDialog(title, content, buttonText);
        if (decision != null) {
          setState(() {
            _authMode = AuthMode.signup;
          });
        } else if (httpException.message.contains('INVALID_PASSWORD')) {
          title = 'Forgot the Pass Again? 🤣';
          content =
              'Start Eating Almonds Bro!! 🤭 Just Kidding, \'Forgot Password\' Got your Back 😉';
          buttonText = 'Yayy!!! 🥳';
          final decision = await showErrorDialog(title, content, buttonText);
          if (decision != null) {
            setState(() {
              _showForgotPass = true;
            });
          }
        }
      } else {
        showErrorDialog(title, content, buttonText);
      }
    } catch (error) {
      showErrorDialog(title, content, buttonText);
    }

    setState(() {
      _formKey.currentState?.reset();
      _passwordController.clear();
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _showForgotPass = false;
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: _authMode == AuthMode.forgotPass
          ? ForgotPass(
              callback: ({AuthMode authMode = AuthMode.login}) {
                setState(() {
                  _authMode = authMode;
                });
              },
            )
          : Container(
              height: _authMode == AuthMode.signup
                  ? 320
                  : _showForgotPass
                      ? 320
                      : 260,
              constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.signup
                      ? 320
                      : _showForgotPass
                          ? 320
                          : 260),
              width: deviceSize.width * 0.75,
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
                          _authData['email'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty || value.length <= 5) {
                            return 'Password is too short!';
                          }
                        },
                        onSaved: (value) {
                          _authData['password'] = value!;
                        },
                      ),
                      if (_authMode == AuthMode.signup)
                        TextFormField(
                          enabled: _authMode == AuthMode.signup,
                          decoration: const InputDecoration(
                              labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          child: Text(_authMode == AuthMode.login
                              ? 'LOGIN'
                              : 'SIGN UP'),
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              primary: Theme.of(context).primaryColor,
                              textStyle: TextStyle(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .button
                                    ?.color,
                              )),
                        ),
                      if (!_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 4),
                          child: TextButton(
                            child: Text(
                                '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            onPressed: _switchAuthMode,
                          ),
                        ),
                      if (_showForgotPass)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 4),
                          child: TextButton(
                            child: Text('Forgot Password? 🤭',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            onPressed: () => setState(() {
                              _authMode = AuthMode.forgotPass;
                              _showForgotPass = false;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
