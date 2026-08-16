import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/screens/caption_editor.dart';
import 'package:movie_journal/features/journal/widgets/scenes_select_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/core/utils/tmdb_image_url.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/shared_widgets/tmdb_image.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class SelectedSceneCard extends StatelessWidget {
  const SelectedSceneCard({
    super.key,
    required this.imagePath,
    required this.onRemove,
    required this.sceneIndex,
    this.caption,
  });

  /// A TMDB `file_path`; the size bucket belongs to [TmdbImage], not the caller.
  final String imagePath;
  final VoidCallback onRemove;
  final int sceneIndex;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          enableDrag: false,
          context: context,
          builder: (context) => CaptionEditor(initialSceneIndex: sceneIndex),
        );
      },
      child: SizedBox(
        width: 240,
        height: 175,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TmdbImage(
                path: imagePath,
                size: TmdbImageSize.w500,
                width: 240,
                height: 175,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  padding: EdgeInsets.zero,
                  backgroundColor: DarkSurfaces.card.withAlpha(204),
                  shape: const CircleBorder(),
                ),
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.text_fields,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),

                  if (caption != null && caption!.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          caption!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'AvenirNext',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScenesSelector extends ConsumerStatefulWidget {
  const ScenesSelector({super.key, required this.movieId});
  final int movieId;

  @override
  ConsumerState<ScenesSelector> createState() => _ScenesSelectorState();
}

class _ScenesSelectorState extends ConsumerState<ScenesSelector> {
  static const double _borderRadius = 16.0;
  static const double _minMaxHeight = 215.0;

  void _navigateToScenesSelectSheet() {
    showModalBottomSheet(
      useSafeArea: true,
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScenesSelectSheet(movieId: widget.movieId),
    );
  }

  Widget _buildEmptyScenesView(String firstBackdropPath) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _minMaxHeight,
        maxHeight: _minMaxHeight,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: TmdbImage(
              path: firstBackdropPath,
              size: TmdbImageSize.w342,
              width: double.infinity,
              height: double.infinity,
              errorWidget: Center(child: Text(l10n.sceneErrorLoadingImage)),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(102),
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToScenesSelectSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        l10n.scenesAdd,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AvenirNext',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScenesView(List<SceneItem> selectedScenes) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: selectedScenes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final scene = selectedScenes[index];
              return SelectedSceneCard(
                imagePath: scene.path,
                sceneIndex: index,
                caption: scene.caption,
                onRemove: () {
                  ref
                      .read(journalControllerProvider.notifier)
                      .removeScene(scene.path);
                },
              );
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: _navigateToScenesSelectSheet,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: Text(
            l10n.sceneAdd,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'AvenirNext',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBackdropsState() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: _minMaxHeight,
      decoration: BoxDecoration(
        color: DarkSurfaces.sheetSecondary,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.scenesMissingTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'AvenirNext',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.scenesMissingBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'AvenirNext',
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.scenesMissingTagline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                letterSpacing: 0,
                fontSize: 14,
                fontFamily: 'AvenirNext',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movieImagesAsync = ref.watch(
      movieImagesControllerProvider(widget.movieId),
    );
    // Only the scenes matter here; thoughts/emotion edits shouldn't rebuild.
    final selectedScenes = ref.watch(
      journalControllerProvider.select((j) => j.selectedScenes),
    );

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.scenesPrompt,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'AvenirNext',
          ),
        ),
        movieImagesAsync.when(
          data: (movieImages) {
            final backdrops = movieImages.backdrops;
            if (backdrops.isEmpty) {
              return _buildEmptyBackdropsState();
            }

            return selectedScenes.isEmpty
                ? _buildEmptyScenesView(backdrops[0].filePath)
                : _buildSelectedScenesView(selectedScenes);
          },
          loading:
              () => Skeletonizer(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: _minMaxHeight,
                    maxHeight: _minMaxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    child: const Bone(
                      width: double.infinity,
                      height: _minMaxHeight,
                    ),
                  ),
                ),
              ),
          error:
              (error, stack) =>
                  Center(child: Text(l10n.sceneErrorLoadingImages)),
        ),
      ],
    );
  }
}
