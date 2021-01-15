import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/search_contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/extensions/hext_to_color.dart';
import 'package:ppldo_flutter_test_app/helper/contacts_helper.dart';
import 'package:ppldo_flutter_test_app/helper/resize_helper.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';
import 'package:ppldo_flutter_test_app/services/avatar_service.dart';
import 'package:ppldo_flutter_test_app/widgets/add_contact_button.dart';
import 'package:ppldo_flutter_test_app/widgets/contacts_search_bar.dart';

import 'package:ppldo_flutter_test_app/globals.dart' as globals;

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _scrollController.dispose();
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
            key: _scaffoldKey,
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
                  // Uncomment this part if you want to scroll search bar when inactive and not when active
                  /*
                  _isSearchBarActive ? Container(
                    width: double.infinity,
                    height: constraints.maxHeight * 0.11,
                    child: ContactsSearchBar(_contactsBloc, _searchBarActivatedCallback, _isSearchBarActive)
                  ) : Container(),
                   */
                  Container(
                      width: double.infinity,
                      height: 64.0,
                      child: ContactsSearchBar(_contactsBloc, _searchBarActivatedCallback, _isSearchBarActive)
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (c, boxConstraints) => NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (cont, value) => [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 32.0,
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
                                _isSearchBarActive ?
                                Container() :
                                Container(
                                  height: 56.0,
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
                                            "Invite",
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
                              ],
                            )
                        )],
                        body: Container(
                            height: boxConstraints.minHeight,
                            child: StreamBuilder<List<PpldoContact>>(
                              stream: _contactsBloc.contactsStream,
                              builder: (ctx, snapshot) {
                                final contacts = snapshot.data;
                                if (snapshot == null || !snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(HexColor.fromHex("7CB342")),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "No one found",
                                      style: TextStyle(
                                        color: HexColor.fromHex("272C3C"),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500
                                      ),
                                    )
                                  );
                                }
                                if (contacts.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "Oops something went wrong, try again later",
                                      style: TextStyle(
                                        color: HexColor.fromHex("272C3C"),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500
                                      ),
                                    )
                                  );
                                }
                                return _contactListView(contacts, _aspectRatio);
                                },
                            ),
                          ),
                        )
                      ),
                    ),
                ],),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactListView(List<PpldoContact> contacts, double aspectRatio) {
    return Scrollbar(
      child: ListView.builder(
        itemBuilder: (ctx, index) {
          final contact = contacts[index];
          return Column(
            children: [
              Container(
                height: 73.0,
                child: ListTile(
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
                        ResizeHelper().getResizedUrlForAvatar(globals.resizeBaseUrl, contact.avatarKey, contact.area),
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
                    contact.inPPLDO ? "Registered" : _contactsHelper.e164ToBeautifulInternational(contact.phone),
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
        //shrinkWrap: true,
        //physics: NeverScrollableScrollPhysics(),
      ),
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
    return AddContactButton(_contactsBloc, id, isContact, _showAddContactSnackBar);
  }

  void _showAddContactSnackBar(double aspectRatio) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds : 2000),
      content: Container(
        height: 20.0 / aspectRatio,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "User added to contacts",
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400
            ),
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating,
    ));
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
