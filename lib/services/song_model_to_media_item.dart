import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_player_poc/services/get_song_art.dart';
import 'package:on_audio_query/on_audio_query.dart';

Future<MediaItem> songToMediaItem(SongModel song) async {
  try {
    /* final Uri? art = await getSongArt(
      id: song.id,
      type: ArtworkType.AUDIO,
      quality: 100,
      size: 300,
    ); */

    //final Uri artUri = File("assets/images/cover.jpg").uri;

    return MediaItem(
      id: song.uri.toString(),
      artist: song.artist,
      duration: Duration(milliseconds: song.duration!),
      displayDescription: song.id.toString(),
      title: song.title,
    );
  } catch (e) {
    debugPrint('Error converting SongModel to MediaItem: $e');
    return const MediaItem(id: "", title: "");
  }
}
