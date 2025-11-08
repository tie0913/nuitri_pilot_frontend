import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class AppendableListPanel extends StatefulWidget {
  final String tag;

  const AppendableListPanel({super.key, required this.tag});

  @override
  State<AppendableListPanel> createState() => _AppendableListPanelState();
}

class _AppendableListPanelState extends State<AppendableListPanel> {
  late Future<WellnessCatagory?> _future;

  // 本地可编辑状态
  List<CatagoryItem> _items = [];
  Set<String> _selected = {}; // 用 Set 便于增删
  String _query = '';
  bool _dirty = false; // 有未保存改动

  @override
  void initState() {
    super.initState();
    _future = DI.I.wellnessService.getWellnessCatagory(widget.tag);
  }

  Future<void> _refresh() async {
    final f = DI.I.wellnessService.getWellnessCatagory(widget.tag);
    final cat = await f;
    if (!mounted) return;
    setState(() {
      _future = f;
      _applyLoaded(cat);
    });
  }

  void _applyLoaded(WellnessCatagory? cat) {
    if (cat == null) return;
    _items = cat.items;
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
          onSubmitted: (_) => Navigator.of(ctx).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final created = await DI.I.wellnessService.addItem(widget.tag, trimmed);
    if (!mounted || created == null) return;

    List<CatagoryItem> newItems = [];
    newItems.addAll(_items);
    if (!_items.contains(created)) {
      newItems.add(created);
    }

    setState(() {
      _items = newItems;
      _selected.add(created.id); // 新增默认选中
      _dirty = true;
      _query = ''; // 清空过滤，避免看不到新项
    });
  }

  Future<void> _save() async {
    bool succeed = await DI.I.wellnessService.saveUserSelection(
      widget.tag,
      _selected.toList(),
    );
    if (!mounted && !succeed) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  List<CatagoryItem> _filtered() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<WellnessCatagory?>(
        future: _future,
        builder: (context, snap) {
          // 首屏加载
          if (snap.connectionState == ConnectionState.waiting &&
              _items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // 加载成功后把数据灌入本地一次
          if (snap.hasData && _items.isEmpty) {
            _applyLoaded(snap.data);
          }
          // 错误占位（首屏）
          if (snap.hasError && _items.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      const Text('Loading data has error'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Reload'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final visible = _filtered();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), // 预留底部保存条
                children: [
                  // 顶部：搜索 + 新增
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
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Add new',
                        child: IconButton(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  // 列表/空态
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: const [
                          Icon(Icons.inbox_outlined, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'No results. Try a different keyword or add a new one.',
                          ),
                        ],
                      ),
                    )
                  else
                    ...visible.map((item) {
                      final checked = _selected.contains(item.id);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) => _toggleItem(item, v ?? false),
                        title: Text(item.name),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                ],
              ),

              // 底部保存条（有改动才显示）
              if (_dirty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(context).colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'You have unsaved changes',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 丢弃改动：重新拉取并覆盖本地
                                final cat = await DI.I.wellnessService
                                    .getWellnessCatagory(widget.tag);
                                if (!mounted) return;
                                setState(() => _applyLoaded(cat));
                              },
                              child: const Text('Discard'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
