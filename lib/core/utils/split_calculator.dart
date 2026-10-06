class SplitCalculator {
  /// Calculates an equal split between all participants.
  ///
  /// The amount is converted to paise first so that
  /// floating-point rounding errors are avoided.
  ///
  /// If the amount cannot be divided equally, the remainder
  /// is assigned to the final participant.
  static Map<String, double> calculateEqual({
    required double amount,
    required List<String> participantIds,
  }) {
    if (amount <= 0 || participantIds.isEmpty) {
      return {};
    }

    final totalPaise = (amount * 100).round();

    final baseShare = totalPaise ~/ participantIds.length;
    final remainder = totalPaise % participantIds.length;

    final Map<String, double> shares = {};

    for (int i = 0; i < participantIds.length; i++) {
      final sharePaise =
          baseShare + (i == participantIds.length - 1 ? remainder : 0);

      shares[participantIds[i]] = sharePaise / 100;
    }

    return shares;
  }

  /// Calculates an exact split.
  ///
  /// [enteredAmounts] contains the amounts entered for participants.
  ///
  /// The final participant receives the remaining amount automatically.
  ///
  /// Example:
  /// Total = ₹1000
  /// Jay = ₹300
  /// Chetna = ₹250
  /// Vinay = ₹450
  ///
  /// The final participant's amount is calculated as:
  /// total amount - all previously entered amounts.
  static Map<String, double> calculateExact({
    required double amount,
    required List<String> participantIds,
    required Map<String, double> enteredAmounts,
  }) {
    if (amount <= 0 || participantIds.isEmpty) {
      return {};
    }

    final Map<String, double> shares = {};

    final totalPaise = (amount * 100).round();

    int enteredTotalPaise = 0;

    // Calculate all explicitly entered amounts.
    for (int i = 0; i < participantIds.length; i++) {
      final participantId = participantIds[i];

      // The final participant receives the remainder.
      if (i == participantIds.length - 1) {
        final remainingPaise = totalPaise - enteredTotalPaise;

        if (remainingPaise < 0) {
          return {};
        }

        shares[participantId] = remainingPaise / 100;
        continue;
      }

      final enteredAmount = enteredAmounts[participantId];

      if (enteredAmount == null || enteredAmount < 0) {
        return {};
      }

      final enteredPaise = (enteredAmount * 100).round();

      // An individual amount cannot exceed the total expense.
      if (enteredPaise > totalPaise) {
        return {};
      }

      enteredTotalPaise += enteredPaise;

      // The entered amounts cannot exceed the total.
      if (enteredTotalPaise > totalPaise) {
        return {};
      }

      shares[participantId] = enteredPaise / 100;
    }

    return shares;
  }

  /// Calculates a percentage split.
  ///
  /// [enteredPercentages] contains the percentages entered for
  /// participants other than the final participant.
  ///
  /// The final participant receives the remaining percentage.
  ///
  /// Example:
  /// Total = ₹1000
  /// Jay = 30%
  /// Chutni = 25%
  /// Vinay = 45%
  static Map<String, double> calculatePercentage({
    required double amount,
    required List<String> participantIds,
    required Map<String, double> enteredPercentages,
  }) {
    if (amount <= 0 || participantIds.isEmpty) {
      return {};
    }

    final Map<String, double> shares = {};

    final totalPaise = (amount * 100).round();

    double enteredPercentage = 0;

    // Calculate explicitly entered percentages.
    for (int i = 0; i < participantIds.length; i++) {
      final participantId = participantIds[i];

      // The final participant receives the remaining percentage.
      if (i == participantIds.length - 1) {
        final remainingPercentage = 100 - enteredPercentage;

        if (remainingPercentage < 0) {
          return {};
        }

        final sharePaise =
        (totalPaise * remainingPercentage / 100).round();

        shares[participantId] = sharePaise / 100;
        continue;
      }

      final percentage = enteredPercentages[participantId];

      if (percentage == null || percentage < 0 || percentage > 100) {
        return {};
      }

      enteredPercentage += percentage;

      // Entered percentages cannot exceed 100%.
      if (enteredPercentage > 100) {
        return {};
      }

      final sharePaise =
      (totalPaise * percentage / 100).round();

      shares[participantId] = sharePaise / 100;
    }

    return shares;
  }

  /// Checks whether an exact split is valid.
  ///
  /// The total of all shares must equal the expense amount.
  static bool isExactSplitValid({
    required double amount,
    required Map<String, double> shares,
  }) {
    if (amount <= 0 || shares.isEmpty) {
      return false;
    }

    final totalPaise = (amount * 100).round();

    int calculatedTotalPaise = 0;

    for (final share in shares.values) {
      if (share < 0) {
        return false;
      }

      calculatedTotalPaise += (share * 100).round();
    }

    return calculatedTotalPaise == totalPaise;
  }

  /// Checks whether percentage values are valid.
  ///
  /// The total percentage must equal exactly 100%.
  static bool isPercentageSplitValid({
    required Map<String, double> percentages,
  }) {
    if (percentages.isEmpty) {
      return false;
    }

    double totalPercentage = 0;

    for (final percentage in percentages.values) {
      if (percentage < 0 || percentage > 100) {
        return false;
      }

      totalPercentage += percentage;
    }

    return (totalPercentage - 100).abs() < 0.0001;
  }

  /// Returns the remaining amount after subtracting
  /// the entered amounts from the total expense.
  static double calculateRemainingAmount({
    required double amount,
    required Map<String, double> enteredAmounts,
  }) {
    if (amount <= 0) {
      return 0;
    }

    final totalPaise = (amount * 100).round();

    int enteredTotalPaise = 0;

    for (final enteredAmount in enteredAmounts.values) {
      if (enteredAmount < 0) {
        continue;
      }

      enteredTotalPaise += (enteredAmount * 100).round();
    }

    final remainingPaise = totalPaise - enteredTotalPaise;

    return remainingPaise / 100;
  }

  /// Returns the remaining percentage after subtracting
  /// the entered percentages from 100%.
  static double calculateRemainingPercentage({
    required Map<String, double> enteredPercentages,
  }) {
    double enteredTotal = 0;

    for (final percentage in enteredPercentages.values) {
      if (percentage < 0) {
        continue;
      }

      enteredTotal += percentage;
    }

    final remaining = 100 - enteredTotal;

    return remaining < 0 ? 0 : remaining;
  }
}