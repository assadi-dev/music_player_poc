import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player_poc/components/player_deck.dart';
import 'package:music_player_poc/components/song_list.dart';
import 'package:music_player_poc/notifiers/songs_provider.dart';
import 'package:music_player_poc/services/song_handler.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class HomeScreen extends StatefulWidget {
  final SongHandler songHandler;
  const HomeScreen({super.key, required this.songHandler});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  // Create an AutoScrollController for smooth scrolling
  final AutoScrollController _autoScrollController = AutoScrollController();
  // Method to scroll to a specific index in the song list
  void _scrollTo(int index) {
    _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness:
            Theme.of(context).colorScheme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Consumer<SongsProvider>(builder: (context, songsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Player songs"),
          ),
          body: songsProvider.isLoading
              ? _buildLoadingIndicator()
              : _buildSongsList(songsProvider),
        );
      }),
    );
  }

  // Method to build the loading indicator widget
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
      ),
    );
  }

  // Method to build the main songs list with a player deck
  Widget _buildSongsList(SongsProvider songsProvider) {
    return Stack(
      children: [
        // SongsList widget to display the list of songs
        SongsList(
          songHandler: widget.songHandler,
          songs: songsProvider.songs,
          autoScrollController: _autoScrollController,
        ),
        _buildPlayerDeck(), // PlayerDeck widget for music playback controls
      ],
    );
  }

  // Method to build the player deck widget
  Widget _buildPlayerDeck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // PlayerDeck widget with controls and the ability to scroll to a specific song
        PlayerDeck(
          songHandler: widget.songHandler,
          isLast: false,
          onTap: _scrollTo,
        ),
      ],
    );
  }
}
