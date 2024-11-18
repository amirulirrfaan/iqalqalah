import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String name;
  final String className;

  const QuizScreen({
    super.key,
    required this.name,
    required this.className,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));
  int _currentQuestionIndex = 0;
  int _score = 0;

  Stream<List<Map<String, dynamic>>> _fetchQuestions() {
    return FirebaseFirestore.instance
        .collection('quizzes') // Nama koleksi
        .snapshots() // Mendengar perubahan masa nyata
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            // Menganggap setiap dokumen mengandungi medan 'questions'
            var questionsData = doc['questions'] as List<dynamic>;

            return questionsData.map((questionData) {
              return {
                'title': questionData['title'],
                'options': List<String>.from(questionData['options']),
                'answer': questionData['answer'],
              };
            }).toList();
          })
          .expand((x) => x)
          .toList(); // Ratakan senarai soalan
    });
  }

  void _saveScoreToFirestore(
      String studentName, String studentClass, int score) async {
    try {
      // Reference to the 'scores' collection in Firestore
      CollectionReference scoresCollection =
          FirebaseFirestore.instance.collection('scores');

      // Add the student's score to the collection
      await scoresCollection.add({
        'name': studentName,
        'class': studentClass,
        'score': score,
        'timestamp':
            FieldValue.serverTimestamp(), // To store the time of submission
      });

      // You can also add any additional fields if required
      print('Score saved successfully');
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  // Fungsi untuk mengendalikan jawapan soalan
  void _answerQuestion(
      String selectedOption, int correctAnswerIndex, List<String> options) {
    setState(() {
      if (selectedOption == options[correctAnswerIndex]) {
        _score++;
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min, // Membuat saiz lajur sekecil mungkin
            children: [
              RichText(
                textAlign: TextAlign.center, // Tengah kan kandungan
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: selectedOption == options[correctAnswerIndex]
                          ? '🎉 Tahniah!\n'
                          : '😞 Oops!\n',
                      style: const TextStyle(
                        fontWeight: FontWeight
                            .bold, // Tebal untuk "Tahniah!" dan "Oops!"
                      ),
                    ),
                    TextSpan(
                      text: selectedOption == options[correctAnswerIndex]
                          ? '\nJawapan anda betul! 🎉'
                          : '\nJawapan yang betul adalah "${options[correctAnswerIndex]}". 😞',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.normal, // Normal untuk mesej selebihnya
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: const SizedBox(
              height: 10), // Simpan ruang minimal dalam kandungan
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          actions: <Widget>[
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0), // Simpan padding minimal
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF4B61EA), // Warna latar belakang
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shadowColor: Colors.blueAccent,
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    setState(() {
                      _currentQuestionIndex++; // Pergi ke soalan seterusnya
                    });

                    // Jika semua soalan telah dijawab
                    if (_currentQuestionIndex == 2) {
                      // Gantikan dengan jumlah soalan sebenar
                      _confettiController.play();
                    }
                  },
                  child: const Text(
                    'Seterusnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B61EA),
        title: Text(
          'Uji Minda',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream:
            _fetchQuestions(), // Menggunakan kaedah pengambilan data sebenar
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ralat: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tiada data kuiz tersedia.'));
          }

          final questions = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _currentQuestionIndex < questions.length
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Soalan ${_currentQuestionIndex + 1} dari ${questions.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          questions[_currentQuestionIndex]['title'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: (questions[_currentQuestionIndex]['options']
                                as List<String>)
                            .map(
                              (option) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 15),
                                      backgroundColor: const Color(0xFF4B61EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      final correctAnswerIndex =
                                          questions[_currentQuestionIndex]
                                              ['answer'] as int;
                                      final options = List<String>.from(
                                          questions[_currentQuestionIndex]
                                              ['options']);
                                      _answerQuestion(
                                          option, correctAnswerIndex, options);
                                    },
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  )
                : Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality:
                              BlastDirectionality.explosive, // Arah konfeti
                          shouldLoop: true, // Gelung animasi
                          colors: const [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.yellow
                          ],
                          gravity: 0.2, // Kelajuan konfeti
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kuiz Selesai!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Skor anda: $_score / ${questions.length}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B61EA),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                backgroundColor: const Color(0xFF4B61EA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                _saveScoreToFirestore(
                                    widget.name, widget.className, _score);
                                _resetQuiz();
                                _confettiController
                                    .play(); // Mulakan konfeti apabila kuiz diulang
                              },
                              child: const Text(
                                'Ulang Kuiz',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
