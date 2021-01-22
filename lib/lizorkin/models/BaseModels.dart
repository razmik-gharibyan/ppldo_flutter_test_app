import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:random_words/random_words.dart';

import '../PPDEntities.dart';

class BaseItemModel {
  final Entity _entity;

  BaseItemModel(this._entity, Function() notifyListener) {
    _entity.addListener(notifyListener);
  }

  dynamic getValue(String valueName) {
    return _entity.values[valueName];
  }
}

abstract class BaseEntityListModel extends ChangeNotifier {
  //TODO For fakes random to be removed
  Random _rnd = Random();

  List<Entity> _list;

  Future<void> init();

  Future<void> getMore({int offset, int length});

  Entity getItem(int index) {
    if (index < 0 || index >= _list.length) {
      return null;
    }
    return _list[index];
  }

  ChatEntity _randomChatEntity(int i) {
    return ChatEntity(data: {
      "id": i,
      "created_at": generateTime(),
      "image": FileEntity(
          data: {"url": "https://source.unsplash.com/random/300×300"}),
      "caption":
          "${adjectives.take(1).first} ${nouns.take(1).first}",
      "title": nouns.take(1).first,
    });
  }

  ReminderEntity _randomReminderEntity(int i, UserEntity creator) {
    return ReminderEntity(data: {
      "id": i,
      "created_at": generateTime(inPast: true),
      "is_my": _rnd.nextBool(),
      "checked": _rnd.nextBool(),
      "timestamp": generateTime(inPast: false),
      "title": nouns.take(1).first,
      "creator": creator,
      "created_at": generateTime(inPast: true),
    });
  }

  UserEntity _randomUserEntity(int i, bool isMy) {
    return UserEntity(data: {
      "id": i,
      "is_my": isMy,
      "is_operator": _rnd.nextBool(),
      "join_date": generateTime(inPast: true),
      "last_seen": generateTime(inPast: true),
      "online": _rnd.nextBool(),
      "avatar": FileEntity(
          data: {"url": "https://source.unsplash.com/random/300×300"}),
    });
  }

  BaseMessageEntity _randomMessageEntity(
      int i, UserEntity user, ChatEntity chat) {
    List<String> words = nouns.take(_rnd.nextInt(10)+1).toList();
    words.addAll(adjectives.take(_rnd.nextInt(11)).toList());
    words.sort((a, b){return _rnd.nextInt(3)-1;});

    return RegularMessageEntity(data: {
      "id": i,
      "timestamp": generateTime(),
      "order": 1.0,
      "is_favorite": _rnd.nextBool(),
      "is_my": _rnd.nextBool(),
      "chat": chat,
      "user": user,
      "message": words.join(" ")
    });
  }

  DateTime generateTime({int hours, bool inPast}) {
    int pastMultiplier = (inPast ?? _rnd.nextBool()) ? -1 : 1;
    return DateTime.now().add(Duration(
        hours: _rnd.nextInt(hours ?? 1000) * pastMultiplier,
        minutes: _rnd.nextInt(60) * pastMultiplier));
  }
}

class FlowList extends BaseEntityListModel {
  List<ChatEntity> _chats = List<ChatEntity>();
  List<BaseMessageEntity> _messages = List<BaseMessageEntity>();
  List<ReminderEntity> _reminders = List<ReminderEntity>();
  List<UserEntity> _users = List<UserEntity>();
  UserEntity me;

  @override
  Future<void> getMore({int offset, int length}) {
    return Future.delayed(Duration(milliseconds: _rnd.nextInt(1000) + 1000),
        () {
      generateMore();
    });
  }

  List<Entity> actualList() {
    List<Entity> ret = List<Entity>();
    _chats.forEach((chat) {
      BaseMessageEntity lastMessage;
      _messages.forEach((message) {
        if (((message.getValue("chat") as ChatEntity)?.getValue("id") ==
                chat.getValue("id")) &&
            (lastMessage == null ||
                ((message.getValue("timestamp") as DateTime)
                    .difference(lastMessage.getValue("timestamp"))
                    .isNegative))) {
          lastMessage = message;
        }
      });
      if (lastMessage != null) {
        ret.add(lastMessage);
      }
    });
    ret.addAll(_reminders);
    ret.sort((a, b) {
      Duration dur = a.getLastDate().difference(b.getLastDate());
      return dur.isNegative ? -1 : dur == Duration.zero ? 0 : 1;
    });
    return ret;
  }

  @override
  Future<void> init() {
    return Future.delayed(Duration(milliseconds: _rnd.nextInt(1000) + 1000),
        () {
      me = _randomUserEntity(0, true);
//      generateMore();
    });
  }

  void generateMore() {
    for (int i = 0; i < 100; i++) {
      _users.add(_randomUserEntity(_users.length, false));
    }
    for (int i = 0; i < 1000; i++) {
      ChatEntity chat = _randomChatEntity(_chats.length);
      for (int a = 0; a < 1000; a++) {
        _messages.add(_randomMessageEntity(_messages.length,
            _rnd.nextBool() ? me : _users[_rnd.nextInt(_users.length)], chat));
      }
      _chats.add(chat);
    }
    for (int i = 0; i < 1000; i++) {
      _reminders.add(_randomReminderEntity(_reminders.length,
          _rnd.nextBool() ? me : _users[_rnd.nextInt(_users.length)]));
    }
  }
}

class ChatsList extends BaseEntityListModel {
  @override
  Future<void> getMore({int offset, int length}) {
    int _offset = offset ?? _list.length;
    int _length = length ?? 10;
    return Future.delayed(Duration(milliseconds: _rnd.nextInt(1000) + 1000),
        () {
      for (int i = _offset; i < _offset + _length; i++) {
        _list.add(_randomChatEntity(i));
      }
    });
  }

  @override
  Future<void> init() {
    _list = List<ChatEntity>();
    return getMore();
  }
//TODO Fake chat

}
