import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/screens/userScreen/tabs/requestTab/incomming_request.dart';
import 'package:skidrow_friend/screens/userScreen/tabs/requestTab/outgoin_request.dart';

class RequestScreen extends StatelessWidget {
  static String requestStatus = '';
  final SocketServices socket;
  
  const RequestScreen({super.key, required this.socket});

  @override
  Widget build(BuildContext context) {
    var token  = Provider.of<Auth>(context).token;

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            // title: const Text('Requests'),
            bottom: TabBar(
              tabs: const [
                Tab(text: 'Out'),
                Tab(text: 'In'),
              ],
              onTap: (value) {
                onTab(value, context, token);
              },
            ),
          ),
          body:  TabBarView(
            children: [
               OutgoingRequest(socket: socket),
              IncomingReuests(socket: socket),
              
              
            ],
          ),
          
        ),
      ),
    );
  }

void onTab(int value, BuildContext context, dynamic token) {
  print('value $value');
  switch(value) {
    case 0:
    Provider.of<AllUsers>(context, listen: false).getRequestUsers(status: 'out', token: token);
    break;
    case 1:
    Provider.of<AllUsers>(context, listen: false).getRequestUsers(status: 'in', token: token);
    break;
  }
}
  }
