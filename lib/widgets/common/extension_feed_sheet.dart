import 'dart:convert';
import 'package:anymex/database/data_keys/keys.dart';
import 'package:anymex/utils/theme_extensions.dart';
import 'package:anymex/widgets/custom_widgets/anymex_image.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ExtensionFeedItemConfig {
  final String sourceId;
  bool enabled;
  String feedType; // 'popular', 'latest', 'search'
  String searchQuery;

  ExtensionFeedItemConfig({
    required this.sourceId,
    this.enabled = true,
    this.feedType = 'popular',
    this.searchQuery = '',
  });

  Map<String, dynamic> toJson() => {
        'sourceId': sourceId,
        'enabled': enabled,
        'feedType': feedType,
        'searchQuery': searchQuery,
      };

  factory ExtensionFeedItemConfig.fromJson(Map<String, dynamic> json) {
    return ExtensionFeedItemConfig(
      sourceId: json['sourceId'] ?? '',
      enabled: json['enabled'] ?? true,
      feedType: json['feedType'] ?? 'popular',
      searchQuery: json['searchQuery'] ?? '',
    );
  }
}

class ExtensionFeedManager {
  static List<ExtensionFeedItemConfig> getConfig(
      ItemType type, List<Source> installedSources) {
    final raw = SourceKeys.extensionFeedConfig.get<String>('{}');
    Map<String, dynamic> map = {};
    try {
      map = jsonDecode(raw);
    } catch (_) {}

    final typeKey = type.name;
    final List<dynamic> listJson = map[typeKey] ?? [];
    final existingConfigs =
        listJson.map((e) => ExtensionFeedItemConfig.fromJson(e)).toList();

    final List<ExtensionFeedItemConfig> result = [];
    for (final cfg in existingConfigs) {
      if (installedSources.any((s) => s.id == cfg.sourceId)) {
        result.add(cfg);
      }
    }
    for (final src in installedSources) {
      if (!result.any((c) => c.sourceId == src.id)) {
        result.add(ExtensionFeedItemConfig(sourceId: src.id ?? src.name ?? ''));
      }
    }
    return result;
  }

  static void saveConfig(
      ItemType type, List<ExtensionFeedItemConfig> configs) {
    final raw = SourceKeys.extensionFeedConfig.get<String>('{}');
    Map<String, dynamic> map = {};
    try {
      map = jsonDecode(raw);
    } catch (_) {}

    map[type.name] = configs.map((c) => c.toJson()).toList();
    SourceKeys.extensionFeedConfig.set(jsonEncode(map));
  }
}

class ExtensionFeedSheet extends StatefulWidget {
  final ItemType itemType;
  final List<Source> installedSources;
  final VoidCallback onConfigSaved;

  const ExtensionFeedSheet({
    super.key,
    required this.itemType,
    required this.installedSources,
    required this.onConfigSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required ItemType itemType,
    required List<Source> installedSources,
    required VoidCallback onConfigSaved,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtensionFeedSheet(
        itemType: itemType,
        installedSources: installedSources,
        onConfigSaved: onConfigSaved,
      ),
    );
  }

  @override
  State<ExtensionFeedSheet> createState() => _ExtensionFeedSheetState();
}

class _ExtensionFeedSheetState extends State<ExtensionFeedSheet> {
  late List<ExtensionFeedItemConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = ExtensionFeedManager.getConfig(
        widget.itemType, widget.installedSources);
  }

  void _save() {
    ExtensionFeedManager.saveConfig(widget.itemType, _configs);
    widget.onConfigSaved();
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _configs = widget.installedSources
          .map((s) => ExtensionFeedItemConfig(sourceId: s.id ?? s.name ?? ''))
          .toList();
    });
  }

  Source? _findSource(String sourceId) {
    return widget.installedSources.cast<Source?>().firstWhere(
          (s) => s?.id == sourceId,
          orElse: () => widget.installedSources.isNotEmpty
              ? widget.installedSources.first
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.8;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      margin: EdgeInsets.fromLTRB(12, 0, 12, 16 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    HugeIcons.strokeRoundedFilter,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configure ${widget.itemType.name.toUpperCase()} Feed',
                      style: const TextStyle(
                        fontFamily: 'Poppins-Bold',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _configs.isEmpty
                  ? Center(
                      child: Text(
                        'No installed extensions found for ${widget.itemType.name}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: _configs.length,
                      onReorder: (oldIdx, newIdx) {
                        setState(() {
                          if (newIdx > oldIdx) newIdx -= 1;
                          final item = _configs.removeAt(oldIdx);
                          _configs.insert(newIdx, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final config = _configs[index];
                        final source = _findSource(config.sourceId);

                        return Container(
                          key: ValueKey(config.sourceId),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AnymeXImage(
                                      width: 28,
                                      height: 28,
                                      imageUrl: source?.iconUrl ?? '',
                                      errorImage: '',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          source?.name ?? 'Extension',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins-SemiBold',
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (source?.lang != null)
                                          Text(
                                            source!.lang!.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: config.enabled,
                                    onChanged: (val) {
                                      setState(() {
                                        config.enabled = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (config.enabled) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 36),
                                    const Text('Feed Type: ',
                                        style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 6),
                                    ChoiceChip(
                                      label: const Text('Popular',
                                          style: TextStyle(fontSize: 11)),
                                      selected: config.feedType == 'popular',
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() =>
                                              config.feedType = 'popular');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    ChoiceChip(
                                      label: const Text('Latest',
                                          style: TextStyle(fontSize: 11)),
                                      selected: config.feedType == 'latest',
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() =>
                                              config.feedType = 'latest');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    ChoiceChip(
                                      label: const Text('Search',
                                          style: TextStyle(fontSize: 11)),
                                      selected: config.feedType == 'search',
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() =>
                                              config.feedType = 'search');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                if (config.feedType == 'search') ...[
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 36),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Enter search query...',
                                        hintStyle: const TextStyle(fontSize: 12),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      controller: TextEditingController(
                                          text: config.searchQuery),
                                      style: const TextStyle(fontSize: 12),
                                      onChanged: (val) =>
                                          config.searchQuery = val,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save & Apply Feed'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
