import 'package:equatable/equatable.dart';
import 'package:notes_app/models/note.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final int index;
  final List<String> visibleTags;
  final List<Note> allNotes;
  final List<Note> visibleNotes;
  final List<String> tags;
  final String? activeTag;
  final NotesStatus status;
  final String? errorMessage;
  final bool isLoading;

  const NotesState({
    required this.index,
    required this.tags,
    required this.visibleTags,
    required this.allNotes,
    required this.visibleNotes,
    required this.activeTag,
    required this.status,
    this.errorMessage,
    required this.isLoading,
  });

  const NotesState.initial() 
    : index = 0,
    tags = const [],
    visibleTags = const [],
    allNotes = const [],
    visibleNotes = const [],
    activeTag = null,
    status = NotesStatus.initial,
    errorMessage = null,
    isLoading = false;

  NotesState copyWith({
    int? index,
    List<String>? tags,
    List<String>? visibleTags,
    List<Note>? allNotes,
    List<Note>? visibleNotes,
    String? activeTag,
    NotesStatus? status,
    String? errorMessage,
    bool? isLoading,
  }) {
    return NotesState(
      index: index ?? this.index,
      tags: tags ?? this.tags,
      visibleTags: visibleTags ?? this.visibleTags,
      allNotes: allNotes ?? this.allNotes,
      visibleNotes: visibleNotes ?? this.visibleNotes,
      activeTag: activeTag ?? this.activeTag,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    index, 
    tags, 
    visibleTags, 
    allNotes, 
    visibleNotes, 
    activeTag, 
    status, 
    errorMessage, 
    isLoading
  ];
}
