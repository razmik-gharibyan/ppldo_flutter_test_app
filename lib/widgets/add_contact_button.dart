import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';

class AddContactButton extends StatefulWidget {
  final ContactsBloc _contactsBloc;
  final String _id;
  final bool _isContact;
  final Function _showSnackBar;

  AddContactButton(this._contactsBloc, this._id, this._isContact, this._showSnackBar);

  @override
  _AddContactButtonState createState() => _AddContactButtonState();
}

class _AddContactButtonState extends State<AddContactButton> {
  bool _isContactAdded;

  @override
  void initState() {
    super.initState();
    // Initialize [_isContactAdded]
    _isContactAdded = widget._isContact;
  }


  @override
  void didUpdateWidget(AddContactButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // [_isContactAdded] is checker in didUpdateWidget method because when updating listView
    // only this and build method are called once again
    _isContactAdded = widget._isContact;
  }

  @override
  Widget build(BuildContext context) {
    final _aspectRatio = MediaQuery.of(context).size.aspectRatio;
    return _isContactAdded
        ? IconButton(
          icon: Icon(
              Icons.check_circle,
              color: Color(0xFF7CB342),
              size: 24.0,
            ),
          onPressed: () {},
        )
        : IconButton(
            icon: Icon(Icons.person_add),
            color: Color(0xFF6D7278),
            iconSize: 24.0,
            onPressed: () async {
              widget._contactsBloc.addContact(widget._id);
              widget._showSnackBar(_aspectRatio);
            },
          );
  }
}
