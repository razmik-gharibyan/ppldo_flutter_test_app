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
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // -- Init
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
     // -- Init Bloc
    _searchContactsBloc = BlocProvider.of<SearchContactsBloc>(context);
    // -- Init Tools
    _keyboardVisibilityController = KeyboardVisibilityController();
    // -- Start Operations
    _listenForContactsSearch();
    _listenForFocusChange();
    _listenForKeyboardVisibility();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: Icon(
              _focusNode.hasFocus ? Icons.search : Icons.arrow_back,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          suffixIcon: Icon(
            _focusNode.hasFocus ? Icons.close : Icons.search,
            color: Colors.grey,
          ),
          hintText: "Contacts",
        ),
        focusNode: _focusNode,
        onChanged: (String data) => _searchContactsBloc.inSearchContactsController.add(data),
      )
    );
  }

  void _listenForFocusChange() {
    _focusNode.addListener(() {
      setState(() {});
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
    _searchContactsBloc.searchContactsStream.debounce(Duration(milliseconds: 400)).listen((String searchText) {
      print("Searched for contacts");
      final contacts = widget._contactBloc.contacts;
      if (contacts != null && contacts.isNotEmpty) {
        final result = contacts.where((element) =>
            element.name.toLowerCase().contains(searchText.toLowerCase())).toList();
        widget._contactBloc.addContactsToContactsController(result);
      }
    });
  }
}
