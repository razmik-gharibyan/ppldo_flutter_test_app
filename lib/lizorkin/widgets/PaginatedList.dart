import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/PPDNetwork/Helpers.dart';
import 'package:gql/ast.dart';
import 'package:people_do/lizorkin/PPDNetwork/PPDNetwork.dart';
import 'package:people_do/lizorkin/PPDNetwork/QueryBloc.dart';
import 'package:people_do/lizorkin/graphql/schema.schema.gql.dart';
import 'package:tuple/tuple.dart';

import '../LocalSettings.dart';

enum WidgetType { Common, Separator }

class AnimatedWidget<T> {
  final Widget widget;
  final WidgetType type;
  final T element;

  AnimatedWidget(this.widget, this.type, this.element);
}

class ConvertResult<T> {
  ConvertResult(
      {this.list,
      this.hasNextPage,
      this.hasPreviousPage,
      this.nextPageStartCursor,
      this.prevPageEndCursor});

  final List<Cursored<T>> list;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String nextPageStartCursor;
  final String prevPageEndCursor;
}

class PaginatedListWidget<T> extends StatefulWidget {
  final DocumentNode documentNode;
  final Map<String, dynamic> initOptions;
  final Widget Function(T item, T prevItem, T nextItem) itemBuilder;
  final Widget Function(T item) headerBuilder;
  final Widget fetchLoadingBuilder;
  final Widget initLoadingBuilder;
  final ConvertResult<T> Function(Map<String, dynamic> result) resultConverter;
  final Widget emptyListDummy;
  final ImageProvider background;
  final Widget Function(String error) errorWidgetBuilder;
  final bool reversed;
  final bool Function(T item1, T item2) needBreak;
  final bool showFetchButton;
  final bool showToStartButton;


  PaginatedListWidget(
      {Key key,
      @required this.documentNode,
      @required this.initOptions,
      @required this.itemBuilder,
      @required this.resultConverter,
      this.headerBuilder,
      this.fetchLoadingBuilder,
      this.initLoadingBuilder,
      this.emptyListDummy,
      this.background,
      this.errorWidgetBuilder,
      this.reversed = false,
      this.showFetchButton = true,
      this.showToStartButton = true,
      this.needBreak})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaginatedListWidgetState<T>();
}

class _PaginatedListWidgetState<T> extends State<PaginatedListWidget<T>> {
  QueryBloc _query;

  Widget _fetchLoadingBuilder;
  Widget _initLoadingBuilder;
  Widget _emptyListDummy;
  Widget Function(String error) _errorWidgetBuilder;
  bool fetchShown = false;
  bool toStartShown = false;

  final PaginatedList<T> _list;

  bool fetchingNext = false;
  bool fetchingPrev = false;

  _PaginatedListWidgetState() : _list = PaginatedList<T>();

  bool fetching() {
    return fetchingPrev || fetchingNext;
  }

  void dropFetching() {
    fetchingNext = false;
    fetchingNext = false;
  }

  Function(Map<String, dynamic> fetchMoreOptions, bool next) scrollFetchMore;

  bool _globalLoading = true;

  Widget _errorWidget;

  List<PPDDateAnimatedList<T>> _slivers = List<PPDDateAnimatedList<T>>();

