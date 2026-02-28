
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/page/appendable_list_panel.dart';

class WellnessBody extends StatelessWidget{
  const WellnessBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Column(
        children: [
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
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: const [
                AppendableListPanel(tag:"chronics"),
                AppendableListPanel(tag:"allergies"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}