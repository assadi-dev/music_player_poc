import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:music_player_poc/services/request_songs_permission.dart';
import 'package:music_player_poc/services/song_model_to_media_item.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

Future<List<MediaItem>> getSongs() async {
  try {
    await requestSongPermission();

    final List<MediaItem> songs = [];

    final OnAudioQuery onAudioQuery = OnAudioQuery();

    if (Platform.isIOS) {
      await onAudioQuery.checkAndRequest();
    }
    var savedFiles = await pickMusicFolder();
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

Future<List<SongModel>> pickMusicFolder() async {
  final List<SongModel> songs = [];
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3', 'wav', 'aac'],
    allowMultiple: true,
  );

  if (result != null) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory audioFolder = Directory("${appDocDir.path}/audios");

    // Vérifier et créer le dossier si nécessaire
    if (!audioFolder.existsSync()) {
      audioFolder.createSync(recursive: true);
      print("📁 Dossier créé : ${audioFolder.path}");
    }

    for (var selected in result.files) {
      if (selected.path != null) {
        var extension = selected.extension;
        File originalFile = File(selected.path!);
        String newFilePath =
            "${audioFolder.path}/${DateTime.now().millisecondsSinceEpoch}.$extension";

        File copiedFile = await originalFile.copy(newFilePath);

        Map<dynamic, dynamic> songData = {
          "id": DateTime.now().millisecondsSinceEpoch, // ID unique
          "title": originalFile.uri.pathSegments.last ??
              "Titre inconnu", // Nom du fichier
          "data": copiedFile.path, // Chemin du fichier
          "artist": "Inconnu", // Valeur par défaut
          "album": "Inconnu",
          "duration": 0, // Pas d'accès direct à la durée
        };

        // Créer un objet SongModel pour chaque fichier copié
        SongModel song = SongModel(songData);

        songs.add(song);
      }
    }
  } else {
    print("❌ Aucun fichier sélectionné.");
  }

  print("🎵 ${songs.length} fichiers musicaux enregistrés !");
  return songs;
}

Future<File> saveFile(PlatformFile file) async {
  var downloadDir = await getApplicationDocumentsDirectory();
  Directory audioFolder = Directory("${downloadDir.path}/audios");
  // Étape 3 : Vérifier si le dossier existe, sinon le créer
  if (!audioFolder.existsSync()) {
    audioFolder.createSync(recursive: true);
    print("📁 Dossier créé : ${audioFolder.path}");
  }
  var extenstion = file.extension;
  var time = DateTime.now().millisecondsSinceEpoch;

  var path = "${downloadDir.path}/audios/$time.mp3";
  var newFile = File(file.path!);
  await newFile.copy(path);
  return File(path);
}
