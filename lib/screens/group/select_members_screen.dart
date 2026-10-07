import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

import '../../models/registered_user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/group_provider.dart';

import '../../widgets/app_button.dart';

import 'group_screen.dart';

class SelectMembersScreen extends StatefulWidget {
  final String groupName;

  // Used when adding members to an existing group.
  final String? groupId;

  // false = create group
  // true = add members to existing group
  final bool isAddingMembers;

  // Phone numbers of users who are already members
  // of the group.
  final List<String> existingMemberPhoneNumbers;

  const SelectMembersScreen({
    super.key,
    required this.groupName,
    this.groupId,
    this.isAddingMembers = false,
    this.existingMemberPhoneNumbers =
    const [],
  });

  @override
  State<SelectMembersScreen> createState() =>
      _SelectMembersScreenState();
}

class _SelectMembersScreenState
    extends State<SelectMembersScreen> {
  final TextEditingController
  _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final contactsProvider =
      context.read<ContactsProvider>();

      final authProvider =
      context.read<AuthProvider>();

      // ============================================================
      // NEW GROUP
      // ============================================================

      // When creating a new group, previous
      // selections from another group must not
      // remain selected.
      if (!widget.isAddingMembers) {
        contactsProvider
            .clearSelectedContacts();
      }

      // ============================================================
      // LOAD CONTACTS
      // ============================================================

      contactsProvider.loadContacts(
        currentUserPhoneNumber:
        authProvider
            .currentUser
            ?.phoneNumber,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // PHONE NUMBER NORMALIZATION
  // ================================================================

  // Keep this method because it is used for
  // existing-group member comparison.
  String _normalizePhoneNumber(
      String phoneNumber,
      ) {
    final digits = phoneNumber.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.length > 10) {
      return digits.substring(
        digits.length - 10,
      );
    }

    return digits;
  }

  // ================================================================
  // EXISTING MEMBER CHECK
  // ================================================================

  bool _isExistingMember(
      String phoneNumber,
      ) {
    final normalizedPhoneNumber =
    _normalizePhoneNumber(
      phoneNumber,
    );

    return widget
        .existingMemberPhoneNumbers
        .any(
          (existingPhoneNumber) =>
      _normalizePhoneNumber(
        existingPhoneNumber,
      ) ==
          normalizedPhoneNumber,
    );
  }

  // ================================================================
  // SUBMIT
  // ================================================================

  Future<void> _submit() async {
    final contactsProvider =
    context.read<ContactsProvider>();

    final groupProvider =
    context.read<GroupProvider>();

    try {
      // ============================================================
      // ADD MEMBERS TO EXISTING GROUP
      // ============================================================

      if (widget.isAddingMembers) {
        if (widget.groupId == null) {
          throw Exception(
            'Group ID is missing.',
          );
        }

        final updatedGroup =
        await groupProvider.addMembers(
          groupId: widget.groupId!,
          memberPhoneNumbers:
          contactsProvider
              .selectedContacts
              .toList(),
        );

        if (!mounted) return;

        Navigator.pop(
          context,
          updatedGroup,
        );

        return;
      }

      // ============================================================
      // CREATE NEW GROUP
      // ============================================================

      final createdGroup =
      await groupProvider.createGroup(
        groupName: widget.groupName,
        memberPhoneNumbers:
        contactsProvider
            .selectedContacts
            .toList(),
      );

      if (!mounted) return;

      // ============================================================
      // OPEN THE NEWLY CREATED GROUP DIRECTLY
      // ============================================================

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GroupScreen(
            group: createdGroup,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor:
      AppColors.background,

      // ==============================================================
      // ACTION BUTTON
      // ==============================================================

      floatingActionButtonLocation:
      FloatingActionButtonLocation
          .centerFloat,

      floatingActionButton:
      Consumer<ContactsProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          final bool hasSelectedMembers =
              provider.selectedContacts
                  .isNotEmpty;

          final bool showButton =
          widget.isAddingMembers
              ? hasSelectedMembers
              : provider.canCreateGroup;

          return AnimatedSlide(
            duration:
            const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
            offset: showButton
                ? Offset.zero
                : const Offset(0, 2),
            child: AnimatedOpacity(
              duration:
              const Duration(
                milliseconds: 250,
              ),
              opacity:
              showButton ? 1 : 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: s.h(20),
                ),
                child: SizedBox(
                  width: s.w(220),
                  child: AppButton(
                    text:
                    widget.isAddingMembers
                        ? 'Add Member'
                        : 'Create',
                    width:
                    double.infinity,
                    height: s.h(52),
                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                    showShadow: false,
                    onPressed:
                    showButton
                        ? _submit
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // ==============================================================
      // BODY
      // ==============================================================

      body: Container(
        decoration:
        const BoxDecoration(
          gradient:
          AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ==========================================================
              // TOP-RIGHT PURPLE GLOW
              // ==========================================================

              Positioned(
                top: -s.h(120),
                right: -s.w(130),
                child: Container(
                  width: s.w(280),
                  height: s.w(280),
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    gradient:
                    RadialGradient(
                      colors: [
                        AppColors.primary
                            .withValues(
                          alpha: 0.16,
                        ),
                        AppColors.primary
                            .withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // BOTTOM-LEFT PURPLE GLOW
              // ==========================================================

              Positioned(
                bottom: -s.h(120),
                left: -s.w(150),
                child: Container(
                  width: s.w(300),
                  height: s.w(300),
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    gradient:
                    RadialGradient(
                      colors: [
                        AppColors.accent
                            .withValues(
                          alpha: 0.12,
                        ),
                        AppColors.accent
                            .withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // MONEY TRANSFER BACKGROUND
              // ==========================================================

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
                      AppAssets
                          .moneyTransfer,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // MAIN CONTENT
              // ==========================================================

              Column(
                children: [
                  // ========================================================
                  // HEADER
                  // ========================================================

                  Container(
                    width:
                    double.infinity,
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: s.w(12),
                      vertical: s.h(10),
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.025,
                      ),
                      border:
                      Border(
                        bottom:
                        BorderSide(
                          color: Colors
                              .white
                              .withValues(
                            alpha: 0.06,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Stack(
                      alignment:
                      Alignment.center,
                      children: [
                        // ------------------------------------------------
                        // BACK ARROW
                        // ------------------------------------------------

                        Align(
                          alignment:
                          Alignment
                              .centerLeft,
                          child:
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: Opacity(
                              opacity: 0.85,
                              child: SizedBox(
                                width: s.w(50),
                                height:
                                s.h(48),
                                child:
                                Image.asset(
                                  AppAssets
                                      .backArrow,
                                  fit: BoxFit
                                      .contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // TITLE
                        // ------------------------------------------------

                        Text(
                          widget
                              .isAddingMembers
                              ? 'Add Members'
                              : widget
                              .groupName,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontFamily:
                            'Raleway',
                            fontSize:
                            s.sp(20),
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========================================================
                  // CONTACTS
                  // ========================================================

                  Expanded(
                    child:
                    Consumer<
                        ContactsProvider>(
                      builder: (
                          context,
                          provider,
                          child,
                          ) {
                        // ------------------------------------------------
                        // LOADING
                        // ------------------------------------------------

                        if (provider
                            .isLoading) {
                          return Center(
                            child:
                            CircularProgressIndicator(
                              color:
                              AppColors
                                  .accent,
                              strokeWidth: 2.5,
                            ),
                          );
                        }

                        // ------------------------------------------------
                        // PERMISSION
                        // ------------------------------------------------

                        if (!provider
                            .hasPermission) {
                          return Center(
                            child: Text(
                              'Contacts permission denied',
                              style:
                              TextStyle(
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.70,
                                ),
                                fontFamily:
                                'Raleway',
                                fontSize:
                                s.sp(15),
                              ),
                            ),
                          );
                        }

                        // ------------------------------------------------
                        // NO CONTACTS
                        // ------------------------------------------------

                        if (provider
                            .contacts
                            .isEmpty) {
                          return Center(
                            child: Text(
                              'No contacts found',
                              style:
                              TextStyle(
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.70,
                                ),
                                fontFamily:
                                'Raleway',
                                fontSize:
                                s.sp(15),
                              ),
                            ),
                          );
                        }

                        // ------------------------------------------------
                        // REMOVE EXISTING MEMBERS
                        // ------------------------------------------------

                        final availableUsers =
                        provider
                            .registeredUsers
                            .where(
                              (user) =>
                          !_isExistingMember(
                            user.phoneNumber,
                          ),
                        ).toList();

                        return Column(
                          children: [
                            // ============================================
                            // SEARCH
                            // ============================================

                            Padding(
                              padding:
                              EdgeInsets
                                  .fromLTRB(
                                s.w(16),
                                s.h(16),
                                s.w(16),
                                s.h(12),
                              ),
                              child:
                              Container(
                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha:
                                    0.055,
                                  ),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    s.w(14),
                                  ),
                                  border:
                                  Border.all(
                                    color: AppColors
                                        .primary
                                        .withValues(
                                      alpha:
                                      0.22,
                                    ),
                                  ),
                                ),
                                child:
                                TextField(
                                  controller:
                                  _searchController,
                                  onChanged:
                                      (value) {
                                    provider
                                        .searchContacts(
                                      value,
                                    );
                                  },
                                  style:
                                  TextStyle(
                                    color:
                                    Colors
                                        .white,
                                    fontFamily:
                                    'Raleway',
                                    fontSize:
                                    s.sp(
                                      14,
                                    ),
                                  ),
                                  cursorColor:
                                  AppColors
                                      .accent,
                                  decoration:
                                  InputDecoration(
                                    hintText:
                                    'Search contacts...',
                                    hintStyle:
                                    TextStyle(
                                      color: Colors
                                          .white
                                          .withValues(
                                        alpha:
                                        0.45,
                                      ),
                                      fontFamily:
                                      'Raleway',
                                      fontSize:
                                      s.sp(
                                        14,
                                      ),
                                    ),
                                    prefixIcon:
                                    Icon(
                                      Icons
                                          .search_rounded,
                                      color:
                                      AppColors
                                          .accent,
                                      size:
                                      s.sp(
                                        22,
                                      ),
                                    ),
                                    border:
                                    InputBorder
                                        .none,
                                    enabledBorder:
                                    InputBorder
                                        .none,
                                    focusedBorder:
                                    InputBorder
                                        .none,
                                    contentPadding:
                                    EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      s.w(
                                        4,
                                      ),
                                      vertical:
                                      s.h(
                                        15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ============================================
                            // REGISTERED USERS
                            // ============================================

                            Expanded(
                              child:
                              availableUsers
                                  .isEmpty
                                  ? Center(
                                child:
                                Text(
                                  'No new members available',
                                  style:
                                  TextStyle(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                      0.65,
                                    ),
                                    fontFamily:
                                    'Raleway',
                                    fontSize:
                                    s.sp(
                                      15,
                                    ),
                                  ),
                                ),
                              )
                                  : ListView
                                  .builder(
                                physics:
                                const BouncingScrollPhysics(),
                                padding:
                                EdgeInsets.only(
                                  left:
                                  s.w(
                                    16,
                                  ),
                                  right:
                                  s.w(
                                    16,
                                  ),
                                  bottom:
                                  s.h(
                                    100,
                                  ),
                                ),
                                itemCount:
                                availableUsers
                                    .length,
                                itemBuilder:
                                    (
                                    context,
                                    index,
                                    ) {
                                  final user =
                                  availableUsers[
                                  index];

                                  final contactId =
                                      user.phoneNumber;

                                  final isSelected =
                                  provider
                                      .selectedContacts
                                      .contains(
                                    contactId,
                                  );

                                  return Padding(
                                    padding:
                                    EdgeInsets.only(
                                      bottom:
                                      s.h(
                                        10,
                                      ),
                                    ),
                                    child:
                                    _MemberTile(
                                      user:
                                      user,
                                      isSelected:
                                      isSelected,
                                      scaler:
                                      s,
                                      onTap:
                                          () {
                                        provider
                                            .toggleSelection(
                                          contactId,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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

// ===========================================================================
// MEMBER TILE
// ===========================================================================

class _MemberTile
    extends StatelessWidget {
  final RegisteredUserModel user;
  final bool isSelected;
  final AppScaler scaler;
  final VoidCallback onTap;

  const _MemberTile({
    required this.user,
    required this.isSelected,
    required this.scaler,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final username =
    user.username.trim();

    final initials =
    username.isNotEmpty
        ? username
        .split(' ')
        .where(
          (e) => e.isNotEmpty,
    )
        .take(2)
        .map(
          (e) =>
          e[0].toUpperCase(),
    )
        .join()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 180,
        ),
        width: double.infinity,
        padding:
        EdgeInsets.symmetric(
          horizontal: scaler.w(14),
          vertical: scaler.h(11),
        ),
        decoration:
        BoxDecoration(
          color: isSelected
              ? AppColors.primary
              .withValues(
            alpha: 0.16,
          )
              : AppColors.background
              .withValues(
            alpha: 0.72,
          ),
          borderRadius:
          BorderRadius.circular(
            scaler.w(16),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                .withValues(
              alpha: 0.65,
            )
                : AppColors.primary
                .withValues(
              alpha: 0.20,
            ),
            width:
            isSelected ? 1.2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors
                  .primary
                  .withValues(
                alpha: 0.16,
              ),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            // =============================================================
            // USER AVATAR
            // =============================================================

            Container(
              width: scaler.w(46),
              height: scaler.w(46),
              decoration:
              const BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    AppColors.accent,
                    AppColors.primary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    AppColors.primary,
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment:
              Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color:
                  Colors.white,
                  fontFamily:
                  'Raleway',
                  fontSize:
                  scaler.sp(16),
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            SizedBox(
              width: scaler.w(14),
            ),

            // =============================================================
            // USER DETAILS
            // =============================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    user.username,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      color:
                      Colors.white,
                      fontFamily:
                      'Raleway',
                      fontSize:
                      scaler.sp(15),
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height:
                    scaler.h(4),
                  ),
                  Text(
                    user.phoneNumber,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      color: Colors
                          .white
                          .withValues(
                        alpha: 0.55,
                      ),
                      fontFamily:
                      'Raleway',
                      fontSize:
                      scaler.sp(13),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: scaler.w(10),
            ),

            // =============================================================
            // SELECTION INDICATOR
            // =============================================================

            AnimatedContainer(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              width: scaler.w(24),
              height: scaler.w(24),
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                border:
                Border.all(
                  color: isSelected
                      ? AppColors
                      .accent
                      : Colors.white
                      .withValues(
                    alpha: 0.30,
                  ),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons
                    .check_rounded,
                color:
                Colors.white,
                size:
                scaler.sp(16),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}