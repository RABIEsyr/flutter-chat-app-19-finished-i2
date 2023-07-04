import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/crypto/encrypt_decrypt.dart';
import 'package:skidrow_friend/providers/Message.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/widgets/chat/message_bubble.dart';

class Messages extends StatefulWidget {
  String prk;
   Messages({super.key, required this.prk});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
   ScrollController? _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      //      SchedulerBinding.instance.addPostFrameCallback((_) {
      //   _scrollController!.jumpTo(_scrollController!.position.maxScrollExtent);
      // });

    final myId = Provider.of<Auth>(context).userId;

   var scrollStatus = Provider.of<MessageRepo>(context, listen: true).isShouldScroll;
   if (scrollStatus == true) {
    print('scrolling');
    _scrollController?.animateTo(
      _scrollController!.position.minScrollExtent ,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
     Provider.of<MessageRepo>(context, listen: false).setSCrollcontroller(false);
   }
    // final myPrivateKey = Provider.of<Auth>(context).privateKeyEncryptedFromServer;
  // print('fofo $myPrivateKey');
    // Auth authService = Provider.of<Auth>(context, listen: false);
    print('prpr, ${widget.prk}');
    final encrypto = Crypto();

    return Consumer<MessageRepo>(
      builder: (ctx, messages, child) => ListView.builder(
        controller: _scrollController,
         reverse: true,
         shrinkWrap: true,
         
        itemCount: messages.messages.length,
        itemBuilder: (ctx, index) { 
          final reversedIndex = messages.messages.length - 1 - index;
           final item = messages.messages[reversedIndex];
         return MessageBubble(
          isMe: item.fromId == myId,
          message: item.fromId == myId
              ? encrypto.decrypMessage(
                  privateKey: widget.prk,
                  message: item.fromText!)
              : encrypto.decrypMessage(
                  privateKey: widget.prk,
                  message: item.toText!),
          username: 'username',
        );
        }
      ),
    );
  }
}