namespace Pcm.Api.Entities
{
    public enum Tier
    {
        Bronze = 0,
        Silver = 1,
        Gold = 2,
        Diamond = 3
    }

    public enum TransactionType
    {
        Deposit = 1,
        Payment = 2,
        Withdraw = 3,
        Refund = 4,
        Reward = 5
    }

    public enum BookingStatus
    {
        Holding = -1,       // Đang giữ chỗ (5 phút)
        PendingPayment = 0,
        Confirmed = 1,
        Cancelled = 2,
        Completed = 3
    }

    public enum RecurrenceType
    {
        None = 0,
        Daily = 1,
        Weekly = 2,
        Monthly = 3
    }

    // Daily Matches enums
    public enum MatchStatus
    {
        Scheduled = 0,
        InProgress = 1,
        Completed = 2,
        Cancelled = 3
    }

    public enum MatchType
    {
        Friendly = 0,    // Giao hữu
        Ranked = 1,      // Xếp hạng
        Tournament = 2   // Giải đấu
    }

    // Tournament Match enums
    public enum TournamentMatchStatus
    {
        Pending = 0,     // Chưa xác định đội
        Scheduled = 1,   // Đã xếp lịch
        InProgress = 2,
        Completed = 3
    }

    public enum TournamentFormat
    {
        SingleElimination = 0,  // Loại trực tiếp
        DoubleElimination = 1,  // Loại kép
        RoundRobin = 2,         // Vòng tròn
        GroupThenKnockout = 3   // Vòng bảng + Knockout
    }

    // Duel enums
    public enum DuelType
    {
        Singles = 0,    // 1v1
        Doubles = 1     // 2v2
    }

    public enum DuelStatus
    {
        Pending = 0,     // Chờ đối thủ chấp nhận
        Accepted = 1,    // Đã chấp nhận, chờ thi đấu
        Declined = 2,    // Từ chối
        InProgress = 3,  // Đang thi đấu
        Completed = 4,   // Hoàn thành
        Cancelled = 5    // Hủy
    }
    public enum TransactionStatus
    {
        Pending = 0,
        Completed = 1,
        Rejected = 2,
        Failed = 3
    }

    public enum NotificationType
    {
        Info = 0,
        Success = 1,
        Warning = 2,
        Error = 3
    }
}

