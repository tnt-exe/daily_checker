import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final shownDate = today.hour < 3
        ? today.subtract(const Duration(days: 1))
        : today;

    return AppBar(
      title: Text('Daily Jobs ${shownDate.toIso8601String().substring(0, 10)}'),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
