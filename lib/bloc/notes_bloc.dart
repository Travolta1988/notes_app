import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/bloc/notes_event.dart';
import 'package:notes_app/bloc/notes_state.dart';
import 'package:notes_app/bloc/notes_exceptions.dart';
import 'package:notes_app/models/note.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {

  NotesBloc() : super(NotesState.initial()) {

    on<LoadNotesEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: NotesStatus.loading, isLoading: true, errorMessage: null));
        
        final notes = await event.loadNotes();
        final tags = _extractTags(notes);

        emit(state.copyWith(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
          status: NotesStatus.success,
          isLoading: false,
          errorMessage: null,
        ));
      } catch (e) {
        String errorMessage = 'Неочікувана помилка';
        
        if (e is NotesException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Помилка завантаження: ${e.toString()}';
        }
        
        emit(state.copyWith(
          status: NotesStatus.failure,
          isLoading: false,
          errorMessage: errorMessage,
        ));
      }
    });

    on<ClearFilterEvent>((event, emit) {
      emit(state.copyWith(
        index: 0,
        visibleNotes: state.allNotes,
        activeTag: null,
        status: NotesStatus.success,
        errorMessage: null,
      ));
    });

    on<AddNoteEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: NotesStatus.loading, isLoading: true, errorMessage: null));
        
        await event.addNote(event.note);
        final notes = [...state.allNotes, event.note];
        final tags = _extractTags(notes);

        emit(state.copyWith(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
          status: NotesStatus.success,
          isLoading: false,
          errorMessage: null,
        ));
      } catch (e) {
        String errorMessage = 'Неочікувана помилка';
        
        if (e is NotesException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Помилка додавання: ${e.toString()}';
        }
        
        emit(state.copyWith(
          status: NotesStatus.failure,
          isLoading: false,
          errorMessage: errorMessage,
        ));
      }
    });

    on<EditNoteEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: NotesStatus.loading, isLoading: true, errorMessage: null));
        
        await event.editNote(event.note);
        final notes = state.allNotes.map((note) {
          if (note.id == event.note.id) {
            return event.note;
          }
          return note;
        }).toList();
        final tags = _extractTags(notes);

        emit(state.copyWith(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
          status: NotesStatus.success,
          isLoading: false,
          errorMessage: null,
        ));
      } catch (e) {
        String errorMessage = 'Неочікувана помилка';
        
        if (e is NotesException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Помилка редагування: ${e.toString()}';
        }
        
        emit(state.copyWith(
          status: NotesStatus.failure,
          isLoading: false,
          errorMessage: errorMessage,
        ));
      }
    });

    on<DeleteNoteEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: NotesStatus.loading, isLoading: true, errorMessage: null));
        
        await event.deleteNote(event.note);
        final notes = state.allNotes.where((note) => note.id != event.note.id).toList();
        final tags = _extractTags(notes);

        emit(state.copyWith(
          index: 0,
          tags: tags,
          visibleTags: tags,
          allNotes: notes,
          visibleNotes: notes,
          activeTag: null,
          status: NotesStatus.success,
          isLoading: false,
          errorMessage: null,
        ));
      } catch (e) {
        String errorMessage = 'Неочікувана помилка';
        
        if (e is NotesException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Помилка видалення: ${e.toString()}';
        }
        
        emit(state.copyWith(
          status: NotesStatus.failure,
          isLoading: false,
          errorMessage: errorMessage,
        ));
      }
    });

    on<FilterByTagEvent>((event, emit) {
      try {
        final notes = state.allNotes.where((note) => note.tags.contains(event.tag)).toList();

        emit(state.copyWith(
          index: 0,
          visibleNotes: notes,
          activeTag: event.tag,
          status: NotesStatus.success,
          errorMessage: null,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: NotesStatus.failure,
          errorMessage: 'Помилка фільтрації: ${e.toString()}',
        ));
      }
    });
  }

  List<String> _extractTags(List<Note> notes) {
    try {
      final tagSet = <String>{};
      for (var note in notes) {
        tagSet.addAll(note.tags);
      }
      return tagSet.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}
