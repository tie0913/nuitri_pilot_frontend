import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class AppendableListPanel extends StatefulWidget {
  final String tag;

  const AppendableListPanel({super.key, required this.tag});

  @override
  State<AppendableListPanel> createState() => _AppendableListPanelState();
}

class _AppendableListPanelState extends State<AppendableListPanel> {
  bool _loading = true;
  bool _error = false;

  List<CatagoryItem> _items = [];
  Set<String> _selected = {};
  String _query = '';
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final result =
        await DI.I.wellnessService.getWellnessCatagory(widget.tag);

    if (!mounted) return;

    if (await DI.I.messageHandler.doIfErr(result)) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    final cat = (result as OK).value;

    setState(() {
      _applyLoaded(cat);
      _loading = false;
    });
  }

  void _applyLoaded(WellnessCatagory? cat) {
    if (cat == null) return;

    _items = List.from(cat.items);
    _selected = cat.selectedIds.toSet();
    _query = '';
    _dirty = false;
  }

  void _toggleItem(CatagoryItem item, bool value) {
    setState(() {
      if (value) {
        _selected.add(item.id);
      } else {
        _selected.remove(item.id);
      }
      _dirty = true;
    });
  }

  Future<void> _addNewItem() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add new item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) =>
              Navigator.of(ctx).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final result =
        await DI.I.wellnessService.addItem(widget.tag, trimmed);

    if (!mounted) return;

    if (!await DI.I.messageHandler.doIfErr(result)) {
      final created = (result as OK).value;

      setState(() {
        if (!_items.any((e) => e.id == created.id)) {
          _items.add(created);
        }
        _selected.add(created.id);
        _dirty = true;
        _query = '';
      });
    }
  }

  Future<void> _save() async {
    final result = await DI.I.wellnessService.saveUserSelection(
      widget.tag,
      _selected.toList(),
    );

    if (!mounted) return;

    if (!await DI.I.messageHandler.doIfErr(result)) {
      setState(() => _dirty = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  List<CatagoryItem> _filtered() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Loading failed'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final visible = _filtered();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Add new',
                  child: IconButton(
                    onPressed: _addNewItem,
                    icon:
                        const Icon(Icons.add_circle_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No results. Try another keyword.',
                  ),
                ),
              )
            else
              ...visible.map((item) {
                final checked =
                    _selected.contains(item.id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) =>
                      _toggleItem(item, v ?? false),
                  title: Text(item.name),
                  controlAffinity:
                      ListTileControlAffinity.leading,
                );
              }),
          ],
        ),
        if (_dirty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              color: Theme.of(context)
                  .colorScheme
                  .surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                          16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'You have unsaved changes',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Discard'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(
                            Icons.save_outlined),
                        label:
                            const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}