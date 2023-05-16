import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmess_app/pages/profile_page.dart';
import 'package:tmess_app/pages/search_page.dart';
import 'package:tmess_app/service/auth_service.dart';
import '../helper/helper_function.dart';
import '../service/database_service.dart';
import '../widgets/group_tile.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({Key? key}) : super(key: key);

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  String uid = "";
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  Stream? allGroupsList;

  bool _isLoading = false;
  String groupName = "";
  String imageURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT73s9z2T_I9BOpGKQpuOL2s8ZCNLNwAnmiFb-5Rjky8-nhfNltVnKKKSdRfsmYQQIwkzQ&usqp=CAU";

  @override
  void initState() {
    super.initState();
    gettingUserData();
    gettingAllGroupsList();
  }

  // string manipulation
  String getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getGroupName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  gettingAllGroupsList() {
    DatabaseService().getGroupsList().then((snapshot) {
      setState(() {
        allGroupsList = snapshot;
      });
    });
  }

  //show all groups
  showAllGroups() {
    return StreamBuilder(
      stream: allGroupsList,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.docs.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return GroupTile(
                  groupId: snapshot.data.docs[index]['groupId'],
                  groupName: snapshot.data.docs[index]['groupName'],
                  //admin
                  userName:
                      snapshot.data.docs[index]['admin'].toString().substring(
                            snapshot.data.docs[index]['admin']
                                    .toString()
                                    .indexOf("_") +
                                1,
                          ),
                );
                // return Text("Hello");
              },
            );
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "List Group",
          style: GoogleFonts.alatsi(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
      ),

      body: showAllGroups(),

      // bottomNavigationBar: ,
    );
  }

  // all groups list stored in database

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupId:
                          getGroupId(snapshot.data['groups'][reverseIndex]),
                      groupName:
                          getGroupName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
            height: 20,
          ),
          Text(
            "Don't exist any group yet",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
