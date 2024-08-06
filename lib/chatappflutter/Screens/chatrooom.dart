import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pickker/chatappflutter/callinvite.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _message.addListener(() {
      setState(() {
        _isTextFieldFocused = _message.text.isNotEmpty;
      });
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _message.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    if (imageFile == null) {
      print("No image selected.");
      return;
    }

    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      if (imageUrl.isNotEmpty) {
        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .update({"message": imageUrl});
        print(imageUrl);
      } else {
        print("Image URL is empty after upload.");
      }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      _scrollToBottom(); // Scroll to the bottom after sending a message
    } else {
      print("Enter Some Text");
    }
  }

  Future<void> deleteMessage(String messageId, String senderName) async {
    if (senderName == _auth.currentUser!.displayName) {
      try {
        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(messageId)
            .delete();
      } catch (e) {
        print("Error deleting message: $e");
      }
    } else {
      print("You can only delete your own messages.");
    }
  }

  Future<void> updateMessage(
      String messageId, String updatedMessage, String senderName) async {
    if (senderName == _auth.currentUser!.displayName) {
      try {
        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(messageId)
            .update({"message": updatedMessage});
      } catch (e) {
        print("Error updating message: $e");
      }
    } else {
      print("You can only edit your own messages.");
    }
  }

  void showOptionsDialog(
      BuildContext context, String messageId, String senderName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    editMessageDialog(context, messageId, senderName);
                  },
                  child: Text("Edit"),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    deleteMessage(messageId, senderName);
                    Navigator.of(context).pop();
                  },
                  child: Text("Delete"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void editMessageDialog(
      BuildContext context, String messageId, String senderName) {
    TextEditingController _editController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: "Enter new message"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateMessage(messageId, _editController.text, senderName);
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(widget.userMap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(widget.userMap['name']),
                        Text(
                          snapshot.data!['status'],
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
  onPressed: () async {
    try {
      final currentUser = _auth.currentUser;
      print("Auth Check: Current User is ${currentUser?.email}");

      if (currentUser != null) {
        print("Current user is not null.");
      } else {
        print("Current user is null.");
      }

      if (widget.userMap != null) {
        print("User map is not null.");
      } else {
        print("User map is null.");
      }

      if (currentUser != null && widget.userMap != null) {
        // Print current user email for debugging
        print("Current User Email: ${currentUser.email}");

        if (widget.userMap.containsKey('email') && widget.userMap['email'] != null) {
          // Get userID and userID2 from email prefix
          String userID = currentUser.email!.split('@')[0];
          userID = userID.isNotEmpty ? userID : currentUser.uid; // Fallback to uid if userID is empty

          String userID2 = widget.userMap['email'].split('@')[0];
          userID2 = userID2.isNotEmpty ? userID2 : widget.userMap['email']; // Fallback to email if userID2 is empty

          // Get userName and userName2
          String userName = currentUser.displayName ?? userID;
          String userName2 = widget.userMap['name'] ?? userID2;

          // Debug prints
          print("Initiating call...");
          print("Current User ID: $userID");
          print("User ID 2: $userID2");
          print("Current User Name: $userName");
          print("User Name 2: $userName2");

          ZegoUIKitPrebuiltCallInvitationService().init(
            appID: 330434724,
            appSign: "5d0ef8212c6e545f1db433ab9d076937ca8c2839f32a6c0938e662ad78b31b23",
            userID: userID,
            userName: userName,
            plugins: [ZegoUIKitSignalingPlugin()],
          );

          // Navigate to CallInvite screen and pass userID and userName
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallInvite(
                userID: userID2,
                userName: userName2,
              ),
            ),
          );
        } else {
          print("User map does not contain 'email' or it is null.");
        }
      } else {
        print("Current user or user map is null.");
      }
    } catch (e) {
      print("Error initiating call: $e");
    }
  },
  icon: Icon(Icons.call),
),




IconButton(
  onPressed: () async {
    try {
      final currentUser = _auth.currentUser;
      print("Auth Check: Current User is ${currentUser?.email}");

      if (currentUser != null) {
        print("Current user is not null.");
      } else {
        print("Current user is null.");
      }

      if (widget.userMap != null) {
        print("User map is not null.");
      } else {
        print("User map is null.");
      }

      if (currentUser != null && widget.userMap != null) {
        // Print current user email for debugging
        print("Current User Email: ${currentUser.email}");

        if (widget.userMap.containsKey('email') && widget.userMap['email'] != null) {
          // Get userID and userID2 from email prefix
          String userID = currentUser.email!.split('@')[0];
          userID = userID.isNotEmpty ? userID : currentUser.uid; // Fallback to uid if userID is empty

          String userID2 = widget.userMap['email'].split('@')[0];
          userID2 = userID2.isNotEmpty ? userID2 : widget.userMap['email']; // Fallback to email if userID2 is empty

          // Get userName and userName2
          String userName = currentUser.displayName ?? userID;
          String userName2 = widget.userMap['name'] ?? userID2;

          // Debug prints
          print("Initiating call...");
          print("Current User ID: $userID");
          print("User ID 2: $userID2");
          print("Current User Name: $userName");
          print("User Name 2: $userName2");

          ZegoUIKitPrebuiltCallInvitationService().init(
            appID: 330434724,
            appSign: "5d0ef8212c6e545f1db433ab9d076937ca8c2839f32a6c0938e662ad78b31b23",
            userID: userID,
            userName: userName,
            plugins: [ZegoUIKitSignalingPlugin()],
          );

          // Navigate to CallInvite screen and pass userID and userName
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallVideoInvite(
                userID: userID2,
                userName: userName2,
              ),
            ),
          );
        } else {
          print("User map does not contain 'email' or it is null.");
        }
      } else {
        print("Current user or user map is null.");
      }
    } catch (e) {
      print("Error initiating call: $e");
    }
  },
  icon: Icon(Icons.video_call),
),








                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(
              child: Container(
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context,
                              snapshot.data!.docs[index].id);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 10,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.58,
                      child: TextField(
                        controller: _message,
                        focusNode: FocusNode(),
                        decoration: InputDecoration(
                          suffixIcon: _isTextFieldFocused
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _message.clear();
                                  },
                                )
                              : null,
                          hintText: "Send Message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: () => getImage(),
                    ),
                    // SizedBox(width:0,),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => onSendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context,
      String messageId) {
    return GestureDetector(
      onLongPress: () {
        showOptionsDialog(context, messageId, map['sendby']);
      },
      child: Container(
        width: size.width,
        alignment: map['sendby'] == _auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: map['type'] == "text"
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                ),
                child: Text(
                  map['message'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                height: size.height / 2.5,
                width: size.width / 2,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ShowImage(imageUrl: map['message']),
                      ),
                    );
                  },
                  child: Image.network(
                    map['message'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  ShowImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image"),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
