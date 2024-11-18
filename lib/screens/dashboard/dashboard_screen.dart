import 'package:flutter/material.dart';
import 'package:iqalqalah/screens/game/game_screen.dart';
import 'package:iqalqalah/screens/leaderboard/leaderboard_screen.dart';
import 'package:iqalqalah/screens/manage/manage_notes_screen.dart';
import 'package:iqalqalah/screens/manage/manage_quiz_screen.dart';
import 'package:iqalqalah/screens/note/notes_screen.dart';
import 'package:iqalqalah/screens/quiz/quiz_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  final String className;
  final String avatarImage;

  const DashboardScreen({
    super.key,
    required this.name,
    required this.className,
    required this.avatarImage,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tapCount = 0; // Track the number of taps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'iQalqalah',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Theme color
        centerTitle: true,
        actions: [
          // Top-right tap detection
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _tapCount++;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(
                    'assets/images/${widget.avatarImage}'), // Display selected avatar
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kelas: ${widget.className}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuItem(
                  context,
                  'Nota',
                  'assets/images/notebook.png',
                  const NotesScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Uji Minda',
                  'assets/images/lightbulb.png',
                  QuizScreen(
                    name: widget.name,
                    className: widget.className,
                  ),
                ),
                _buildMenuItem(
                  context,
                  'Permainan',
                  'assets/images/joystick.png',
                  const GameScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Papan Pendahuluan',
                  'assets/images/trophy.png',
                  const LeaderboardScreen(),
                ),
                // Only show these items if the user has tapped 4 times
                if (_tapCount >= 4) ...[
                  _buildMenuItem(
                    context,
                    'Urus Nota',
                    'assets/images/manage_note.png',
                    const ManageNotesScreen(),
                  ),
                  _buildMenuItem(
                    context,
                    'Urus Uji Minda',
                    'assets/images/manage_quiz.png',
                    const ManageQuizScreen(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, String imagePath, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 60, // Adjust size as needed
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
