import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:people_do/lizorkin/ErrorsLog.dart';

class EntityValue<T> extends ValueNotifier<T> {
  EntityValue([T value]) : super(value);
  Type type = T.runtimeType;
}

abstract class Entity with ChangeNotifier {
  Map<String, EntityValue> values = Map<String, EntityValue>();
  String entityName = 'unknown';

  DateTime getLastDate();

  factory Entity.fromJson(String jsonData) {
    try {
      var parsedJson = json.decode(jsonData);
      String jsonType = (parsedJson as Map<String, dynamic>).keys.first;
      Map<String, dynamic> plainJsonData =
          (parsedJson as Map<String, dynamic>).values.first;
      return _makeEntityFromJsonData(plainJsonData, entityByName(jsonType));
    } catch (e) {
      return null;
    }
  }

  void _initEntity();

  void fromJson(String jsonData) {
    fromMap(jsonDecode(jsonData));
  }

  static Entity entityByName(String name) {
    if (name == 'makeOTP') {
      return MakeOTPEntity();
    }
    if (name == 'settings') {
      return ServerSettingsEntity();
    }
    return null;
  }

//  Entity();
  Entity() {
    _initEntity();
  }

  dynamic getValue(String valueName) {
    return values[valueName]?.value;
  }

  List<String> valueNames() {
    return values.keys.toList();
  }

  static Entity _makeEntityFromJsonData(
      Map<String, dynamic> plainJsonData, Entity receiver) {
    receiver.fromMap(plainJsonData);
    return receiver;
  }

  void fromMap(Map<String, dynamic> data) {
    data?.forEach((k, v) {
      try {
        if (values.containsKey(k)) {
          if (values[k] is EntityValue<DateTime>) {
            values[k].value = !(v is String) ? v : DateTime.tryParse(v);
          } else if (values[k].value is EntityValue<double>) {
            values[k].value = !(v is String) ? v : double.tryParse(v);
          } else if (values[k].value is EntityValue<int>) {
            values[k].value = !(v is String) ? v : int.tryParse(v);
          } else {
            values[k].value = v;
          }
        }
      } catch (e) {
        ErrorsLog().addErrorMessage("Error settin value $v for key $k", e.toString());
      }
    });
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = Map<String, dynamic>();
    values.forEach((k, v) => {
          ret.addAll({k: values[k].value})
        });
    return ret;
  }

  String toJson() {
    try {
      Map<String, String> ret = Map<String, String>();
      values.forEach((name, entityValue) {
        if (entityValue is EntityValue<DateTime>) {
          ret.addAll({name: entityValue.value?.toIso8601String()});
        } else {
          ret.addAll({name: entityValue.value?.toString()});
        }
      });
      return jsonEncode(ret);
    } catch (e) {
      return null;
    }
  }
}

abstract class EditableEntity extends Entity {
  EntityValue<bool> changed;

