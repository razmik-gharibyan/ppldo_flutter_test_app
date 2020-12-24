import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';
import 'package:ppldo_flutter_test_app/widgets/contacts_search_bar.dart';

class ContactsScreen extends StatefulWidget {
  final JSCommunicationBloc _jsCommunicationBloc;

  ContactsScreen(this._jsCommunicationBloc);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // -- Bloc
  ContactsBloc _contactsBloc;

  @override
  void initState() {
    super.initState();
    // -- Init Bloc
    _contactsBloc = ContactsBloc();
    // -- Start Operations
    _contactsBloc.getContactList();
  }

  @override
  void dispose() {
    _contactsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchContactsBloc>(
      bloc: SearchContactsBloc(),
      child: LayoutBuilder(
        builder: (c, constraints) => SafeArea(
          child: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.1,
                      child: ContactsSearchBar(_contactsBloc),
                    ),
                    Container(
                      height: constraints.maxHeight * 0.1,
                      child: InkWell(
                        child: Row(
                          children: [
                            Spacer(
                              flex: 1,
                            ),
                            Icon(Icons.person_add),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Invite to PPLDO"),
                            Spacer(
                              flex: 10,
                            )
                          ],
                        ),
                        onTap: () {
                          widget._jsCommunicationBloc.addContactNumber("");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                      height: constraints.maxHeight * 0.76,
                      child: StreamBuilder<List<PpldoContact>>(
                        stream: _contactsBloc.contactsStream,
                        builder: (ctx, snapshot) {
                          final contacts = snapshot.data;
                          if (snapshot == null || !snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            );
                          }
                          if (contacts.isEmpty) {
                            return Text("No contacts found on your phone");
                          }
                          return _contactListView(contacts);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactListView(List<PpldoContact> contacts) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final contact = contacts[index];
        return Column(
          children: [
            Divider(
              thickness: 1,
            ),
            ListTile(
              leading: Icon(Icons.person_rounded,size: 40.0,),
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              trailing: contact.isContact == null
                  ? _inviteButton(contact.phone)
                  : contact.isContact
                      ? null
                      : _addButton(contact.id),
            ),
          ],
        );
      },
      itemCount: contacts.length,
      shrinkWrap: true,
    );
  }

  Widget _inviteButton(String phone) {
    return RaisedButton(
        child: Text("Invite"),
        onPressed: () {
          widget._jsCommunicationBloc.addContactNumber(phone);
          Navigator.pop(context);
        });
  }

  Widget _addButton(String id) {
    return StreamBuilder<bool>(
      stream: _contactsBloc.addContactStream,
      builder: (ct, snapshot) {
        if (!snapshot.hasData) {
          return RaisedButton(
            child: Text("Add"),
            onPressed: () {
              _contactsBloc.addContact(id);
            },
          );
        } else {
          if (snapshot.data) {
            return Text("Contact Added");
          } else {
            return RaisedButton(
              child: Text("Add"),
              onPressed: () {
                _contactsBloc.addContact(id);
              },
            );
          }
        }
      }
    );
  }

}
