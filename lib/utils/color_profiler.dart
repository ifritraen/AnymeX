// ignore_for_file: deprecated_member_use

import 'package:anymex/controllers/settings/settings.dart';
import 'package:anymex/database/data_keys/keys.dart';
import 'package:anymex/screens/anime/watch/controller/player_controller.dart';
import 'package:anymex/utils/logger.dart';
import 'package:anymex/utils/player_core_visual_settings.dart';
import 'package:anymex/utils/shaders.dart';
import 'package:anymex/utils/theme_extensions.dart';
import 'package:anymex/widgets/common/custom_tiles.dart';
import 'package:anymex/widgets/common/slider_semantics.dart';
import 'package:anymex/widgets/custom_widgets/custom_expansion_tile.dart';
import 'package:anymex/widgets/custom_widgets/custom_text.dart';
import 'package:anymex/widgets/non_widgets/reusable_checkmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ColorProfileManager {

  static const Map<String, Map<String, int>> profiles = {
    "cinema": {
      "brightness": 2,
      "contrast": 12,
      "saturation": 8,
      "gamma": 5,
      "hue": 0,
    },
    "cinema_dark": {
      "brightness": -12,
      "contrast": 18,
      "saturation": 6,
      "gamma": 12,
      "hue": -1,
    },
    "cinema_hdr": {
      "brightness": 5,
      "contrast": 22,
      "saturation": 12,
      "gamma": 3,
      "hue": -1,
    },
    "anime": {
      "brightness": 10,
      "contrast": 22,
      "saturation": 30,
      "gamma": -3,
      "hue": 3,
    },
    "anime_vibrant": {
      "brightness": 14,
      "contrast": 28,
      "saturation": 42,
      "gamma": -6,
      "hue": 4,
    },
    "anime_soft": {
      "brightness": 8,
      "contrast": 16,
      "saturation": 25,
      "gamma": -1,
      "hue": 2,
    },
    "anime_4k": {
      "brightness": 0,
      "contrast": 20,
      "saturation": 100,
      "gamma": 1,
      "hue": 2,
    },
    "vivid": {
      "brightness": 8,
      "contrast": 25,
      "saturation": 35,
      "gamma": 2,
      "hue": 1,
    },
    "vivid_pop": {
      "brightness": 12,
      "contrast": 32,
      "saturation": 48,
      "gamma": 4,
      "hue": 2,
    },
    "vivid_warm": {
      "brightness": 6,
      "contrast": 24,
      "saturation": 32,
      "gamma": 1,
      "hue": 8,
    },
    "natural": {
      "brightness": 0,
      "contrast": 0,
      "saturation": 0,
      "gamma": 0,
      "hue": 0,
    },
    "dark": {
      "brightness": -18,
      "contrast": 15,
      "saturation": -8,
      "gamma": 15,
      "hue": -2,
    },
    "warm": {
      "brightness": 3,
      "contrast": 10,
      "saturation": 15,
      "gamma": 2,
      "hue": 6,
    },
    "cool": {
      "brightness": 1,
      "contrast": 8,
      "saturation": 12,
      "gamma": 1,
      "hue": -6,
    },
    "grayscale": {
      "brightness": 2,
      "contrast": 20,
      "saturation": -100,
      "gamma": 8,
      "hue": 0,
    },
    "custom": {
      "brightness": 0,
      "contrast": 0,
      "saturation": 0,
      "gamma": 0,
      "hue": 0,
    },
  };

  static const Map<String, String> profileDescriptions = {
    "cinema": "Balanced colors for movie watching",
    "cinema_dark": "Optimized for dark room cinema viewing",
    "cinema_hdr": "Enhanced cinema with HDR-like contrast",
    "anime": "Enhanced colors perfect for animation",
    "anime_vibrant": "Maximum saturation for colorful anime",
    "anime_soft": "Gentle enhancement for pastel anime",
    "anime_4k": "Ultra-sharp with vibrant 4K clarity",
    "vivid": "Bright and punchy colors",
    "vivid_pop": "Maximum vibrancy for eye-catching content",
    "vivid_warm": "Vivid colors with warm temperature",
    "natural": "Default balanced settings",
    "dark": "Optimized for dark environments",
    "warm": "Warmer tones for comfort viewing",
    "cool": "Cooler tones for clarity",
    "grayscale": "Black and white viewing",
    "custom": "Your personalized settings",
  };

  static const Map<String, IconData> profileIcons = {
    "cinema": Icons.movie,
    "cinema_dark": Icons.movie_outlined,
    "cinema_hdr": Icons.hd,
    "anime": Icons.animation,
    "anime_vibrant": Icons.color_lens,
    "anime_soft": Icons.blur_on,
    "anime_4k": Icons.four_k,
    "vivid": Icons.palette,
    "vivid_pop": Icons.auto_awesome,
    "vivid_warm": Icons.wb_sunny,
    "natural": Icons.nature,
    "dark": Icons.dark_mode,
    "warm": Icons.wb_sunny,
    "cool": Icons.ac_unit,
    "grayscale": Icons.gradient,
    "custom": Icons.tune,
  };

  static Map<String, Map<String, int>> getCustomProfiles() {
    final raw = PlayerUiKeys.customColorProfiles.get<Map<String, dynamic>>({});
    Map<String, Map<String, int>> result = {};
    if (raw.isNotEmpty) {
      raw.forEach((name, map) {
        if (map is Map) {
          result[name.toString()] = map.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      });
    }
    if (result.isEmpty) {
      final oldSingle = PlayerUiKeys.customColorProfile.get<Map<String, dynamic>>({});
      if (oldSingle.isNotEmpty) {
        final converted = oldSingle.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        result["Custom 1"] = converted;
        PlayerUiKeys.customColorProfiles.set(result);
      }
    }
    return result;
  }

  static Future<void> saveCustomProfiles(Map<String, Map<String, int>> customProfiles) async {
    PlayerUiKeys.customColorProfiles.set(customProfiles);
  }

  static Future<void> saveCustomProfile(String name, Map<String, int> settings) async {
    final customProfiles = getCustomProfiles();
    customProfiles[name] = settings;
    await saveCustomProfiles(customProfiles);
    PlayerUiKeys.customColorProfile.set(settings);
  }

  static Future<void> deleteCustomProfile(String name) async {
    final customProfiles = getCustomProfiles();
    customProfiles.remove(name);
    await saveCustomProfiles(customProfiles);
    if (customProfiles.isNotEmpty) {
      PlayerUiKeys.customColorProfile.set(customProfiles.values.first);
    }
  }

  static Future<void> renameCustomProfile(String oldName, String newName) async {
    final customProfiles = getCustomProfiles();
    if (customProfiles.containsKey(oldName)) {
      final settings = customProfiles.remove(oldName)!;
      customProfiles[newName] = settings;
      await saveCustomProfiles(customProfiles);
    }
  }

  Future<void> applyColorProfile(String profile, dynamic player) async {
    final customProfiles = getCustomProfiles();
    Map<String, int>? settings;

    if (customProfiles.containsKey(profile)) {
      settings = customProfiles[profile];
    } else if (profile.startsWith('custom:')) {
      final customName = profile.substring(7);
      if (customProfiles.containsKey(customName)) {
        settings = customProfiles[customName];
      } else if (customProfiles.isNotEmpty) {
        settings = customProfiles.values.first;
      }
    } else if (profile.toLowerCase() == 'custom') {
      if (customProfiles.isNotEmpty) {
        settings = customProfiles.values.first;
      } else {
        final savedMap = PlayerUiKeys.customColorProfile.get<Map<String, dynamic>>({});
        if (savedMap.isNotEmpty) {
          settings = savedMap.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      }
    } else {
      settings = profiles[profile.toLowerCase()];
    }

    if (settings != null && player.platform != null) {
      try {
        for (final entry in settings.entries) {
          await (player.platform as dynamic)
              .setProperty(entry.key, entry.value.toString());
          Logger.i('Applied ${entry.key}: ${entry.value}');
        }
      } catch (e) {
        Logger.i('Error applying color profile: $e');
      }
    }
  }

  Future<void> applyCustomSettings(
      Map<String, int> customSettings, dynamic player) async {
    PlayerUiKeys.customColorProfile.set(customSettings);
    if (player.platform != null) {
      try {
        for (final entry in customSettings.entries) {
          await (player.platform as dynamic)
              .setProperty(entry.key, entry.value.toString());
        }
      } catch (e) {
        Logger.i('Error applying custom settings: $e');
      }
    }
  }

  Future<void> resetToNatural(dynamic player) async {
    await applyColorProfile('natural', player);
  }

  Future<void> resetShader(dynamic player) async {
    try {
      if (player.platform != null) {
        await PlayerShaders.setShaders(player, "Default");
        Logger.i('Shader reset to Default');
      }
    } catch (e) {
      Logger.i('Error resetting shader: $e');
    }
  }
}

class ColorProfileBottomSheet extends StatefulWidget {
  final String currentProfile;
  final Map<String, int> activeSettings;
  final Function(String) onProfileSelected;
  final Function(Map<String, int>) onCustomSettingsChanged;
  final dynamic player;

  const ColorProfileBottomSheet({
    super.key,
    required this.currentProfile,
    required this.activeSettings,
    required this.onProfileSelected,
    required this.onCustomSettingsChanged,
    required this.player,
  });

  static Future<void> showColorProfileSheet(
      BuildContext context, PlayerController controller, dynamic player) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final panelWidth =
        MediaQuery.of(context).size.width * (isLandscape ? 0.45 : 0.85);

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Color Profile',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: panelWidth,
              height: double.infinity,
              child: ColorProfileBottomSheet(
                activeSettings: controller.customSettings.value,
                currentProfile: controller.currentVisualProfile.value,
                player: player,
                onProfileSelected: (profile) {
                  controller.currentVisualProfile.value = profile;
                  PlayerUiKeys.currentVisualProfile.set(profile);
                },
                onCustomSettingsChanged: (sett) {
                  controller.customSettings.value = sett;
                  PlayerUiKeys.currentVisualSettings.set(sett);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<ColorProfileBottomSheet> createState() =>
      _ColorProfileBottomSheetState();
}

class _ColorProfileBottomSheetState extends State<ColorProfileBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedProfile = '';
  String _selectedShader = '';
  Map<String, int> _customSettings = {
    "brightness": 0,
    "contrast": 0,
    "saturation": 0,
    "gamma": 0,
    "hue": 0,
  };
  late Map<String, dynamic> _visualSettings;
  bool _areShadersDownloaded = false;

  bool get _experimentalEnabled =>
      PlayerUiKeys.playerExperimentalEnabled.get<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedProfile = widget.currentProfile;
    _selectedShader = settingsController.selectedShader.isEmpty
        ? "Default"
        : settingsController.selectedShader;
    final savedCustom = PlayerUiKeys.customColorProfile.get<Map<String, dynamic>>({});
    if (widget.currentProfile.toLowerCase() == 'custom') {
      _customSettings = Map.from(widget.activeSettings);
    } else if (savedCustom.isNotEmpty) {
      _customSettings = Map<String, int>.from(
          savedCustom.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
    } else {
      _customSettings = Map.from(ColorProfileManager.profiles['natural']!);
    }
    _visualSettings = PlayerCoreVisualSettings.getMpvVisualSettings();
    _checkShaders();
  }

  Future<void> _checkShaders() async {
    final downloaded = await PlayerShaders.areShadersDownloaded();
    if (mounted) {
      setState(() {
        _areShadersDownloaded = downloaded;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProfileAppliedFeedback(String profileName) {
    HapticFeedback.lightImpact();
    Logger.i('Applied ${profileName.toUpperCase()} profile');
  }

  Future<void> _applyCustomSettings() async {
    setState(() => _selectedProfile = 'custom');
    await ColorProfileManager()
        .applyCustomSettings(_customSettings, widget.player);
    widget.onProfileSelected('custom');
    widget.onCustomSettingsChanged(_customSettings);
    _showProfileAppliedFeedback('Custom');
  }

  Future<void> _resetShaderToDefault() async {
    setState(() {
      _selectedShader = "Default";
    });
    if (Get.isRegistered<PlayerController>()) {
      await Get.find<PlayerController>().applyShader("Default");
    } else {
      await ColorProfileManager().resetShader(widget.player);
      settingsController.selectedShader = "Default";
      PlayerUiKeys.selectedShader.set("Default");
    }
    HapticFeedback.lightImpact();
    Logger.i('Shader reset to Default');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Shader reset to Default'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _resetPresetToNatural() async {
    setState(() {
      _selectedProfile = 'natural';
    });
    await ColorProfileManager().resetToNatural(widget.player);
    widget.onProfileSelected('natural');
    _showProfileAppliedFeedback('natural');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset to Natural profile'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _resetCustomToDefault() async {
    setState(() {
      _customSettings = Map.from(ColorProfileManager.profiles['natural']!);
    });
    await _applyCustomSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Custom settings reset to default'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _applyVisualSettings() async {
    if (!_experimentalEnabled) return;
    PlayerUiKeys.mpvVisualSettings.set(_visualSettings);
    await PlayerCoreVisualSettings.applyMpvVisualSettings(widget.player);
  }

  Future<void> _resetVisualToDefault() async {
    setState(() {
      _visualSettings = Map<String, dynamic>.from(
        PlayerCoreVisualSettings.mpvVisualDefaults,
      );
    });
    await _applyVisualSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Visual settings reset to defaults'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Color Profiles',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.eye, size: 16),
                          SizedBox(width: 6),
                          AnymexText.semiBold(text: 'Shaders'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.movie_filter_rounded, size: 16),
                          SizedBox(width: 6),
                          AnymexText.semiBold(text: 'Visual'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dashboard_customize, size: 16),
                          SizedBox(width: 6),
                          AnymexText.semiBold(text: 'Presets'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune, size: 16),
                          SizedBox(width: 6),
                          AnymexText.semiBold(text: 'Custom'),
                        ],
                      ),
                    ),
                  ],
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildShadersTab(theme),
            _buildVisualTab(theme),
            _buildPresetsTab(theme),
            _buildCustomTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildShadersTab(ThemeData theme) {
    bool enableShaders = PlayerUiKeys.shadersEnabled.get<bool>(false) && _areShadersDownloaded;
    return Column(
      children: [
        Expanded(
          child: Opacity(
            opacity: enableShaders ? 1 : 0.3,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.opaque(0.3),
                        theme.colorScheme.secondaryContainer.opaque(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          enableShaders
                              ? 'Choose a shader that matches your viewing preference'
                              : 'Shaders are not installed or disabled. Enable and download them from Settings > Experimental',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AnymexExpansionTile(
                  title: 'ANIME 4K',
                  initialExpanded: true,
                  content: Obx(() {
                    final shaders = ["Default", ...PlayerShaders.getShaders()];
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 64,
                      ),
                      itemCount: shaders.length,
                      itemBuilder: (context, index) {
                        final shader = shaders[index];
                        final isSelected = shader == "Default"
                            ? settingsController.selectedShader.isEmpty ||
                                settingsController.selectedShader == shader
                            : settingsController.selectedShader == shader;

                        return IgnorePointer(
                          ignoring: !enableShaders,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setShaders(shader),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            theme.colorScheme.primaryContainer,
                                            theme.colorScheme.primaryContainer.opaque(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : theme.colorScheme.surfaceVariant.opaque(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                                      : Border.all(color: theme.colorScheme.outline.opaque(0.2), width: 1),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.opaque(0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        shader,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: isSelected
                                              ? theme.colorScheme.onPrimaryContainer
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: theme.colorScheme.onPrimary,
                                          size: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton.icon(
            onPressed: enableShaders ? _resetShaderToDefault : null,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset Shader to Default', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Future<void> setShaders(String message, {bool backOut = true}) async {
    if (Get.isRegistered<PlayerController>()) {
      await Get.find<PlayerController>().applyShader(message);
    } else {
      await PlayerShaders.setShaders(widget.player, message);
      settingsController.selectedShader = message == "Default" ? "" : message;
      PlayerUiKeys.selectedShader.set(message == "Default" ? "" : message);
    }
    setState(() {
      _selectedShader = message;
    });
    HapticFeedback.lightImpact();
    if (backOut) {
      Navigator.pop(context);
    }
  }

  Future<void> _showSaveCustomProfileDialog({String? defaultName}) async {
    final customProfiles = ColorProfileManager.getCustomProfiles();
    final nameController = TextEditingController(
        text: defaultName ?? 'Custom ${customProfiles.length + 1}');

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Custom Profile'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Profile Name',
              hintText: 'Enter profile name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = nameController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await ColorProfileManager.saveCustomProfile(result, _customSettings);
      setState(() {
        _selectedProfile = result;
      });
      await ColorProfileManager().applyColorProfile(result, widget.player);
      widget.onProfileSelected(result);
      widget.onCustomSettingsChanged(_customSettings);
      _showProfileAppliedFeedback(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved profile "$result"'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showRenameCustomProfileDialog(String oldName) async {
    final nameController = TextEditingController(text: oldName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Profile'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Profile Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = nameController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != oldName) {
      await ColorProfileManager.renameCustomProfile(oldName, result);
      setState(() {
        if (_selectedProfile == oldName) {
          _selectedProfile = result;
        }
      });
      widget.onProfileSelected(_selectedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Renamed to "$result"'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteCustomProfile(String name) async {
    await ColorProfileManager.deleteCustomProfile(name);
    setState(() {
      if (_selectedProfile == name) {
        _selectedProfile = 'natural';
      }
    });
    if (_selectedProfile == 'natural') {
      await ColorProfileManager().resetToNatural(widget.player);
      widget.onProfileSelected('natural');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted profile "$name"'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildPresetsTab(ThemeData theme) {
    final customProfiles = ColorProfileManager.getCustomProfiles();
    Map<String, List<String>> groupedProfiles = {
      'Anime': ['anime_4k', 'anime', 'anime_vibrant', 'anime_soft'],
      'Cinema': ['cinema', 'cinema_dark', 'cinema_hdr'],
      'Vivid': ['vivid', 'vivid_pop', 'vivid_warm'],
      'Other': ['natural', 'dark', 'warm', 'cool', 'grayscale'],
    };

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.opaque(0.3),
                      theme.colorScheme.secondaryContainer.opaque(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose a preset that matches your viewing preference',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnymexExpansionTile(
                title: 'Custom',
                initialExpanded: true,
                content: Column(
                  children: [
                    ...customProfiles.entries.map((entry) {
                      final customName = entry.key;
                      final isSelected = _selectedProfile == customName ||
                          _selectedProfile == 'custom:$customName';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                _selectedProfile = customName;
                                _customSettings = Map.from(entry.value);
                              });
                              await ColorProfileManager()
                                  .applyColorProfile(customName, widget.player);
                              widget.onProfileSelected(customName);
                              widget.onCustomSettingsChanged(_customSettings);
                              _showProfileAppliedFeedback(customName);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          theme.colorScheme.primaryContainer,
                                          theme.colorScheme.primaryContainer
                                              .opaque(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : theme.colorScheme.surfaceVariant
                                        .opaque(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                    : Border.all(
                                        color: theme.colorScheme.outline
                                            .opaque(0.2),
                                        width: 1,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .opaque(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary,
                                                theme.colorScheme.primary
                                                    .opaque(0.8),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.tune,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customName.toUpperCase(),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? theme.colorScheme
                                                    .onPrimaryContainer
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Custom user profile',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme
                                                    .onPrimaryContainer
                                                    .opaque(0.8)
                                                : theme.colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    onSelected: (val) {
                                      if (val == 'rename') {
                                        _showRenameCustomProfileDialog(
                                            customName);
                                      } else if (val == 'delete') {
                                        _deleteCustomProfile(customName);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'rename',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Rename'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                size: 18, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: theme.colorScheme.onPrimary,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => _showSaveCustomProfileDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Custom Profile'),
                    ),
                  ],
                ),
              ),
              ...groupedProfiles.entries.map((category) {
                return AnymexExpansionTile(
                  title: category.key,
                  initialExpanded: true,
                  content: Column(
                    children: category.value.map((profileKey) {
                      final isSelected = _selectedProfile == profileKey;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              setState(() => _selectedProfile = profileKey);
                              await ColorProfileManager()
                                  .applyColorProfile(profileKey, widget.player);
                              widget.onProfileSelected(profileKey);
                              _showProfileAppliedFeedback(profileKey);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          theme.colorScheme.primaryContainer,
                                          theme.colorScheme.primaryContainer
                                              .opaque(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : theme.colorScheme.surfaceVariant
                                        .opaque(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                    : Border.all(
                                        color: theme.colorScheme.outline
                                            .opaque(0.2),
                                        width: 1,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .opaque(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary,
                                                theme.colorScheme.primary
                                                    .opaque(0.8),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .opaque(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Icon(
                                      ColorProfileManager
                                          .profileIcons[profileKey],
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profileKey
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? theme.colorScheme
                                                    .onPrimaryContainer
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ColorProfileManager
                                                      .profileDescriptions[
                                                  profileKey] ??
                                              '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme
                                                    .onPrimaryContainer
                                                    .opaque(0.8)
                                                : theme.colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: theme.colorScheme.onPrimary,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton.icon(
            onPressed: _resetPresetToNatural,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset to Natural Profile', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualTab(ThemeData theme) {
    if (!_experimentalEnabled) {
      return _buildVisualLockedState(theme);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.opaque(0.3),
                      theme.colorScheme.secondaryContainer.opaque(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These controls directly affect mpv rendering quality & picture output',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildVisualSwitchTile(
                keyName: 'deband',
                title: 'Deband',
                description: 'Reduce color banding in gradients',
                icon: Icons.gradient_rounded,
              ),
              _buildVisualSwitchTile(
                keyName: 'correctDownscaling',
                title: 'Correct Downscaling',
                description: 'Improve quality when scaling down video',
                icon: Icons.fit_screen_rounded,
              ),
              _buildVisualSwitchTile(
                keyName: 'sigmoidUpscaling',
                title: 'Sigmoid Upscaling',
                description: 'Reduce haloing while upscaling',
                icon: Icons.auto_fix_high_rounded,
              ),
              _buildVisualSwitchTile(
                keyName: 'temporalDither',
                title: 'Temporal Dither',
                description: 'Smoother gradients with slight temporal noise',
                icon: Icons.grain_rounded,
              ),
              _buildVisualSelectionTile(
                keyName: 'scale',
                title: 'Luma Upscaler',
                icon: Icons.zoom_in_map_rounded,
                items: const [
                  'bilinear',
                  'bicubic',
                  'spline36',
                  'ewa_lanczossharp',
                ],
              ),
              _buildVisualSelectionTile(
                keyName: 'cscale',
                title: 'Chroma Upscaler',
                icon: Icons.color_lens_rounded,
                items: const [
                  'bilinear',
                  'bicubic',
                  'spline36',
                  'ewa_lanczossharp',
                ],
              ),
              _buildVisualSelectionTile(
                keyName: 'dscale',
                title: 'Downscaler',
                icon: Icons.zoom_out_map_rounded,
                items: const ['bilinear', 'bicubic', 'mitchell', 'spline36'],
              ),
              _buildVisualSelectionTile(
                keyName: 'ditherDepth',
                title: 'Dither Depth',
                icon: Icons.blur_linear_rounded,
                items: const ['auto', '8', '10', '12'],
              ),
              _buildVisualSelectionTile(
                keyName: 'toneMapping',
                title: 'Tone Mapping',
                icon: Icons.hdr_auto_rounded,
                items: const ['auto', 'mobius', 'reinhard', 'hable', 'bt.2390'],
              ),
              _buildVisualSliderTile(
                keyName: 'debandIterations',
                title: 'Deband Iterations',
                description: 'More iterations = stronger debanding',
                icon: Icons.layers_rounded,
                min: 1,
                max: 4,
                divisions: 3,
              ),
              _buildVisualSliderTile(
                keyName: 'debandThreshold',
                title: 'Deband Threshold',
                description: 'Higher value increases debanding strength',
                icon: Icons.tune_rounded,
                min: 16,
                max: 128,
                divisions: 28,
              ),
              _buildVisualSliderTile(
                keyName: 'targetPeak',
                title: 'Target Peak',
                description: 'HDR tone mapping target peak',
                icon: Icons.brightness_6_rounded,
                min: 50,
                max: 1000,
                divisions: 38,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton.icon(
            onPressed: _resetVisualToDefault,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset Visual Settings', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualLockedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.opaque(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.opaque(0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.science_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Visual settings are experimental',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enable Experimental in Player Settings to use this tab.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualSwitchTile({
    required String keyName,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return CustomSwitchTile(
      icon: icon,
      title: title,
      description: description,
      switchValue: (_visualSettings[keyName] as bool?) ?? false,
      onChanged: (value) {
        setState(() => _visualSettings[keyName] = value);
        _applyVisualSettings();
      },
    );
  }

  Widget _buildVisualSelectionTile({
    required String keyName,
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    final current = (_visualSettings[keyName] as String?) ?? items.first;
    return CustomTile(
      icon: icon,
      title: title,
      description: current,
      isDescBold: true,
      descColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        showSelectionDialog<String>(
          title: title,
          items: items,
          selectedItem: current.obs,
          getTitle: (v) => v,
          onItemSelected: (v) {
            setState(() => _visualSettings[keyName] = v);
            _applyVisualSettings();
          },
          leadingIcon: icon,
        );
      },
    );
  }

  Widget _buildVisualSliderTile({
    required String keyName,
    required String title,
    required String description,
    required IconData icon,
    required double min,
    required double max,
    required int divisions,
  }) {
    final value = ((_visualSettings[keyName] as num?) ?? min).toDouble();
    return CustomSliderTile(
      icon: icon,
      title: title,
      description: description,
      sliderValue: value.clamp(min, max),
      min: min,
      max: max,
      divisions: divisions.toDouble(),
      label: value.round().toString(),
      onChanged: (newValue) {
        setState(() => _visualSettings[keyName] = newValue.round());
        _applyVisualSettings();
      },
    );
  }

  Widget _buildCustomTab(ThemeData theme) {
    final customProfiles = ColorProfileManager.getCustomProfiles();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.opaque(0.3),
                      theme.colorScheme.secondaryContainer.opaque(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fine-tune individual settings to your preference',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (customProfiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: customProfiles.entries.map((entry) {
                      final name = entry.key;
                      final isSelected = _selectedProfile == name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(name),
                          onSelected: (selected) async {
                            if (selected) {
                              setState(() {
                                _selectedProfile = name;
                                _customSettings = Map.from(entry.value);
                              });
                              await ColorProfileManager()
                                  .applyColorProfile(name, widget.player);
                              widget.onProfileSelected(name);
                              widget.onCustomSettingsChanged(_customSettings);
                              _showProfileAppliedFeedback(name);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ..._customSettings.keys.map((setting) {
                return _buildSliderTile(setting, theme);
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () => _showSaveCustomProfileDialog(
                    defaultName: _selectedProfile.isNotEmpty &&
                            !ColorProfileManager.profiles
                                .containsKey(_selectedProfile)
                        ? _selectedProfile
                        : null),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save as Custom Preset',
                    style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _resetCustomToDefault,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset to Default Settings',
                    style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile(String setting, ThemeData theme) {
    final value = _customSettings[setting]!;
    final displayName = setting[0].toUpperCase() + setting.substring(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.opaque(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.opaque(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.opaque(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.opaque(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  value.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomSlider(
            value: value.toDouble(),
            min: -100,
            max: 100,
            divisions: 200,
            onChanged: (newValue) {
              setState(() {
                _customSettings[setting] = newValue.round();
              });
              _applyCustomSettings();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-100',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '100',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