  bool setValue(String valueName, dynamic value) {
    if (values.containsKey(valueName)) {
      values[valueName].value = value;
      changed.value = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void fromMap(Map<String, dynamic> data) {
    if (data.containsKey('_changed')) {
      changed.value = data['_changed'];
    } else {
      changed.value = false;
    }
    super.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = super.toMap();
    ret.addAll({'_changed': changed.value});
    return ret;
  }

  @override
  void _initEntity() {
    changed.value = false;
  }
}

class MakeOTPEntity extends Entity {
  @override
  void _initEntity() {
    entityName = 'makeOTP';
    values = {
      "newUser": EntityValue<bool>(),
      "nextBackoffTime": EntityValue<DateTime>(),
      "oneTimeLogin": EntityValue<String>(),
    };
  }

  @override
  DateTime getLastDate() {
    return getValue("nextBackoffTime");
  }
}

class AuthTokenEntity extends Entity {
  @override
  void _initEntity() {
    entityName = 'AuthToken';
    values = {
      "expiration": EntityValue<int>(),
      "expiration_date": EntityValue<DateTime>(),
      "token": EntityValue<String>(),
    };
  }

  @override
  DateTime getLastDate() {
    return getValue("expiration_date");
  }
  
}

class ServerSettingsEntity extends Entity {
  ServerSettingsEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  DateTime getLastDate() {
    return DateTime.now();
  }

  @override
  void _initEntity() {
    entityName = "settings";
    values = {
      "addressBookSyncInterval": EntityValue<int>(),
      "maxFieldLength": EntityValue<int>(),
      "maxMessageLength": EntityValue<int>(),
      "backendBaseUrl": EntityValue<String>(),
      "frontendBaseUrl": EntityValue<String>(),
      "resizeBaseUrl": EntityValue<String>(),
      "scrapperBaseUrl": EntityValue<String>(),
      "zipperBaseUrl": EntityValue<String>(),
      "typingTimeout": EntityValue<int>(),
      "messageUpdateInterval": EntityValue<int>(),
      "messageDeleteInterval": EntityValue<int>(),
      "chatDeleteInterval": EntityValue<int>(),
      "version": EntityValue<String>(),
    };
  }
}

abstract class BaseMessageEntity extends Entity {

  @override
  DateTime getLastDate() {
    return getValue("timestamp");
  }

  @override
  void _initEntity() {
    entityName = "IMessage";
    //TODO Values list incomplete
    values = {
      "id": EntityValue<int>(),
      "timestamp": EntityValue<DateTime>(),
      "order": EntityValue<double>(),
      "is_favorite": EntityValue<bool>(),
      "is_my": EntityValue<bool>(),
      "chat": EntityValue<BaseChatEntity>(),
      "user": EntityValue<UserEntity>(),
    };
  }
}

class RegularMessageEntity extends BaseMessageEntity{
  RegularMessageEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  void _initEntity() {
    super._initEntity();
    entityName = "RegularMessage";
    //TODO Values list incomplete
    values.addAll({"message": EntityValue<String>(),});
  }
}

abstract class BaseChatEntity extends Entity {


  @override
  void _initEntity() {
    entityName = "IChat";
    //TODO Values list incomplete
    values = {
      "id": EntityValue<int>(),
      "created_at": EntityValue<DateTime>(),
      "sort": EntityValue<double>(),
    };
  }
}

class ChatEntity extends BaseChatEntity {
  ChatEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  DateTime getLastDate() {
    return getValue("created_at");
  }

  @override
  void _initEntity() {
    super._initEntity();
    entityName = "Chat";
    //TODO Values list incomplete
    values.addAll({
      "image": EntityValue<FileEntity>(),
      "caption": EntityValue<String>(),
      "title": EntityValue<String>(),
      //FAKE VALUE:
      "lastMessage": EntityValue<BaseMessageEntity>()
    });
  }
}

class FileEntity extends Entity {
  FileEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  DateTime getLastDate() {
    return getValue("timestamp");
  }

  @override
  void _initEntity() {
    entityName = "File";
    //TODO Values list incomplete
    values = {
      "id": EntityValue<int>(),
      "attached_to": EntityValue<BaseChatEntity>(),
      "image_of_chat": EntityValue<ChatEntity>(),
      "avatar_of": EntityValue<UserEntity>(),
      "key": EntityValue<String>(),
      "timestamp": EntityValue<DateTime>(),
      "url": EntityValue<String>(),
      "file_name": EntityValue<String>(),
      "sort": EntityValue<int>(),
      "content_length": EntityValue<int>(),
      "content_type": EntityValue<String>(),
    };
  }
}

class UserEntity extends Entity {
  UserEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  DateTime getLastDate() {
    return getValue("last_seen");
  }

  @override
  void _initEntity() {
    entityName = "User";
    //TODO Values list incomplete
    values = {
      "id": EntityValue<int>(),
      "is_my": EntityValue<bool>(),
      "is_operator": EntityValue<bool>(),
      "join_date": EntityValue<DateTime>(),
      "last_seen": EntityValue<DateTime>(),
      "online": EntityValue<bool>(),
      "avatar": EntityValue<FileEntity>(),
    };
  }
}

class ReminderEntity extends Entity {
  ReminderEntity({Map<String, dynamic> data}) : super() {
    this.fromMap(data);
  }

  @override
  DateTime getLastDate() {
    return getValue("timestamp");
  }

  @override
  void _initEntity() {
    entityName = "Reminder";
    //TODO Values list incomplete
    values = {
      "id": EntityValue<int>(),
      "is_my": EntityValue<bool>(),
      "checked": EntityValue<bool>(),
      "timestamp": EntityValue<DateTime>(),
      "title": EntityValue<String>(),
      "chat": EntityValue<ChatEntity>(),
      "creator": EntityValue<UserEntity>(),
      "created_at": EntityValue<DateTime>(),
    };
  }
}
