import '../models/focus_preset.dart';

abstract class FocusPresetRepository {
  // Save a new focus preset and return its generated ID.
  Future<int> createPreset(FocusPreset preset);

  // Retrieve every saved focus preset.
  Future<List<FocusPreset>> getAllPresets();

  // Retrieve a single preset using its ID.
  Future<FocusPreset?> getPresetById(int id);

  // Update an existing preset.
  // Return the number of rows updated.
  Future<int> updatePreset(FocusPreset preset);

  // Delete a preset by ID.
  // Return the number of rows deleted.
  Future<int> deletePreset(int id);
}
