import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';
import '../../models/group_model.dart';
import '../../providers/group_provider.dart';
import 'select_members_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailScreen> createState() =>
      _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late GroupModel _group;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _group = widget.group;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(curvedAnimation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================================================================
  // REFRESH GROUP DETAILS
  // ================================================================

  Future<void> _refreshGroupDetails() async {
    try {
      /*
       * Fetch the user's groups again from the backend.
       *
       * GroupProvider updates its internal group list.
       * We then find the current group and update the local
       * GroupModel used by this screen.
       */
      await context.read<GroupProvider>().fetchGroups();

      if (!mounted) return;

      final groups = context.read<GroupProvider>().groups;

      GroupModel? updatedGroup;

      for (final group in groups) {
        if (group.id == _group.id) {
          updatedGroup = group;
          break;
        }
      }

      if (updatedGroup != null) {
        setState(() {
          _group = updatedGroup!;
        });
      }
    } catch (e) {
      debugPrint(
        'FAILED TO REFRESH GROUP DETAILS: $e',
      );
    }
  }

  // ================================================================
  // ADD MEMBER
  // ================================================================

  Future<void> _openAddMemberScreen() async {
    final updatedGroup = await Navigator.push<GroupModel>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersScreen(
          groupName: _group.groupName,
          groupId: _group.id,
          isAddingMembers: true,
          existingMemberPhoneNumbers: _group.memberDetails
              .map((member) => member.phoneNumber)
              .toList(),
        ),
      ),
    );

    if (!mounted || updatedGroup == null) return;

    setState(() {
      _group = updatedGroup;
    });
  }

  // ================================================================
  // LEAVE GROUP
  // ================================================================

  Future<void> _leaveGroup() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Leave Group',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to leave "${_group.groupName}"?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontFamily: 'Raleway',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.accent,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true || !mounted) {
      return;
    }

    try {
      await context.read<GroupProvider>().leaveGroup(
        groupId: _group.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have left the group'),
        ),
      );

      // Close Group Details and Group Screen,
      // returning the user to the group list.
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final groupInitial = _group.groupName.isNotEmpty
        ? _group.groupName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ===========================================================
              // TOP-RIGHT AMBIENT GLOW
              // ===========================================================

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

              // ===========================================================
              // BOTTOM-LEFT AMBIENT GLOW
              // ===========================================================

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

              // ===========================================================
              // MONEY TRANSFER BACKGROUND
              // ===========================================================

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

              // ===========================================================
              // MAIN CONTENT
              // ===========================================================

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // =====================================================
                      // HEADER
                      // =====================================================

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: s.w(12),
                          vertical: s.h(10),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.025,
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(
                                alpha: 0.06,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ------------------------------------------------
                            // BACK ARROW
                            // ------------------------------------------------

                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Opacity(
                                  opacity: 0.85,
                                  child: SizedBox(
                                    width: s.w(50),
                                    height: s.h(48),
                                    child: Image.asset(
                                      AppAssets.backArrow,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ------------------------------------------------
                            // TITLE
                            // ------------------------------------------------

                            Text(
                              'Group Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: s.sp(22),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // ------------------------------------------------
                            // MENU
                            // ------------------------------------------------

                            Align(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<String>(
                                color: AppColors.background,
                                position:
                                PopupMenuPosition.under,
                                elevation: 12,
                                shadowColor:
                                AppColors.primary.withValues(
                                  alpha: 0.30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    s.w(14),
                                  ),
                                  side: BorderSide(
                                    color:
                                    AppColors.primary
                                        .withValues(
                                      alpha: 0.30,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_vert,
                                  color:
                                  Colors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                  size: s.w(28),
                                ),
                                splashRadius: s.w(22),
                                onSelected: (value) {
                                  if (value == 'leave') {
                                    _leaveGroup();
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'leave',
                                    height: s.h(48),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: s.w(32),
                                          height: s.w(32),
                                          decoration:
                                          BoxDecoration(
                                            shape:
                                            BoxShape.circle,
                                            color: AppColors
                                                .error
                                                .withValues(
                                              alpha: 0.10,
                                            ),
                                            border: Border.all(
                                              color: AppColors
                                                  .error
                                                  .withValues(
                                                alpha: 0.25,
                                              ),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color:
                                            AppColors.error,
                                            size: s.sp(17),
                                          ),
                                        ),
                                        SizedBox(
                                          width: s.w(10),
                                        ),
                                        Text(
                                          'Leave Group',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                            'Raleway',
                                            fontSize: s.sp(13),
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =====================================================
                      // SCROLLABLE CONTENT + REFRESH
                      // =====================================================

                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.accent,
                          backgroundColor: AppColors.card,
                          displacement: 24,
                          strokeWidth: 2.4,
                          onRefresh: _refreshGroupDetails,
                          child: SingleChildScrollView(
                            physics:
                            const AlwaysScrollableScrollPhysics(
                              parent:
                              BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              bottom: s.h(30),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // =========================================
                                // GROUP PROFILE
                                // =========================================

                                Container(
                                  width: double.infinity,
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal: s.w(20),
                                    vertical: s.h(28),
                                  ),
                                  child: Column(
                                    children: [
                                      // -------------------------------
                                      // GROUP AVATAR
                                      // -------------------------------

                                      Container(
                                        width: s.w(96),
                                        height: s.w(96),
                                        padding:
                                        EdgeInsets.all(
                                          s.w(3),
                                        ),
                                        decoration:
                                        BoxDecoration(
                                          shape:
                                          BoxShape.circle,
                                          gradient:
                                          const LinearGradient(
                                            begin:
                                            Alignment.topLeft,
                                            end:
                                            Alignment.bottomRight,
                                            colors: [
                                              AppColors.accent,
                                              AppColors.primary,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors
                                                  .primary
                                                  .withValues(
                                                alpha: 0.28,
                                              ),
                                              blurRadius: 24,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration:
                                          BoxDecoration(
                                            shape:
                                            BoxShape.circle,
                                            color: AppColors
                                                .background
                                                .withValues(
                                              alpha: 0.90,
                                            ),
                                          ),
                                          alignment:
                                          Alignment.center,
                                          child: Text(
                                            groupInitial,
                                            style: TextStyle(
                                              color:
                                              Colors.white,
                                              fontFamily:
                                              'Raleway',
                                              fontSize:
                                              s.sp(32),
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: s.h(14),
                                      ),

                                      // -------------------------------
                                      // GROUP NAME
                                      // -------------------------------

                                      Text(
                                        _group.groupName,
                                        textAlign:
                                        TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                          'Raleway',
                                          fontSize: s.sp(24),
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(
                                        height: s.h(6),
                                      ),

                                      Text(
                                        '${_group.memberDetails.length} ${_group.memberDetails.length == 1 ? 'Member' : 'Members'}',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(
                                            alpha: 0.50,
                                          ),
                                          fontFamily:
                                          'Raleway',
                                          fontSize: s.sp(13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // =========================================
                                // ADD MEMBER
                                // =========================================

                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: s.w(16),
                                  ),
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal: s.w(16),
                                    vertical: s.h(14),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(
                                      alpha: 0.035,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      s.w(16),
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(
                                        alpha: 0.20,
                                      ),
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap:
                                    _openAddMemberScreen,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: s.w(44),
                                          height: s.w(44),
                                          decoration:
                                          BoxDecoration(
                                            shape:
                                            BoxShape.circle,
                                            gradient:
                                            const LinearGradient(
                                              begin: Alignment
                                                  .topLeft,
                                              end: Alignment
                                                  .bottomRight,
                                              colors: [
                                                AppColors
                                                    .accent,
                                                AppColors
                                                    .primary,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors
                                                    .primary
                                                    .withValues(
                                                  alpha: 0.18,
                                                ),
                                                blurRadius: 12,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons
                                                .person_add_alt_1_rounded,
                                            color: Colors.white,
                                            size: s.sp(21),
                                          ),
                                        ),
                                        SizedBox(
                                          width: s.w(12),
                                        ),
                                        Text(
                                          'Add Member',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                            'Raleway',
                                            fontSize: s.sp(15),
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons
                                              .arrow_forward_ios_rounded,
                                          color: Colors.white
                                              .withValues(
                                            alpha: 0.35,
                                          ),
                                          size: s.sp(16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: s.h(24),
                                ),

                                // =========================================
                                // MEMBERS TITLE
                                // =========================================

                                Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal: s.w(20),
                                  ),
                                  child: Text(
                                    'MEMBERS',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(
                                        alpha: 0.50,
                                      ),
                                      fontFamily: 'Raleway',
                                      fontSize: s.sp(12),
                                      fontWeight:
                                      FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: s.h(8),
                                ),

                                // =========================================
                                // MEMBERS LIST
                                // =========================================

                                Container(
                                  width: double.infinity,
                                  margin:
                                  EdgeInsets.symmetric(
                                    horizontal: s.w(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background
                                        .withValues(
                                      alpha: 0.72,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      s.w(16),
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(
                                        alpha: 0.20,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ..._group.memberDetails
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) {
                                          final index =
                                              entry.key;
                                          final member =
                                              entry.value;

                                          final isAdmin =
                                              member.id ==
                                                  _group.createdBy;

                                          final initial = member
                                              .username
                                              .isNotEmpty
                                              ? member
                                              .username[0]
                                              .toUpperCase()
                                              : '?';

                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                EdgeInsets
                                                    .symmetric(
                                                  horizontal:
                                                  s.w(14),
                                                  vertical:
                                                  s.h(12),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    // -----------------
                                                    // MEMBER AVATAR
                                                    // -----------------

                                                    Container(
                                                      width:
                                                      s.w(46),
                                                      height:
                                                      s.w(46),
                                                      padding:
                                                      EdgeInsets
                                                          .all(
                                                        s.w(1.5),
                                                      ),
                                                      decoration:
                                                      BoxDecoration(
                                                        shape: BoxShape
                                                            .circle,
                                                        gradient:
                                                        const LinearGradient(
                                                          begin: Alignment
                                                              .topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            AppColors
                                                                .accent,
                                                            AppColors
                                                                .primary,
                                                          ],
                                                        ),
                                                      ),
                                                      child:
                                                      Container(
                                                        decoration:
                                                        BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          color: AppColors
                                                              .background
                                                              .withValues(
                                                            alpha:
                                                            0.90,
                                                          ),
                                                        ),
                                                        alignment:
                                                        Alignment
                                                            .center,
                                                        child:
                                                        Text(
                                                          initial,
                                                          style:
                                                          TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontFamily:
                                                            'Raleway',
                                                            fontSize:
                                                            s.sp(
                                                              16,
                                                            ),
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      width:
                                                      s.w(12),
                                                    ),

                                                    // -----------------
                                                    // MEMBER DETAILS
                                                    // -----------------

                                                    Expanded(
                                                      child:
                                                      Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                child:
                                                                Text(
                                                                  member
                                                                      .username,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  style:
                                                                  TextStyle(
                                                                    color:
                                                                    Colors.white,
                                                                    fontFamily:
                                                                    'Raleway',
                                                                    fontSize:
                                                                    s.sp(14),
                                                                    fontWeight:
                                                                    FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (isAdmin) ...[
                                                                SizedBox(
                                                                  width:
                                                                  s.w(8),
                                                                ),
                                                                Container(
                                                                  padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                    s.w(6),
                                                                    vertical:
                                                                    s.h(2),
                                                                  ),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: AppColors
                                                                        .primary
                                                                        .withValues(
                                                                      alpha:
                                                                      0.35,
                                                                    ),
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                  Text(
                                                                    'Admin',
                                                                    style:
                                                                    TextStyle(
                                                                      color:
                                                                      Colors.white,
                                                                      fontFamily:
                                                                      'Raleway',
                                                                      fontSize:
                                                                      s.sp(9),
                                                                      fontWeight:
                                                                      FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                            s.h(4),
                                                          ),
                                                          Text(
                                                            member
                                                                .phoneNumber,
                                                            style:
                                                            TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                alpha:
                                                                0.50,
                                                              ),
                                                              fontFamily:
                                                              'Raleway',
                                                              fontSize:
                                                              s.sp(11),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              if (index <
                                                  _group
                                                      .memberDetails
                                                      .length -
                                                      1)
                                                Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  indent: s.w(72),
                                                  endIndent:
                                                  s.w(14),
                                                  color: Colors
                                                      .white
                                                      .withValues(
                                                    alpha: 0.06,
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}