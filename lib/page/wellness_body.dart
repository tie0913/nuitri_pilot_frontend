
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class WellnessBody extends StatelessWidget{
  const WellnessBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 四个分类
      child: Column(
        children: [
          // 顶部标签栏
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 2,
            child: TabBar(
              isScrollable: false,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: "Chronics"),
                Tab(text: "Allergies"),
                Tab(text: "Goals"),
                Tab(text: "Metrics"),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: const [
                //_ConditionsPanel(),
                ConditionsPanelStateful(),
                _AllergiesPanel(),
                _GoalsPanel(),
                _MetricsPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConditionsPanelStateful extends StatefulWidget {
  const ConditionsPanelStateful({super.key});

  @override
  State<ConditionsPanelStateful> createState() => _ConditionsPanelStatefulState();
}

class _ConditionsPanelStatefulState extends State<ConditionsPanelStateful> {
  late Future<UserChronic?> _future;

  @override
  void initState() {
    super.initState();
    _future = DI.I.wellnessService.getUserChronics();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = DI.I.wellnessService.getUserChronics(); // 重新拉取
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<UserChronic?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Text('加载失败：${snap.error}'),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: _refresh, child: const Text('重试')),
                    ],
                  ),
                ),
              ],
            );
          }

          final data = snap.data?.chronics?? const [];
          if (data.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                _PlaceholderPanel(
                  title: "Chronic Conditions",
                  description: "No conditions yet. Pull to refresh or add new.",
                  icon: Icons.favorite_outline,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = data[i];
              return ListTile(
                title: Text(c.name),
                leading: const Icon(Icons.health_and_safety_outlined),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}


class _ConditionsPanel extends StatelessWidget {
  const _ConditionsPanel();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: "Chronic Conditions",
      description: "View and manage your chronic conditions here.",
      icon: Icons.favorite_outline,
    );
  }
}

class _AllergiesPanel extends StatelessWidget {
  const _AllergiesPanel();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: "Allergies",
      description: "Track your allergies and sensitivities.",
      icon: Icons.local_florist_outlined,
    );
  }
}

class _GoalsPanel extends StatelessWidget {
  const _GoalsPanel();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: "Health Goals",
      description: "Set personal fitness or health improvement targets.",
      icon: Icons.flag_outlined,
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPanel(
      title: "Health Metrics",
      description: "Monitor your body indicators and progress.",
      icon: Icons.show_chart_outlined,
    );
  }
}

/// 通用占位面板（你后面可以删掉）
class _PlaceholderPanel extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _PlaceholderPanel({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}