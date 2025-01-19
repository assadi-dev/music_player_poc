import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:music_player_poc/models/song_model.dart';
import 'package:music_player_poc/services/request_songs_permission.dart';
import 'package:music_player_poc/services/song_model_to_media_item.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<List<MediaItem>> getSongs() async {
  try {
    await requestSongPermission();

    final List<MediaItem> songs = [];

    final OnAudioQuery onAudioQuery = OnAudioQuery();

    if (Platform.isIOS) {
      await onAudioQuery.checkAndRequest();
    }
    // var songModels = await pickMusicFolder();
    final List<SongModel> songModels = await getSongsFromAssets();
    //final songModels = await onAudioQuery.querySongs();

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
    Directory appDocDir = await getApplicationSupportDirectory();
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
        // final cover = await getArtwork();
        Map<dynamic, dynamic> songData = {
          "_id": DateTime.now().millisecondsSinceEpoch, // ID unique
          "title": originalFile.uri.pathSegments.last ??
              "Titre inconnu", // Nom du fichier
          //"_data": cover.path, // Chemin du fichier
          "artist": "Inconnu", // Valeur par défaut
          "album": "Inconnu",
          "duration": 197,
          "_uri": copiedFile.uri.toString(),
        };

        // Créer un objet SongModel pour chaque fichier copié
        SongModel song = SongModel(songData);

        songs.add(song);
      }
    }
  } else {
    print("❌ Aucun fichier sélectionné.");
  }

  return songs;
}

Future<File> saveFile(PlatformFile file) async {
  var downloadDir = await getApplicationSupportDirectory();
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

final List<Song> _playlist = [
  Song(
      id: 100,
      songName: 'Dynasties & Dystopia',
      artistName: 'Denzel Curry, Gizzle, Bren Joy',
      albumName: 'Arcane League Of Legends',
      albumArtImagePath: "assets/images/cover.jpg",
      audioPath: 'assets/audios/audio_1.mp3',
      duration: 178),
  Song(
      id: 101,
      songName: 'Playground (Baby Tate Remix) ',
      artistName: 'Bea Miller',
      albumName: 'Arcane League Of Legends',
      albumArtImagePath: "assets/images/cover.jpg",
      audioPath: 'assets/audios/audio_2.mp3',
      duration: 151),
  Song(
      id: 102,
      songName: 'Come Play',
      artistName: 'Stray Kids, Young Miko, Tom Morello',
      albumName: 'Arcane League Of Legends',
      albumArtImagePath: "assets/images/cover.jpg",
      audioPath: 'assets/audios/audio_3.mp3',
      duration: 162),
  Song(
      id: 103,
      songName: 'To Ashes and Blood',
      artistName: 'Woodkid',
      albumName: 'Arcane League Of Legends',
      albumArtImagePath: "assets/images/cover.jpg",
      audioPath: 'assets/audios/audio_4.mp3',
      duration: 246),
];

Future<List<SongModel>> getSongsFromAssets() async {
  List<SongModel> songs = [];
  Directory appDocDir = await getApplicationSupportDirectory();
  Directory audioFolder = Directory("${appDocDir.path}/audios");

  // Créer le dossier si nécessaire
  if (!audioFolder.existsSync()) {
    audioFolder.createSync(recursive: true);
  }

  for (var song in _playlist) {
    String fileName = "${song.id}.mp3";
    String assetPath =
        song.audioPath; // Chemin dans les assets (ex: "assets/audios/song.mp3")
    String localFilePath = "${audioFolder.path}/$fileName";

    // Copier le fichier depuis les assets vers le stockage local
    File localFile = File(localFilePath);
    if (!localFile.existsSync()) {
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List();
      await localFile.writeAsBytes(bytes);
      print("✅ Fichier copié : $localFilePath");
    }

    Map<dynamic, dynamic> infoData = {
      "_id": DateTime.now().millisecondsSinceEpoch, // ID unique
      "title": song.songName,
      "_data": localFilePath,
      "artist": song.artistName,
      "fileExtension": "mp3",
      "displayNameWOExt": song.songName,
      "displayName": song.songName,
      "album": song.albumName,
      "duration": song.duration,
      "_uri": localFile.uri.toString()
    };

    songs.add(SongModel(infoData));
  }

  return songs;
}

Future<File> getArtwork() async {
  const String assetPath = "assets/images/cover.jpg";
  Directory appDocDir = await getApplicationSupportDirectory();
  String audioFolder = "${appDocDir.path}/audios";

  final String path = "$audioFolder/cover.jpeg";
  File originalFile = File(path);
  if (!originalFile.existsSync()) {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();
    File copyFile = File(path);
    copyFile.writeAsBytes(bytes);
    return copyFile;
  }
  return originalFile;
}
