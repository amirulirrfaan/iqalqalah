import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorful_print/colorful_print.dart';
import 'package:flutter/material.dart';

class ManageNotesScreen extends StatefulWidget {
  const ManageNotesScreen({super.key});

  @override
  _ManageNotesScreenState createState() => _ManageNotesScreenState();
}

class _ManageNotesScreenState extends State<ManageNotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Fungsi untuk mendapatkan nota dari Firestore
  Stream<List<Map<String, dynamic>>> fetchNotesFromFirestore() {
    return FirebaseFirestore.instance.collection('notes').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Fungsi untuk menambah nota ke Firestore
  Future<void> addNoteToFirestore(String title, String content) async {
    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'content': content,
        'createdAt': Timestamp.now(),
      });
      _titleController.clear();
      _contentController.clear();

      // Semak jika widget masih dipasang
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota berjaya ditambah!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      printColor(e, textColor: TextColor.cyan);

      // Semak jika widget masih dipasang
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat semasa menambah nota: $e')),
      );
    }
  }

  // Fungsi untuk mengedit nota dalam Firestore
  Future<void> editNoteInFirestore(
      String id, String title, String content) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.now(),
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota berjaya dikemas kini!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat semasa mengemas kini nota: $e')),
      );
    }
  }

  // Fungsi untuk memadam nota dari Firestore
  Future<void> deleteNoteFromFirestore(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).delete();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota berjaya dipadam!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat semasa memadam nota: $e')),
      );
    }
  }

  // Fungsi untuk menunjukkan dialog mengedit nota
  void showEditNoteDialog(Map<String, dynamic> note) {
    _titleController.text =
        note['title'] ?? ''; // Lalai kepada string kosong jika null
    _contentController.text =
        note['content'] ?? ''; // Lalai kepada string kosong jika null
    note['content'] ?? ''; // Lalai kepada string kosong jika null

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            note['id'] == null ? 'Tambah Nota' : 'Edit Nota'), // Tajuk dinamik
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tajuk',
                  labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor), // Set label color
                  filled: true,
                  fillColor: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.1), // Background color for the input field
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .primaryColor), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.5)), // Border color when enabled
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan tajuk';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Kandungan',
                  labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor), // Set label color
                  filled: true,
                  fillColor: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.1), // Background color for the input field
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .primaryColor), // Border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.5)), // Border color when enabled
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila masukkan kandungan';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final title = _titleController.text;
                final content = _contentController.text;
                if (note['id'] == null) {
                  // Tambah nota baru
                  addNoteToFirestore(title, content);
                } else {
                  // Edit nota sedia ada
                  editNoteInFirestore(note['id'], title, content);
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Urus Nota',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: const Color(0xFF4B61EA),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchNotesFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Ralat: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tiada nota dijumpai.'));
                  }

                  final notes = snapshot.data!;

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(note['title'] ??
                              'Tanpa Tajuk'), // Menangani nilai null
                          subtitle: Text(
                              note['content'] ?? 'Tiada kandungan tersedia'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showEditNoteDialog(note),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    deleteNoteFromFirestore(note['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _titleController.clear();
          _contentController.clear();
          showEditNoteDialog({'id': null, 'title': '', 'content': ''});
        },
        backgroundColor: const Color(0xFF4B61EA),
        child: const Icon(Icons.add),
      ),
    );
  }
}
