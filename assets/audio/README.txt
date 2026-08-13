Put your bundled/streamable mp3 files here, e.g.:
  sample_1.mp3
  sample_2.mp3

These names must match lib/providers/library_provider.dart -> kBundledSongs.
If you rename or add more files, update that list AND pubspec.yaml assets
section (already points at assets/audio/ as a whole folder, so new files
just need `flutter pub get` / a hot restart to be picked up).
