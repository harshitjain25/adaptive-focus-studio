import 'package:flutter/material.dart';

class PresetEditorScreen extends StatelessWidget {
  const PresetEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preset Editor'),
      ),
      body: const Center(
        child: Text(
          'Preset Editor',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}