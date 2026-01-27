using Microsoft.AspNetCore.SignalR;

namespace Pcm.Api.Hubs
{
    public class PcmHub : Hub
    {
        // Hàm này để App gọi lên Server: "Tao là User A đây, tao đang online"
        public async Task JoinRoom(string userId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, userId);
        }
    }
}