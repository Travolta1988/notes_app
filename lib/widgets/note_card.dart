import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';
import '../models/notes_provider.dart';
import 'package:provider/provider.dart';
import 'add_note_form.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: onEdit,
          mini: true,
          backgroundColor: Colors.black26,
          child: Icon(Icons.edit, color: Colors.amber,),
        ),
        FloatingActionButton(
          onPressed: onDelete,
          mini: true,
          backgroundColor: Colors.black26,
          child: Icon(Icons.delete, color: Colors.amber),
        ),
      ],
    );
  }
}

class NoteCard extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String date;
  final List<String> tags;

  const NoteCard({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(0.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ActionButtons(
                      onEdit: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AddNoteForm(
                              notesProvider,
                              note: Note(
                                id: id,
                                title: title,
                                content: content,
                                date: date,
                                tags: tags,
                              ),
                            );
                          },
                        );
                      },
                      onDelete: () {
                        notesProvider.deleteNote(Note(
                          id: id,
                          title: title,
                          content: content,
                          date: date,
                          tags: tags,
                        ));
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 0,
                      children: tags.map((tag) {
                        return Chip(
                          avatar: Icon(
                            Icons.tag,
                            size: 16.0,
                            color: Colors.grey.shade700,
                          ),
                          label: Text(tag),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
