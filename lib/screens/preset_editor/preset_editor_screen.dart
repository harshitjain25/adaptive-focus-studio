import 'package:flutter/material.dart';

class PresetEditorScreen extends StatefulWidget {
  const PresetEditorScreen({super.key});

  @override
  State<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends State<PresetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  String? _selectedMood;
  double _durationMinutes = 25;

  final List<String> _moods = [
    'Focused',
    'Calm',
    'Tired',
    'Motivated',
  ];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _savePreset() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preset is valid and ready to save.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Focus Preset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Preset Name',
                  hintText: 'Example: Machine Learning Study',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a preset name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _selectedMood,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(),
                ),
                items: _moods.map((mood) {
                  return DropdownMenuItem(
                    value: mood,
                    child: Text(mood),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMood = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a mood.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Duration: ${_durationMinutes.round()} minutes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                value: _durationMinutes,
                min: 10,
                max: 60,
                divisions: 10,
                label: '${_durationMinutes.round()} min',
                onChanged: (value) {
                  setState(() {
                    _durationMinutes = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _savePreset,
                child: const Text('Save Preset'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}