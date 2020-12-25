import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

class ContactsSearchBar extends StatefulWidget {
  final ContactsBloc _contactBloc;

  ContactsSearchBar(this._contactBloc);

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
  bool _isSearchBarActive = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // -- Init Bloc
    _searchContactsBloc = BlocProvider.of<SearchContactsBloc>(context);
    // -- Init Tools
    _keyboardVisibilityController = KeyboardVisibilityController();
    // -- Start Operations
    _listenForContactsSearch();
    _listenForFocusChange();
    _listenForKeyboardVisibility();
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
    return Container(
      padding: const EdgeInsets.all(3.0),
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0 / _aspectRatio)),
        border: Border.all(
          color: Colors.black54,
          width: 0.2 / _aspectRatio,
        )
      ),
      child: _isSearchBarActive ? _activeSearchBar(_aspectRatio) : _inactiveSearchBar(_aspectRatio),
    );
  }

  Widget _activeSearchBar(double aspectRatio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          child: Icon(
            Icons.search,
            color: Colors.black54,
            size: 18.0 / aspectRatio,
          ),
        ),
        Flexible(
          flex: 8,
          child: TextField(
            controller: _controller,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12.0 / aspectRatio,
            ),
            decoration: InputDecoration.collapsed(
              hintText: "Search contact",
              hintStyle: TextStyle(
                color: Colors.black87,
                fontStyle: FontStyle.italic,
                fontSize: 13.0 / aspectRatio,
              ),
            ),
            cursorColor: Colors.lightGreen,
            focusNode: _focusNode,
            onChanged: (String data) => _searchContactsBloc.inSearchContactsController.add(data),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black54,
              size: 18.0 / aspectRatio,
            ),
            onPressed: () {
              _controller.clear();
              _searchContactsBloc.inSearchContactsController.add(_controller.text);
              _focusNode.unfocus();
            },
          ),
        ),
      ],
    );
  }

  Widget _inactiveSearchBar(double aspectRatio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black54,
              size: 18.0 / aspectRatio,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.settings.name == "/");
            }
          ),
        ),
        Expanded(
          flex: 8,
          child: Text(
            "Contacts",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.0 / aspectRatio,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black54,
              size: 18.0 / aspectRatio,
            ),
            onPressed: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
              setState(() {
                _isSearchBarActive = !_isSearchBarActive;
              });
            },
          ),
        ),
      ],
    );
  }

  void _listenForFocusChange() {
    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasFocus) {
          _isSearchBarActive = !_isSearchBarActive;
        }
      });
    });
  }

  void _listenForKeyboardVisibility() {
    _keyboardVisibilityController.onChange.listen((bool isVisible) {
      if (!isVisible) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      }
    });
  }

  void _listenForContactsSearch() {
    _searchContactsBloc.searchContactsStream
        .debounce(Duration(milliseconds: 400))
        .listen((String searchText) {
      print("Searched for contacts");
      final contacts = widget._contactBloc.contacts;
      if (contacts != null && contacts.isNotEmpty) {
        final result = contacts
            .where((element) =>
                element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        widget._contactBloc.addContactsToContactsController(result);
      }
    });
  }
}
