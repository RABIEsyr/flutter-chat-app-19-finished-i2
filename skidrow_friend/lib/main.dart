import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/global/singleton.dart';
import 'package:skidrow_friend/model/rsa.dart';
import 'package:skidrow_friend/providers/Message.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/providers/context_change.dart';
import 'package:skidrow_friend/providers/expansipn_open_colse.dart';
import 'package:skidrow_friend/providers/request_message.dart';
import 'package:skidrow_friend/providers/sign_up_in.dart';
import 'package:skidrow_friend/screens/auth_screen.dart';
import 'package:skidrow_friend/screens/all_screen.dart';
import 'package:skidrow_friend/screens/chat/chat_screen.dart';
import 'package:skidrow_friend/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:encrypt/encrypt.dart' as ee;


import 'package:skidrow_friend/model/socket_custom.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'global/currentChatId.dart';
import 'services/signalling.service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

var routeToGo = '/';

var isFirebaseError = false;

  AndroidNotificationChannel  channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

  bool isFlutterLocalNotificationsInitialized = false;



 
  void showNotificationCC(RemoteMessage message) {
    var payloadEncoded = json.decode(message.data['det']);
    flutterLocalNotificationsPlugin?.show(
          0,
          payloadEncoded['title'],
          payloadEncoded['title'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload:  message.data['det']);
    
  }

  // void showFlutterNotification(RemoteMessage? message) {
  //   // RemoteNotification? notification = message?.notification;
  //   // AndroidNotification? android = message?.notification?.android;
  //   if (message != null  ) {
  //     flutterLocalNotificationsPlugin.show(
  //       message.hashCode,
  //       message.messageId,
  //       'body',
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //          ' channel.id',
  //           channel.name,
  //           channelDescription: channel.description,
  //           // TODO add a proper drawable resource to android, for now using
  //           //      one that already exists in example app.
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),
  //     );
      
  //   }
  // }
  
  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    

    

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    
    isFlutterLocalNotificationsInitialized = true;
  }
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await setupFlutterNotifications();
    showNotificationCC(message);
    // showFlutterNotification(message);
     
    
    //  showNotification(message);
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //   AndroidInitializationSettings('@mipmap/ic_launcher');
    // final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    // onSelectNotification:  (payload) => onSelectNotification0(payload: payload!, id: message.data['senderId'], publicKey: message.data['bodyLocKey']));
    // // If you're going to use other Firebase services in the background, such as Firestore,
    // // make sure you call `initializeApp` before using other Firebase services.
    // print('Handling a background message ${message.messageId}');
    

    
  }

  Future onSelectNotification0({required String payload, required String id, required String publicKey,}) async {
    routeToGo = '/ch';
    print('sss');
    final prefs = await SharedPreferences.getInstance();
    var extracted = json.decode(prefs.getString('apiKey')!);

    String privateKey = extracted['privateKey']!;
    if (payload != null) {
      debugPrint('notification payload: $payload');
      
      // await Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
      //                             MaterialPageRoute(
      //                               builder: (context) {return ChatScreen(privateKey: privateKey);},
      //                               settings: RouteSettings(
      //                                 arguments: {
      //                                   'status': 'out',
      //                                   'id': id,
      //                                   'toPublicKey': publicKey
      //                                 }
      //                               )
      //                             ),
      //                           );
    }
    await Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': id,
                                        'toPublicKey': publicKey
                                      }
                                    )
                                  ),
                                );
  } 
  var details = null; 
