import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/bloc/notes_event.dart';
import 'package:notes_app/bloc/notes_state.dart';
import 'package:notes_app/models/note.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {

  NotesBloc() : super(NotesState.initial()) {

    on<LoadNotesEvent>((event, emit) async {
      final notes = await event.loadNotes();
      final tags = _extractTags(notes);

      emit(
        NotesState(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
        ),
      );
    });

    on<ClearFilterEvent>((event, emit) {
      emit(
        NotesState(
          index: 0,
          tags: state.tags,
          visibleTags: state.tags,
          allNotes: state.allNotes,
          visibleNotes: state.allNotes,
          activeTag: null,
        ),
      );
    });

    on<AddNoteEvent>((event, emit) async {
      await event.addNote(event.note);
      final notes = [...state.allNotes, event.note];
      final tags = _extractTags(notes);

      emit(
        NotesState(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
        ),
      );
      
    });

    on<EditNoteEvent>((event, emit) async {
      await event.editNote(event.note);
      final notes = state.allNotes.map((note) {
        if (note.id == event.note.id) {
          return event.note;
        }
        return note;
      }).toList();
      final tags = _extractTags(notes);

      emit(
        NotesState(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
        ),
      );
    });

    on<DeleteNoteEvent>((event, emit) async {
      await event.deleteNote(event.note);
      final notes = state.allNotes.where((note) => note.id != event.note.id).toList();
      final tags = _extractTags(notes);

      emit(
        NotesState(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
        ),
      );
    });

    on<FilterByTagEvent>((event, emit) {
      final notes = state.allNotes.where((note) => note.tags.contains(event.tag)).toList();

      emit(
        NotesState(
          index: 0,
          tags: state.tags,
          visibleTags: state.tags,
          allNotes: state.allNotes,
          visibleNotes: notes,
          activeTag: event.tag,
        ),
      );
    });
  }

  List<String> _extractTags(List<Note> notes) {
    final tagSet = <String>{};
    for (var note in notes) {
      tagSet.addAll(note.tags);
    }
    return tagSet.toList()..sort();
  }

}
