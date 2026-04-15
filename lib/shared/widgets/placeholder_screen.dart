import 'package:flutter/material.dart';

/// A generic placeholder screen shown for routes that are not yet implemented.
///
/// Displays the screen [title] in the AppBar and a centred label in the body
/// so that navigation can be wired up and tested before the real screen exists.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('(coming soon)')),
    );
  }
}
