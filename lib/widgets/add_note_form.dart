import 'package:flutter/material.dart';
import 'package:notes_app/bloc/notes_state.dart';
import '../models/note.dart';
import 'package:provider/provider.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';

class AddNoteForm extends StatefulWidget {
  
  const AddNoteForm({super.key, this.id});
  
  final int? id;
  
  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _formKey = GlobalKey<FormState>();
  late final Note? note;
  late final int? id;
  late final String? title;
  late final String? content;
  late final String? date;
  late final List<String>? tags;
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final TextEditingController dateController;
  late final TextEditingController tagsController;
  
  late final Note _note = context.read<NotesBloc>().state.allNotes.firstWhere(
    (note) {
      return note.id == widget.id;
    },
    orElse: () => NotesState.initial().allNotes.firstWhere(
      (note) => note.id == widget.id,
      orElse: () => Note(id: 0, title: '', content: '', date: '', tags: []),
    ),
  );

  @override
  void initState() {
    super.initState();
    note = null;
    id = widget.id;
    title = _note.title;
    content = _note.content;
    date = _note.date;
    tags = _note.tags;
    titleController = TextEditingController(text: title);
    contentController = TextEditingController(text: content);
    dateController = TextEditingController(text: date);
    tagsController = TextEditingController(text: tags?.join(','));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      height: 500,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.close, color: Colors.black,),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    validator: (value) => value!.isEmpty ? 'Назва нотатки' : null,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      labelText: 'Назва нотатки',
                    ),
                  ),
                  TextFormField(
                    controller: contentController,
                    validator: (value) => value!.isEmpty ? 'Контент' : null,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      labelText: 'Контент',
                    ),
                  ),
                  TextFormField(
                    controller: dateController,
                    validator: (value) => value!.isEmpty ? 'Введіть дату' : null,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      labelText: 'Дата',
                    ),
                  ),
                  TextFormField(
                    controller: tagsController,
                    validator: (value) => value!.isEmpty ? 'Введіть теги' : null,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      labelText: 'Теги (через кому)',
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.amber),
                foregroundColor: WidgetStateProperty.all(Colors.black),
                minimumSize: WidgetStateProperty.all(Size(double.infinity, 50.0)),
              ),
              icon: Icon(Icons.save),
              label: Text('Зберегти', style: TextStyle(fontSize: 18.0),),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Нотатку збережено')),
                  );
                } else {
                  return;
                }

                final tags = tagsController.text.split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                if (id != null) {
                  context.read<NotesBloc>().add(EditNoteEvent(
                    Note(
                      id: id!,
                      title: titleController.text,
                      content: contentController.text,
                      date: dateController.text,
                      tags: tags,
                    )
                  ));
                  Navigator.pop(context);
                  return;
                }

                context.read<NotesBloc>().add(AddNoteEvent(
                  Note(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: titleController.text,
                    content: contentController.text,
                    date: dateController.text,
                    tags: tags,
                  )
                ));
                
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    dateController.dispose();
    tagsController.dispose();
    super.dispose();
  }
}
