import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';

/// Handles importing audio files from the device.
///
/// FilePicker uses the native system file picker, so we do not request
/// Permission.audio before opening it. This is especially important on
/// modern Android versions where the system picker can grant access to
/// the selected file directly.
class FileImportService {
  /// Opens the native audio file picker.
  ///
  /// Selected files are copied into the app's documents directory so they
  /// remain available after the picker is closed.
  Future<List<Song>> pickAndImportSongs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final docsDir = await getApplicationDocumentsDirectory();

    final musicDir = Directory(
      '${docsDir.path}/imported_music',
    );

    if (!musicDir.existsSync()) {
      await musicDir.create(recursive: true);
    }

    final songs = <Song>[];

    for (final picked in result.files) {
      final sourcePath = picked.path;

      if (sourcePath == null || sourcePath.isEmpty) {
        continue;
      }

      final fileName = picked.name;

      // Make the destination filename safe.
      final safeFileName = fileName
          .replaceAll('/', '_')
          .replaceAll('\\', '_');

      final destination = File(
        '${musicDir.path}/$safeFileName',
      );

      try {
        if (!destination.existsSync()) {
          await File(sourcePath).copy(destination.path);
        }
      } catch (_) {
        // If copying fails, we'll use the original picked path below.
      }

      final finalPath = destination.existsSync()
          ? destination.path
          : sourcePath;

      final title = fileName.contains('.')
          ? fileName.substring(
        0,
        fileName.lastIndexOf('.'),
      )
          : fileName;

      songs.add(
        Song(
          id: 'file_${DateTime.now().microsecondsSinceEpoch}_$safeFileName',
          title: title,
          artist: 'Imported',
          path: finalPath,
          source: SongSource.file,
        ),
      );
    }

    return songs;
  }
}