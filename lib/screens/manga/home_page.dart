// ignore_for_file: invalid_use_of_protected_member

import 'package:anymex/controllers/source/source_controller.dart';
import 'package:anymex/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/widgets/common/installed_extensions_gridview.dart';
import 'package:anymex/widgets/common/scroll_aware_app_bar.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';

import 'package:anymex/widgets/custom_widgets/anymex_tabbar.dart';

class MangaHomePage extends StatefulWidget {
  const MangaHomePage({
    super.key,
  });

  @override
  State<MangaHomePage> createState() => _MangaHomePageState();
}

class _MangaHomePageState extends State<MangaHomePage> {
  late ScrollController _scrollController;
  final ValueNotifier<bool> _isAppBarVisibleExternally =
      ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    sourceController.initNovelExtensions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isAppBarVisibleExternally.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourceController = Get.find<SourceController>();
    final serviceHandler = Get.find<ServiceHandler>();
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (serviceHandler.serviceType.value == ServicesType.extensions) {
                  return InstalledExtensionsGridView(
                    sources: sourceController.installedMangaExtensions.value,
                    itemType: ItemType.manga,
                  );
                }
                return Column(
                  children: serviceHandler.mangaWidgets(context),
                );
              }),
              if (!isDesktop)
                SizedBox(height: bottomNavBarHeight)
              else
                const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
