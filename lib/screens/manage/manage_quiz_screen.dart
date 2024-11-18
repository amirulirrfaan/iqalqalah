import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageQuizScreen extends StatefulWidget {
  const ManageQuizScreen({Key? key}) : super(key: key);

  @override
  _ManageQuizScreenState createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  // Mengambil kuiz dari Firestore
  Stream<List<Map<String, dynamic>>> fetchQuizzesFromFirestore() {
    return FirebaseFirestore.instance.collection('quizzes').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Menambah kuiz baru ke Firestore
  Future<void> addQuizToFirestore(List<Map<String, dynamic>> questions) async {
    try {
      await FirebaseFirestore.instance.collection('quizzes').add({
        'questions': questions,
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuiz berjaya ditambah!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat menambah kuiz: $e')),
      );
    }
  }

  // Mengedit kuiz yang ada di Firestore
  Future<void> editQuizInFirestore(
      String id, List<Map<String, dynamic>> questions) async {
    try {
      await FirebaseFirestore.instance.collection('quizzes').doc(id).update({
        'questions': questions,
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuiz berjaya dikemaskini!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat mengemaskini kuiz: $e')),
      );
    }
  }

  // Memadam kuiz dari Firestore
  Future<void> deleteQuizFromFirestore(String id) async {
    try {
      await FirebaseFirestore.instance.collection('quizzes').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuiz berjaya dipadam!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat memadam kuiz: $e')),
      );
    }
  }

  // Memaparkan dialog untuk mengedit atau menambah kuiz
  void showEditQuizDialog(Map<String, dynamic> quiz) {
    final List<Map<String, dynamic>> questions =
        List<Map<String, dynamic>>.from(quiz['questions'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void addQuestion() {
            questions.add({
              'title': '',
              'options': ['', ''],
              'answer': null,
            });
            setDialogState(() {});
          }

          void updateQuestion(int index, String title) {
            questions[index]['title'] = title;
            setDialogState(() {});
          }

          void updateOption(int questionIndex, int optionIndex, String value) {
            questions[questionIndex]['options'][optionIndex] = value;
            setDialogState(() {});
          }

          void addOption(int questionIndex) {
            questions[questionIndex]['options'].add('');
            setDialogState(() {});
          }

          void removeOption(int questionIndex, int optionIndex) {
            questions[questionIndex]['options'].removeAt(optionIndex);
            setDialogState(() {});
          }

          void setAnswer(int questionIndex, int answerIndex) {
            questions[questionIndex]['answer'] = answerIndex;
            setDialogState(() {});
          }

          return AlertDialog(
            title: Text(
              quiz['id'] == null ? 'Tambah Kuiz' : 'Edit Kuiz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            content: Form(
              key: _formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // List of questions
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, questionIndex) {
                            final question = questions[questionIndex];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title input for the question
                                    TextFormField(
                                      initialValue: question['title'],
                                      decoration: InputDecoration(
                                        labelText: 'Tajuk Soalan',
                                        labelStyle: const TextStyle(
                                          color: Colors.blueGrey,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          updateQuestion(questionIndex, value),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tajuk soalan tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Options inputs for the question
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: question['options'].length,
                                      itemBuilder: (context, optionIndex) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                initialValue:
                                                    question['options']
                                                        [optionIndex],
                                                decoration: InputDecoration(
                                                  labelText: 'Pilihan',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.blueGrey,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.blue,
                                                      width: 2.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                onChanged: (value) =>
                                                    updateOption(questionIndex,
                                                        optionIndex, value),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Pilihan tidak boleh kosong';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => removeOption(
                                                  questionIndex, optionIndex),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    // Add option button
                                    TextButton(
                                      onPressed: () => addOption(questionIndex),
                                      child: const Text(
                                        'Tambah Pilihan',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // Dropdown for selecting the correct answer
                                    DropdownButton<int>(
                                      value: question['answer'],
                                      hint: const Text('Pilih Jawapan Betul'),
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      items: List.generate(
                                        question['options'].length,
                                        (index) => DropdownMenuItem(
                                          value: index,
                                          child: Text('Pilihan ${index + 1}'),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          setAnswer(questionIndex, value!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Button to add a new question
                      TextButton(
                        onPressed: addQuestion,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          backgroundColor: Colors
                              .blueAccent, // Using a modern blue color for the background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Rounded corners for a clean look
                          ),
                          side: const BorderSide(
                              color: Colors.blueAccent,
                              width:
                                  1), // Subtle border to match the background
                        ),
                        child: const Text(
                          'Tambah Soalan',
                          style: TextStyle(
                            color: Colors
                                .white, // White text for contrast and clarity
                            fontWeight: FontWeight
                                .w600, // Slightly lighter than bold for a refined look
                            fontSize:
                                16, // Larger font size for better readability
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (quiz['id'] == null) {
                      addQuizToFirestore(questions);
                    } else {
                      editQuizInFirestore(quiz['id'], questions);
                    }
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary, // Change button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Urus Uji Minda',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: const Color(0xFF4B61EA),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchQuizzesFromFirestore(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No quizzes found.'));
              }

              final quizzes = snapshot.data!;
              return ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title:
                          Text(quiz['questions'][0]['title'] ?? 'Tiada Tajuk'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditQuizDialog(quiz),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteQuizFromFirestore(quiz['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          showEditQuizDialog({
            'id': null,
            'questions': [],
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
