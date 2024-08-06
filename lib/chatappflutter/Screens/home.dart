// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pickker/chatappflutter/Screens/chatrooom.dart';
// import 'package:pickker/chatappflutter/groupchat/groupchatscreen.dart';
// import 'package:pickker/chatappflutter/methode.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setStatus("Online");
//   }

//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       setStatus("Online");
//     } else {
//       setStatus("Offline");
//     }
//   }

//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }

//   void onSearch() async {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where("email", isEqualTo: _search.text)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         setState(() {
//           userMap = querySnapshot.docs[0].data() as Map<String, dynamic>?;
//           isLoading = false;
//         });
//         print(userMap);
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         print("No user found");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: Container(
//                 height: size.height / 20,
//                 width: size.height / 20,
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           : Column(
//               children: [
//                 SizedBox(
//                   height: size.height / 20,
//                 ),
//                 Container(
//                   height: size.height / 14,
//                   width: size.width,
//                   alignment: Alignment.center,
//                   child: Container(
//                     height: size.height / 14,
//                     width: size.width / 1.15,
//                     child: TextField(
//                       controller: _search,
//                       decoration: InputDecoration(
//                         hintText: "Search",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: size.height / 50,
//                 ),
//                 ElevatedButton(
//                   onPressed: onSearch,
//                   child: Text("Search"),
//                 ),
//                 SizedBox(
//                   height: size.height / 30,
//                 ),
//                 userMap != null
//                     ? ListTile(
//                         onTap: () {
//                           String roomId = chatRoomId(
//                               _auth.currentUser!.displayName!,
//                               userMap!['name']);

//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => ChatRoom(
//                                 chatRoomId: roomId,
//                                 userMap: userMap!,
//                               ),
//                             ),
//                           );
//                         },
//                         leading: Icon(Icons.account_box, color: Colors.black),
//                         title: Text(
//                           userMap!['name'],
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         subtitle: Text(userMap!['email']),
//                         trailing: Icon(Icons.chat, color: Colors.black),
//                       )
//                     : Container(),
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _firestore.collection('users').snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }

//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }

//                       if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
//                         return Center(child: Text('No users found'));
//                       }

//                       return ListView.builder(
//                         itemCount: snapshot.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           Map<String, dynamic> user =
//                               snapshot.data!.docs[index].data() as Map<String, dynamic>;

//                           return ListTile(
//                             onTap: () {
//                               String roomId = chatRoomId(
//                                   _auth.currentUser!.displayName!,
//                                   user['name']);

//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (_) => ChatRoom(
//                                     chatRoomId: roomId,
//                                     userMap: user,
//                                   ),
//                                 ),
//                               );
//                             },
//                             leading: Icon(Icons.account_box, color: Colors.black),
//                             title: Text(
//                               user['name'],
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             subtitle: Text(user['email']),
//                             trailing: Icon(Icons.chat, color: Colors.black),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.group),
//         onPressed: () => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => GroupChatHomeScreen(),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pickker/chatappflutter/Screens/chatrooom.dart';
// import 'package:pickker/chatappflutter/methode.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     setStatus("Online");
//   }

//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // online
//       setStatus("Online");
//     } else {
//       // offline
//       setStatus("Offline");
//     }
//   }

//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }

//   void onSearch() async {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;

//     setState(() {
//       isLoading = true;
//     });

//     await _firestore
//         .collection('users')
//         .where("email", isEqualTo: _search.text)
//         .get()
//         .then((value) {
//       setState(() {
//         userMap = value.docs[0].data();
//         isLoading = false;
//       });
//       print(userMap);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: Container(
//                 height: size.height / 20,
//                 width: size.height / 20,
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           : Column(
//               children: [
//                 SizedBox(
//                   height: size.height / 20,
//                 ),
//                 Container(
//                   height: size.height / 14,
//                   width: size.width,
//                   alignment: Alignment.center,
//                   child: Container(
//                     height: size.height / 14,
//                     width: size.width / 1.15,
//                     child: TextField(
//                       controller: _search,
//                       decoration: InputDecoration(
//                         hintText: "Search",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: size.height / 50,
//                 ),
//                 ElevatedButton(
//                   onPressed: onSearch,
//                   child: Text("Search"),
//                 ),
//                 SizedBox(
//                   height: size.height / 30,
//                 ),
//                 userMap != null
//                     ? ListTile(
//                         onTap: () {
//                           String roomId = chatRoomId(
//                               _auth.currentUser!.displayName!,
//                               userMap!['name']);

//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => ChatRoom(
//                                 chatRoomId: roomId,
//                                 userMap: userMap!,
//                               ),
//                             ),
//                           );
//                         },
//                         leading: Icon(Icons.account_box, color: Colors.black),
//                         title: Text(
//                           userMap!['name'],
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         subtitle: Text(userMap!['email']),
//                         trailing: Icon(Icons.chat, color: Colors.black),
//                       )
//                     : Container(),
//               ],
//             ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.group),
//       //   onPressed: () => Navigator.of(context).push(
//       //     MaterialPageRoute(
//       //       builder: (_) => GroupChatHomeScreen(),
//       //     ),
//       //   ),
//       // ),
//     );
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pickker/chatappflutter/Screens/chatrooom.dart';
// import 'package:pickker/chatappflutter/methode.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   List<DocumentSnapshot> users = [];
//   bool isLoading = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     setStatus("Online");

//     // Fetch all users from Firestore
//     fetchUsers();
//   }

//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }

//   void fetchUsers() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       QuerySnapshot querySnapshot =
//           await _firestore.collection('users').get();

//       setState(() {
//         users = querySnapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching users: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // online
//       setStatus("Online");
//     } else {
//       // offline
//       setStatus("Offline");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : Column(
//               children: [
//                 SizedBox(height: size.height / 20),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: users.length,
//                     itemBuilder: (context, index) {
//                       var userMap = users[index].data();
//                       // Ensure userMap is not null and is of type Map<String, dynamic>
//                       if (userMap != null &&
//                           userMap is Map<String, dynamic> &&
//                           userMap['email'] != _auth.currentUser!.email) {
//                         return ListTile(
//                           onTap: () {
//                             String roomId = chatRoomId(
//                                 _auth.currentUser!.displayName!,
//                                 userMap['name']);

//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => ChatRoom(
//                                   chatRoomId: roomId,
//                                   userMap: userMap,
//                                 ),
//                               ),
//                             );
//                           },
//                           leading: Icon(Icons.account_box, color: Colors.black),
//                           title: Text(
//                             userMap['name'],
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           subtitle: Text(userMap['email']),
//                           trailing: Icon(Icons.chat, color: Colors.black),
//                         );
//                       } else {
//                         return Container(); // Placeholder or handle null case
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.group),
//       //   onPressed: () => Navigator.of(context).push(
//       //     MaterialPageRoute(
//       //       builder: (_) => GroupChatHomeScreen(),
//       //     ),
//       //   ),
//       // ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pickker/chatappflutter/Screens/chatrooom.dart';
import 'package:pickker/chatappflutter/methode.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = []; // Filtered list based on search
  Map<String, int> messageCountMap = {}; // Map to track message counts
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");

    // Fetch all users from Firestore
    fetchUsers();
  }

  void setStatus(String status) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({"status": status});
  }

  void fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();

      setState(() {
        users = querySnapshot.docs;
        filteredUsers = users; // Initialize filtered users with all users
        isLoading = false;
      });

      // Fetch message counts
      await fetchMessageCounts();
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMessageCounts() async {
    final currentUserUid = _auth.currentUser!.uid;

    try {
      // Initialize message count map
      Map<String, int> tempMessageCountMap = {};

      // Query all chat rooms where current user is a participant
      QuerySnapshot querySnapshot = await _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserUid)
          .get();

      // Iterate through chat rooms to update message count map
      querySnapshot.docs.forEach((doc) {
        List<dynamic> participants = doc['participants'];
        String otherUserId = participants.firstWhere(
          (uid) => uid != currentUserUid,
          orElse: () => '',
        );

        if (otherUserId.isNotEmpty) {
          // Increment message count for this user pair
          tempMessageCountMap.update(otherUserId, (value) => value + 1,
              ifAbsent: () => 1);
        }
      });

      // Set state with updated message count map
      setState(() {
        messageCountMap = tempMessageCountMap;
      });
    } catch (e) {
      print("Error fetching message counts: $e");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

 void searchUsers(String query) {
  List<DocumentSnapshot> matchedUsers = [];

  users.forEach((user) {
    // Explicitly cast user.data() to Map<String, dynamic>
    var userMap = user.data() as Map<String, dynamic>?;

    if (userMap != null &&
        userMap['name'].toString().toLowerCase().contains(query.toLowerCase())) {
      matchedUsers.add(user);
    }
  });

  setState(() {
    filteredUsers = matchedUsers;
  });
}



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(height: size.height / 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      searchUsers(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search for a user...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var userMap = filteredUsers[index].data() as Map<String, dynamic>?;

                      // Ensure userMap is not null and is of type Map<String, dynamic>
                      if (userMap != null &&
                          userMap is Map<String, dynamic> &&
                          userMap['email'] != _auth.currentUser!.email) {
                        String userId = userMap['uid'] as String;
                        int messageCount = messageCountMap[userId] ?? 0;

                        return ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                              _auth.currentUser!.displayName!,
                              userMap['name'] as String,
                            );

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap,
                                ),
                              ),
                            );
                          },
                          leading: Icon(Icons.account_box, color: Colors.black),
                          title: Text(
                            userMap['name'] as String,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(userMap['email'] as String),
                          trailing: messageCount > 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(Icons.chat, color: Colors.black),
                                    Text(
                                      messageCount.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      } else {
                        return Container(); // Placeholder or handle null case
                      }
                    },
                  ),
                ),
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.group),
      //   onPressed: () => Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (_) => GroupChatHomeScreen(),
      //     ),
      //   ),
      // ),
    );
  }
}


