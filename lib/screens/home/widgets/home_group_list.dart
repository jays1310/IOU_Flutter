import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/group_provider.dart';
import '../../../core/utils/app_scaler.dart';
import 'empty_groups.dart';
import 'group_card.dart';

class HomeGroupList extends StatelessWidget {
  const HomeGroupList({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final groupProvider = context.watch<GroupProvider>();

    if (groupProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (groupProvider.groups.isEmpty) {
      return const EmptyGroups();
    }

    return ListView.builder(
      itemCount: groupProvider.groups.length,
      itemBuilder: (context, index) {
        final group = groupProvider.groups[index];

        return GroupCard(
          group: group,
          onTap: () {
            // ChatScreen navigation later
          },
        );
      },
    );
  }
}