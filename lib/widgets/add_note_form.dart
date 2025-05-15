import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/notes_provider.dart';

class AddNoteForm extends StatefulWidget {
  final NotesProvider notesProvider;
  final Note? note;
  
  const AddNoteForm(this.notesProvider, {super.key, this.note});
  
  @override
  _AddNoteFormState createState() => _AddNoteFormState();
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
  
  @override
  void initState() {
    super.initState();
    note = widget.note;
    id = note?.id;
    title = note?.title;
    content = note?.content;
    date = note?.date;
    tags = note?.tags;
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

                if (id != null) {
                  widget.notesProvider.editNote(
                    Note(
                      id: id!,
                      title: titleController.text,
                      content: contentController.text,
                      date: dateController.text,
                      tags: tagsController.text.split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList(),
                    )
                  );
                  Navigator.pop(context);
                  return;
                }

                final tags = tagsController.text.split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
                
                widget.notesProvider.addNote(
                  Note(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: titleController.text,
                    content: contentController.text,
                    date: dateController.text,
                    tags: tags,
                  )
                );
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
