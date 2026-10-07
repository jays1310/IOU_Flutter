import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/group_provider.dart';
import '../../../providers/transaction_provider.dart';

import '../../group/group_screen.dart';
import 'empty_groups.dart';
import 'group_card.dart';
import 'individual_card.dart';

import '../../individual/individual_screen.dart';
import '../../../models/registered_user_model.dart';

class HomeGroupList extends StatelessWidget {
  final String searchQuery;
  final Future<void> Function()? onRefresh;

  const HomeGroupList({
    super.key,
    this.searchQuery = '',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final transactionProvider =
    context.watch<TransactionProvider>();

    // =========================================================
    // LOADING
    // =========================================================

    if (groupProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    final groups = groupProvider.groups;
    final individuals =
        transactionProvider.individualRelationships;

    // =========================================================
    // SEARCH QUERY
    // =========================================================

    final query = searchQuery.trim().toLowerCase();

    // =========================================================
    // FILTER GROUPS
    // =========================================================

    final filteredGroups = query.isEmpty
        ? groups
        : groups.where((group) {
      return group.groupName
          .toLowerCase()
          .contains(query);
    }).toList();

    // =========================================================
    // FILTER INDIVIDUALS
    // =========================================================

    final filteredIndividuals = query.isEmpty
        ? individuals
        : individuals.where((relationship) {
      final username =
          relationship['username']
              ?.toString()
              .toLowerCase() ??
              '';

      return username.contains(query);
    }).toList();

    // =========================================================
    // EMPTY STATE
    // =========================================================

    if (filteredGroups.isEmpty &&
        filteredIndividuals.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // -----------------------------------------------------
          // SEARCH HAS NO RESULTS
          // -----------------------------------------------------

          if (query.isNotEmpty) {
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: onRefresh ?? () async {},
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.45,
                          ),
                          fontFamily: 'Raleway',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // -----------------------------------------------------
          // NO GROUPS / NO INDIVIDUALS
          // -----------------------------------------------------

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.card,
            strokeWidth: 2.5,
            displacement: 20,
            onRefresh: onRefresh ?? () async {},
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: const Center(
                    child: EmptyGroups(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // =========================================================
    // BUILD UNIFIED ACTIVITY LIST
    // =========================================================

    final List<_HomeActivityItem> activities = [];

    // =========================================================
    // GROUPS
    // =========================================================

    for (final group in filteredGroups) {
      activities.add(
        _HomeActivityItem(
          lastActivity:
          group.lastActivity ?? group.createdAt,
          child: GroupCard(
            group: group,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupScreen(
                    group: group,
                  ),
                ),
              );

              // -------------------------------------------------
              // Refresh both groups and individuals after
              // returning from GroupScreen.
              // -------------------------------------------------

              if (!context.mounted) return;

              await groupProvider.fetchGroups();

              await transactionProvider
                  .getIndividualRelationships();
            },
          ),
        ),
      );
    }

    // =========================================================
    // INDIVIDUALS
    // =========================================================

    for (final relationship in filteredIndividuals) {
      final user = RegisteredUserModel(
        id: relationship['user_id'] ?? '',
        username: relationship['username'] ?? '',
        phoneNumber: relationship['phoneNumber'] ?? '',
        email: '',
      );

      final balance =
          (relationship['balance'] as num?)?.toDouble() ??
              0.0;

      DateTime lastActivity;

      final rawLastActivity =
      relationship['last_activity'];

      if (rawLastActivity != null) {
        lastActivity = DateTime.parse(
          rawLastActivity.toString(),
        );
      } else {
        lastActivity =
            DateTime.fromMillisecondsSinceEpoch(0);
      }

      activities.add(
        _HomeActivityItem(
          lastActivity: lastActivity,
          child: IndividualCard(
            username: user.username,
            phoneNumber: user.phoneNumber,
            balance: balance,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IndividualScreen(
                    user: user,
                  ),
                ),
              );

              // -------------------------------------------------
              // Refresh both groups and individuals after
              // returning from IndividualScreen.
              // -------------------------------------------------

              if (!context.mounted) return;

              await groupProvider.fetchGroups();

              await transactionProvider
                  .getIndividualRelationships();
            },
          ),
        ),
      );
    }

    // =========================================================
    // SORT NEWEST ACTIVITY FIRST
    // =========================================================

    activities.sort(
          (a, b) => b.lastActivity.compareTo(
        a.lastActivity,
      ),
    );

    // =========================================================
    // DISPLAY
    // =========================================================

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      strokeWidth: 2.5,
      displacement: 20,
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.zero,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];

          return _AnimatedHomeItem(
            index: index,
            child: activity.child,
          );
        },
      ),
    );
  }
}

// =============================================================
// ANIMATED HOME ITEM
// =============================================================

class _AnimatedHomeItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedHomeItem({
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedHomeItem> createState() =>
      _AnimatedHomeItemState();
}

class _AnimatedHomeItemState extends State<_AnimatedHomeItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);

    Future.delayed(
      Duration(
        milliseconds: 60 * widget.index,
      ),
          () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// =============================================================
// HOME ACTIVITY ITEM
// =============================================================

class _HomeActivityItem {
  final DateTime lastActivity;
  final Widget child;

  const _HomeActivityItem({
    required this.lastActivity,
    required this.child,
  });
}