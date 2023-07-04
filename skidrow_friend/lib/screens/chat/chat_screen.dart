import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/providers/Message.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/providers/context_change.dart';
import 'package:skidrow_friend/widgets/chat/message.dart';
import 'package:skidrow_friend/widgets/chat/new_message.dart';
import 'package:skidrow_friend/global/currentChatId.dart';

import 'package:skidrow_friend/screens/call_screen/call_screen.dart';

import '../../services/signalling.service.dart';

class ChatScreen extends StatefulWidget {
  
  static const routeName = 'chat_screen';
  String? privateKey;

   ChatScreen({super.key, this.privateKey});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 MessageRepo _myProvider = MessageRepo();
 dynamic incomingSDPOffer;
  @override
  void dispose() {
     
    CurrentChatUserID.userId = null;
    super.dispose();
  }

 @override
  void initState() {
    super.initState();
    
    _myProvider = Provider.of<MessageRepo>(context, listen: false);
     _myProvider.resetMessageList();

     SignallingService.instance.socket!.on("newCall", (data) {
      if (mounted) {
        // set SDP Offer of incoming call
        setState(() => incomingSDPOffer = data);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // bool? isFriend = Provider.of<Auth>(context).isFriend;
    
    var token = Provider.of<Auth>(context, listen: false).token;
    print('toto $token');
    Map<String, dynamic>? arg = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    CurrentChatUserID.userId = arg['id'];
    String username = arg['username'];
    print('args, ${arg}');
    if (arg != null) {
     if (arg['status'] == 'out') {
       Provider.of<MessageRepo>(context, listen: false).getAllMessages(token: token!, userId: arg['id']!);
     } 
     if (arg['status'] == 'in') {
      Provider.of<MessageRepo>(context, listen: false).getAllMessages(token: token!, userId: arg['id']!);
     }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: [
          IconButton(
          icon: Icon(
            Icons.video_call,
            color: Colors.white,
          ),
          onPressed: () {
            print('object111');
            _joinCall(
              callerId: '',
              calleeId: CurrentChatUserID.userId!,
            );
          } 
        )
        ],
      ),
      body: 
      incomingSDPOffer != null ?
              Container(
                child: ListTile(
                  title: Text(
                    "Incoming Call from ${incomingSDPOffer["callerId"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.redAccent,
                        onPressed: () {
                          setState(() => incomingSDPOffer = null);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.greenAccent,
                        onPressed: () {
                          _joinCall(
                            callerId: incomingSDPOffer["callerId"]!,
                             calleeId: 'aaaa', //widget.selfCallerId,
                            offer: incomingSDPOffer["sdpOffer"],
                          );
                        },
                      )
                    ],
                  ),
                ),
              )
              :
      Container(
        child: Column(
          children: [
            Expanded(
              child: Messages(prk: widget.privateKey!),
            ),
           arg['status'] != null ? NewMessage(status: arg['status'], toUserId:  arg['id']!, toPublicKey: arg['toPublicKey']!,) 
           : NewMessage(toPublicKey: 'sssssss', toUserId: 'sssssss'),
          ],
        ),
      ),
    );
  }

  _joinCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
  }) {
    print('NavTo');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
        ),
      ),
    );
  }
}
