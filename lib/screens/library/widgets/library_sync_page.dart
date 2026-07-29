import 'dart:async';
import 'package:anymex/controllers/offline/offline_storage_controller.dart';
import 'package:anymex/controllers/service_handler/params.dart';
import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/database/isar_models/custom_list.dart';
import 'package:anymex/database/isar_models/offline_media.dart';
import 'package:anymex/models/Media/media.dart';
import 'package:anymex/utils/theme_extensions.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:anymex/widgets/custom_widgets/anymex_button.dart';
import 'package:anymex/widgets/custom_widgets/anymex_image.dart';
import 'package:anymex/widgets/custom_widgets/custom_text.dart';
import 'package:anymex/widgets/non_widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarySyncPage extends StatefulWidget {
  const LibrarySyncPage({super.key});

  @override
  State<LibrarySyncPage> createState() => _LibrarySyncPageState();
}

class _LibrarySyncPageState extends State<LibrarySyncPage> {
  final OfflineStorageController _storageCtrl = Get.find<OfflineStorageController>();
  bool _isLoading = true;
  List<CustomListGroupData> _categories = [];
  final Set<String> _selectedMediaIds = {};

  bool _isSyncing = false;
  int _syncProgress = 0;
  int _syncTotal = 0;
  bool _cancelSync = false;

  @override
  void initState() {
    super.initState();
    _loadLocalCategories();
  }

