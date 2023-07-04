import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/screens/chat/chat_screen.dart';
import 'package:skidrow_friend/screens/userScreen/user_card.dart';

class IncomingReuests extends StatefulWidget {
  final SocketServices socket;
  const IncomingReuests({super.key, required this.socket});

  @override
  State<IncomingReuests> createState() => _IncomingReuestsState();
}

class _IncomingReuestsState extends State<IncomingReuests> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllUsers>(
      builder: (ctx, users, child) => Container(
        decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        height: double.maxFinite - 100,
                        width: double.maxFinite,
                        child: ListView.builder(
                          // key: Key('builder ${sselected.toString()}'),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: users.incomingRequestUsers.length,
                          itemBuilder: (ctx, index) {
                            return InkWell(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                var extracted  = json.decode(prefs.getString('apiKey')!);
                               String privateKey = extracted['privateKey']!;
                                print('iii $privateKey');
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(privateKey: privateKey,),
                                  settings: RouteSettings(
                                      arguments: {
                                        'status': 'in',
                                        'id': users.incomingRequestUsers[index].userId!,
                                        'toPublicKey': users.incomingRequestUsers[index].publicKey!,
                                        'username': users.incomingRequestUsers[index].username
                                      }
                                    )
                                ));
                              },
                              child: IgnorePointer(
                                child: USerCard(
                                  id: users.incomingRequestUsers[index].userId!,
                                  gender: users.incomingRequestUsers[index].gender!,
                                  province:
                                      users.incomingRequestUsers[index].province!,
                                  name: users.incomingRequestUsers[index].username!,
                                  cardIndex: index,
                                  status: Status.outRequestpending,
                                  socket: widget.socket,
                                  publicKey:
                                      users.incomingRequestUsers[index].publicKey!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
