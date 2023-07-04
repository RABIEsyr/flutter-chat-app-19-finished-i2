import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/model/socket_custom.dart';
import 'package:skidrow_friend/providers/all_users.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/providers/expansipn_open_colse.dart';
import 'package:skidrow_friend/screens/chat/chat_screen.dart';
import 'package:skidrow_friend/screens/userScreen/user_card.dart';

class NotFriendUserScreen extends StatefulWidget {
  final SocketServices socket;
  const NotFriendUserScreen({Key? key, required this.socket}) : super(key: key);

  @override
  State<NotFriendUserScreen> createState() => _NotFriendUserScreenState();
}

class _NotFriendUserScreenState extends State<NotFriendUserScreen> {
  String searchedProvince2 = 'all';

  @override
  Widget build(BuildContext context) {
    var token = Provider.of<Auth>(context).token;
    int sselected = Provider.of<ExpansionOpenClose>(context).selected;

    return Consumer<AllUsers>(
      builder: (ctx, users, child) => Container(
        decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
        child: SingleChildScrollView(
           physics: ScrollPhysics(),
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
                        children: [
                          DropdownButton<String>(
                            dropdownColor: Colors.white24,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            items: <String>['all', 'Damascus', 'Aleppo', 'Homs']
                                .map(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  alignment: AlignmentDirectional.center,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                            value: searchedProvince2,
                            onChanged: (province) {
                              Provider.of<AllUsers>(context, listen: false)
                                  .xProvince = province!;
                              Provider.of<AllUsers>(context, listen: false)
                                  .getAllUsers(token!, province);
                              searchedProvince2 = province;
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SingleChildScrollView(
                   physics: ScrollPhysics(),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: SingleChildScrollView(
                           physics: ScrollPhysics(),
                          // height: double.maxFinite - 100,
                          // width: double.maxFinite,
                          child: ListView.builder(
                             physics: NeverScrollableScrollPhysics(),
                            key: Key('builder ${sselected.toString()}'),
                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: users.allUsers.length,
                            itemBuilder: (ctx, index) {
                
                              return SingleChildScrollView(
                                child: InkWell(
                                 
                                  onLongPress: () {
                                                        //                        print('InkWell2 ${users.allUsers[index].userId}');
                                                        //                       //  Navigator.of(context).pushNamed(ChatScreen.routeName);
                                                        //                       Navigator.push(
                                                        // context,
                                                        // MaterialPageRoute(
                                                        //     builder: (BuildContext context) =>  ChatScreen()));
                                                        //                       setState(() {});
                                  },
                                  child: SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: USerCard(
                                      id: users.allUsers[index].userId!,
                                      gender: users.allUsers[index].gender!,
                                      province: users.allUsers[index].province!,
                                      name: users.allUsers[index].username!,
                                      cardIndex: index,
                                      status: Status.notFriend,
                                      socket: widget.socket,
                                      publicKey: users.allUsers[index].publicKey!
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
