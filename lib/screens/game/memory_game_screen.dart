import 'dart:math';

import 'package:flutter/material.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  // Cards with pairs
  final List<String> _cards = [
    'م',
    'م',
    'ع',
    'ع',
    'ك',
    'ك',
    'ب',
    'ب',
    'ر',
    'ر',
    'ل',
    'ل',
    'ق',
    'ق',
    'ت',
    'ت',
  ];

  List<bool> _cardFlipped = List.filled(16, false);
  int _flippedCardCount = 0;
  int _matchesFound = 0;
  int _firstCardIndex = -1;
  int _secondCardIndex = -1;

  // Shuffle cards and reset game state
  void _resetGame() {
    setState(() {
      _cards.shuffle(Random()); // Shuffle the cards
      _cardFlipped = List.filled(16, false); // Reset flipped state of cards
      _matchesFound = 0; // Reset match count
    });
  }

  // Flip card logic
  void _flipCard(int index) {
    if (_cardFlipped[index] || _flippedCardCount == 2) {
      return;
    }

    setState(() {
      _cardFlipped[index] = true;
      _flippedCardCount++;

      if (_flippedCardCount == 1) {
        _firstCardIndex = index;
      } else if (_flippedCardCount == 2) {
        _secondCardIndex = index;

        // Check if the two flipped cards match
        if (_cards[_firstCardIndex] == _cards[_secondCardIndex]) {
          _matchesFound++;
        } else {
          // If they don't match, reset them after a delay
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _cardFlipped[_firstCardIndex] = false;
              _cardFlipped[_secondCardIndex] = false;
            });
          });
        }
        _flippedCardCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B61EA),
        title: Text(
          'Memory Game',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Padanan Ditemui: $_matchesFound / 8',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color:
                          _cardFlipped[index] ? Colors.white : Colors.blue[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _cardFlipped[index]
                          ? Text(
                              _cards[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: const Color(0xFF4B61EA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Mula Semula Permainan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
