import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showCloseButton = false,
    this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          showCloseButton
              ? IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF2D3142)),
                onPressed: onClose ?? () => Navigator.of(context).pop(),
              )
              : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
