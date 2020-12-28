import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/helper/contacts_helper.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';
import 'package:ppldo_flutter_test_app/widgets/add_contact_button.dart';
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
    final _aspectRatio = MediaQuery.of(context).size.aspectRatio;

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
                            Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 27.0 / _aspectRatio,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              "Invite to PPLDO",
                              style: TextStyle(
                                fontSize: 12.0 / _aspectRatio
                              ),
                            ),
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
                          return _contactListView(contacts, _aspectRatio);
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

  Widget _contactListView(List<PpldoContact> contacts, double aspectRatio) {
    final contactsHelper = ContactsHelper();
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final contact = contacts[index];
        return Column(
          children: [
            Divider(
              height: 1 / aspectRatio,
              indent: 40.0 / aspectRatio,
              endIndent: 10.0 / aspectRatio,
              thickness: 1,
            ),
            ListTile(
              leading: CircleAvatar(
                child: contact.avatarUrl == null
                 ? Icon(
                    Icons.person_rounded,
                    size: 15.0 / aspectRatio,
                   )
                 : null,
                backgroundImage: contact.avatarUrl != null
                ? NetworkImage(
                  contact.avatarUrl,
                )
                : null,
              ),
              title: Text(contact.name),
              subtitle: Text(contact.inPPLDO ? "in PPLDO" : contactsHelper.e164ToBeautifulInternational(contact.phone)),
              trailing: contact.inPPLDO
                  ? _addButton(contact.id, contact.isContact)
                  : _inviteButton(contact.phone)
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

  Widget _addButton(String id, bool isContact) {
    return AddContactButton(_contactsBloc, id, isContact);
  }

}
