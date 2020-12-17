import 'package:flutter/material.dart';
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
    // -- Start Operations
    _listenForContactsSearch();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          suffixIcon: Icon(
            _focusNode.hasFocus ? Icons.close : Icons.search,
            color: Colors.grey,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _focusNode.hasFocus ? Icons.search : Icons.arrow_back,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          hintText: "Contacts",
        ),
        //focusNode: _focusNode,
        onChanged: (String data) => _searchContactsBloc.inSearchContactsController.add(data),
      )
    );
  }

  void _listenForContactsSearch() {
    _searchContactsBloc.searchContactsStream.debounce(Duration(microseconds: 400)).listen((String searchText) {
      final contacts = widget._contactBloc.contacts;
      if (contacts != null && contacts.isNotEmpty) {
        final result = contacts.where((element) => element.displayName.contains(searchText)).toList();
        widget._contactBloc.addToContactsController(result);
      }
    });
  }
}
