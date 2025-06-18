import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_exceptions.dart';

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
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    note = null;
    id = widget.id;
    
    // Ініціалізуємо дані для редагування
    if (id != null) {
      try {
        final currentState = BlocProvider.of<NotesBloc>(context, listen: false).state;
        final existingNote = currentState.allNotes.firstWhere(
          (note) => note.id == id,
          orElse: () => Note(id: 0, title: '', content: '', date: '', tags: []),
        );
        
        title = existingNote.title;
        content = existingNote.content;
        date = existingNote.date;
        tags = existingNote.tags;
      } catch (e) {
        title = '';
        content = '';
        date = '';
        tags = [];
      }
    } else {
      title = '';
      content = '';
      date = DateTime.now().toString().split(' ')[0]; // Поточна дата
      tags = [];
    }
    
    titleController = TextEditingController(text: title);
    contentController = TextEditingController(text: content);
    dateController = TextEditingController(text: date);
    tagsController = TextEditingController(text: tags?.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      id != null ? 'Редагувати нотатку' : 'Нова нотатка',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20.0),
                
                // Отображение ошибки
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 20.0),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade600, fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Назва нотатки обов\'язкова';
                          }
                          if (value.trim().length < 2) {
                            return 'Назва повинна містити мінімум 2 символи';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Назва нотатки *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade400, width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.title, color: Colors.green.shade600),
                          filled: true,
                          fillColor: Colors.green.shade50,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      
                      TextFormField(
                        controller: contentController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Контент нотатки обов\'язковий';
                          }
                          if (value.trim().length < 5) {
                            return 'Контент повинен містити мінімум 5 символів';
                          }
                          return null;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Контент *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade400, width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.note, color: Colors.green.shade600),
                          filled: true,
                          fillColor: Colors.green.shade50,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      
                      TextFormField(
                        controller: dateController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Дата обов\'язкова';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Дата *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade400, width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.green.shade600),
                          filled: true,
                          fillColor: Colors.green.shade50,
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.green.shade400,
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            dateController.text = date.toString().split(' ')[0];
                          }
                        },
                        readOnly: true,
                      ),
                      const SizedBox(height: 20.0),
                      
                      TextFormField(
                        controller: tagsController,
                        decoration: InputDecoration(
                          labelText: 'Теги (через кому)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.green.shade400, width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.tag, color: Colors.green.shade600),
                          filled: true,
                          fillColor: Colors.green.shade50,
                          hintText: 'наприклад: важливо, робота, особисте',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24.0),
                
                SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                    ),
                    icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                    label: Text(
                      _isSubmitting ? 'Збереження...' : 'Зберегти',
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    // Очищаємо попередню помилку
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final tags = tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final note = Note(
        id: id ?? DateTime.now().millisecondsSinceEpoch,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        date: dateController.text.trim(),
        tags: tags,
      );

      if (id != null) {
        BlocProvider.of<NotesBloc>(context, listen: false).add(EditNoteEvent(note));
      } else {
        BlocProvider.of<NotesBloc>(context, listen: false).add(AddNoteEvent(note));
      }

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(id != null ? 'Нотатку оновлено!' : 'Нотатку збережено!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        if (e is NotesException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = 'Неочікувана помилка: ${e.toString()}';
        }
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
