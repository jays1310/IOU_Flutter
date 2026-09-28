import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../group/create_group_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_fab.dart';
import 'widgets/home_group_list.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: HomeFAB(
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

        onJoinGroup: () {},

        onAddContact: () {},
      ),

      body: SafeArea(
        child: Stack(
          children: [
              /// Background Image
              Positioned(
                left: 0,
                right: 0,
                top: 155,
                child: Opacity(
                  opacity: 0.20,
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

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: s.w(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),

                    SizedBox(height: s.h(10)),

                    const HomeSearchBar(),

                    SizedBox(height: s.h(16)),

                    const Expanded(
                      child: HomeGroupList(),
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }
}