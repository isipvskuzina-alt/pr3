import 'package:flutter/material.dart';

void main() => runApp(const NotesApp());

class Note {
  String title;
  String text;
  bool important;

  Note({required this.title, required this.text, this.important = false});
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> notes = [];

  Future<void> _add() async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const EditPage()),
    );
    if (result != null) {
      setState(() => notes.add(result));
    }
  }

  Future<void> _edit(Note note) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditPage(note: note)),
    );
    if (result != null) {
      setState(() {
        note.title = result.title;
        note.text = result.text;
      });
    }
  }

  void _view(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewPage(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: notes.isEmpty
          ? const Center(child: Text('Заметок пока нет'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: ObjectKey(note),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.restore, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      setState(() => note.important = false);
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (_) {
                    setState(() => notes.remove(note));
                  },
                  child: Card(
                    color: note.important ? Colors.amber.shade100 : null,
                    child: InkWell(
                      onTap: () => _view(note),
                      onDoubleTap: () => setState(() => note.important = true),
                      onLongPress: () => _edit(note),
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          note.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: note.important
                            ? const Icon(Icons.star, color: Colors.orange)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ViewPage extends StatelessWidget {
  final Note note;

  const ViewPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(note.text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final Note? note;

  const EditPage({super.key, this.note});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late final TextEditingController titleController;
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    textController = TextEditingController(text: widget.note?.text ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }

  void _save() {
    final title = titleController.text.trim();
    final text = textController.text.trim();
    if (title.isEmpty && text.isEmpty) return;
    Navigator.pop(
      context,
      Note(title: title.isEmpty ? 'Без названия' : title, text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Новая заметка' : 'Редактирование'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Заголовок'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Текст',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
