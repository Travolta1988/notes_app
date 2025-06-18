import 'package:flutter/cupertino.dart';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/bloc/notes_exceptions.dart';
import 'dart:convert';
import 'dart:io';

@immutable
abstract class NotesEvent {
  const NotesEvent();

  Future<String> get _localPath async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      throw const FileSystemException('Не удалось отримати шлях до директорії додатку');
    }
  }

  Future<File> get _localFile async {
    try {
      final path = await _localPath;
      return File('$path/notes.json');
    } catch (e) {
      throw const FileSystemException('Не удалось створити файл нотаток');
    }
  }
}

class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();

  Future<List<Note>> loadNotes() async {
    try {
      final file = await _localFile;
      
      if (await file.exists()) {
        try {
          final contents = await file.readAsString();
          final data = json.decode(contents);
          
          if (data is! Map<String, dynamic> || !data.containsKey('notes')) {
            throw const ValidationException('Невірний формат файлу нотаток');
          }
          
          final notesList = data['notes'] as List;
          final notes = notesList.map((noteJson) {
            try {
              return Note.fromJson(noteJson);
            } catch (e) {
              throw ValidationException('Помилка парсингу нотатки: ${e.toString()}');
            }
          }).toList();
          
          return notes;
        } catch (e) {
          if (e is ValidationException) rethrow;
          throw LoadNotesException('Помилка читання файлу: ${e.toString()}');
        }
      } else {
        try {
          await file.writeAsString(json.encode({'notes': []}));
          return [];
        } catch (e) {
          throw LoadNotesException('Не удалось створити файл нотаток: ${e.toString()}');
        }
      }
    } catch (e) {
      if (e is NotesException) rethrow;
      throw LoadNotesException('Неочікувана помилка: ${e.toString()}');
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
    try {
      // Валидация заметки
      if (note.title.trim().isEmpty) {
        throw const ValidationException('Назва нотатки не може бути порожньою');
      }
      
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = json.decode(contents);
      
      if (data is! Map<String, dynamic> || !data.containsKey('notes')) {
        throw const ValidationException('Невірний формат файлу нотаток');
      }
      
      final notes = (data['notes'] as List).map((noteJson) {
        try {
          return Note.fromJson(noteJson);
        } catch (e) {
          throw ValidationException('Помилка парсингу існуючої нотатки: ${e.toString()}');
        }
      }).toList();
      
      notes.add(note);
      final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
      await file.writeAsString(updatedData);
    } catch (e) {
      if (e is NotesException) rethrow;
      throw SaveNotesException('Неочікувана помилка при збереженні: ${e.toString()}');
    }
  }
}

class EditNoteEvent extends NotesEvent {
  final Note note;

  const EditNoteEvent(this.note);

  Future<void> editNote(Note note) async {
    try {
      // Валидация заметки
      if (note.title.trim().isEmpty) {
        throw const ValidationException('Назва нотатки не може бути порожньою');
      }
      
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = json.decode(contents);
      
      if (data is! Map<String, dynamic> || !data.containsKey('notes')) {
        throw const ValidationException('Невірний формат файлу нотаток');
      }
      
      final notes = (data['notes'] as List).map((noteJson) {
        try {
          return Note.fromJson(noteJson);
        } catch (e) {
          throw ValidationException('Помилка парсингу існуючої нотатки: ${e.toString()}');
        }
      }).toList();
      
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index == -1) {
        throw const SaveNotesException('Нотатку не знайдено');
      }
      
      notes[index] = note;
      final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
      await file.writeAsString(updatedData);
    } catch (e) {
      if (e is NotesException) rethrow;
      throw SaveNotesException('Неочікувана помилка при редагуванні: ${e.toString()}');
    }
  }
}

class DeleteNoteEvent extends NotesEvent {
  final Note note;

  const DeleteNoteEvent(this.note);

  Future<void> deleteNote(Note note) async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final data = json.decode(contents);
      
      if (data is! Map<String, dynamic> || !data.containsKey('notes')) {
        throw const ValidationException('Невірний формат файлу нотаток');
      }
      
      final notes = (data['notes'] as List).map((noteJson) {
        try {
          return Note.fromJson(noteJson);
        } catch (e) {
          throw ValidationException('Помилка парсингу існуючої нотатки: ${e.toString()}');
        }
      }).toList();
      
      final initialLength = notes.length;
      notes.removeWhere((n) => n.id == note.id);
      
      if (notes.length == initialLength) {
        throw const DeleteNotesException('Нотатку не знайдено');
      }
      
      final updatedData = json.encode({'notes': notes.map((note) => note.toJson()).toList()});
      await file.writeAsString(updatedData);
    } catch (e) {
      if (e is NotesException) rethrow;
      throw DeleteNotesException('Неочікувана помилка при видаленні: ${e.toString()}');
    }
  }
}
