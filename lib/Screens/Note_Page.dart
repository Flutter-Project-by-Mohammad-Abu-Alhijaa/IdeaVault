import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_app/Models/note.dart';
import 'package:note_app/Screens/detales_page_note.dart';
import 'package:note_app/Screens/setting_page.dart';
import 'package:note_app/Services/SharedPreferencesHelper.dart';
import 'package:note_app/generated/l10n.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Note> notes = [];
  final _formKey = GlobalKey<FormState>();
  final Titlecontroller = TextEditingController();
  final Contactcontroller = TextEditingController();
  Note? _editingNote;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final data = await SharedPreferencesHelper.getAllNotes();
    setState(() {
      notes = data;
    });
  }

  Future<void> _saveNote() async {
    if (_editingNote != null) {
      final updatedNote = _editingNote!.copyWith(
        title: Titlecontroller.text,
        content: Contactcontroller.text,
      );
      await SharedPreferencesHelper.updateNote(updatedNote);
    } else {
      final note = Note(
        title: Titlecontroller.text,
        content: Contactcontroller.text,
      );
      await SharedPreferencesHelper.insertNote(note);
    }
    _clearForm();
    _refreshNotes();
  }

  void _clearForm() {
    Titlecontroller.clear();
    Contactcontroller.clear();
    _editingNote = null;
  }

  Future<void> _deleteNote(String id) async {
    await SharedPreferencesHelper.deleteNote(id);
    _refreshNotes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).Notedeleted),
        backgroundColor: Colors.red.shade900,
      ),
    );
  }

  void _submitNote() {
    if (_formKey.currentState!.validate()) {
      _saveNote();
      Navigator.of(context).pop();
    }
  }

  void _editNote(Note note) {
    setState(() {
      _editingNote = note;
      Titlecontroller.text = note.title;
      Contactcontroller.text = note.content;
    });
    _showNoteDialog();
  }

  void _addNoteDialog() {
    _clearForm();
    _showNoteDialog();
  }

  void _showNoteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Color(0xff0a3697),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                      controller: Titlecontroller,
                      decoration: InputDecoration(
                        labelText: S.of(context).NoteTitle,
                        prefixIcon: Icon(Icons.title),
                        filled: true,
                        fillColor: Colors.blueAccent[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a content' : null,
                      controller: Contactcontroller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: S.of(context).NoteContent,
                        prefixIcon: const Icon(Icons.notes),
                        filled: true,
                        fillColor: Colors.blueAccent[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitNote,
                icon: Icon(
                  _editingNote != null ? Icons.edit : Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  _editingNote != null
                      ? S.of(context).update
                      : S.of(context).add,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0a3697),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff152e6a),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xff152e6a),
              ),
              shape: MaterialStateProperty.all<LinearBorder>(LinearBorder.none),
              elevation: MaterialStateProperty.all<double>(0),
              shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
            ),
            label: Text(
              S.of(context).add,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Icon(Icons.add, color: Colors.blueGrey),
            onPressed: _addNoteDialog,
          ),
        ],
        backgroundColor: Color(0xff152e6a),
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                S.of(context).backNote,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : MasonryGridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final gradients = [
                  [Colors.teal, Colors.greenAccent],
                  [Colors.amber, Colors.orange],
                  [Colors.cyan, Colors.teal],
                  [Colors.indigo, Colors.blueAccent],
                ];
                final gradient =
                    gradients[note.id != null
                        ? _getHash(note.id!) % gradients.length
                        : 0];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetalesPageNote(),
                        settings: RouteSettings(arguments: note),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showOptionsDialog(note);
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(note.updatedAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xff0a3697),
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomAppBar(
          color: const Color(0xFF092462),
          elevation: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFF092462),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    size: 32,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white70,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search_outlined,
                    size: 32,
                    color: _selectedIndex == 1 ? Colors.white : Colors.white70,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
                IconButton(
                  icon: Icon(
                    Icons.credit_card,
                    size: 32,
                    color: _selectedIndex == 2 ? Colors.white : Colors.white70,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 2),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 32,
                    color: _selectedIndex == 3 ? Colors.white : Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),

                SizedBox(width: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int _getHash(String input) {
    return input.codeUnits.fold(0, (prev, element) => prev + element);
  }

  void _showOptionsDialog(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).noteOptions),
          content: Text(S.of(context).optionsTile),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editNote(note);
              },
              child: Text(S.of(context).Edit),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (note.id != null) {
                  _deleteNote(note.id!);
                }
              },
              child: Text(
                S.of(context).Delete,
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).Cancel),
            ),
          ],
        );
      },
    );
  }
}
