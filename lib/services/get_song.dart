import 'package:audio_service/audio_service.dart';
import 'package:music_player_poc/services/request_songs_permission.dart';

Future<List<MediaItem>> getSongs() async {
  try {
    await requestSongPermission();

    final List<MediaItem> songs = []

  } catch (e) {}
}
