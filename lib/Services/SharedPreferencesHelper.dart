import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_app/Models/note.dart';

class SharedPreferencesHelper {
  static const String _notesKey = 'notes';

  static Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    final notes = notesJson.map((json) => Note.fromJson(json)).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  static Future<void> insertNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: note.title,
      content: note.content,
    );

    notes.add(newNote);
    await _saveNotes(notes);
  }

  static Future<void> updateNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();

    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await _saveNotes(notes);
    }
  }

  static Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();

    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
  }

  static Future<void> _saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => note.toJson()).toList();
    await prefs.setStringList(_notesKey, notesJson);
  }
}
