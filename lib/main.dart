import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/add_note_form.dart';
import '../widgets/note_card.dart';
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
        home: NotesScreen(),
      ),
    );
  }
}
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<NotesBloc>().add(const LoadNotesEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Нотатки',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade300,
        actions: [
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              final tagsList = state.tags.map((tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList();

              if (state.tags.isNotEmpty) {
                tagsList.insert(0, DropdownMenuItem<String>(
                  value: null,
                  child: Text('Всі теги'),
                ));
              }

              return DropdownButton<String>(
                  hint: Text('Вибрати тег'),
                  items: tagsList,
                  onChanged: (value) {
                    if (value == null) {
                      context.read<NotesBloc>().add(const ClearFilterEvent());
                    } else {
                      context.read<NotesBloc>().add(FilterByTagEvent(value));
                    }
                  },
                  value: state.activeTag,
                );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<NotesBloc, NotesState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return ListView.builder(
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
                },
              ),
            ),
            BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Додати нотатку', style: TextStyle(fontSize: 18.0)),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.amber),
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        minimumSize: WidgetStateProperty.all(Size(double.infinity, 50.0)),
                      ),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AddNoteForm();
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
    );
  }
}
