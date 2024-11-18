import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // List untuk menyimpan data papan pendahulu
  List<Map<String, dynamic>> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  // Mendapatkan data papan pendahulu dari Firestore
  Future<void> _fetchLeaderboardData() async {
    FirebaseFirestore.instance
        .collection('scores')
        .orderBy('score',
            descending: true) // Menyusun mengikut skor secara menurun
        .get()
        .then((snapshot) {
      final data = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'score': doc['score'],
          // Tambah lebih banyak medan jika anda ingin memaparkannya (cth: 'class', 'timestamp')
        };
      }).toList();

      setState(() {
        leaderboardData = data;
      });
    }).catchError((e) {
      // Mengendalikan ralat jika ada
      print("Ralat semasa mengambil data: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Papan Pendahulu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F5FA),
      body: leaderboardData.isEmpty
          ? const Center(
              child: Text('Tiada data tersedia',
                  style: TextStyle(
                      fontSize: 18))) // Paparkan "Tiada data tersedia"
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardTile(context, index);
              },
            ),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, int index) {
    final student = leaderboardData[index];
    final name = student['name'];
    final score = student['score'];

    // Gaya khas untuk 3 teratas
    if (index == 0) {
      // Tempat Pertama
      return _buildTopPositionTile(
          context, name, score, Colors.yellow.shade700, Icons.star);
    } else if (index == 1) {
      // Tempat Kedua
      return _buildTopPositionTile(
          context, name, score, Colors.grey.shade400, Icons.emoji_events);
    } else if (index == 2) {
      // Tempat Ketiga
      return _buildTopPositionTile(
          context, name, score, Colors.brown.shade600, Icons.emoji_events);
    } else {
      // Kedudukan lain
      return ListTile(
        leading: Text(
          '${index + 1}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.black,
              ),
        ),
        trailing: Text(
          '$score mata',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      );
    }
  }

  Widget _buildTopPositionTile(BuildContext context, String name, int score,
      Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ),
          Text(
            '$score mata',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
