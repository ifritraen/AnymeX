import 'package:anymex/controllers/settings/settings.dart';
import 'package:anymex/models/Media/media.dart';
import 'package:anymex/utils/extension_utils.dart';
import 'package:anymex/widgets/common/cards/card_gate.dart';
import 'package:anymex/widgets/common/reusable_carousel.dart';
import 'package:anymex/widgets/custom_widgets/custom_text.dart';
import 'package:anymex_extension_runtime_bridge/anymex_extension_runtime_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewAllGridScreen extends StatefulWidget {
  final String title;
  final List<dynamic> mediaList;
  final ItemType itemType;

  const ViewAllGridScreen({
    super.key,
    required this.title,
    required this.mediaList,
    this.itemType = ItemType.anime,
  });

  @override
  State<ViewAllGridScreen> createState() => _ViewAllGridScreenState();
}

class _ViewAllGridScreenState extends State<ViewAllGridScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<dynamic> _filteredList;

  @override
  void initState() {
    super.initState();
    _filteredList = widget.mediaList;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredList = widget.mediaList;
      });
    } else {
      setState(() {
        _filteredList = widget.mediaList.where((item) {
          final title = item is Media
              ? (item.title ?? '')
              : item.toString();
          return title.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final cardStyle = CardStyle.values[Get.find<Settings>().cardStyle];

    return Scaffold(
      appBar: AppBar(
        title: AnymexText(
          text: widget.title,
          variant: TextVariant.bold,
          size: 18,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Filter ${widget.title}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: AnymexText(
                      text: 'No items found',
                      variant: TextVariant.semiBold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 6 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: getCardHeight(cardStyle, isDesktop),
                    ),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      final tag = '${widget.title}_${index}_${item.id ?? index}';
                      return MediaCardGate(
                        itemData: item,
                        tag: tag,
                        variant: DataVariant.regular,
                        cardStyle: cardStyle,
                        type: widget.itemType,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
