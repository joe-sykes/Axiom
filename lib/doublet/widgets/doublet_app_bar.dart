import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/route_names.dart';
import '../../core/providers/core_providers.dart';
import 'about_dialog.dart';

/// Shared AppBar widget used across all screens
class DoubletAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool showBackButton;

  const DoubletAppBar({
    super.key,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return AppBar(
      leading: leading ?? IconButton(
        icon: const Icon(Icons.home),
        onPressed: () => _goHome(context),
        tooltip: 'Back to Axiom',
      ),
      title: GestureDetector(
        onTap: () => _goHome(context),
        child: const MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.linear_scale),
              SizedBox(width: 8),
              Text('DOUBLET'),
            ],
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: [
        Semantics(
          button: true,
          label: 'How to play',
          child: IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showAboutGameDialog(context),
            tooltip: 'How to play',
          ),
        ),
        Semantics(
          button: true,
          label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        ),
        Semantics(
          button: true,
          label: 'Archive',
          child: IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.doubletArchive),
            tooltip: 'Archive',
          ),
        ),
      ],
    );
  }
}