  Future<void> _loadLocalCategories() async {
    setState(() => _isLoading = true);
    final animeLists = await _storageCtrl.getCustomListsByType(ItemType.anime);
    final mangaLists = await _storageCtrl.getCustomListsByType(ItemType.manga);
    final novelLists = await _storageCtrl.getCustomListsByType(ItemType.novel);

    final allLists = [...animeLists, ...mangaLists, ...novelLists];
    final List<CustomListGroupData> loadedGroups = [];

    for (final customList in allLists) {
      if (customList.mediaIds == null || customList.mediaIds!.isEmpty) continue;
      final type = ItemType.values[customList.mediaTypeIndex.clamp(0, ItemType.values.length - 1)];
      final medias = await _storageCtrl.getMediaFromCustomList(customList.listName ?? 'Default', mediaType: type);
      if (medias.isNotEmpty) {
        loadedGroups.add(CustomListGroupData(
          listName: customList.listName ?? 'Default',
          mediaType: type,
          items: medias,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _categories = loadedGroups;
        _isLoading = false;
      });
    }
  }

  void _toggleSelectAllGroup(CustomListGroupData group, bool selected) {
    setState(() {
      for (final media in group.items) {
        if (media.mediaId != null) {
          if (selected) {
            _selectedMediaIds.add(media.mediaId!);
          } else {
            _selectedMediaIds.remove(media.mediaId!);
          }
        }
      }
    });
  }

  void _toggleMediaSelection(String mediaId) {
    setState(() {
      if (_selectedMediaIds.contains(mediaId)) {
        _selectedMediaIds.remove(mediaId);
      } else {
        _selectedMediaIds.add(mediaId);
      }
    });
  }

  String _statusFromCategoryName(String listName) {
    final name = listName.toLowerCase();
    if (name.contains('plan')) return 'PLANNING';
    if (name.contains('watch') || name.contains('read') || name.contains('current')) return 'CURRENT';
    if (name.contains('comple')) return 'COMPLETED';
    if (name.contains('pause')) return 'PAUSED';
    if (name.contains('drop')) return 'DROPPED';
    if (name.contains('repeat')) return 'REPEATING';
    return 'PLANNING';
  }

  Future<void> _startBulkSync() async {
    if (_selectedMediaIds.isEmpty) {
      snackBar('Please select at least 1 item to sync');
      return;
    }

    final serviceHandler = Get.find<ServiceHandler>();
    if (!serviceHandler.onlineService.isLoggedIn.value) {
      snackBar('Please log in to AniList first in Settings > Accounts');
      return;
    }

    final itemsToSync = <OfflineMediaSyncItem>[];
    for (final group in _categories) {
      final status = _statusFromCategoryName(group.listName);
      for (final item in group.items) {
        if (item.mediaId != null && _selectedMediaIds.contains(item.mediaId)) {
          itemsToSync.add(OfflineMediaSyncItem(
            mediaId: item.mediaId!,
            status: status,
            isAnime: group.mediaType == ItemType.anime,
            customList: group.listName.contains('Plan') ||
                    group.listName.contains('Watch') ||
                    group.listName.contains('Read') ||
                    group.listName.contains('Comple') ||
                    group.listName.contains('Pause') ||
                    group.listName.contains('Drop')
                ? null
                : group.listName,
          ));
        }
      }
    }

    setState(() {
      _isSyncing = true;
      _syncProgress = 0;
      _syncTotal = itemsToSync.length;
      _cancelSync = false;
    });

    for (int i = 0; i < itemsToSync.length; i++) {
      if (_cancelSync) break;
      final target = itemsToSync[i];

      try {
        await serviceHandler.onlineService.updateListEntry(UpdateListEntryParams(
          listId: target.mediaId,
          isAnime: target.isAnime,
          status: target.status,
          customLists: target.customList != null ? [target.customList!] : null,
        ));
      } catch (_) {}

      if (mounted) {
        setState(() {
          _syncProgress = i + 1;
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      snackBar(_cancelSync ? 'Sync cancelled' : 'Successfully synced $_syncTotal items to AniList!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Sync & Migration'),
        actions: [
          if (_selectedMediaIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: AnymexButton(
                  onTap: _startBulkSync,
                  height: 36,
                  color: colors.primary,
                  child: Text(
                    'Sync (${_selectedMediaIds.length})',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off_rounded, size: 48, color: colors.onSurfaceVariant),
                      const SizedBox(height: 12),
                      AnymexText(
                        text: 'No local library entries found to sync',
                        variant: TextVariant.bold,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final group = _categories[index];
                        final allSelected = group.items.every((m) => m.mediaId != null && _selectedMediaIds.contains(m.mediaId));
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: colors.surfaceContainerHighest.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colors.outline.withOpacity(0.1)),
                          ),
                          child: ExpansionTile(
                            shape: const Border(),
                            leading: Checkbox(
                              value: allSelected,
                              activeColor: colors.primary,
                              onChanged: (val) => _toggleSelectAllGroup(group, val ?? false),
                            ),
                            title: Text(
                              '${group.listName} (${group.items.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Target: ${_statusFromCategoryName(group.listName)}',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                            ),
                            children: group.items.map((item) {
                              final isSelected = item.mediaId != null && _selectedMediaIds.contains(item.mediaId);
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnymeXImage(
                                    width: 36,
                                    height: 48,
                                    imageUrl: item.poster ?? '',
                                  ),
                                ),
                                title: Text(
                                  item.name ?? 'Untitled',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  item.english ?? item.jname ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  activeColor: colors.primary,
                                  onChanged: (val) {
                                    if (item.mediaId != null) {
                                      _toggleMediaSelection(item.mediaId!);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    if (_isSyncing) _buildSyncingOverlay(context),
                  ],
                ),
    );
  }

  Widget _buildSyncingOverlay(BuildContext context) {
    final colors = context.colors;
    final progressPct = _syncTotal > 0 ? _syncProgress / _syncTotal : 0.0;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnymexText(
                text: 'Syncing to AniList...',
                variant: TextVariant.bold,
                size: 16,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progressPct,
                backgroundColor: colors.surfaceContainerHighest,
                color: colors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                '$_syncProgress / $_syncTotal items',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _cancelSync = true),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListGroupData {
  final String listName;
  final ItemType mediaType;
  final List<OfflineMedia> items;

  CustomListGroupData({
    required this.listName,
    required this.mediaType,
    required this.items,
  });
}

class OfflineMediaSyncItem {
  final String mediaId;
  final String status;
  final bool isAnime;
  final String? customList;

  OfflineMediaSyncItem({
    required this.mediaId,
    required this.status,
    required this.isAnime,
    this.customList,
  });
}
