import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/add_note_form.dart';
import '../widgets/note_card.dart';
import '../widgets/error_widget.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc(),
      child: MaterialApp(
        title: 'Нотатки',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green.shade300,
          scaffoldBackgroundColor: Colors.green.shade50,
        ),
        home: NotesScreen(),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Завантажуємо нотатки при ініціалізації екрану
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<NotesBloc>(context, listen: false).add(const LoadNotesEvent());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Нотатки',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Фільтр тегів
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state.status == NotesStatus.success && state.tags.isNotEmpty) {
                    final tagsList = state.tags.map((tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag, style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }).toList();

                    tagsList.insert(0, const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Всі теги', style: TextStyle(fontWeight: FontWeight.w500)),
                    ));

                    return Container(
                      margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 18.0, bottom: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade100.withValues(alpha: 0.25),
                            blurRadius: 10.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.green.shade100, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt_rounded, color: Colors.green.shade400, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(14.0),
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green.shade400, size: 28),
                                style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                                items: tagsList,
                                onChanged: (value) {
                                  if (value == null) {
                                    BlocProvider.of<NotesBloc>(context, listen: false).add(const ClearFilterEvent());
                                  } else {
                                    BlocProvider.of<NotesBloc>(context, listen: false).add(FilterByTagEvent(value));
                                  }
                                },
                                value: state.activeTag,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(
                child: BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    // Показуємо повідомлення про помилки
                    if (state.status == NotesStatus.failure && state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: Colors.red.shade600,
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: 'Повторити',
                            textColor: Colors.white,
                            onPressed: () {
                              BlocProvider.of<NotesBloc>(context, listen: false).add(const LoadNotesEvent());
                            },
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    // Стан завантаження
                    if (state.isLoading) {
                      return const LoadingWidget(message: 'Завантаження...');
                    }

                    // Стан помилки
                    if (state.status == NotesStatus.failure && state.errorMessage != null) {
                      return ErrorDisplayWidget(
                        errorMessage: state.errorMessage!,
                        onRetry: () {
                          BlocProvider.of<NotesBloc>(context, listen: false).add(const LoadNotesEvent());
                        },
                        retryButtonText: 'Спробувати знову',
                      );
                    }

                    // Порожній стан
                    if (state.status == NotesStatus.success && state.visibleNotes.isEmpty) {
                      return EmptyStateWidget(
                        message: state.allNotes.isEmpty 
                          ? 'У вас поки немає нотаток.\nСтворіть першу нотатку!'
                          : 'Не знайдено нотаток з вибраним тегом.',
                        icon: state.allNotes.isEmpty ? Icons.note_add : Icons.search_off,
                        onAction: state.allNotes.isEmpty ? () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return const AddNoteForm();
                            },
                          );
                        } : null,
                        actionText: state.allNotes.isEmpty ? 'Додати нотатку' : null,
                      );
                    }

                    // Список нотаток
                    if (state.status == NotesStatus.success && state.visibleNotes.isNotEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: state.visibleNotes.length,
                        itemBuilder: (context, index) {
                          final note = state.visibleNotes[index];
                          return NoteCard(
                            id: note.id,
                            title: note.title,
                            content: note.content,
                            date: note.date,
                            tags: note.tags,
                          );
                        },
                      );
                    }

                    // Початковий стан
                    return const LoadingWidget(message: 'Ініціалізація...');
                  },
                ),
              ),
              // Кнопка додавання нотатки
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  // Ховаємо кнопку під час завантаження або при помилках
                  if (state.isLoading || state.status == NotesStatus.failure) {
                    return const SizedBox.shrink();
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Додати нотатку', style: TextStyle(fontSize: 18.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return const AddNoteForm();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
