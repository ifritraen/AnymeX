import 'dart:async';
import 'package:anymex/controllers/service_handler/params.dart';
import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/controllers/settings/methods.dart';
import 'package:anymex/database/data_keys/keys.dart';
import 'package:anymex/widgets/non_widgets/snackbar.dart';
import 'package:anymex/models/Anilist/anilist_media_user.dart';
import 'package:anymex/models/Media/media.dart';
import 'package:anymex/screens/anime/details_page.dart';
import 'package:anymex/screens/manga/details_page.dart';
import 'package:anymex/screens/novel/details/details_view.dart';
import 'package:anymex/controllers/source/source_controller.dart';
import 'package:anymex/utils/function.dart';
import 'package:anymex/utils/theme_extensions.dart';
import 'package:anymex/widgets/custom_widgets/anymex_image.dart';
import 'package:anymex/widgets/custom_widgets/custom_text.dart';
import 'package:anymex/widgets/custom_widgets/custom_textspan.dart';
import 'package:anymex/widgets/helper/platform_builder.dart';
import 'package:anymex/widgets/helper/tv_wrapper.dart';
import 'package:anymex/widgets/media_items/media_peek_popup.dart';
import 'package:anymex_extension_runtime_bridge/Models/Source.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CardData {
  String id;
  String title;
  String poster;
  String? episodeCount;
  String? rating;
  String? totalEpisodes;
  String? format;
  String? mediaStatus;
  String? score;
  String? type;
  Media data;
  String? nextEpisode;

  CardData(
      {required this.id,
      required this.title,
      required this.poster,
      this.episodeCount,
      this.rating,
      this.totalEpisodes,
      this.format,
      this.mediaStatus,
      this.score,
      this.type,
      this.nextEpisode,
      required this.data});

  factory CardData.fromTrackedMedia(TrackedMedia data) {
    return CardData(
      id: data.id ?? '',
      title: data.title ?? '',
      poster: data.poster ?? '',
      episodeCount: data.episodeCount,
      rating: data.rating,
      totalEpisodes: data.totalEpisodes ?? '?',
      score: data.score,
      type: data.type,
      data: Media(
          id: data.id!,
          title: data.title ?? '??',
          poster: data.poster ?? '',
          mediaType: data.type == 'MANGA' ? ItemType.manga : ItemType.anime,
          serviceType: data.servicesType),
    );
  }

  factory CardData.fromMedia(Media data) {
    return CardData(
      id: data.id,
      title: data.title,
      poster: data.poster,
      rating: data.rating,
      episodeCount: 'N/A',
      totalEpisodes: data.totalEpisodes,
      nextEpisode: data.nextAiringEpisode?.episode.toString(),
      score: data.rating,
      type: data.type,
      data: data,
    );
  }
}

enum CardVariant {
  search,
  onlinelist,
}

class GridAnimeCard extends StatelessWidget {
  const GridAnimeCard({
    super.key,
    required this.data,
    required this.isManga,
    this.variant,
    this.type,
  });
  final dynamic data;
  final bool isManga;
  final CardVariant? variant;
  final ItemType? type;

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 108;
    const double cardHeight = 270;
    final media = data is Media
        ? CardData.fromMedia(data)
        : CardData.fromTrackedMedia(data);
    final itemType = type ?? (isManga ? ItemType.manga : ItemType.anime);

    final badgeText = extractTitleBadge(media.title, format: media.format);

