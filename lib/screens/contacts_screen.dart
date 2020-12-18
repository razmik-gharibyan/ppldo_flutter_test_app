import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/widgets/contacts_search_bar.dart';

class ContactsScreen extends StatefulWidget {
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
                      child: Row(
                        children: [
                          Spacer(flex: 1,),
                          Icon(Icons.person_add),
                          SizedBox(width: 10.0,),
                          Text("Invite to PPLDO"),
                          Spacer(flex: 10,)
                        ],
                      ),
                    ),
                    Container(
                      height: constraints.maxHeight * 0.76,
                      child: StreamBuilder<List<Contact>>(
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

  Widget _contactListView(List<Contact> contacts) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return Column(
          children: [
            Divider(thickness: 3,),
            ListTile(
              title: Text(contacts[index].displayName),
              subtitle: Text(contacts[index].phones.toList()[0].value),
              trailing: RaisedButton(
                child: Text(
                    "Add"
                ),
                onPressed: () {
                  //TODO call js method
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