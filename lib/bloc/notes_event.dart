
import 'package:flutter/cupertino.dart';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

@immutable
abstract class NotesEvent {
  const NotesEvent();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }
}

class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();

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
      return [];
    }
  }
}

class ClearFilterEvent extends NotesEvent {
  const ClearFilterEvent();
}

class FilterByTagEvent extends NotesEvent {
  final String tag;

  const FilterByTagEvent(this.tag);
}

class AddNoteEvent extends NotesEvent {
  final Note note;

  const AddNoteEvent(this.note);

  Future<void> addNote(Note note) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final data = json.decode(contents);
    final notes = (data['notes'] as List).map((note) {
      return Note.fromJson(note);
    }).toList();
    notes.add(note);
    final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
    await file.writeAsString(updatedData);
  }
}

class EditNoteEvent extends NotesEvent {
  final Note note;

  const EditNoteEvent(this.note);

  Future<void> editNote(Note note) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final data = json.decode(contents);
    final notes = (data['notes'] as List).map((note) {
      return Note.fromJson(note);
    }).toList();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
      await file.writeAsString(updatedData);
    }
  }
}

class DeleteNoteEvent extends NotesEvent {
  final Note note;

  const DeleteNoteEvent(this.note);

  Future<void> deleteNote(Note note) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final data = json.decode(contents);
    final notes = (data['notes'] as List).map((note) {
      return Note.fromJson(note);
    }).toList();
    notes.removeWhere((n) => n.id == note.id);
    final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
    await file.writeAsString(updatedData);
  }
}
