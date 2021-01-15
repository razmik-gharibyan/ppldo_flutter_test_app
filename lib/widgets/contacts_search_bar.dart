import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/extensions/hext_to_color.dart';
import 'package:stream_transform/stream_transform.dart';

class ContactsSearchBar extends StatefulWidget {
  final ContactsBloc _contactBloc;
  final Function _searchBarActivatedCallback;
  final bool _isSearchBarActive;

  ContactsSearchBar(this._contactBloc, this._searchBarActivatedCallback,
      this._isSearchBarActive);

  @override
  _ContactsSearchBarState createState() => _ContactsSearchBarState();
}

class _ContactsSearchBarState extends State<ContactsSearchBar> {
  // Bloc
  SearchContactsBloc _searchContactsBloc;

  // Tools
  KeyboardVisibilityController _keyboardVisibilityController;

  // Vars
  FocusNode _focusNode;
  TextEditingController _controller;
  bool _isSearchBarActive;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _isSearchBarActive = widget._isSearchBarActive;
    if (_isSearchBarActive) _focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // -- Init Bloc
    _searchContactsBloc = BlocProvider.of<SearchContactsBloc>(context);
    // -- Init Tools
    _keyboardVisibilityController = KeyboardVisibilityController();
    // -- Start Operations
    //_listenForKeyboardVisibility();
    _listenForContactsSearch();
    _listenForFocusChange();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return WillPopScope(
      child: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: HexColor.fromHex("EFEFEF"),
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: _isSearchBarActive
            ? _activeSearchBar(_aspectRatio)
            : _inactiveSearchBar(_aspectRatio),
      ),
      onWillPop: _onBackPressed,
    );
  }

  Widget _activeSearchBar(double aspectRatio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(
                  Icons.search,
                  color: HexColor.fromHex("7D808A"),
                  size: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      height: 1.5,
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: "Search contact",
                      hintStyle: TextStyle(
                        color: HexColor.fromHex("7D808A"),
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    cursorColor: HexColor.fromHex("272C3C"),
                    focusNode: _focusNode,
                    onChanged: (String data) => _searchContactsBloc.inSearchContactsController.add(data),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: HexColor.fromHex("7D808A"),
              size: 24,
            ),
            onPressed: () {
              _unFocusAndShowFullContacts();
            },
          ),
        ),
      ],
    );
  }

  Widget _inactiveSearchBar(double aspectRatio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: HexColor.fromHex("7D808A"),
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((route) => route.settings.name == "/");
                }),
            Text(
              "Contacts",
              style: TextStyle(
                  color: HexColor.fromHex("272C3C"),
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: HexColor.fromHex("7D808A"),
              size: 24,
            ),
            onPressed: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
              setState(() {
                _isSearchBarActive = !_isSearchBarActive;
                widget._searchBarActivatedCallback(_isSearchBarActive);
              });
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _onBackPressed() {
    if (_focusNode.hasFocus) {
      _unFocusAndShowFullContacts();
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _listenForFocusChange() {
    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasFocus) {
          _isSearchBarActive = !_isSearchBarActive;
          widget._searchBarActivatedCallback(_isSearchBarActive);
        }
      });
    });
  }

  void _unFocusAndShowFullContacts() {
    _controller.clear();
    _searchContactsBloc.inSearchContactsController.add(_controller.text);
    _focusNode.unfocus();
  }

  void _listenForKeyboardVisibility() {
    _keyboardVisibilityController.onChange.listen((bool isVisible) {});
  }

  void _listenForContactsSearch() {
    _searchContactsBloc.searchContactsStream
        .debounce(Duration(milliseconds: 400))
        .listen((String searchText) {
      print("Searched for contacts");
      final contacts = widget._contactBloc.contacts;
      if (contacts != null && contacts.isNotEmpty) {
        final result = contacts.where((element) =>
                element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        widget._contactBloc.addContactsToContactsController(result);
      }
    });
  }
}
