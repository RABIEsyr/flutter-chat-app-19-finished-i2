import 'package:flutter/material.dart';
import 'package:skidrow_friend/model/socket_custom.dart';

import 'package:skidrow_friend/screens/userScreen/user_list_tile.dart';

enum Status {
  notFriend,
  outRequestpending,
  inRequestpending,
  friend
}

class USerCard extends StatelessWidget {
  final String gender;
  final String province;
  final String name;
  final int cardIndex;
  final String id;
  final Status status;
  final SocketServices socket;
  final String publicKey;

  const USerCard(
      {Key? key,
      required this.id,
      required this.gender,
      required this.name,
      required this.province,
      required this.cardIndex,
      required this.status,
      required this.socket,
      required this.publicKey
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: UserListTile(
            id: id,
            gender: gender,
            name: name,
            province: province,
            currentTileSelected: cardIndex,
            status: status,
            socket: socket,
            publicKey: publicKey,),
      ),
    );
  }
}
