import 'package:equatable/equatable.dart';
import 'package:notes_app/models/note.dart';

class NotesState extends Equatable {
  final int index;
  final List<String> visibleTags;
  final List<Note> allNotes;
  final List<Note> visibleNotes;
  final List<String> tags;
  final String? activeTag;

  const NotesState({
    required this.index,
    required this.tags,
    required this.visibleTags,
    required this.allNotes,
    required this.visibleNotes,
    required this.activeTag,
  });

  const NotesState.initial() 
    : index = 0,
    tags = const [],
    visibleTags = const [],
    allNotes = const [],
    visibleNotes = const [],
    activeTag = null;

  @override
  List<Object?> get props => [index, tags, visibleTags, allNotes, visibleNotes, activeTag];
}
