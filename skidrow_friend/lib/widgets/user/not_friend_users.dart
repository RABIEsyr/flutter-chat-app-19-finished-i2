import 'package:flutter/material.dart';
import 'package:skidrow_friend/providers/all_users.dart';

class NotFriendUser extends StatelessWidget {
  final User user;
  const NotFriendUser({ Key? key, required this.user }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: const SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Outlined Card')),
        ),
    ),
    );
  }
}