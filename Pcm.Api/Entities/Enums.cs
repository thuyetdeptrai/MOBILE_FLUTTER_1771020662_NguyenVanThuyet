namespace Pcm.Api.Entities // Hoặc Pcm.Api.Enums tùy bạn, nhưng nên để cùng namespace với Entity
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
        PendingPayment = 0,
        Confirmed = 1,
        Cancelled = 2,
        Completed = 3
    }
}