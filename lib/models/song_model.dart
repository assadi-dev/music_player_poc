class Song {
  final int id;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtImagePath;
  final String audioPath;
  final int duration;

  Song(
      {required this.id,
      required this.songName,
      required this.artistName,
      required this.albumName,
      required this.albumArtImagePath,
      required this.audioPath,
      required this.duration});
}
