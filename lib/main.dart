import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/notes_repository.dart';
import '../models/notes_provider.dart';
import '../widgets/add_note_form.dart';
import '../widgets/note_card.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  final NotesRepository repository = NotesRepository();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesProvider(repository),
      child: MaterialApp(
        title: 'Нотатки',
        home: NotesScreen(),
      ),
    );
  }
}
class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              if (!notesProvider.isLoading) {
                return DropdownButton<String>(
                  hint: Text('Всі теги'),
                  items: notesProvider.tags.map((tag) {
                    return DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      notesProvider.clearFilter();
                    } else {
                      notesProvider.filterByTag(value);
                    }
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  if (!notesProvider.isLoading) {
                    return ListView.builder(
                      itemCount: notesProvider.visibleNotes.length,
                      itemBuilder: (context, index) {
                        final note = notesProvider.visibleNotes[index];
                        return NoteCard(
                          id: note.id,
                          title: note.title,
                          content: note.content,
                          date: note.date,
                          tags: note.tags,
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (!notesProvider.isLoading) {
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
                            return AddNoteForm(notesProvider);
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
