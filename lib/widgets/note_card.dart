import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/bloc/notes_bloc.dart';
import 'package:notes_app/models/note.dart';
import '../bloc/notes_event.dart';
import 'add_note_form.dart';
import '../bloc/notes_state.dart';


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
          backgroundColor: Colors.white,
          child: Icon(Icons.edit, color: Colors.green.shade600),
        ),
        const SizedBox(width: 8.0),
        FloatingActionButton(
          onPressed: onDelete,
          mini: true,
          backgroundColor: Colors.green.shade50,
          child: Icon(Icons.delete, color: Colors.green.shade300),
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(0.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
            spreadRadius: 1.0,
          ),
        ],
        border: Border.all(color: Colors.green.shade100, width: 1.0),
      ),
      child: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          // Показуємо повідомлення про успішні операції
          if (state.status == NotesStatus.success) {
            // Повідомлення показуються на головному екрані
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade300,
                      Colors.green.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ActionButtons(
                      onEdit: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return AddNoteForm(id: id);
                          },
                        );
                      },
                      onDelete: () => _showDeleteConfirmation(context),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.0,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14.0,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600),
              const SizedBox(width: 8.0),
              const Text('Підтвердження'),
            ],
          ),
          content: Text('Ви дійсно хочете видалити нотатку "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Скасувати',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                backgroundColor: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(BuildContext context) {
    try {
      BlocProvider.of<NotesBloc>(context, listen: false).add(DeleteNoteEvent(
        Note(
          id: id,
          title: title,
          content: content,
          date: date,
          tags: tags,
        ),
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Нотатку видалено'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка видалення: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }
}
