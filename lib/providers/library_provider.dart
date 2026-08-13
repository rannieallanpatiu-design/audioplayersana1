import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../services/file_import_service.dart';

const _prefsKey = 'liquid_music_library_v1';
const _playlistPrefsKey = 'liquid_music_playlists_v1';

final List<Song> kBundledSongs = [
  const Song(
    id: 'asset_1',
    title: 'Midnight Drift',
    artist: 'Liquid Glass Demo',
    path: 'assets/audio/sample_1.mp3',
    source: SongSource.asset,
  ),
  const Song(
    id: 'asset_2',
    title: 'Neon Tide',
    artist: 'Liquid Glass Demo',
    path: 'assets/audio/sample_2.mp3',
    source: SongSource.asset,
  ),
];

class MusicPlaylist {
  final String id;
  final String name;
  final List<String> songIds;

  const MusicPlaylist({
    required this.id,
    required this.name,
    required this.songIds,
  });

  MusicPlaylist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
  }) {
    return MusicPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
    };
  }

  factory MusicPlaylist.fromJson(Map<String, dynamic> json) {
    return MusicPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      songIds: List<String>.from(json['songIds'] ?? const []),
    );
  }
}

class PlaylistController extends StateNotifier<List<MusicPlaylist>> {
  PlaylistController() : super(const []) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistPrefsKey);

    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List;

      state = decoded
          .map(
            (item) => MusicPlaylist.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _playlistPrefsKey,
      jsonEncode(
        state.map((playlist) => playlist.toJson()).toList(),
      ),
    );
  }

  Future<void> createPlaylist(String name) async {
    final cleaned = name.trim();

    if (cleaned.isEmpty) return;

    final playlist = MusicPlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: cleaned,
      songIds: const [],
    );

    state = [...state, playlist];

    await _persist();
  }

  Future<void> deletePlaylist(String playlistId) async {
    state = state
        .where((playlist) => playlist.id != playlistId)
        .toList();

    await _persist();
  }

  Future<void> renamePlaylist(
      String playlistId,
      String name,
      ) async {
    final cleaned = name.trim();

    if (cleaned.isEmpty) return;

    state = [
      for (final playlist in state)
        if (playlist.id == playlistId)
          playlist.copyWith(name: cleaned)
        else
          playlist,
    ];

    await _persist();
  }

  Future<void> addSongToPlaylist(
      String playlistId,
      String songId,
      ) async {
    state = [
      for (final playlist in state)
        if (playlist.id == playlistId)
          playlist.songIds.contains(songId)
              ? playlist
              : playlist.copyWith(
            songIds: [
              ...playlist.songIds,
              songId,
            ],
          )
        else
          playlist,
    ];

    await _persist();
  }

  Future<void> removeSongFromPlaylist(
      String playlistId,
      String songId,
      ) async {
    state = [
      for (final playlist in state)
        if (playlist.id == playlistId)
          playlist.copyWith(
            songIds: playlist.songIds
                .where((id) => id != songId)
                .toList(),
          )
        else
          playlist,
    ];

    await _persist();
  }

  Future<void> removeSongFromAllPlaylists(String songId) async {
    state = [
      for (final playlist in state)
        playlist.copyWith(
          songIds: playlist.songIds
              .where((id) => id != songId)
              .toList(),
        ),
    ];

    await _persist();
  }

  List<Song> songsForPlaylist(
      MusicPlaylist playlist,
      List<Song> library,
      ) {
    final songsById = <String, Song>{
      for (final song in library) song.id: song,
    };

    return [
      for (final id in playlist.songIds)
        if (songsById.containsKey(id)) songsById[id]!,
    ];
  }
}

final playlistControllerProvider =
StateNotifierProvider<PlaylistController, List<MusicPlaylist>>(
      (ref) => PlaylistController(),
);

class LibraryController extends StateNotifier<List<Song>> {
  LibraryController(this.ref) : super([...kBundledSongs]) {
    _restoreImported();
  }

  final Ref ref;
  final FileImportService _importService = FileImportService();

  Future<void> _restoreImported() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) return;

    try {
      final list = (jsonDecode(raw) as List)
          .map(
            (item) => Song.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();

      state = [...kBundledSongs, ...list];
    } catch (_) {}
  }

  Future<void> _persistImported() async {
    final prefs = await SharedPreferences.getInstance();

    final imported = state
        .where((song) => song.source == SongSource.file)
        .toList();

    await prefs.setString(
      _prefsKey,
      jsonEncode(
        imported.map((song) => song.toJson()).toList(),
      ),
    );
  }

  Future<int> importFromDevice() async {
    final imported = await _importService.pickAndImportSongs();

    if (imported.isEmpty) return 0;

    state = [...state, ...imported];

    await _persistImported();

    return imported.length;
  }

  Future<void> removeSong(String id) async {
    state = state.where((song) => song.id != id).toList();

    await _persistImported();

    await ref
        .read(playlistControllerProvider.notifier)
        .removeSongFromAllPlaylists(id);
  }
}

final libraryProvider =
StateNotifierProvider<LibraryController, List<Song>>(
      (ref) => LibraryController(ref),
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final library = ref.watch(libraryProvider);

  if (query.isEmpty) return library;

  return library.where((song) {
    return song.title.toLowerCase().contains(query) ||
        song.artist.toLowerCase().contains(query);
  }).toList();
});