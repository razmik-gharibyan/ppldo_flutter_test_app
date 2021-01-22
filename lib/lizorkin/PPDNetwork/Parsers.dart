import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
//import 'package:people_do/graphql/flow.query.data.gql.dart';
import 'package:people_do/lizorkin/graphql/loadme.query.data.gql.dart';
//import 'package:people_do/graphql/schema.schema.gql.dart';

import 'Utils.dart';

enum MessageType { Regular, File, Notification, Unknown }

enum DeliveryStatus { Pended, Sent, Delivered, Read, ReadByAll }

class UserProfileParser {
  String id;
  String firstName = '';
  String lastName = '';
  String avatarUrl = '';
  Rectangle area;

  UserProfileParser(
      {@required this.id,
      @required this.firstName,
      @required this.lastName,
      this.avatarUrl,
      this.area});

  factory UserProfileParser.myProfile($loadMe$result data) {
    if (data is $loadMe$result$asRegisteringUser) {
      throw Exception("Registration is not supported yet");
    }
    var d = data as $loadMe$result$asActiveUser;
    return UserProfileParser(
      id: d.id,
      firstName: d.profile.first_name,
      lastName: d.profile.last_name,
      avatarUrl: d.avatar?.url ?? "" ,
    );
  }

  /*
  UserProfileParser.forChat(this.id,
      $loadFlow$result$edges$node$asChat$users$edges$node chatProfile) {
    firstName = chatProfile.profile.first_name;
    lastName = chatProfile.profile.last_name;
    avatarUrl = chatProfile.avatar?.url;
  }
   */
  static String getFullName(String fName, String lName) {
    return "${fName.trim()} ${lName.trim()}".trim();
  }

  String fullName() {
    return getFullName(firstName, lastName);
  }

  /*
  UserProfileParser.forPrivateChat(this.id,
      $loadFlow$result$edges$node$asPrivateChat$other_id privateProfile) {
    firstName = privateProfile.profile_data.first_name;
    lastName = privateProfile.profile_data.last_name;
    avatarUrl = privateProfile.image?.url;
  }

   */
}

Map<String, String> getBestUserNames(List<UserProfileParser> users) {
  Map<String, String> ret = Map<String, String>();
  Map<String, String> fullNames = Map<String, String>();
  users.forEach((element) {
    fullNames.addAll({
      element.id:
          (element.firstName.trim() + " " + element.lastName.trim()).trim()
    });
  });
  fullNames.addAll({
    LocalSettings().user.id:
    (LocalSettings().user.firstName.trim() + " " + LocalSettings().user.lastName.trim()).trim()
  });
  fullNames.forEach((key, value) {
    var names = value.split(" ");
    if (names.length <= 1) {
      ret.addAll({key: value});
    } else {
      var name = names[0];
      bool nameUpdated = true;
      int needFromLastName = 0;
      while (nameUpdated) {
        nameUpdated = false;
        fullNames.forEach((key2, value2) {
          if (key != key2 && value2.length>=name.length && value2.substring(0, name.length-1) == name) {
            needFromLastName++;
            if (needFromLastName < names[1].length) {
              name = names[0] + " " + names[1].substring(0, needFromLastName);
              nameUpdated = true;
            }
          }
        });
        if (!nameUpdated &&
            needFromLastName < names[1].length &&
            needFromLastName > 0) {
          name += ".";
        }
      }
      ret.addAll({key: name});
    }
  });
  return ret;
}

List<TextSpan> messageToSpan(
    {@required String message,
    @required List<String> mentionedUsers,
    @required List<String> foundLinks,
    @required Map<String, String> bestUserNames,
    @required Function(String url) onUrlTap,
    @required Function(String userId) onUserTap}) {
  List<TextSpan> ret = List<TextSpan>();

  Map<int, String> mentions = mentionedUsers == null
      ? Map<int, String>()
      : Utils.findAllMatches(mentionedUsers, message);

  Map<int, String> links = foundLinks == null
      ? Map<int, String>()
      : Utils.findAllMatches(foundLinks, message);

  int currentPos = 0;
  String commonText = '';
  while (currentPos < message.length) {
    if (mentions.containsKey(currentPos)) {
      final userId = mentions[currentPos].substring(1);
      if (commonText.isNotEmpty) {
        ret.add(TextSpan(
          text: commonText,
          style: TextStyle(color: GlobalVariables.darkBackgroundColor),
        ));
        commonText = '';
      }
      ret.add(TextSpan(
          text: "@" + bestUserNames[mentions[currentPos].substring(1)],
          style: onUserTap == null
              ? TextStyle(color: GlobalVariables.darkBackgroundColor)
              : TextStyle(color: GlobalVariables.userHighlightedColor),
          recognizer: onUserTap == null ? null : (TapGestureRecognizer()
            ..onTap = () {
              onUserTap(userId);
            })));
      currentPos += mentions[currentPos].length;
    } else if (links.containsKey(currentPos)) {
      final linkUrl = links[currentPos];
      if (commonText.isNotEmpty) {
        ret.add(TextSpan(
          text: commonText,
          style: TextStyle(color: GlobalVariables.darkBackgroundColor),
        ));
        commonText = '';
      }
      ret.add(TextSpan(
        text: links[currentPos],
        style: onUrlTap == null
            ? TextStyle(color: GlobalVariables.darkBackgroundColor)
            : TextStyle(color: GlobalVariables.linksColor),
        recognizer: onUrlTap == null ? null : TapGestureRecognizer()
          ..onTap = () {
            onUrlTap(linkUrl);
          },
      ));
      currentPos += links[currentPos].length;
    } else {
      commonText += message[currentPos];
      currentPos++;
    }
  }
  if (commonText.isNotEmpty) {
    ret.add(TextSpan(
      text: commonText,
      style: TextStyle(color: Color(0xFF272C3D)),
    ));
    commonText = '';
  }
  return ret;
}
