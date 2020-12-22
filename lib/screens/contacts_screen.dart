import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';
import 'package:ppldo_flutter_test_app/widgets/contacts_search_bar.dart';

class ContactsScreen extends StatefulWidget {

  JSCommunicationBloc _jsCommunicationBloc;

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
                            Spacer(flex: 1,),
                            Icon(Icons.person_add),
                            SizedBox(width: 10.0,),
                            Text("Invite to PPLDO"),
                            Spacer(flex: 10,)
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
                          if (snapshot == null || !snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            );
                          }
                          if (snapshot.data.isEmpty) {
                            return Text("No contacts found on your phone");
                          }
                          return _contactListView(snapshot.data);
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
        return Column(
          children: [
            Divider(thickness: 3,),
            ListTile(
              title: Text(contacts[index].name),
              subtitle: Text(contacts[index].phone),
              trailing: RaisedButton(
                child: Text(
                    "Invite"
                ),
                onPressed: () {
                  widget._jsCommunicationBloc.addContactNumber(contacts[index].phone);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
      itemCount: contacts.length,
      shrinkWrap: true,
    );
  }
}
