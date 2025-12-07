import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Assuming you have these models/controllers
import '../controllers/chat_controller.dart';
import '../../../data/models/message_model.dart'; // Assuming you have a MessageModel
// Add this for proper time formatting

// --- Theme Colors ---
const Color kDarkBackground = Colors.transparent; // Primary dark background
const Color kDarkAppBar = Color(
  0xFF212C36,
); // Slightly lighter dark for App Bar/Cards
const Color kSenderBubble = Color(0xFF51B06C); // Telegram sender green/blue
const Color kReceiverBubble = Color(
  0xFF334252,
); // Telegram receiver deep blue-grey
const Color kInputBackground = Color(0xFF23303D); // Input field background

// Custom Painter for the chat bubble "tail"
class ChatBubblePainter extends CustomPainter {
  final Color color;
  final bool isSender;

  ChatBubblePainter(this.color, this.isSender);

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rRect = RRect.fromLTRBAndCorners(
      0,
      0,
      size.width,
      size.height,
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      // Adjusted corner radii for the Telegram style
      bottomLeft: isSender
          ? const Radius.circular(20)
          : const Radius.circular(4),
      bottomRight: isSender
          ? const Radius.circular(4)
          : const Radius.circular(12),
    );

    final Paint paint = Paint()..color = color;
    canvas.drawRRect(rRect, paint);

    // Draw the "tail" triangle
    final Path path = Path();
    if (isSender) {
      path.moveTo(size.width, size.height - 12);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - 12, size.height);
    } else {
      path.moveTo(0, size.height - 12);
      path.lineTo(0, size.height);
      path.lineTo(12, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ChatScreen Widget ---

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController(chatId));
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: kDarkBackground, // Primary Dark Background
      appBar: AppBar(
        title: Text(otherUserName, style: const TextStyle(color: Colors.white)),
        backgroundColor: kDarkAppBar, // Darker App Bar
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true, // Show most recent at the bottom
                itemCount: controller.messages.length,
                padding: const EdgeInsets.only(top: 8),
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMine = msg.senderId == currentUserId;
                  return _buildMessageBubble(msg, isMine, controller);
                },
              ),
            ),
          ),
          // Input Section
          _buildChatInput(controller, textController, currentUserId),
        ],
      ),
    );
  }

  // Helper widget for Message Bubble
  Widget _buildMessageBubble(
    MessageModel msg,
    bool isMine,
    ChatController controller,
  ) {
    final Color bubbleColor = isMine ? kSenderBubble : kReceiverBubble;
    final Alignment alignment = isMine
        ? Alignment.centerRight
        : Alignment.centerLeft;
    // Use the controller to format the timestamp
    final String time = controller.formatTime(
      msg.timestamp,
    ); // Assuming formatTime exists
    if (msg.requestType == MessageType.requestRide) {
      return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                msg.text, // "User requested 1 seat for your ride"
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Only the rider sees the buttons
              if (!isMine)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 1. Create a controller for the input field
                        final TextEditingController upiController =
                            TextEditingController();

                        // 2. Show the Dialog Box
                        Get.defaultDialog(
                          title: "Enter UPI ID",
                          titleStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          content: Column(
                            children: [
                              const Text(
                                "Enter your UPI ID to receive payment from the passenger.",
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: upiController,
                                decoration: const InputDecoration(
                                  hintText: "e.g. 9876543210@ybl",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textConfirm: "Confirm & Accept",
                          textCancel: "Cancel",
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            // 3. Validate and send
                            if (upiController.text.trim().isNotEmpty) {
                              Get.back(); // Close the dialog

                              // Call the controller with BOTH the message and the entered UPI ID
                              controller.acceptRideRequest(
                                msg,
                                upiController.text.trim(),
                              );
                            } else {
                              Get.snackbar(
                                "Required",
                                "Please enter a UPI ID to continue.",
                              );
                            }
                          },
                        );
                      },
                      child: const Text("Accept"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => controller.rejectRideRequest(msg),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: alignment,
      child: Container(
        // Limits the maximum width of the bubble
        constraints: BoxConstraints(maxWidth: Get.width * 0.8),
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          // Adjusted margins to account for the bubble tail positioning
          left: isMine ? 40 : 8,
          right: isMine ? 8 : 40,
        ),
        child: Stack(
          // Keep clipBehavior: Clip.none to allow the tail to draw outside the boundary
          clipBehavior: Clip.none,
          children: [
            // VITAL FIX: Keep IntrinsicWidth for block size fit
            IntrinsicWidth(
              child: Container(
                // Padding reduced to allow time/status to dynamically define the width
                // Increased bottom padding slightly to give time more space from the edge
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  // Use CrossAxisAlignment.end to align the time/status to the bottom
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Message Text: MUST be wrapped in Expanded to allow wrapping
                    Expanded(
                      // Use RichText to combine the message text with a tiny invisible spacer
                      // to help push the time/status out of the way when the text is long.
                      // A simple Text widget works better for plain text display.
                      child: Padding(
                        // Add a small margin to the right of the text
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          msg.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // 2. Time and Status Cluster: Pushed to the far right of the last line
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2.0,
                      ), // Adjust alignment vertically
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                          ],
                          // Keep a tiny bit of final right padding
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CustomPaint for the message tail/pointer
          ],
        ),
      ),
    );
  }

  // Helper widget for Chat Input
  Widget _buildChatInput(
    ChatController controller,
    TextEditingController textController,
    String currentUserId,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 25, top: 8),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                // FIX: Add a border using Border.all
                border: Border.all(
                  color: Colors
                      .grey, // Choose a color for the border (e.g., subtle grey or white54 for dark theme)
                  width: 1.0, // Set the thickness of the border
                ),
              ),

              child: Padding(
                // This handles the space between the rounded container edge and the text
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ), // Keep clean horizontal margin
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Message",
                          hintStyle: TextStyle(color: Colors.white54),

                          // VITAL FIXES: Remove all border states
                          border: InputBorder.none,
                          focusedBorder: InputBorder
                              .none, // Removes the border when the field is focused
                          enabledBorder: InputBorder
                              .none, // Ensures consistency when the field is active but not focused

                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8, 10.0, 8, 10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 4.0),
            child: SizedBox(
              // Define a custom, circular size (e.g., 40x40)
              width: 40.0,
              height: 40.0,
              child: FloatingActionButton(
                // REMOVED: mini: true
                backgroundColor: kSenderBubble,
                foregroundColor: Colors.white,
                onPressed: () {
                  final msg = textController.text.trim();
                  if (msg.isNotEmpty) {
                    controller.sendMessage(msg, currentUserId);
                    textController.clear();
                  } else {
                    // Handle voice message recording if text is empty
                  }
                },
                // VITAL: Increased Icon size for better visual fullness
                child: const Icon(Icons.send, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
