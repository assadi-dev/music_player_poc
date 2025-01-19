import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_player_poc/components/player_deck.dart';
import 'package:music_player_poc/components/song_item.dart';
import 'package:music_player_poc/services/song_handler.dart';
import 'package:music_player_poc/utils/formatted_title.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class SongsList extends StatelessWidget {
  final List<MediaItem> songs;
  final SongHandler songHandler;
  final AutoScrollController autoScrollController;

  const SongsList({
    super.key,
    required this.songs,
    required this.songHandler,
    required this.autoScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return songs.isEmpty
        ? const Center(child: Text("Pas de musique"))
        : ListView.builder(
            controller: autoScrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              MediaItem song = songs[index];
              return StreamBuilder<MediaItem?>(
                stream: songHandler.mediaItem.stream,
                builder: (context, snapshot) {
                  MediaItem? playingSong = snapshot.data;
                  // Check if the current item is the last one
                  return index == (songs.length - 1)
                      ? _buildLastSongItem(song, playingSong)
                      : AutoScrollTag(
                          // Utilize AutoScrollTag for automatic scrolling
                          key: ValueKey(index),
                          controller: autoScrollController,
                          index: index,
                          child: _buildRegularSongItem(song, playingSong),
                        );
                },
              );
            },
          );
  }

  // Build the last song item with a PlayerDeck for controls
  Widget _buildLastSongItem(MediaItem song, MediaItem? playingSong) {
    return Column(
      children: [
        // Display the last song item
        SongItem(
          id: int.parse(song.displayDescription!),
          isPlaying: song == playingSong,
          title: formattedTitle(song.title),
          artist: song.artist,
          onSongTap: () async {
            await songHandler.skipToQueueItem(songs.length - 1);
          },
          art: song.artUri,
        ),
        // Display the player deck for controls
        PlayerDeck(
          songHandler: songHandler,
          isLast: true,
          onTap: () {},
        ),
      ],
    );
  }

  // Build a regular song item
  Widget _buildRegularSongItem(MediaItem song, MediaItem? playingSong) {
    return SongItem(
      id: int.parse(song.id),
      isPlaying: song == playingSong,
      title: formattedTitle(song.title),
      artist: song.artist,
      onSongTap: () async {
        await songHandler.skipToQueueItem(songs.indexOf(song));
      },
      art: song.artUri,
    );
  }
}
