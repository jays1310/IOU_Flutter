import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/token_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

import '../../providers/group_provider.dart';
import '../../providers/transaction_provider.dart';

import '../group/create_group_sheet.dart';
import '../group/join_group_sheet.dart';
import '../individual/individual_screen.dart';
import '../individual/select_individual_screen.dart';

import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_fab.dart';
import 'widgets/home_group_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        await _refreshHomeData();

        final token = await TokenService().getToken();

        debugPrint(
          'JWT TOKEN: $token',
        );
      },
    );
  }

  // =========================================================
  // REFRESH HOME DATA
  // =========================================================

  Future<void> _refreshHomeData() async {
    final groupProvider =
    context.read<GroupProvider>();

    final transactionProvider =
    context.read<TransactionProvider>();

    await Future.wait([
      groupProvider.fetchGroups(),
      transactionProvider.getIndividualRelationships(),
    ]);
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      // =========================================================
      // IOU DARK PURPLE THEME
      // =========================================================

      backgroundColor: AppColors.background,

      // =========================================================
      // FLOATING ACTION BUTTON
      // =========================================================

      floatingActionButton: HomeFAB(
        // -------------------------------------------------------
        // CREATE GROUP
        // -------------------------------------------------------

        onCreateGroup: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            builder: (_) => const CreateGroupSheet(),
          );
        },

        // -------------------------------------------------------
        // JOIN GROUP
        // -------------------------------------------------------

        onJoinGroup: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            builder: (_) => const JoinGroupSheet(),
          );
        },

        // -------------------------------------------------------
        // ADD CONTACT
        // -------------------------------------------------------

        onAddContact: () async {
          // Capture Navigator before the async gap so that
          // BuildContext is not accessed after awaiting.

          final navigator = Navigator.of(context);

          final selectedUser = await navigator.push(
            MaterialPageRoute(
              builder: (_) =>
              const SelectIndividualScreen(),
            ),
          );

          if (selectedUser != null && mounted) {
            await navigator.push(
              MaterialPageRoute(
                builder: (_) => IndividualScreen(
                  user: selectedUser,
                ),
              ),
            );

            if (!mounted) return;

            await _refreshHomeData();
          }
        },
      ),

      // =========================================================
      // MAIN BODY
      // =========================================================

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // =================================================
              // TOP RIGHT PURPLE GLOW
              // =================================================

              Positioned(
                top: -s.h(120),
                right: -s.w(130),
                child: Container(
                  width: s.w(280),
                  height: s.w(280),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.16,
                        ),
                        AppColors.primary.withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =================================================
              // BOTTOM LEFT PURPLE GLOW
              // =================================================

              Positioned(
                bottom: -s.h(120),
                left: -s.w(150),
                child: Container(
                  width: s.w(300),
                  height: s.w(300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(
                          alpha: 0.12,
                        ),
                        AppColors.accent.withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =================================================
              // BACKGROUND MONEY TRANSFER IMAGE
              // =================================================

              Positioned(
                left: 0,
                right: 0,
                top: 155,
                child: Opacity(
                  opacity: 0.18,
                  child: SizedBox(
                    width: s.w(411),
                    height: s.h(428),
                    child: Image.asset(
                      AppAssets.moneyTransfer,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // =================================================
              // HOME CONTENT
              // =================================================

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // HOME HEADER
                  // =============================================

                  const HomeHeader(),

                  // =============================================
                  // SEARCH + LIST AREA
                  // =============================================

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: s.w(8),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // =====================================
                          // SPACE BELOW HEADER
                          // =====================================

                          SizedBox(
                            height: s.h(10),
                          ),

                          // =====================================
                          // SEARCH BAR
                          // =====================================

                          HomeSearchBar(
                            onChanged: _onSearchChanged,
                          ),

                          // =====================================
                          // SPACE BELOW SEARCH
                          // =====================================

                          SizedBox(
                            height: s.h(16),
                          ),

                          // =====================================
                          // GROUP / INDIVIDUAL LIST
                          // =====================================

                          Expanded(
                            child: HomeGroupList(
                              searchQuery: _searchQuery,
                              onRefresh:
                              _refreshHomeData,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}