import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skidrow_friend/providers/Message.dart';
import 'package:skidrow_friend/providers/auth.dart';

class NewMessage extends StatefulWidget {
  final String? status;
  final String toUserId;
  final String toPublicKey;
  const NewMessage({super.key, this.status, required this.toUserId, required this.toPublicKey});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    // var token = Provider.of<Auth>(context).token;
    
     var isMyFriend = Provider.of<Auth>(context).isFriend;
    

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                  print('_enteredMessage $_enteredMessage');
                });
              },
            ),
          ),
          widget.status != null ?
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _controller.text.isEmpty ? null : 
            () => _sendMessage(ctx: context, isFriend: isMyFriend),
          )
          :
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _controller.text.isEmpty ? null : () => _sendMessage(ctx: context, isFriend: isMyFriend)
          )
        ],
      ),
    );
  }

  //  _sendMessage({required String token, String? status, bool? isFriend, required BuildContext ctx, required String message})  {
   _sendMessage({required BuildContext ctx, required bool? isFriend})  {
    FocusScope.of(ctx).unfocus();
    print('status33 ${widget.status} , ${widget.toUserId}');

     Provider.of<MessageRepo>(context, listen: false).setSCrollcontroller(true);
   
    if (widget.status != null) {
       if (widget.status == 'in') {
        if (isFriend == false) {
          var token = Provider.of<Auth>(ctx, listen: false).token;
          Provider.of<MessageRepo>(context, listen: false).acceptFriendRequest(
              token: token!,
              userId: widget.toUserId,
              message: _enteredMessage,
              recieverPublicKey: widget.toPublicKey,
              context: context);
        } else if (isFriend == true) {
          var token = Provider.of<Auth>(ctx, listen: false).token;
          Provider.of<MessageRepo>(context, listen: false).repeatRequest(
              token: token!,
              userId: widget.toUserId,
              message: _enteredMessage,
              recieverPublicKey: widget.toPublicKey,
              context: context);
        }
        _controller.clear();
      } else if (widget.status == 'out') {
        var token = Provider.of<Auth>(ctx,listen: false).token;
          Provider.of<MessageRepo>(context, listen: false).repeatRequest(token: token!, userId: widget.toUserId, message: _enteredMessage, recieverPublicKey: widget.toPublicKey, context: context);
           _controller.clear();
         // return;
        }
        
    } else {

    }
     _controller.clear();
     return;
    
    
  }
}