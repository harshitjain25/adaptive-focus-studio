import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/focus_preset.dart';
import '../../providers/repository_providers.dart';

class PresetEditorScreen extends ConsumerStatefulWidget {
  final FocusPreset? preset;

  // Optional starting values used by Session Scout.
  final String? initialMood;
  final int? initialDurationMinutes;

  const PresetEditorScreen({
    super.key,
    this.preset,
    this.initialMood,
    this.initialDurationMinutes,
  });

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  String? _selectedMood;
  double _durationMinutes = 25;
  bool _isSaving = false;

  final List<String> _moods = ['Focused', 'Calm', 'Tired', 'Motivated'];

  bool get _isEditing => widget.preset != null;

  @override
  void initState() {
    super.initState();

    final preset = widget.preset;

    if (preset != null) {
      // Editing an existing preset.
      _labelController.text = preset.label;
      _selectedMood = preset.moodTag;
      _durationMinutes = preset.plannedSeconds / 60;
    } else {
      // Creating a new preset.
      // Session Scout may provide the initial mood and duration.
      if (widget.initialMood != null && _moods.contains(widget.initialMood)) {
        _selectedMood = widget.initialMood;
      }

      if (widget.initialDurationMinutes != null) {
        _durationMinutes = widget.initialDurationMinutes!
            .clamp(10, 60)
            .toDouble();
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _savePreset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMood == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(focusPresetRepositoryProvider);

      final preset = FocusPreset(
        id: widget.preset?.id,
        label: _labelController.text.trim(),
        moodTag: _selectedMood!,
        plannedSeconds: _durationMinutes.round() * 60,
      );

      if (_isEditing) {
        final updatedRows = await repository.updatePreset(preset);

        if (updatedRows == 0) {
          throw Exception('Preset could not be updated.');
        }
      } else {
        final newId = await repository.createPreset(preset);

        if (newId <= 0) {
          throw Exception('Preset could not be created.');
        }
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Preset updated successfully.'
                : 'Preset created successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save preset: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Focus Preset' : 'Create Focus Preset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _labelController,
                enabled: !_isSaving,
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
                  return DropdownMenuItem<String>(
                    value: mood,
                    child: Text(mood),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
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
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _durationMinutes = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _savePreset,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Preset' : 'Save Preset'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
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
