import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final List<FeedItem> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  double _lastOffset = 0;
  bool _hasMore = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    _items.clear();
    await _fetchNextPage();
    if (mounted) setState(() {});
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    setState(() {});

    final String? lastId = _items.isNotEmpty ? _items.last.id : null;

    final Result<Error, List<FeedItem>?> result =
        await DI.I.suggestionSerivce.getSuggestionsList(lastId);

    if (!await DI.I.messageHandler.doIfErr(result)) {
      final ok = result as OK<Error, List<FeedItem>?>;
      final list = ok.value ?? <FeedItem>[];

      if (list.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(list);
        _hasMore = true;
      }
    }

    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  Future<void> _deleteRecord(FeedItem item) async {
    final Result<Error, bool> result =
        await DI.I.suggestionSerivce.deleteRecordById(item.id);

    if (!await DI.I.messageHandler.doIfErr(result)) {
      if ((result as OK<Error, bool>).value) {
        _items.remove(item);
        if (mounted) setState(() {});
      }
    }
  }

  void _onScroll() {
    print("scroll: ${_scrollController.position.pixels}");
    final pos = _scrollController.position;
    final double offset = pos.pixels;

    if (offset > _lastOffset &&
        offset >= pos.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        pos.userScrollDirection == ScrollDirection.reverse) {
      _fetchNextPage();
      _lastOffset = offset;
    }
  }

  // =========================
  // Modal helpers
  // =========================

  Future<T?> _showDraggableModal<T>({
    required Widget Function(BuildContext ctx, ScrollController sc)
        builderWithScroll,
    bool enableDragToClose = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      enableDrag: enableDragToClose,
      isDismissible: enableDragToClose,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          snap: false, // ✅ 关闭 snap，避免 pop 时抖一下
          builder: (sheetCtx, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: builderWithScroll(sheetCtx, scrollController),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openItemDetail(FeedItem item) {
    _showDraggableModal(
      builderWithScroll: (ctx, sc) {
        return _SuggestionSheetBody(
          scrollController: sc,
          image: Image.network(
            item.path,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image);
            },
          ),
          score: item.mark,
          feedback: item.feedback.explaination,
          recommendation: item.recommendation,
        );
      },
    );
  }

  // =========================
  // Image source picker
  // =========================

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final xfile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 92,
                  );
                  if (xfile != null && mounted) {
                    _startUploadFlow(xfile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select From Album'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final xfile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 92,
                  );
                  if (xfile != null && mounted) {
                    _startUploadFlow(xfile);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // Upload flow (重构后的核心)
  // =========================

  Future<void> _startUploadFlow(XFile xfile) async {
    final file = File(xfile.path);

    // 1) 先弹一个“不可拖拽不可关闭”的 loading modal（避免 DraggableSheet 动画冲突）
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UploadingView(file: file),
    );

    // 2) await 后端
    final Result<Error, FeedItem?> result = await _getSuggesstion(file);

    if (!mounted) return;

    // 3) 关掉 loading modal（这里 context 一定在）
    Navigator.of(context).pop();

    // 4) 失败：弹错
    if (result is Err) {
      DI.I.messageHandler.doIfErr(result);
      return;
    }

    // 5) 成功：插入列表 + 打开结果 draggable modal
    final FeedItem item = (result as OK<Error, FeedItem>).value;

    _items.insert(0, item);
    setState(() {});

    _showDraggableModal(
      builderWithScroll: (ctx, sc) {
        return _SuggestionSheetBody(
          scrollController: sc,
          image: Image.file(file, fit: BoxFit.cover),
          score: item.mark,
          feedback: item.feedback.explaination,
          recommendation: item.recommendation,
        );
      },
    );
  }

  Future<Result<Error, FeedItem?>> _getSuggesstion(File file) async {
    return await DI.I.suggestionSerivce.seekingSuggestion(file);
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SlidableAutoCloseBehavior(
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  // footer item
                  if (index == _items.length) {
                    if (_isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (!_hasMore) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'You are reaching my Bottom Line!',
                            style: Theme.of(ctx)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }

                  final item = _items[index];

                  return Slidable(
                    key: ValueKey(item.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.2,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _deleteRecord(item),
                          icon: Icons.delete,
                          backgroundColor: Colors.blueGrey,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: _FeedCard(
                      item: item,
                      onTap: () => _openItemDetail(item),
                    ),
                  );
                },
                childCount: _items.length + 1,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceActionSheet,
        tooltip: 'Add Photo',
        child: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// =========================
// Widgets
// =========================

class _FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const _FeedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(item.time);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Row(
            children: [
              _FeedImage(item: item, size: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: ${item.mark}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          formattedTime,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.feedback.explaination,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedImage extends StatelessWidget {
  final FeedItem item;
  final double size;

  const _FeedImage({required this.item, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final base64 = item.thumbnail.split(',').last;
    final bytes = base64Decode(base64);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String text;

  const _ResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _SuggestionSheetBody extends StatelessWidget {
  final ScrollController scrollController;
  final Widget image;
  final int score;
  final String feedback;
  final List<String> recommendation;

  const _SuggestionSheetBody({
    required this.scrollController,
    required this.image,
    required this.score,
    required this.feedback,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text('Suggestions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 200, child: image),
        ),
        const SizedBox(height: 16),
        _ResultCard(text: 'Score: $score'),
        const SizedBox(height: 8),
        _ResultCard(text: 'Feedback: $feedback'),
        const SizedBox(height: 12),
        if (recommendation.isNotEmpty) ...[
          Text('Recommendations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...recommendation.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(r, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// ✅ 新增：上传中视图（非 draggable，不会 pop 抖动）
class _UploadingView extends StatelessWidget {
  final File file;

  const _UploadingView({required this.file});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analyzing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover, height: 200),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'AI is working, please hold on ...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}