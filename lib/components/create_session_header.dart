import 'package:flutter/material.dart';

class CreateSessionHeader extends StatelessWidget implements PreferredSizeWidget {
  const CreateSessionHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(106);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      flexibleSpace: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'ESTIMATION TOOL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 41,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: const Color(0xFFADB5FF),
            ),
          ),
        ),
      ),
    );
  }
}

