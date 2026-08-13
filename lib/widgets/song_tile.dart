import 'package:flutter/cupertino.dart';
import '../models/song.dart';
import '../theme/gradients.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(gradient: AppGradients.artworkFor(index)),
                child: Icon(
                  song.source == SongSource.asset
                      ? CupertinoIcons.waveform
                      : CupertinoIcons.doc_on_doc,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? const Color(0xFFFF5FA2) : CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: CupertinoColors.white.withOpacity(0.6), fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.ellipsis, color: CupertinoColors.white.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
