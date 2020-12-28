import 'package:flutter/cupertino.dart';

class PpldoContact {

  final String id;
  final bool isContact;
  bool inPPLDO;
  final String rawPhone;
  final String name;
  String phone;
  final String avatarUrl;
  final String avatarKey;

  PpldoContact({
    @required this.name,
    @required this.phone,
    this.id,
    this.isContact,
    this.inPPLDO,
    this.rawPhone,
    this.avatarUrl,
    this.avatarKey
  });

}