    return GestureDetector(
      onSecondaryTap: () {
        MediaPeekPopup.showIfUntracked(
          context,
          media.data,
          itemType,
          media.title,
        );
      },
      onLongPress: () {
        MediaPeekPopup.showIfUntracked(
          context,
          media.data,
          itemType,
          media.title,
        );
      },
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                AnymexOnTap(
                  margin: 0,
                  onTap: () {
                    final heroTag = '${media.id}-${itemType.name}-grid-card';
                    if (itemType == ItemType.novel) {
                      final sourceController = Get.find<SourceController>();
                      var novSource = sourceController.getNovelExtensionByName(media.data.season);
                      novSource ??= sourceController.activeNovelSource.value ??
                          sourceController.installedNovelExtensions.firstOrNull;
                      if (novSource != null) {
                        final Source activeSource = novSource;
                        navigate(() => NovelDetailsPage(
                              media: media.data,
                              tag: heroTag,
                              source: activeSource,
                            ));
                      }
                    } else if (itemType == ItemType.manga) {
                      navigate(() => MangaDetailsPage(media: media.data, tag: heroTag));
                    } else {
                      navigate(() => AnimeDetailsPage(media: media.data, tag: heroTag));
                    }
                  },
                  child: Hero(
                    tag: '${media.id}-${itemType.name}-grid-card',
                    transitionOnUserGestures: true,
                    flightShuttleBuilder: AnymeXImage.heroFlightShuttleBuilder,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnymeXImage(
                        radius: 12,
                        imageUrl: media.poster,
                        width: cardWidth,
                        height: 160,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        errorImage:
                            'https://s4.anilist.co/file/anilistcdn/character/large/default.jpg',
                      ),
                    ),
                  ),
                ),
                if (badgeText != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      unawaited(handleQuickAddTap(
                        context,
                        media.data,
                        itemType,
                      ));
                    },
                    onLongPress: () {
                      MediaPeekPopup.show(
                        context,
                        media.data,
                        itemType,
                        '${media.id}-${itemType.name}-quick-add',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHigh.withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        media.data.userStatus != null &&
                                media.data.userStatus!.isNotEmpty
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        size: 14,
                        color: media.data.userStatus != null &&
                                media.data.userStatus!.isNotEmpty
                            ? context.colors.primary
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildEpisodeChip(context, media),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (data is Media &&
                ((variant ?? CardVariant.onlinelist) != CardVariant.search))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isManga ? Iconsax.book : Icons.movie_filter_rounded,
                      color: Colors.grey, size: 16),
                  const SizedBox(width: 2),
                  AnymexText(
                    text: isManga ? "MANGA" : 'ANIME',
                    maxLines: 1,
                    variant: TextVariant.regular,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    size: 12,
                  ),
                ],
              ),
            const SizedBox(height: 5),
            SizedBox(
              width: cardWidth,
              child: AnymexText(
                text: media.title,
                maxLines: 2,
                size: 14,
                variant: TextVariant.semiBold,
                isMarquee: true,
              ),
            ),
            const SizedBox(height: 3),
            if (media.episodeCount != 'N/A' && media.episodeCount != null)
              SizedBox(
                width: cardWidth,
                child: AnymexTextSpans(
                  text: '  |  ~',
                  maxLines: 1,
                  fontSize: 14,
                  spans: [
                    AnymexTextSpan(
                        text: "${media.episodeCount} ",
                        color: context.colors.primary,
                        variant: TextVariant.semiBold),
                    if (media.nextEpisode != null)
                      AnymexTextSpan(
                          text: "| ${media.nextEpisode} ",
                          color: Colors.grey,
                          variant: TextVariant.semiBold),
                    AnymexTextSpan(
                        text:
                            "| ${media.totalEpisodes == '0' ? '?' : media.totalEpisodes} ",
                        color: Colors.grey,
                        variant: TextVariant.semiBold),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeChip(BuildContext context, CardData media) {
    String displayScore = '0.0';
    if (media.score != null && media.score != '0' && media.score != '0.0') {
      final parsedScore = double.tryParse(media.score!);
      if (parsedScore != null) {
        if (parsedScore > 10) {
          displayScore = (parsedScore / 10).toStringAsFixed(1);
        } else {
          displayScore = parsedScore.toStringAsFixed(1);
        }
      } else {
        displayScore = media.score!;
      }
    } else if (media.rating != null &&
        media.rating != '0' &&
        media.rating != '0.0') {
      displayScore = media.rating!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.star5,
            size: 16,
            color: context.colors.onPrimary,
          ),
          const SizedBox(width: 4),
          AnymexText(
            text: displayScore,
            color: context.colors.onPrimary,
            size: 12,
            variant: TextVariant.bold,
          ),
        ],
      ),
    );
  }
}

class BlurAnimeCard extends StatelessWidget {
  final Media data;

