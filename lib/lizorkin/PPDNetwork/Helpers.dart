//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:people_do/graphql/chat.query.data.gql.dart';
//import 'package:people_do/widgets/PaginatedList.dart';
import 'package:tuple/tuple.dart';

import 'Utils.dart';

class NotifyListModel<T> extends ChangeNotifier {
  List<T> _items = List<T>();

  List<T> get items => _items;

  void add(T item) {
    _items.add(item);
    notifyListeners();
  }

  void addAll(Iterable<T> items) {
    _items.addAll(items);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class Cursored<T> {
  T data;
  String cursor;

  Cursored(this.cursor, this.data);
}

class PaginatedList<T> {
  List<Cursored<T>> _list = List<Cursored<T>>();

  List<T> get list => _list.map<T>((e) => e.data).toList();

  String get startCursor => _list.isEmpty ? null : _list?.first?.cursor ?? null;

  String get endCursor => _list.isEmpty ? null : _list?.last?.cursor ?? null;
  bool _hasNextPage;

  bool get hasNextPage => (_hasNextPage ?? false);
  bool _hasPreviousPage;

  bool get hasPreviousPage => (_hasPreviousPage ?? false);

  void sortByCursor(List<Cursored<T>> list) {
    list.sort((Cursored<T> a, Cursored<T> b) => b.cursor.compareTo(a.cursor));
  }

  static bool cursorInBounds(
      String cursor, String firstBoundCursor, String lastBoundCursor) {
    if (cursor == null || firstBoundCursor == null || lastBoundCursor == null) {
      return false;
    }
    return (cursor.compareTo(firstBoundCursor) >= 0 &&
            cursor.compareTo(lastBoundCursor) <= 0) ||
        (cursor.compareTo(lastBoundCursor) >= 0 &&
            cursor.compareTo(firstBoundCursor) <= 0);
  }

  PaginatedList();

  void addOrUpdateList(List<Cursored<T>> newList,
      {bool hasNextPage, bool hasPreviousPage}) {
    if (newList.length == 0) {
      return;
    }

    final bool hNP = (hasNextPage ?? false);
    final bool hPP = (hasPreviousPage ?? false);

    sortByCursor(newList);

    final startExists =
        cursorInBounds(newList.first.cursor, startCursor, endCursor);
    final endExists =
        cursorInBounds(newList.last.cursor, startCursor, endCursor);

    if ((!startExists && !endExists) || _list == null) {
      createList(newList, hPP, hNP);
      return;
    }

    if (!startExists) {
      _hasNextPage = hNP;
      int fromIndex = 0;
      int toIndex = newList.lastIndexWhere(
          (element) => element.cursor.compareTo(startCursor) < 0);
      _list.insertAll(0, newList.getRange(fromIndex, toIndex));
    }

    if (!endExists) {
      _hasPreviousPage = hPP;
      int fromIndex = newList
          .indexWhere((element) => element.cursor.compareTo(endCursor) > 0);
      int toIndex = newList.length - 1;
      _list.addAll(newList.getRange(fromIndex, toIndex));
    }
  }

  int _addNextPage(List<Cursored<T>> newList, {bool hasNextPage}) {
    int startIndex = newList.indexWhere(
        (element) => element.cursor.compareTo(_list.last.cursor) < 0);
    if (startIndex >= 0 && startIndex < newList.length - 1) {
      _list.addAll(newList.getRange(startIndex, newList.length));
      this._hasNextPage = hasNextPage;
      return newList.length - startIndex;
    }
    return 0;
  }

  int _insertPrevPage(List<Cursored<T>> newList, {bool hasPrevPage}) {
    int endIndex = newList.lastIndexWhere(
        (element) => element.cursor.compareTo(_list.first.cursor) > 0);
    if (endIndex >= 0 && endIndex < newList.length - 1) {
      _list.insertAll(0, newList.getRange(0, endIndex + 1));
      this._hasPreviousPage = hasPrevPage;
      return endIndex;
    }
    return 0;
  }

  Tuple2<int, bool> addPage(List<Cursored<T>> newList,
      {bool hasNextPage,
      bool hasPreviousPage,
      String nextPageStartCursor,
      String previousPageEndCursor}) {
    if (newList.isEmpty) {
      return Tuple2(0, false);
    }
    sortByCursor(newList);
    if (_list.length > 0 &&
        cursorInBounds(
            previousPageEndCursor, _list.first.cursor, _list.last.cursor)) {
      return Tuple2(_addNextPage(newList, hasNextPage: hasNextPage), false);
    } else if (_list.length > 0 &&
        cursorInBounds(
            nextPageStartCursor, _list.first.cursor, _list.last.cursor)) {
      return Tuple2(
          -_insertPrevPage(newList, hasPrevPage: hasPreviousPage), false);
    }
    _list = newList;
    this._hasPreviousPage = hasPreviousPage;
    this._hasNextPage = hasNextPage;
    return Tuple2(_list.length, true);
  }

  void createList(List<Cursored> newList, bool hPP, bool hNP) {
    _list = newList;
    _hasPreviousPage = hPP;
    _hasNextPage = hNP;
    return;
  }

  void clear() {
    _list.clear();
  }
}

Widget shortMessage({
  String title,
  String text,
  Widget image,
  Function() closeAction,
}) {
  return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(10),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: Border.all(
          color: Colors.black.withAlpha(20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          image,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (closeAction != null)
            PlatformIconButton(
              icon: Icon(Icons.close),
              onPressed: closeAction,
            )
        ],
      ));
}

/*
Widget getMessageImage(
    $loadMessages$result$messages$edges$node_extended message,
    {double size = 40.0}) {
  if (message
      is $loadMessages$result$messages$edges$node_extended$asFileMessage) {
    if (message.file.content_type.startsWith("image")) {
      return SizedBox(
        height: size,
        width: size,
        child: CachedNetworkImage(
          imageUrl: message.file.url,
          placeholder: (BuildContext context, String url) => Center(
            child: PlatformCircularProgressIndicator(),
          ),
          errorWidget: (BuildContext context, String url, dynamic error) =>
              MimeImage(size: size, mimeType: message.file.content_type),
        ),
      );
    } else {
      return MimeImage(size: size, mimeType: message.file.content_type);
    }
  } else {
    return SizedBox(
      height: 0,
      width: 0,
    );
  }
}


String getMessageText($loadMessages$result$messages$edges$node_extended message) {
  if (message
      is $loadMessages$result$messages$edges$node_extended$asFileMessage) {
    if (message.file.content_type.startsWith("image")) {
      return "Изображение";
    } else {
      return message.file.file_name;
    }
  } else if (message
      is $loadMessages$result$messages$edges$node_extended$asRegularMessage) {
    return message.message;
  }
  else {
    return "Сообщение";
  }
}

 */

class MimeImage extends StatelessWidget {
  final double size;
  final String mimeType;

  const MimeImage({
    Key key,
    this.size,
    this.mimeType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            Utils.mimeStringToImageUrl(mimeType),
          ),
        ));
  }
}
