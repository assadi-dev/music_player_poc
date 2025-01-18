import 'package:flutter/material.dart';
import 'package:music_player_poc/services/song_handler.dart';

class HomeScreen extends StatefulWidget {
  final SongHandler songHandler;
  const HomeScreen({super.key, required this.songHandler});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
