import 'package:flutter/cupertino.dart';

class PpldoContact {

  final String id;
  final bool isContact;
  final String name;
  final String phone;
  final String avatarUrl;
  final String avatarKey;

  PpldoContact({
    @required this.name,
    @required this.phone,
    this.id,
    this.isContact,
    this.avatarUrl,
    this.avatarKey
  });

}