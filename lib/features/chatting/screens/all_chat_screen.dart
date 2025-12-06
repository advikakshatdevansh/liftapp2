import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liftapp2/utils/constants/image_strings.dart';
import '../../../common/widgets/images/t_circular_image.dart';
import '../controllers/chat_list_controller.dart';
import 'chat_screen.dart';

class AllChatsScreen extends StatelessWidget {
  const AllChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    return Scaffold(
      appBar: AppBar(title: Text("All Chats")),
      body: Obx(() {
        if (controller.chats.isEmpty) {
          return const Center(child: Text("No chats yet"));
        }

        return ListView.builder(
          itemCount: controller.chats.length,
          itemBuilder: (context, index) {
            final chat = controller.chats[index];
            final otherUserId = controller.getOtherUserId(chat);
            final name = controller.getOtherUserName(otherUserId);
            final photo = controller.getOtherUserPhoto(otherUserId);

            return ListTile(
              leading: TCircularImage(image: TImages.tProfileImage),
              title: Text(name, style: const TextStyle(fontSize: 16)),
              subtitle: Text(
                chat.lastMessage.isNotEmpty
                    ? chat.lastMessage
                    : "No messages yet",
              ),
              trailing: Text(
                chat.lastMessageTime != null
                    ? "${chat.lastMessageTime!.hour}:${chat.lastMessageTime!.minute.toString().padLeft(2, '0')}"
                    : "",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
