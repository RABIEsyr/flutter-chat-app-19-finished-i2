import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/providers/expansipn_open_colse.dart';
import 'package:skidrow_friend/screens/userScreen/user_card.dart';

class UserListTile extends StatefulWidget {
  final String gender;
  final String province;
  final String name;
  final String id;
  final int currentTileSelected;
  final SocketServices socket;
  final Status status;
  final String publicKey;

  const UserListTile(
      {Key? key,
      required this.id,
      required this.gender,
      required this.name,
      required this.province,
      required this.currentTileSelected,
      required this.status,
      required this.socket,
      required this.publicKey,
      })
      : super(key: key);

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  TextEditingController emailController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var token = Provider.of<Auth>(context).token;
    int cSelected = Provider.of<ExpansionOpenClose>(context).selected;

    return ExpansionTile(
      key: Key(widget.currentTileSelected.toString()),
      onExpansionChanged: (newState) {
        
            if (newState) {
              Provider.of<ExpansionOpenClose>(context, listen: false).changeSelecteTile(widget.currentTileSelected);
            } else {
              Provider.of<ExpansionOpenClose>(context, listen: false).changeSelecteTile(-1);

            }
          },
       initiallyExpanded : widget.currentTileSelected == cSelected,
      // contentPadding:
      //     const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border:
                Border(right: BorderSide(width: 1.0, color: Colors.white24))),
        child: widget.gender == 'male'
            ? const Icon(
                MdiIcons.humanMale,
                color: Colors.blue,
              )
            : const Icon(
                MdiIcons.humanFemale,
                color: Colors.purple,
              ),
      ),
      children: [
      if (widget.status == Status.notFriend) Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
          child: 
          TextField(
            controller: emailController,
            keyboardType: TextInputType.visiblePassword,
            autofocus: true,
            style: TextStyle(
              fontSize: 22.0,
              color: Colors.blue,
              decoration: TextDecoration.none,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  setState(() {
                    // widget.socket.sendSocketRequest(token: token?? '', message: 'hello message', toUserId: widget.id);
                    print(widget.currentTileSelected);
                    Provider.of<AllUsers>(context, listen: false)
                        .removeUserAfterSendRequest(
                      index: widget.currentTileSelected,
                      userId: widget.id,
                      token: token?? '',
                      publicKey: widget.publicKey,
                      message: emailController.text,
                      context: context
                    );
                  });
                  print('current user ${widget.id}');
                },
              ),

              hintText: 'Say hi',
              
            ),
            
          ),
          
        ),
        
      ],
      title: Text(
        widget.name,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      subtitle: Row(
        children: <Widget>[
          Icon(Icons.linear_scale, color: Colors.yellowAccent),
          Text(widget.province, style: TextStyle(color: Colors.white))
        ],
      ),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          
    );
  }
}
