import 'package:flutter/cupertino.dart';
import 'package:people_do/model/area.dart';

class PpldoContact {

  final String id;
  bool isContact;
  bool inPPLDO;
  final String rawPhone;
  final String name;
  String phone;
  final String avatarUrl;
  final String avatarKey;
  final Area area;

  PpldoContact({
    @required this.name,
    @required this.phone,
    this.id,
    this.isContact,
    this.inPPLDO,
    this.rawPhone,
    this.avatarUrl,
    this.avatarKey,
    this.area,
  });

}