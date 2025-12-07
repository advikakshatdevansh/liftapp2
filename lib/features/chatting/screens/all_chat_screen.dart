import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liftapp2/utils/constants/image_strings.dart';
import '../../../common/widgets/images/t_circular_image.dart';
import '../controllers/chat_list_controller.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart'; // VITAL: For clean time formatting

// Define a consistent highlight color (Telegram Blue or WhatsApp Green)
const Color kAccentColor = Color(
  0xFF075E54,
); // WhatsApp Green or similar primary color

class AllChatsScreen extends StatelessWidget {
  const AllChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Optional: Add a search icon
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.chats.isEmpty) {
          return const Center(
            child: Text(
              "No chats yet. Start a new conversation!",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.chats.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
          ), // Divider below the avatar
          itemBuilder: (context, index) {
            final chat = controller.chats[index];
            final otherUserId = controller.getOtherUserId(chat);
            final name = controller.getOtherUserName(otherUserId);
            final photo = controller.getOtherUserPhoto(otherUserId);

            // Assume we can check if a chat has unread messages (Dummy check here)
            final unreadCount =
                index % 3; // Example: every 3rd chat has unread messages
            final hasUnread = unreadCount > 0;

            final lastMessageText = chat.lastMessage.isNotEmpty
                ? chat.lastMessage
                : "No messages yet";

            // Format time using intl package
            final timeString = chat.lastMessageTime != null
                ? DateFormat.jm().format(
                    chat.lastMessageTime!,
                  ) // Example: 4:05 PM
                : "";

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 16.0,
              ),

              // 1. Avatar (Leading)
              leading: SizedBox(
                width: 54, // Match original TCircularImage size
                height: 54,
                child: CircleAvatar(
                  backgroundImage: (photo != null && photo.isNotEmpty)
                      ? NetworkImage(photo)
                      : const AssetImage(TImages.tProfileImage)
                            as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),

              // 2. Chat Details (Title & Subtitle)
              title: Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                lastMessageText,
                maxLines: 1, // Reduced to 1 line for cleaner list view
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: hasUnread ? Colors.black87 : Colors.grey[600],
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),

              // 3. Time and Status (Trailing)
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasUnread
                          ? kAccentColor
                          : Colors.grey[600], // Highlight time if unread
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              onTap: () {
                Get.to(
                  () => ChatScreen(
                    chatId: chat.id,
                    currentUserId: controller.currentUserId,
                    otherUserId: otherUserId,
                    otherUserName: name,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
