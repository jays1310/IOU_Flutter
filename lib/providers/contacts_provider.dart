import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/registered_user_model.dart';
import '../repositories/contacts_repository.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsRepository _repository =
  ContactsRepository();

  bool _isLoading = false;
  bool _hasPermission = false;

  List<Contact> _contacts = [];
  List<RegisteredUserModel> _registeredUsers = [];

  final Set<String> _selectedContacts = {};

  String _searchQuery = "";

  // Normalized phone number of the currently
  // logged-in user.
  String? _currentUserPhoneNumber;

  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  List<Contact> get contacts {
    if (_searchQuery.isEmpty) {
      return _contacts;
    }

    return _contacts.where((contact) {
      return contact.displayName
          .toLowerCase()
          .contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();
  }

  List<RegisteredUserModel> get registeredUsers =>
      _registeredUsers;

  Set<String> get selectedContacts =>
      _selectedContacts;

  bool get canCreateGroup =>
      _selectedContacts.length >= 2;

  // ================================================================
  // PHONE NUMBER NORMALIZATION
  // ================================================================

  String normalizePhoneNumber(
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
  // LOAD CONTACTS
  // ================================================================

  Future<void> loadContacts({
    String? currentUserPhoneNumber,
  }) async {
    try {
      debugPrint(
        "loadContacts() called",
      );

      _isLoading = true;
      notifyListeners();

      // Store the logged-in user's normalized
      // phone number.
      if (currentUserPhoneNumber != null &&
          currentUserPhoneNumber
              .trim()
              .isNotEmpty) {
        _currentUserPhoneNumber =
            normalizePhoneNumber(
              currentUserPhoneNumber,
            );
      } else {
        _currentUserPhoneNumber = null;
      }

      _hasPermission =
      await _repository.requestPermission();

      debugPrint(
        "Permission after request = "
            "$_hasPermission",
      );

      if (!_hasPermission) {
        debugPrint(
          "Permission denied",
        );

        _contacts = [];
        _registeredUsers = [];

        return;
      }

      _contacts =
      await _repository.getContacts();

      // ============================================================
      // NORMALIZE DEVICE CONTACT NUMBERS
      // ============================================================

      final phoneNumbers = _contacts
          .where(
            (contact) =>
        contact.phones.isNotEmpty,
      )
          .map((contact) {
        final phone =
            contact.phones.first.number;

        return normalizePhoneNumber(
          phone,
        );
      })
          .where(
            (phone) => phone.isNotEmpty,
      )
          .toList();

      debugPrint(
        "========== ALL PHONE NUMBERS ==========",
      );

      for (final number in phoneNumbers) {
        debugPrint(number);
      }

      debugPrint(
        "=======================================",
      );

      // ============================================================
      // GET REGISTERED USERS
      // ============================================================

      _registeredUsers =
      await _repository.getRegisteredContacts(
        phoneNumbers,
      );

      // ============================================================
      // REMOVE LOGGED-IN USER
      // ============================================================

      if (_currentUserPhoneNumber != null &&
          _currentUserPhoneNumber!.isNotEmpty) {
        _registeredUsers =
            _registeredUsers.where((user) {
              final userPhone =
              normalizePhoneNumber(
                user.phoneNumber,
              );

              return userPhone !=
                  _currentUserPhoneNumber;
            }).toList();
      }

      debugPrint(
        "========== REGISTERED USERS ==========",
      );

      for (final user in _registeredUsers) {
        debugPrint(
          "${user.username} - "
              "${user.phoneNumber}",
        );
      }

      debugPrint(
        "======================================",
      );

      debugPrint(
        "Contacts loaded = "
            "${_contacts.length}",
      );

      _contacts.sort(
            (a, b) =>
            a.displayName.compareTo(
              b.displayName,
            ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================================================
  // SELECTION
  // ================================================================

  void toggleSelection(
      String contactId,
      ) {
    if (_selectedContacts.contains(
      contactId,
    )) {
      _selectedContacts.remove(
        contactId,
      );
    } else {
      _selectedContacts.add(
        contactId,
      );
    }

    notifyListeners();
  }

  void clearSelectedContacts() {
    _selectedContacts.clear();
    notifyListeners();
  }

  // ================================================================
  // SEARCH
  // ================================================================

  void searchContacts(
      String query,
      ) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }
}