import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

class NotesProvider extends ChangeNotifier {
  final NotesRepository repository;
  List<Note> _allNotes = [];
  List<Note> _visibleNotes = [];
  List<String> _tags = [];
  String? _activeTag;

  NotesProvider(this.repository) {
    loadNotes();
  }

  List<Note> get allNotes => _allNotes;
  List<Note> get visibleNotes => _visibleNotes;
  List<String> get tags => _tags;
  String? get activeTag => _activeTag;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    isLoading = true;
    try {
      _allNotes = await repository.loadNotes();
      _visibleNotes = _allNotes;
      isLoading = false;
      _extractTags();
      notifyListeners();
    } catch (e) {
      print('Failed to load notes: $e');
    }
  }

  Future<void> deleteNote(Note note) async {
    _allNotes.removeWhere((n) => n.id == note.id);
    _visibleNotes.removeWhere((n) => n.id == note.id);
    await repository.saveNotes(_allNotes);
    _extractTags();
    notifyListeners();
  }

  Future<void> editNote(Note note) async {
    final index = _allNotes.indexWhere((n) => n.id == note.id);
    
    if (index != -1) {
      _allNotes[index] = note;
      await repository.saveNotes(_allNotes);
      _extractTags();
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    _allNotes.add(note);
    if (_activeTag != null || note.tags.contains(_activeTag)) {
      _visibleNotes.add(note);
    }
    await repository.saveNotes(_allNotes);
    _extractTags();
    notifyListeners();
  }

  void filterByTag(String tag) {
    _activeTag = tag;
    _visibleNotes = _allNotes.where((note) => note.tags.contains(tag)).toList();
    notifyListeners();
  }

  void clearFilter() {
    _activeTag = null;
    _visibleNotes = _allNotes;
    notifyListeners();
  }

  void _extractTags() {
    final tagSet = <String>{};
    for (var note in _allNotes) {
      tagSet.addAll(note.tags);
    }
    _tags = tagSet.toList()..sort();
  }
}