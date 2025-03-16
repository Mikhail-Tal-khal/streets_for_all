import 'package:flutter/material.dart';
import '../models/doctor.dart';

class MessageDialog extends StatelessWidget {
  final Doctor doctor;
  final TextEditingController messageController;
  final VoidCallback onSendPressed;

  const MessageDialog({
    super.key,
    required this.doctor,
    required this.messageController,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Message Dr. ${doctor.name.split(' ')[1]}'),
      content: TextField(
        controller: messageController,
        decoration: const InputDecoration(
          hintText: 'Type your message here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onSendPressed();
          },
          child: const Text('Send'),
        ),
      ],
    );
  }

  // Factory method to show the dialog
  static void show({
    required BuildContext context,
    required Doctor doctor,
    required TextEditingController messageController,
    required VoidCallback onSendPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => MessageDialog(
        doctor: doctor,
        messageController: messageController,
        onSendPressed: onSendPressed,
      ),
    );
  }
}