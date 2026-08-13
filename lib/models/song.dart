/// Where the audio bytes for a [Song] come from.
enum SongSource {
  /// Bundled inside the app under assets/audio/ (streamed via AssetSource).
  asset,

  /// Imported by the user from their device storage (played via DeviceFileSource).
  file,
}

/// Simple, serializable model representing a single track in the library.
class Song {
  final String id;
  final String title;
  final String artist;
  final String path; // asset path (e.g. "audio/song.mp3") or absolute file path
  final SongSource source;
  final Duration? duration;
  final String? artworkPath;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.path,
    required this.source,
    this.duration,
    this.artworkPath,
  });

  Song copyWith({Duration? duration}) => Song(
    id: id,
    title: title,
    artist: artist,
    path: path,
    source: source,
    duration: duration ?? this.duration,
    artworkPath: artworkPath,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'path': path,
    'source': source.name,
    'durationMs': duration?.inMilliseconds,
    'artworkPath': artworkPath,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String,
    path: json['path'] as String,
    source: SongSource.values.firstWhere((s) => s.name == json['source']),
    duration: json['durationMs'] != null
        ? Duration(milliseconds: json['durationMs'] as int)
        : null,
    artworkPath: json['artworkPath'] as String?,
  );
}
