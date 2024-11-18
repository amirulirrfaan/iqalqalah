import 'package:flutter/material.dart';
import 'package:iqalqalah/theme/app_theme.dart';

import 'character_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  void _navigateToCharacterSelection() {
    if (nameController.text.isNotEmpty && classController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterSelectionScreen(
            name: nameController.text,
            className: classController.text,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image on the left side of the text
                Image.asset(
                  'assets/images/quran.png', // Replace with the correct path to your image
                  height: 50, // Adjust the height as needed
                ),
                const SizedBox(
                    width: 10), // Add some space between the image and text
                Text(
                  'iQalqalah',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 50),
            _buildInputField(
              controller: nameController,
              label: 'Masukkan nama anda',
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: classController,
              label: 'Masukkan kelas anda',
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _navigateToCharacterSelection,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Teruskan',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              BorderSide(color: AppTheme.lightTheme.colorScheme.secondary),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
