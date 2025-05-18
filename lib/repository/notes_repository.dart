import 'dart:convert';
import 'dart:io';
import '../models/note.dart';
import 'package:path_provider/path_provider.dart';

class NotesRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }

  Future<List<Note>> loadNotes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        final notes = (data['notes'] as List).map((note) => (Note.fromJson(note))).toList();
        return notes;
      } else {
        await file.writeAsString(json.encode({'notes': []}));
        return [];
      }
    } catch (e) {
      print('Error loading notes: $e');
      // Return empty list on error
      return [];
    }
  }

  Future<void> addNote(Note note) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final data = json.decode(contents);
    final notes = (data['notes'] as List).map((note) {
      return Note.fromJson(note);
    }).toList();
    notes.add(note);
    json.encode({'notes': notes.map((note) => note.toJson()).toList()});
    await file.writeAsString(data);
  }

  Future<void> saveNotes(List<Note> notes) async {
    final file = await _localFile;
    final data = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
    await file.writeAsString(data);
  }
}
