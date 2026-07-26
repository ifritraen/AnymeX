import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> itemBuilders;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.itemBuilders,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _initialized;

  @override
  void initState() {
    super.initState();
    _initialized = List<bool>.generate(
      widget.itemBuilders.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemBuilders.length != _initialized.length) {
      _initialized = List<bool>.generate(
        widget.itemBuilders.length,
        (i) => i < _initialized.length ? _initialized[i] : i == widget.index,
      );
    }
    if (widget.index < _initialized.length && !_initialized[widget.index]) {
      _initialized[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index >= widget.itemBuilders.length) {
      return const SizedBox.shrink();
    }
    if (!_initialized[widget.index]) {
      _initialized[widget.index] = true;
    }

    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List<Widget>.generate(
        widget.itemBuilders.length,
        (i) => _initialized[i]
            ? widget.itemBuilders[i](context)
            : const SizedBox.shrink(),
      ),
    );
  }
}