Future<void> main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  //---- firebase ---- ///
  await  Firebase.initializeApp();
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      
      var initSettings = InitializationSettings(
          android: initializationSettingsAndroid,
         );
      flutterLocalNotificationsPlugin?.initialize(initSettings,
          onSelectNotification: (payload) async{
             
            SharedPreferences.getInstance().then((prefs) async{
              
     var extracted = json.decode(prefs.getString('apiKey')!);

    String privateKey = extracted['privateKey']!;
      var notificationPayload = json.decode(payload!);
      if (CurrentChatUserID.userId != null) {
       Navigator.of(ContexChange.ctx1!).popUntil((route) => true);
      await Navigator.of(ContexChange.ctx1!, rootNavigator: true).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                         'id': notificationPayload['senderId'], 
                                       'toPublicKey': notificationPayload['bodyLocKey'] as String,
                                        'username': notificationPayload['title'] as String
                                      }
                                    )
                                  ),
                                );
      } else {
    await Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': notificationPayload['senderId'], 
                                       'toPublicKey': notificationPayload['bodyLocKey'] as String,
                                        'username': notificationPayload['title'] as String
                                      }
                                    )
                                  ),
                                );
  }  

    //  Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
    //                               MaterialPageRoute(
    //                                 builder: (context) {return ChatScreen(privateKey: privateKey);},
    //                                 settings: RouteSettings(
    //                                   arguments: {
    //                                     'status': 'out',
    //                                     'id': notificationPayload['senderId'], 
    //                                     'toPublicKey': notificationPayload['bodyLocKey'],
    //                                     'username': notificationPayload['username']
    //                                   }
    //                                 )
    //                               ),
    //                             );
  });
      });
 try {
    isFirebaseError = false;
    FirebaseMessaging firebaseMessaging =  FirebaseMessaging.instance;
    
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //  print('message3, ${message.notification?.body}');
    
    // });
  
    String? newToken = await firebaseMessaging.getToken();
    // print('--- Firebase token here ---');
    final prefs = await SharedPreferences.getInstance();

     
    if (newToken != null) {
      SetFirebaseToken.firebaseToken = newToken;
      await prefs.setString('firebaseToken', newToken);
     
    }

    
    print('newToken2+ $newToken');
    var token1 = 'f6DQQ8dzSHev7X3YF1em5j:APA91bFdD0EKOH26MtUDlNBuXGSIyyZDzD_QaW6KiLDqoxT3IsokmweTEyoOdM0mdo9SobCra6U4mYPWx1wwAWp_VBWEiE4FwwsoLZxYBRLJjjVMA08bdFFJ_lcOgH79DBDNWEVbBpkT';
    var token2 = 'f6DQQ8dzSHev7X3YF1em5j:APA91bFdD0EKOH26MtUDlNBuXGSIyyZDzD_QaW6KiLDqoxT3IsokmweTEyoOdM0mdo9SobCra6U4mYPWx1wwAWp_VBWEiE4FwwsoLZxYBRLJjjVMA08bdFFJ_lcOgH79DBDNWEVbBpkT';
    if (token1 == token2) {
      print('exact');
    }
 } catch (e) {
   isFirebaseError = true;
   print('firebase token $e');
 }

 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //--- firebase end ----///

  // final prefs = await SharedPreferences.getInstance();
  
  // if (prefs.containsKey('apiKey')) {
  //   if (!prefs.containsKey('rsaKey')) {
  //     print('new new new');
  //     await Rsa().generateKeys();
  //     Rsa.sendRsaKeysToServer();
  //   } else {
  //     print('exist exist ');
  //   }
  // }


  final plainText = "Fallback! I repeat fallback to sector 12!!";
  final key = "This 32 char key have 256 bits..";

  print('Plain text for encryption: $plainText');

  //Encrypt
  ee.Encrypted encrypted = encryptWithAES(key, plainText);
  String encryptedBase64 = encrypted.base64;
  // print('Encrypted data in base64 encoding: $encryptedBase64');

  //Decrypt
  String decryptedText = decryptWithAES(key, encrypted);
  // print('Decrypted data: $decryptedText');
    


    
  // runApp(const MyApp());
  // details = await  flutterLocalNotificationsPlugin
  //   .getNotificationAppLaunchDetails();
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    details = notificationAppLaunchDetails!.payload;
    print('details: $details');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: Auth(),
      ),
      ChangeNotifierProvider.value(
        value: MessageRepo(),
      )
    ],
    child: MaterialApp(
      home: const MyApp(),
      navigatorKey: Singleton().navigatorKey,
    ),
  ));
  
  
}

String decryptWithAES(String key, ee.Encrypted encryptedData) {
  final cipherKey = ee.Key.fromUtf8(key);
  final encryptService = ee.Encrypter(
      ee.AES(cipherKey, mode: ee.AESMode.cbc)); //Using AES CBC encryption
  final initVector = ee.IV.fromUtf8(key.substring(0,
      16)); //Here the IV is generated from key. This is for example only. Use some other text or random data as IV for better security.

  return encryptService.decrypt(encryptedData, iv: initVector);
}

