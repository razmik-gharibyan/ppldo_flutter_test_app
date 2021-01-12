import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/extensions/hext_to_color.dart';
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
  // -- Tools
  ContactsHelper _contactsHelper;
  ScrollController _scrollController;
  // -- Vars
  bool _isSearchBarActive = false;

  @override
  void initState() {
    super.initState();
    // -- Init Bloc
    _contactsBloc = ContactsBloc();
    // -- Init Tools
    _contactsHelper = ContactsHelper();
    _scrollController = ScrollController();
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
            backgroundColor: Colors.white,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Uncomment this part if you want to unFocus (ie close soft keyboard)
                // when user taps outside of searchBar
                //FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Column(
                children: [
                  _isSearchBarActive ? Container(
                    width: double.infinity,
                    height: constraints.maxHeight * 0.11,
                    child: ContactsSearchBar(_contactsBloc, _searchBarActivatedCallback, _isSearchBarActive)
                  ) : Container(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _isSearchBarActive
                          ? Container()
                          : Container(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.11,
                            child: ContactsSearchBar(_contactsBloc, _searchBarActivatedCallback, _isSearchBarActive),
                          ),
                          Container(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.05,
                            color: HexColor.fromHex("F1F1F1"),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "CONTACTS FROM TELEPHONE BOOK",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: constraints.maxHeight * 0.09,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: HexColor.fromHex("EFEFEF"),
                                  spreadRadius: 0,
                                  blurRadius: 0,
                                  offset: Offset(0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: InkWell(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: Icon(
                                      Icons.person_add,
                                      size: 24,
                                      color: HexColor.fromHex("7D808A"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: Text(
                                      "Invite to PPLDO",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor.fromHex("2D3245")
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                widget._jsCommunicationBloc.addContactNumber("");
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            //height: constraints.maxHeight * 0.715,
                            child: StreamBuilder<List<PpldoContact>>(
                              stream: _contactsBloc.contactsStream,
                              builder: (ctx, snapshot) {
                                final contacts = snapshot.data;
                                if (snapshot == null || !snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactListView(List<PpldoContact> contacts, double aspectRatio) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final contact = contacts[index];
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: contact.avatarUrl == null
                 ? Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: Colors.white.withOpacity(0.4),
                   )
                 : null,
                backgroundImage: contact.avatarUrl != null
                ? NetworkImage(
                  contact.avatarUrl,
                )
                : null,
              ),
              title: Text(
                contact.name,
                style: TextStyle(
                  color: HexColor.fromHex("272C3C"),
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text(
                contact.inPPLDO ? "in PPLDO" : _contactsHelper.e164ToBeautifulInternational(contact.phone),
                style: TextStyle(
                    color: HexColor.fromHex(contact.inPPLDO ? "007AFF" : "7D808A"),
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),
              ),
              trailing: contact.inPPLDO
                  ? _addButton(contact.id, contact.isContact)
                  : _inviteButton(contact.phone)
            ),
            Divider(
              color: HexColor.fromHex("EFEFEF"),
              height: 1 / aspectRatio,
              indent: 74.0,
              thickness: 1,
            ),
          ],
        );
      },
      itemCount: contacts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget _inviteButton(String phone) {
    return IconButton(
        icon: Icon(Icons.person_add),
        color: HexColor.fromHex("7D808A"),
        iconSize: 24,
        onPressed: () {
          widget._jsCommunicationBloc.addContactNumber(phone);
          Navigator.pop(context);
        });
  }

  Widget _addButton(String id, bool isContact) {
    return AddContactButton(_contactsBloc, id, isContact);
  }

  /// This method will be called when search bar will become enabled / disabled
  /// in search bar widget
  void _searchBarActivatedCallback(bool isSearchBarActive) {
    setState(() {
      _isSearchBarActive = isSearchBarActive;
      if (!_isSearchBarActive) {
        // Scroll to start of SingleChildScrollView that have this controller attached
        // to show search bar and invite button, after coming back from active search bar
        _scrollController.jumpTo(0.0,);
      }
    });
  }

}
