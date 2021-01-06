import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/extensions/hext_to_color.dart';

class AddContactButton extends StatefulWidget {
  final ContactsBloc _contactsBloc;
  final String _id;
  final bool _isContact;

  AddContactButton(this._contactsBloc, this._id, this._isContact);

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
    return _isContactAdded
        ? IconButton(
          icon: Icon(
              Icons.check_circle_outline,
              color: HexColor.fromHex("6D7278"),
              size: 24,
            ),
          onPressed: () {},
        )
        : IconButton(
            icon: Icon(Icons.add_circle_outline),
            color: HexColor.fromHex("6D7278"),
            iconSize: 24.0,
            onPressed: () async {
              widget._contactsBloc.addContact(widget._id);
            },
          );
  }
}
