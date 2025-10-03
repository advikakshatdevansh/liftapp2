import 'package:flutter/material.dart';

class PublishButton extends StatelessWidget {
  const PublishButton({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.05, // Minimal size
        minChildSize: 0.05,
        maxChildSize: 0.05,
        builder: (context, scrollController) {
          return Center(
            child: SizedBox(
              width: 200, // button width
              child: ElevatedButton(
                onPressed: onTap,
                child: const Text("Publish Lift"),
              ),
            ),
          );
        },
      ),
    );
  }
}
