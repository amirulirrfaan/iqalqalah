import 'package:flutter/material.dart';
import 'package:iqalqalah/screens/dashboard/dashboard_screen.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final String name;
  final String className;

  const CharacterSelectionScreen({
    super.key,
    required this.name,
    required this.className,
  });

  @override
  _CharacterSelectionScreenState createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  String selectedCharacter = '';

  void _selectCharacter(String character) {
    setState(() {
      selectedCharacter = character;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          name: widget.name,
          className: widget.className,
          avatarImage: selectedCharacter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = [
      'boy.png',
      'girl.png',
      'leonardo.png',
      'magician.png',
      'muslim.png',
      'arab-woman.png'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Watak',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return GestureDetector(
                    onTap: () => _selectCharacter(character),
                    child: Card(
                      elevation: selectedCharacter == character ? 6 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/$character',
                              fit: BoxFit.cover,
                              height: 100, // Make the image bigger
                              width: 100, // Adjust the image width
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