///Encrypts the given plainText using the key. Returns encrypted data
ee.Encrypted encryptWithAES(String key, String plainText) {
  final cipherKey = ee.Key.fromUtf8(key);
  final encryptService = ee.Encrypter(ee.AES(cipherKey, mode: ee.AESMode.cbc));
  final initVector = ee.IV.fromUtf8(key.substring(0,
      16)); //Here the IV is generated from key. This is for example only. Use some other text or random data as IV for better security.

  ee.Encrypted encryptedData =
      encryptService.encrypt(plainText, iv: initVector);
  return encryptedData;
}

 

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    
  }
  @override
  void initState() {
    super.initState();
    
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      //  showNotification(message, 'red');
  print('ttt');
  routeToGo ='/ch';
  if (message != null) {
    print('suuu');
  //  final pbKey =  message.data['bodyLocKey'];
    SharedPreferences.getInstance().then((prefs) {
     var extracted = json.decode(prefs.getString('apiKey')!);

    String privateKey = extracted['privateKey']!;
    print(privateKey);
     Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': message.data['senderId'], // '634e76d589d46b0c88ff5440',
                                        'toPublicKey': message.data['bodyLocKey'] as String,
                                        'username': message.data['username'] as String
                                      }
                                    )
                                  ),
                                );
  });
  }
});

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      print('togo $routeToGo');
      print('dada');
      
        final prefs = await SharedPreferences.getInstance();
        var extracted = json.decode(prefs.getString('apiKey')!);

        String privateKey = extracted['privateKey']!;
       Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey,);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'in',
                                        'id': message.data['senderId'] as String,
                                        'toPublicKey':  message.data['bodyLocKey'] as String,
                                        'username':  message.data['username'] as String
                                      }
                                    )
                                  ),
                                );
  }
);
    
  }

  

  
  //
  @override
  Widget build(BuildContext context) {
    // Provider.of<ContexChange>(context, listen: false).setContext1(context);
    ContexChange.ctx1 = context;
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //        print('object');
  //       RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //      showNotification();
    
  // });
    if (isFirebaseError) {
      Singleton().showMyDialog();
    }

     if(details != null) {
      SharedPreferences.getInstance().then((prefs) {
     var extracted = json.decode(prefs.getString('apiKey')!);
      
    String privateKey = extracted['privateKey']!;
    final decodePayload = json.decode(details);
    
    Navigator.of(ContexChange.ctx1!, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': decodePayload['senderId'], // '634e76d589d46b0c88ff5440',
                                        'toPublicKey': decodePayload['bodyLocKey'] as String,
                                        'username': decodePayload['title'] as String
                                      }
                                    )
                                  ),
                                );
});
     }

    return MultiProvider(
      providers: [
        // ChangeNotifierProvider.value(
        //   value: Auth(),
        // ),
        ChangeNotifierProvider.value(
          value: SignMode(),
        ),
        ChangeNotifierProvider.value(
          value: AllUsers(),
        ),
        ChangeNotifierProvider.value(
          value: ExpansionOpenClose(),
        ),
        ChangeNotifierProvider.value(
          value: RequestMessage(),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          
          return MaterialApp(
          title: 'SkidrowFriend',
          // theme: ThemeData(primarySwatch: Colors.purple),
          theme: ThemeData(primaryColor: Color.fromARGB(255, 131, 144, 179)),
          home: 
          FutureBuilder<Widget>(
          future: sock(auth.isAuth, context, auth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data!;
            }
          },
          ),
          // sock( auth.isAuth,  context,  auth),
          initialRoute: (routeToGo != null) ? routeToGo : '/', 
          onGenerateRoute: (settings)  {
            switch (settings.name) {
              case '/ch':

               return
              MaterialPageRoute(builder: (_) => 
                ChatScreen()
              );
            }
          },
          routes: {
            Authscreen.routeName: (ctx) {
              return Authscreen();
            },
             ChatScreen.routeName: (ctx) {
              return ChatScreen();
             }
          },
        );
        }
      ),
    );
  }
}

 Future<Widget> sock(bool isAuth, BuildContext context, Auth auth) async{
  if (isAuth) {
    // check authentication
    // Provider.of<Auth>(context, listen: false).checkAuth();

     var sharedSocket = SocketServices(ctx: context);
     sharedSocket.connectSocket();
 final prefs = await SharedPreferences.getInstance();
 final extractedUserData = json.decode(prefs.getString('apiKey')!);
 final _userId = extractedUserData['userId'];
  print('_userId: $_userId');

     final String websocketUrl = "http://192.168.1.3:3010";
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: _userId,
    );

     return RecentChatScreen(socketo: sharedSocket,);
  } else {
    return FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnpashot) =>
                      authResultSnpashot == ConnectionState.waiting
                          ?  SplashScreen()
                          : Authscreen(),
                );
  }
}

//  call Test

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'screens/call_screen/join_screen.dart';
// import 'services/signalling.service.dart';

// void main() {
//   // start videoCall app
//   runApp(VideoCallApp());
// }

// class VideoCallApp extends StatelessWidget {
//   VideoCallApp({super.key});

//   // signalling server url
//   // final String websocketUrl = "WEB_SOCKET_SERVER_URL";
//   final String websocketUrl = "http://192.168.1.6:3000";

//   // generate callerID of local user
//   final String selfCallerID =
//       Random().nextInt(999999).toString().padLeft(6, '0');

//   @override
//   Widget build(BuildContext context) {
//     // init signalling service
//     SignallingService.instance.init(
//       websocketUrl: websocketUrl,
//       selfCallerID: selfCallerID,
//     );

//     // return material app
//     return MaterialApp(
//       darkTheme: ThemeData.dark().copyWith(
//         useMaterial3: true,
//         colorScheme: const ColorScheme.dark(),
//       ),
//       themeMode: ThemeMode.dark,
//       home: JoinScreen(s192lfCallerId: selfCallerID),
//     );
//   }
// }



 
 