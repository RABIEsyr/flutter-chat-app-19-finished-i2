

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class RequestUser extends StatefulWidget {
  final String status;
  const RequestUser({super.key, required this.status});

  @override
  State<RequestUser> createState() => _RequestUserState();
}

class _RequestUserState extends State<RequestUser> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}