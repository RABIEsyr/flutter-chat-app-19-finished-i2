import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/context_change.dart';
import 'package:skidrow_friend/screens/chat/chat_screen.dart';
import 'package:skidrow_friend/screens/userScreen/user_card.dart';

class OutgoingRequest extends StatefulWidget {
  final SocketServices socket;
  const OutgoingRequest({super.key, required this.socket});

  @override
  State<OutgoingRequest> createState() => _OutgoingRequestState();
}

class _OutgoingRequestState extends State<OutgoingRequest> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllUsers>(builder: (ctx, users, child) => Container(
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
                          itemCount: users.outRequestUsers.length,
                          itemBuilder: (ctx, index) {
                            return  InkWell (
                              
                              // behavior: HitTestBehavior.translucent,
                              onTap: () async{
                                // Navigator.push(
                                //      ContexChange.ctx1!,
                                //     MaterialPageRoute(
                                //         builder: (BuildContext context) =>
                                //             ChatScreen()));
                                           
                        //                     Navigator.pop(context);
                        //                     await Navigator.push(
                        // context, MaterialPageRoute(builder: (context) => ChatScreen()));
  
                              // Navigator.push(
                              //        ContexChange.ctx1!,
                              //       MaterialPageRoute(
                              //           builder: (BuildContext context) =>
                              //               ChatScreen()));

                                final prefs = await SharedPreferences.getInstance();
                                var extracted  = json.decode(prefs.getString('apiKey')!);
                               String privateKey = extracted['privateKey']!;
                              Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(privateKey: privateKey,),
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': users.outRequestUsers[index].userId!,
                                        'toPublicKey': users.outRequestUsers[index].publicKey!,
                                        'username': users.outRequestUsers[index].username
                                      }
                                    )
                                  ),
                                );
                              },
                              child: IgnorePointer(
                                child: USerCard(
                                  id: users.outRequestUsers[index].userId!,
                                  gender: users.outRequestUsers[index].gender!,
                                  province:
                                      users.outRequestUsers[index].province!,
                                  name: users.outRequestUsers[index].username!,
                                  cardIndex: index,
                                  status: Status.outRequestpending,
                                  socket: widget.socket,
                                  publicKey: users.outRequestUsers[index].publicKey!,
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
      ),);
  }
}
