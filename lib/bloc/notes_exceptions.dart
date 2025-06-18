/// Користувацькі виключення для застосунку нотаток
class NotesException implements Exception {
  final String message;
  final String? details;

  const NotesException(this.message, [this.details]);

  @override
  String toString() => 'NotesException: $message${details != null ? ' ($details)' : ''}';
}

/// Виключення для помилок завантаження нотаток
class LoadNotesException extends NotesException {
  const LoadNotesException([String? details]) 
    : super('Не удалось загрузити нотатки', details);
}

/// Виключення для помилок збереження нотаток
class SaveNotesException extends NotesException {
  const SaveNotesException([String? details]) 
    : super('Не удалось зберегти нотатку', details);
}

/// Виключення для помилок видалення нотаток
class DeleteNotesException extends NotesException {
  const DeleteNotesException([String? details]) 
    : super('Не удалось видалити нотатку', details);
}

/// Виключення для помилок файлової системи
class FileSystemException extends NotesException {
  const FileSystemException([String? details]) 
    : super('Помилка файлової системи', details);
}

/// Виключення для помилок валідації даних
class ValidationException extends NotesException {
  const ValidationException([String? details]) 
    : super('Помилка валідації даних', details);
} 