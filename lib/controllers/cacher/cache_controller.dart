import 'dart:convert';

import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/database/kv_helper.dart';
import 'package:anymex/models/Media/media.dart';
import 'package:anymex/utils/logger.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:get/get.dart';

final cacheController = Get.find<CacheController>();

class CacheController extends GetxController {
  RxList<String> cachedAnilistData = <String>[].obs;
  RxList<String> cachedMalData = <String>[].obs;
  RxList<String> cachedSimklData = <String>[].obs;
  RxList<String> cachedExtensionData = <String>[].obs;

  RxString detailsData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPersistedCache();
  }

  void _loadPersistedCache() {
    try {
      cachedAnilistData.assignAll(KvHelper.get<List<dynamic>>('cache_anilist', defaultVal: []).cast<String>());
      cachedMalData.assignAll(KvHelper.get<List<dynamic>>('cache_mal', defaultVal: []).cast<String>());
      cachedSimklData.assignAll(KvHelper.get<List<dynamic>>('cache_simkl', defaultVal: []).cast<String>());
      cachedExtensionData.assignAll(KvHelper.get<List<dynamic>>('cache_extension', defaultVal: []).cast<String>());
    } catch (e) {
      Logger.e('Error loading persisted cache: $e');
    }
  }

  void _savePersistedCache() {
    try {
      final service = Get.find<ServiceHandler>().serviceType;
      switch (service.value) {
        case ServicesType.anilist:
          KvHelper.set('cache_anilist', cachedAnilistData.toList());
          break;
        case ServicesType.mal:
          KvHelper.set('cache_mal', cachedMalData.toList());
          break;
        case ServicesType.simkl:
          KvHelper.set('cache_simkl', cachedSimklData.toList());
          break;
        default:
          KvHelper.set('cache_extension', cachedExtensionData.toList());
      }
    } catch (e) {
      Logger.e('Error saving persisted cache: $e');
    }
  }

  RxList<String> get currentPool => getCacheContainer();

  void addCache(Map<String, dynamic> data) {
    if (!data.containsKey('id') ||
        data['id'] == null ||
        data['id'].toString().isEmpty) {
      Logger.i('Error: Invalid or missing ID in data');
      return;
    }

    final String id = data['id'].toString();
    final String encodedData = jsonEncode(data);

    detailsData.value = encodedData;

    final storedData = getStoredAnime();

    final index = storedData.indexWhere((e) => e.id == id);

    if (index == -1) {
      if (!currentPool.any((item) => jsonDecode(item)['id'] == id)) {
        currentPool.add(encodedData);
        Logger.i('Added new entry to cache: ID $id');
      } else {
        Logger.i('Duplicate entry in currentPool skipped: ID $id');
      }
    } else {
      if (index < currentPool.length) {
        currentPool[index] = encodedData;
        Logger.i('Updated existing entry in cache: ID $id');
      } else {
        Logger.i(
            'Warning: currentPool index out of sync for ID $id, adding as new');
        currentPool.add(encodedData);
      }
    }
    _savePersistedCache();
  }

  List<Media> getStoredAnime() {
    return currentPool
        .map((e) => cacheDataParser(e))
        .toList()
        .reversed
        .toList();
  }

  Media? getCacheById(String id) {
    final pool = getCacheContainer();
    final item = pool.firstWhereOrNull(
        (e) => e.contains('"id":$id') || e.contains('"id":"$id"'));
    if (item != null) {
      return cacheDataParser(item);
    }
    return null;
  }

  Media cacheDataParser(String data) {
    final service = Get.find<ServiceHandler>().serviceType;
    Map<String, dynamic> parsedMap = jsonDecode(data);
    switch (service.value) {
      case ServicesType.anilist:
        return Media.fromJson(parsedMap);
      case ServicesType.mal:
        return Media.fromFullMAL(parsedMap);
      case ServicesType.simkl:
        final dynamic marker = parsedMap['__isMovie'];
        final bool isMovie = marker is bool ? marker : true;
        return Media.fromSimkl(parsedMap, isMovie);
      default:
        parsedMap['status'] = parseStatusToInt(parsedMap['status']);
        return Media.froDMedia(
            DMedia.fromJson(parsedMap),
            serviceHandler.extensionService.lastUpdatedSource.value == "ANIME"
                ? ItemType.anime
                : ItemType.manga);
    }
  }

  RxList<String> getCacheContainer() {
    final service = Get.find<ServiceHandler>().serviceType;
    switch (service.value) {
      case ServicesType.anilist:
        return cachedAnilistData;
      case ServicesType.mal:
        return cachedMalData;
      case ServicesType.simkl:
        return cachedSimklData;
      default:
        return cachedExtensionData;
    }
  }
}

int parseStatusToInt(String status) {
  switch (status) {
    case 'ONGOING':
      return 0;
    case 'COMPLETED':
      return 1;
    case 'ONHIATUS':
      return 2;
    case 'CANCELED':
      return 3;
    case 'PUBLISHINGFINISHED':
      return 4;
    default:
      return -1;
  }
}
