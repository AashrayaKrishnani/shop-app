import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/loading_spinner.dart';

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

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();

  AuthMode _authMode = AuthMode.login;
  // ignore: prefer_final_fields
  Map<String, dynamic> _authData = {
    'email': '',
    'password': '',
  };
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  var _isLoading = false;
  var _showForgotPass = false;
  var _autoLogin = false;

  @override
  void initState() {
    final LogOutReason logOutReason =
        Provider.of<Auth>(context, listen: false).logOutReason;
    if (logOutReason != LogOutReason.none) {
      Future.delayed(Duration.zero).then((_) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(
              seconds: 3,
            ),
            content: Text(
              logOutReason == LogOutReason.error
                  ? 'Login Timed Out! Kindly Login Again! 😼'
                  : 'Logged Out Succesfully! Login Back Again to Enjoy! 🥳',
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      });
    }

    // Setting up  the Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.fastLinearToSlowEaseIn));

    super.initState();
  }

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

  Future<void> _submit({bool validate = true}) async {
    if (validate) {
      if (!_formKey.currentState!.validate()) {
        // Invalid!
        return;
      }

      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });
    }

    // For Error Handling
    String title = 'Oopsies! 😅';
    String content =
        'Something went Wrong, chance for you to let us know (at loveaash3@gmail.com 😳) and help us out! 🥳';
    String buttonText = 'Alright Bud! 😼';

    // Sending Data to Server.
    try {
      final sms = ScaffoldMessenger.of(context);
      await Provider.of<Auth>(context, listen: false)
          .auth(_authMode, _authData);
      sms.hideCurrentSnackBar();
      sms.showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 2,
          ),
          content: Text(validate ? 'Yay We In! 🥳' : 'Welcome Back! 🥳'),
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
          _switchAuthMode();
        }
      } else if (httpException.message.contains('INVALID_PASSWORD')) {
        title = 'Forgot the Pass Again? 🤣';
        content =
            'Start Eating Almonds Bro!! 🤭 Just Kidding, \'Forgot Password\' Got your Back 😉';
        buttonText = 'Yayy Resett!!! 🥳';
        final decision = await showErrorDialog(title, content, buttonText);
        if (decision != null) {
          setState(() {
            _showForgotPass = true;
          });
        }
      } else if (httpException.message
          .contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        title = 'Multiple Failed Logins :< ';
        content =
            'Access is temporarily disabled. You can wait and try again later, or if you too cheeky, we can reset the password and login now? >< ';
        buttonText = 'Resettt! 😼';

        final decision = await showErrorDialog(title, content, buttonText);
        if (decision != null) {
          setState(() {
            _authMode = AuthMode.forgotPass;
          });
        }
      } else {
        showErrorDialog(title, content, buttonText);
      }
    } catch (error) {
      print("Error" + error.toString());
      if (mounted) {
        showErrorDialog(title, content, buttonText);
      }
    }

    if (mounted) {
      setState(() {
        _autoLogin = false;
        _formKey.currentState?.reset();
        _passwordController.clear();
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _showForgotPass = false;
        _authMode = AuthMode.signup;
        _animationController?.forward();
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
        if (!_showForgotPass) {
          _animationController!.reverse();
        }
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
      child: FutureBuilder(
        future: Provider.of<Auth>(context, listen: false).triedCheckingPrefs
            ? null
            : Provider.of<Auth>(context, listen: false).getPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _autoLogin) {
            return const LoadingSpinner(
              message: 'Trying to Auto-Login! 😊',
            );
          } else if (_authData['email'] == '' &&
              _authData['password'] == '' &&
              snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            Future.delayed(Duration.zero).then(
              (_) async {
                setState(
                  () {
                    _autoLogin = true;
                    _authData = snapshot.data as Map<String, dynamic>;
                    _passwordController.value =
                        TextEditingValue(text: _authData['password']);
                  },
                );
                await _submit(validate: false);
              },
            );
          }

          return _authMode == AuthMode.forgotPass
              ? ForgotPass(
                  callback: ({AuthMode authMode = AuthMode.login}) {
                    setState(() {
                      _authMode = authMode;
                    });
                  },
                )
              : AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 300),
                  height: _authMode == AuthMode.signup || _showForgotPass
                      ? 380
                      : 300,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signup || _showForgotPass
                          ? 380
                          : 300),
                  width: deviceSize.width * 0.75,
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: _authData['email'],
                            decoration:
                                const InputDecoration(labelText: 'E-Mail'),
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
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            constraints: BoxConstraints(
                                maxHeight:
                                    _authMode == AuthMode.signup ? 120 : 0),
                            child: FadeTransition(
                              opacity: _opacityAnimation!,
                              child: TextFormField(
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
                            ),
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
                              child: ElevatedButton(
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
                                  ),
                                ),
                                child: const Text(
                                  'Forgot Password? 🤭',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => setState(
                                  () {
                                    _authMode = AuthMode.forgotPass;
                                    _showForgotPass = false;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
