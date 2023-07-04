import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/Message.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/screens/chat/chat_screen.dart';
import 'package:skidrow_friend/screens/userScreen/user_card.dart';

class FriendScreen extends StatefulWidget {
  final SocketServices socket;
  const FriendScreen({super.key, required this.socket});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}


class _FriendScreenState extends State<FriendScreen> {

  @override
  void didChangeDependencies() {
    Provider.of<AllUsers>(context, listen: false).getFriends(context: context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var token = Provider.of<Auth>(context,).token;
    return Consumer<AllUsers>(
      builder: (ctx, users, child) => ListView.builder(
        itemCount: users.friends.length,
        itemBuilder: (ctx, index) {
          return  InkWell (
                              onTap: () async{
                                final prefs = await SharedPreferences.getInstance();
                                var extracted  = json.decode(prefs.getString('apiKey')!);

                                
                               String privateKey = extracted['privateKey']!;
                                print('iii $privateKey');
                              
                             await Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) {return ChatScreen(privateKey: privateKey);},
                                    settings: RouteSettings(
                                      arguments: {
                                        'status': 'out',
                                        'id': users.friends[index].userId!,
                                        'toPublicKey': users.friends[index].publicKey!,
                                        'username': users.friends[index].username
                                      }
                                    )
                                  ),
                                );
                              },
                              child: IgnorePointer(
                                child: USerCard(
                                  id: users.friends[index].userId!,
                                  gender: users.friends[index].gender!,
                                  province:
                                      users.friends[index].province!,
                                  name: users.friends[index].username!,
                                  cardIndex: index,
                                  status: Status.friend,
                                  socket: widget.socket,
                                  publicKey: users.friends[index].publicKey!,
                                ),
                              ),
                            );
        },
      ),
    );
  }
}
