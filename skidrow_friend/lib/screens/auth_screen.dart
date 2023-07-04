import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/model/http_exception.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/providers/sign_up_in.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:slidable_button/slidable_button.dart';

enum AuthMode { signup, login }

var isReadyToLoginUsername = false;
var isReadyToLoginPassword = false;

final GlobalKey<FormState> _formKey = GlobalKey();

class Authscreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var signMode = Provider.of<SignMode>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // colors: [
                //   Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                //   Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                // ],
                // begin: Alignment.topLeft,
                // end: Alignment.bottomRight,
                // stops: [0, 1],
                colors: [Colors.blue, Colors.red],
                  begin: Alignment(-1.0, -4.0),
          end: Alignment(1.0, 4.0),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: signMode.mode == 'login' ? 620 : 660,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 60.0,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // color: Colors.blue,
                        gradient: LinearGradient(
                // colors: [
                //   Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                //   Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                // ],
                // begin: Alignment.topLeft,
                // end: Alignment.bottomRight,
                // stops: [0, 1],
                colors: [Colors.blue, Colors.red],
                  begin: Alignment(-1.0, -4.0),
          end: Alignment(1.0, 4.0),
              ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'SkidrowFriend',
                        style: TextStyle(
                          color: Theme.of(context)
                              .accentTextTheme
                              .headline6!
                              .color,
                          fontSize: 23,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ]),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  // final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  Map<String, String> _authData = {
    'username': '',
    'password': '',
    'province': '',
    'gender': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Damascus"), value: "Damascus"),
      const DropdownMenuItem(child: Text("Rif Dimashq"), value: "Rif Dimashq"),
      const DropdownMenuItem(child: Text("Lattakia"), value: "Lattakia"),
      const DropdownMenuItem(child: Text("Aleppo"), value: "Aleppo"),
    ];
    return menuItems;
  }

  String? province;
  String? gender;

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occurred'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    if (this.mounted)
      setState(() {
        _isLoading = true;
      });

    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).login(
            username: _authData['username']!, password: _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
            username: _authData['username']!,
            password: _authData['password']!,
            province: _authData['province']!,
            gender: _authData['gender']!);
      }
    } on HttpException catch (e) {
      var errorMessage = 'Autentication faild';
      if (e.toString().contains('Username has already been taken')) {
        errorMessage = 'Username has already been taken';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print('error0' + error.toString());
      const errorMessage = 'Could\'t authenticat; try agait later';
      _showErrorDialog(errorMessage);
    }

    if (this.mounted)
      setState(() {
        _isLoading = false;
      });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      Provider.of<SignMode>(context, listen: false).swithchMode('signup');
      if (this.mounted)
        setState(() {
          _formKey.currentState!.reset();
          _authMode = AuthMode.signup;
        });
    } else {
      Provider.of<SignMode>(context, listen: false).swithchMode('login');
      if (this.mounted)
        setState(() {
          _formKey.currentState!.reset();
          _authMode = AuthMode.login;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    var un;
    var pass;
    var signMode = Provider.of<SignMode>(context);
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: signMode.mode == 'login' ? 320 : 460,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signup ? 420 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'username'),
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    _authData['username'] = value as String;
                    un = value as String;
                    if (value != null) {
                      isReadyToLoginUsername = true;
                      Provider.of<SignMode>(context, listen: false)
                          .setUsername(true);
                    } else {
                      isReadyToLoginUsername = false;
                      Provider.of<SignMode>(context, listen: false)
                          .setUsername(false);
                    }
                  },
                  onChanged: (value) {
                    _authData['username'] = value as String;
                    un = value as String;
                    if (value != null) {
                      isReadyToLoginUsername = true;
                      Provider.of<SignMode>(context, listen: false)
                          .setUsername(true);
                    } else {
                      isReadyToLoginUsername = false;
                      Provider.of<SignMode>(context, listen: false)
                          .setUsername(false);
                          
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                     if (_authMode == AuthMode.signup) {
                        return 'username required';
                     }
                    }
                    if (_authMode == AuthMode.signup) if (Provider.of<Auth>(
                            context,
                            listen: false)
                        .usernameExists) {
                      return 'username already taken';
                    }
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onChanged: (value) {
                    _authData['password'] = value as String;
                    pass = value as String;
                    if (value != null) {
                      isReadyToLoginPassword = true;
                      Provider.of<SignMode>(context, listen: false)
                          .setPassword(true);
                    } else {
                      isReadyToLoginPassword = false;
                      Provider.of<SignMode>(context, listen: false)
                          .setPassword(false);
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                    pass = value as String;
                    if (value != null) {
                      isReadyToLoginPassword = true;
                      Provider.of<SignMode>(context, listen: false)
                          .setPassword(true);
                    } else {
                      isReadyToLoginPassword = false;
                      Provider.of<SignMode>(context, listen: false)
                          .setPassword(false);
                    }
                  },
                ),
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                  SizedBox(height: 10,),
                if (_authMode == AuthMode.signup)
                  Row(
                  
                      // crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        //  alignment: Alignment.bottomLeft,
                        // child: Column(
                          child: 
                            Text(province == null ? 'Province:' : province!)
                          ,
                        ),
                      
                      
                      Container(

                          // margin: EdgeInsets.only( top: 15),
                        child: 
                            DropdownButton(
                            
                              items: dropdownItems,
                              value: province,
                              onChanged: (String? newValue) {
                                if (this.mounted)
                                  setState(() {
                                    province = newValue!;
                                    _authData['province'] = province!;
                                  });
                              },
                            ),
                          
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                if (_authMode == AuthMode.signup)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: ListTile(
                              title: Transform.translate(
                                offset: Offset(-33, 0),
                                child: Icon(
                                  Icons.male,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              leading: Radio(
                                  value: "male",
                                  groupValue: gender,
                                  onChanged: (value) {
                                    if (this.mounted)
                                      setState(() {
                                        gender = value.toString();
                                        _authData['gender'] = gender!;
                                        // print(gender);
                                      });
                                  }),
                            ),
                          )
                        ],
                      ),
                      Column(children: [
                        SizedBox(
                          width: 100,
                          child: ListTile(
                            title: Transform.translate(
                              offset: Offset(-33, 0),
                              child: Icon(
                                Icons.female,
                                color: Colors.pink,
                              ),
                            ),
                            leading: Radio(
                                value: "female",
                                groupValue: gender,
                                onChanged: (value) {
                                  if (this.mounted)
                                    setState(() {
                                      gender = value.toString();
                                      _authData['gender'] = gender!;
                                      // print(gender);
                                    });
                                }),
                          ),
                        )
                      ])
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  _authMode == AuthMode.signup
                      ? SignupCircular(
                          username: _authData['username'] ?? un,
                          gender: _authData['gender']!,
                          password: _authData['password']!,
                          province: _authData['province']!,
                        )
                      //  : ElevatedButton(
                      //     child:
                      //         Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGNUP'),
                      //     onPressed: _submit,

                      //   ),
                      : SliderLoginButton(
                          username: _authData['username'] ?? un,
                          password: _authData['password'] ?? pass,
                        ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupCircular extends StatefulWidget {
  final String username;
  final String password;
  final String province;
  final String gender;

  const SignupCircular(
      {super.key,
      required this.username,
      required this.password,
      required this.province,
      required this.gender});

  @override
  State<SignupCircular> createState() => _SignupCircularState();
}

class _SignupCircularState extends State<SignupCircular> {
  @override
  Widget build(BuildContext context) {
    var isUsExists = Provider.of<Auth>(context, listen: false).usernameExists;
    var circularStatus = Provider.of<SignMode>(context).showCircularSpinner;

    Key _refreshKey2 = UniqueKey();
    print('circularStatus: $circularStatus');

    final slider = SleekCircularSlider(
      key:_refreshKey2,
   innerWidget: (val) => Center(
          child: SizedBox(
        width: 70, // <-- match_parent
        height: 70,
        child: ElevatedButton(
          onPressed: () => 
            setState(() {
              // Key _refreshKey2 = UniqueKey();
              signupCirc(context);
            })
          ,
          child: Text('JOIN'),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            // padding: EdgeInsets.all(10),
          ),
        ),
      )),
      min: 0,
      max: 100,
      
       initialValue: 0,
      // onChangeEnd: (value) {
      //   print(value);
      //   // signupCirc(context);
      // },
      appearance: CircularSliderAppearance(
          angleRange: 360,

          // infoProperties:
          //     InfoProperties(topLabelStyle: TextStyle(color: Colors.black)),
          spinnerMode: circularStatus == true ? true : false,
          animationEnabled: true,
          size: 90,
          customColors: CustomSliderColors(
               dotColor: Colors.transparent,
            // shadowColor: Colors.blueGrey,
            // shadowMaxOpacity: 0.2,
            // shadowStep: 5,
            // progressBarColor: Colors.red,
            trackColor: Colors.blueGrey),
        customWidths: CustomSliderWidths(
          progressBarWidth: circularStatus == true ? 10 : 0,
        ),
      ),
    );

    return slider;
  }

  Future<void> signupCirc(BuildContext context, ) async {
    print('username: ${widget.username}');
    print('papa  ${widget.password} ');
    print(widget.gender);
    print('provinceS ${widget.province}');

   if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
   } else {
    try {
      Provider.of<SignMode>(context, listen: false).setCircularSpinnerMode(true);
      await Provider.of<Auth>(context, listen: false).signup(
          username: widget.username,
          password: widget.password,
          province: widget.province,
          gender: widget.gender);
      if (Provider.of<Auth>(context, listen: false).usernameExists) {
        Provider.of<SignMode>(context, listen: false).setCircularSpinnerMode(false);
        throw HttpException(message: 'message');
      }
    } on HttpException catch (e) {
      Provider.of<SignMode>(context, listen: false).setCircularSpinnerMode(false);
      print('error222, $e');
      var errorMessage = 'Autentication faild';
      if (e.toString().contains('Username has already been taken')) {
        errorMessage = 'Username has already been taken';
      }
      _showErrorDialog('Username has already been taken', context);
    } catch (error) {
      print('error0' + error.toString());
      const errorMessage = 'Could\'t authenticat; try agait later';
      _showErrorDialog(errorMessage, context);
    }
   }
  }

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occurred'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }
}

class SliderLoginButton extends StatefulWidget {
  final String username;
  final String password;
  const SliderLoginButton(
      {super.key, required this.password, required this.username});

  @override
  State<SliderLoginButton> createState() => _SliderLoginButtonState();
}

class _SliderLoginButtonState extends State<SliderLoginButton> {
  @override
  Widget build(BuildContext context) {
    var usernameHasEntered =
        Provider.of<SignMode>(context).loginUsernameEntered;
    var passwordHasEntered =
        Provider.of<SignMode>(context).loginPasswordEntered;
    Key _refreshKey = UniqueKey();

    var slider = HorizontalSlidableButton(
      width: MediaQuery.of(context).size.width / 3,
      buttonWidth: 60.0,
      isRestart: usernameHasEntered == true && passwordHasEntered == true
          ? false
          : true,
      color: Theme.of(context).accentColor.withOpacity(0.5),
      buttonColor: Theme.of(context).primaryColor,
      dismissible: false,
      autoSlide: true,
      initialPosition: SlidableButtonPosition.start,
      key: _refreshKey,
      label: Center(child: Icon(Icons.key_outlined)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            usernameHasEntered == true && passwordHasEntered == true
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : Text(''),
            SizedBox(
              height: 20,
              width: 20,
              child: Icon(Icons.lock_outline),
            ),
          ],
        ),
      ),
      onChanged: (position) async {
        if (position == SlidableButtonPosition.end) {
          print('Button is on the right');
          if (usernameHasEntered == true && passwordHasEntered == true) {
            try {
              print('passo ${widget.password}');
              await Provider.of<Auth>(context, listen: false)
                  .login(username: widget.username, password: widget.password);
              if (Provider.of<Auth>(context, listen: false).usernameExists) {
                throw HttpException(message: 'message');
              }
            } on HttpException catch (e) {
              setState(() {
                _refreshKey = UniqueKey();
                SlidableButtonPosition.start;
              });
              print('error222, $e');
              var errorMessage = 'Autentication faild';
              if (e.toString().contains('username or password is invalid')) {
                errorMessage = 'Username or Password is invalid';
              }
              _showErrorDialog2('Username or Password is incorrect', context);
            } catch (error) {
              setState(() {
                _refreshKey = UniqueKey();
                SlidableButtonPosition.start;
              });
              print('error0' + error.toString());
              const errorMessage = 'Could\'t authenticat; try agait later';
              _showErrorDialog2(errorMessage, context);
            }
          }
        } else {
          print('Button is on the left');
        }
      },
    );

    return slider;
  }

  void _showErrorDialog2(String message, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occurred'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }
}