  @override
  Widget build(BuildContext context) {
    _slivers.clear();
    if (_slivers.length == 0 && _list.list.length > 0) {
      List<T> currentList;
      _list.list.forEach((element) {
        if (currentList == null) {
          currentList = List<T>();
        }
        if (widget.needBreak(
            currentList.length > 0 ? currentList.last : null, element)) {
          _slivers.add(PPDDateAnimatedList<T>(
            reversed: widget.reversed,
            widgetBuilder: widget.itemBuilder,
            list: ListModel<T>(
                removedItemBuilder: widget.itemBuilder,
                initialItems: currentList),
          ));
          currentList.clear();
        }
        currentList.add(element);
      });
      if (currentList != null && currentList.length > 0) {
        _slivers.add(PPDDateAnimatedList<T>(
          reversed: widget.reversed,
          widgetBuilder: widget.itemBuilder,
          list: ListModel<T>(
              removedItemBuilder: widget.itemBuilder,
              initialItems: currentList),
        ));
      }
    }

    List<Tuple2<Widget, PPDDateAnimatedList<T>>> _showingList =
        List<Tuple2<Widget, PPDDateAnimatedList<T>>>();
    if (fetchingPrev) {
      _showingList.add(Tuple2(_fetchLoadingBuilder, null));
    }
    for (int i = 0; i < _slivers.length; i++) {
      _showingList.add(Tuple2(
          _slivers[i].list.length > 0
              ? widget.headerBuilder(_slivers[i].list[0])
              : null,
          _slivers[i]));
    }
    if (fetchingNext) {
      _showingList.add(Tuple2(_fetchLoadingBuilder, null));
    }
    return Container(
      decoration: widget.background != null
          ? BoxDecoration(
              image: DecorationImage(
                  image: widget.background, repeat: ImageRepeat.repeat))
          : null,
      child: _slivers.length > 0
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                bool nextEdge = scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent;

                bool prevEdge = scrollInfo.metrics.pixels <=
                            scrollInfo.metrics.maxScrollExtent;

                if (!fetching() && nextEdge && _list.hasNextPage) {
                  var vars = {"after": _list.endCursor};
                  scrollFetchMore(vars, true);
                  setState(() {
                    fetchingNext = true;
                  });
                }
                if (!fetching() && prevEdge && _list.hasPreviousPage) {
                  var vars = {"before": _list.startCursor};
                  scrollFetchMore(vars, true);
                  setState(() {
                    fetchingPrev = true;
                  });
                }
                return false;
              },
              child: CustomScrollView(
                reverse: widget.reversed,
                slivers: _showingList
                    .map((e) => SliverStickyHeader(
                          header: e.item1 ??
                              SizedBox(
                                height: 0,
                              ),
                          sliver: e.item2,
                          sticky: true,
                        ))
                    .toList(),
              ))
          : widget.emptyListDummy,
    );
  }

  @override
  void initState() {
    super.initState();

    _fetchLoadingBuilder = widget.fetchLoadingBuilder ??
        Center(
          child: PlatformCircularProgressIndicator(),
        );

    _initLoadingBuilder = widget.initLoadingBuilder ??
        Center(
          child: PlatformCircularProgressIndicator(),
        );

    _errorWidgetBuilder =
        widget.errorWidgetBuilder ?? (e) => Center(child: Text(e));

    _emptyListDummy =
        widget.emptyListDummy ?? Center(child: Text("Список пуст"));

    _query = QueryBloc(
        variables: widget.initOptions, documentNode: widget.documentNode);

    GQLClient().subscription.listen((event) {
      _query.run();
    });

    _query.resultStream.listen((result) {
      if (result == null) {
        if (!_globalLoading && !fetching()) {
          setState(() {
            _globalLoading = true;
          });
        }
        return;
      }

      if (result.hasException) {
        if (GQLClient.getErrorTypes(result.exception.graphqlErrors)
            .contains(ErrorType.BAD_CREDENTIALS)) {
          LocalSettings().token.value = "";
        }
        setState(() {
          _errorWidget = result.exception.graphqlErrors.length > 0
              ? _errorWidgetBuilder(result.exception.graphqlErrors[0].message)
              : _errorWidgetBuilder(result.exception.clientException.message);
        });
        return;
      }

      var converted = widget.resultConverter(result.data);
      setState(() {
        var addingResult = _list.addPage(converted.list,
            hasNextPage: converted.hasNextPage,
            hasPreviousPage: converted.hasPreviousPage,
            nextPageStartCursor: converted.nextPageStartCursor,
            previousPageEndCursor: converted.prevPageEndCursor);
        if (fetching()) {
          dropFetching();
        }
        if (addingResult.item2) {
          _slivers.clear();
        }
        if (_errorWidget != null) {
          _errorWidget = null;
        }
        if (_globalLoading) {
          _globalLoading = false;
        }
      });
    });

    scrollFetchMore = (Map<String, dynamic> options, bool next) {
      _query.fetchMore(options);
    };

    _query.run();
  }
}

class PPDDateAnimatedList<E> extends StatefulWidget {
  final bool reversed;
  final Widget Function(E item, E prevItem, E nextItem) widgetBuilder;
  final ListModel<E> list;
  final state = PPDDateAnimatedListState<E>();

  PPDDateAnimatedList({Key key, this.reversed, this.widgetBuilder, this.list})
      : super(key: key);

  @override
  PPDDateAnimatedListState<E> createState() => state;
}

class PPDDateAnimatedListState<T> extends State<PPDDateAnimatedList<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    super.initState();
    widget.list.listKey = _listKey;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
        key: _listKey,
        initialItemCount: widget.list.length,
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) {
          return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: widget.widgetBuilder(widget.list[index], index>0 ? widget.list[index-1] : null, index<widget.list.length-1 ? widget.list[index+1] : null));
        });
  }
}

class ListModel<E> {
  ListModel({
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems ?? <E>[]);

  GlobalKey<SliverAnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  SliverAnimatedListState get _animatedList => listKey.currentState;

  void removeItem(int index) {
    final E item = _items.removeAt(index);
    if (item != null) {
      _animatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(_items[index], context, animation);
      });
    }
  }

  void insertItem(
    E item, {
    int index = 0,
  }) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  void addItem(E item) {
    _items.add(item);
    _animatedList.insertItem(_items.length - 1);
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
