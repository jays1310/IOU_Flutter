class SplitCalculator:

    @staticmethod
    def calculate(
        split_type: str,
        amount: float,
        split_details: list,
    ):
        if split_type == "equal":
            return SplitCalculator.calculate_equal(
                amount,
                split_details,
            )

        if split_type == "exact":
            return SplitCalculator.calculate_exact(
                amount,
                split_details,
            )

        if split_type == "percentage":
            return SplitCalculator.calculate_percentage(
                amount,
                split_details,
            )

        raise Exception("Invalid split type.")

    @staticmethod
    def calculate_equal(
        amount: float,
        split_details: list,
    ):
        if len(split_details) == 0:
            raise Exception("No participants provided.")

        participant_count = len(split_details)

        equal_share = round(amount / participant_count, 2)

        participants = []

        total_assigned = 0

        for index, participant in enumerate(split_details):

            share = equal_share

            if index == participant_count - 1:
                share = round(amount - total_assigned, 2)

            participants.append({
                "user_id": participant["user_id"],
                "share": share,
            })

            total_assigned += share

        return participants

    @staticmethod
    def calculate_exact(
        amount: float,
        split_details: list,
    ):
        if len(split_details) == 0:
            raise Exception("No participants provided.")

        participants = []

        total = 0

        for participant in split_details:
            share = round(float(participant["value"]), 2)

            participants.append({
                "user_id": participant["user_id"],
                "share": share,
            })

            total += share

        total = round(total, 2)

        if total != round(amount, 2):
            raise Exception("Exact split total must equal expense amount.")

        return participants

    @staticmethod
    def calculate_percentage(
        amount: float,
        split_details: list,
    ):
        if len(split_details) == 0:
            raise Exception("No participants provided.")

        participants = []

        total_percentage = 0

        total_assigned = 0

        for index, participant in enumerate(split_details):

            percentage = float(participant["value"])
            total_percentage += percentage

            share = round((amount * percentage) / 100, 2)

            if index == len(split_details) - 1:
                share = round(amount - total_assigned, 2)

            participants.append({
                "user_id": participant["user_id"],
                "share": share,
            })

            total_assigned += share

        if round(total_percentage, 2) != 100:
            raise Exception("Total percentage must equal 100.")

        return participants