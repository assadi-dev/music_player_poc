import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:music_player_poc/services/request_songs_permission.dart';
import 'package:music_player_poc/services/song_model_to_media_item.dart';
import 'package:on_audio_query/on_audio_query.dart';

Future<List<MediaItem>> getSongs() async {
  try {
    await requestSongPermission();

    final List<MediaItem> songs = [];

    final OnAudioQuery onAudioQuery = OnAudioQuery();

    if (Platform.isIOS) {
      await onAudioQuery.checkAndRequest();
    }

    final List<SongModel> songModels = await onAudioQuery.querySongs();

    for (final SongModel songModel in songModels) {
      final MediaItem song = await songToMediaItem(songModel);
      songs.add(song);
    }

    return songs;
  } catch (e) {
    debugPrint('Erreur récupération des musiques: $e');
    return [];
  }
}
