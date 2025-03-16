import 'package:flutter/material.dart';
class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor; 
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(
        value,
        style: TextStyle(color: valueColor ?? Colors.grey.shade600),
      ),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}