  const BlurAnimeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      context.colors.surface.opaque(0.3),
      context.colors.primaryContainer.opaque(0.3),
      context.colors.primaryContainer.opaque(0.8),
    ];

    return AnymexOnTap(
      onTap: () {
        navigate(() => AnimeDetailsPage(media: data, tag: data.title));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border(
              right: BorderSide(width: 2, color: context.colors.primary)),
          borderRadius: BorderRadius.circular(12.multiplyRadius()),
          color: context.colors.surface.withAlpha(144),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.multiplyRadius()),
          child: Stack(children: [
            // Background image
            Positioned.fill(
              child: AnymeXImage(
                imageUrl: data.cover ?? data.poster,
                radius: 0,
                width: double.infinity,
              ),
            ),
            Positioned.fill(
              child: Blur(
                blur: 4,
                blurColor: Colors.transparent,
                child: Container(),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: gradientColors)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnymeXImage(
                  width: getResponsiveSize(context,
                      mobileSize: 120, desktopSize: 130),
                  height: getResponsiveSize(context,
                      mobileSize: 150, desktopSize: 180),
                  radius: 0,
                  imageUrl: data.poster,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: getResponsiveSize(context,
                                mobileSize: 10, desktopSize: 30)),
                        AnymexText(
                          text: "Episode ${data.nextAiringEpisode!.episode}",
                          size: 14,
                          maxLines: 2,
                          color: context.colors.primary,
                          variant: TextVariant.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        AnymexText(
                          text: data.title,
                          size: 14,
                          maxLines: 2,
                          variant: TextVariant.bold,
                          isMarquee: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Obx(() {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular((8.multiplyRadius())),
                    color: context.colors.primary,
                  ),
                  child: AnymexText(
                    text: '',
                    size: 12,
                    color: context.colors.onPrimary,
                    variant: TextVariant.bold,
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}

String? extractTitleBadge(String title, {String? format}) {
  final seasonRegex = RegExp(
    r'\b(?:Season\s*\d+|\d+(?:st|nd|rd|th)\s*Season|Part\s*\d+|Cour\s*\d+|S\d+)\b',
    caseSensitive: false,
  );
  final seasonMatch = seasonRegex.firstMatch(title);
  if (seasonMatch != null) {
    return seasonMatch.group(0);
  }

  final formatRegex = RegExp(
    r'\b(?:OVA|ONA|Specials?|Movie|TV\s*Special|Side\s*Story)\b',
    caseSensitive: false,
  );
  final formatMatch = formatRegex.firstMatch(title);
  if (formatMatch != null) {
    return formatMatch.group(0);
  }

  if (format != null) {
    final upperFormat = format.toUpperCase();
    if (upperFormat == 'OVA' ||
        upperFormat == 'ONA' ||
        upperFormat == 'SPECIAL' ||
        upperFormat == 'MOVIE') {
      return upperFormat;
    }
  }

  return null;
}

Future<void> handleQuickAddTap(
  BuildContext context,
  Media media,
  ItemType itemType,
) async {
  final defaultCategory =
      General.quickAddDefaultStatus.get<String>('PLANNING');

  if (defaultCategory == 'PROMPT' ||
      (media.userStatus != null && media.userStatus!.isNotEmpty)) {
    MediaPeekPopup.show(
      context,
      media,
      itemType,
      '${media.id}-${itemType.name}-quick-add',
    );
    return;
  }

  try {
    final serviceHandler = Get.find<ServiceHandler>();
    final isManga = itemType == ItemType.manga || itemType == ItemType.novel;
    final listId =
        serviceHandler.onlineService.currentMedia.value.id ?? media.id;
    await serviceHandler.onlineService.updateListEntry(UpdateListEntryParams(
      listId: listId,
      isAnime: !isManga,
      status: defaultCategory,
    ));
    final statusLabel = defaultCategory == 'PLANNING'
        ? 'Planning'
        : defaultCategory == 'CURRENT'
            ? (isManga ? 'Reading' : 'Watching')
            : 'Completed';
    snackBar('Added to $statusLabel');
  } catch (_) {
    MediaPeekPopup.show(
      context,
      media,
      itemType,
      '${media.id}-${itemType.name}-quick-add',
    );
  }
}
