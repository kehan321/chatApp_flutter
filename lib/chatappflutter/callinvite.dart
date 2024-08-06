import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInvite extends StatefulWidget {
  final String userID;
  final String userName;

  CallInvite({required this.userID, required this.userName});

  @override
  State<CallInvite> createState() => CallInviteState();
}

class CallInviteState extends State<CallInvite> {
  @override
  Widget build(BuildContext context) {
    // Trim the user ID to 1 digit for display purposes
    String trimmedUserID = widget.userID.substring(0, 1);

    return Scaffold(
      body: Padding(  
        padding: const EdgeInsets.all(80.0),
        child: Center(
          child: Container(
            height: 200,
            width: 300,
            child: Column(
              children: [  
                Text("This is user ID (display): $trimmedUserID"),
                Text("This is user name: ${widget.userName}"),
              Text("Press button to make a call"),

                Center(
                  child: ZegoSendCallInvitationButton(
                    isVideoCall: false,
                    resourceID: "zegouikit_call",
                    invitees: [
                      ZegoUIKitUser(id: widget.userID, name: widget.userName), // Use full user ID
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CallVideoInvite extends StatefulWidget {
  final String userID;
  final String userName;

  CallVideoInvite({required this.userID, required this.userName});

  @override
  State<CallVideoInvite> createState() => CallVideoInviteState();
}

class CallVideoInviteState extends State<CallVideoInvite> {
  @override
  Widget build(BuildContext context) {
    // Trim the user ID to 1 digit for display purposes
    String trimmedUserID = widget.userID.substring(0, 1);

    return Scaffold(
    
      body: Stack(
        
        children: [ Positioned(
          top: 290,
          left: 100,
          child: Column(
            children: [
              // Text("This is user ID (display): $trimmedUserID"),
              // Text("This is user name: ${widget.userName}"),
              Text("Press button to make a call"),
              Center(
                child: ZegoSendCallInvitationButton(
                  timeoutSeconds: 15,
                  isVideoCall: true,
                  resourceID: "zegouikit_call",
                  invitees: [
                    ZegoUIKitUser(id: widget.userID, name: widget.userName), // Use full user ID
                  ],
                ),
              ),
            ],
          ),
        ),]
      ),
    );
  }
}


