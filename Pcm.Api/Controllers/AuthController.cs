using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        // 1. Khai báo đúng các biến cần dùng
        private readonly UserManager<IdentityUser> _userManager; // Dùng IdentityUser chuẩn
        private readonly SignInManager<IdentityUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context; // <--- Đã thêm biến này

        // 2. Inject (Tiêm) vào Constructor
        public AuthController(
            UserManager<IdentityUser> userManager,
            SignInManager<IdentityUser> signInManager,
            IConfiguration configuration,
            ApplicationDbContext context) // <--- Nhận context từ đây
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _context = context; // <--- Gán giá trị
        }

        // 3. API Đăng Ký (Code đã sửa khớp với Member Entity)
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest req)
        {
            // Tạo tài khoản đăng nhập (IdentityUser)
            var user = new IdentityUser { UserName = req.Username, Email = req.Email };
            var result = await _userManager.CreateAsync(user, req.Password);

            if (!result.Succeeded) return BadRequest(result.Errors);

            // Tạo hồ sơ thành viên (Member)
            var member = new Member
            {
                Id = user.Id,       // Id member trùng Id user
                UserId = user.Id,   // Link với bảng User
                FullName = req.FullName,
                Tier = Tier.Bronze, // Enum chuẩn
                JoinDate = DateTime.Now,
                WalletBalance = 0,
                IsActive = true,    // Dùng IsActive thay vì Status
                RankLevel = 0
            };

            _context.Members.Add(member);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đăng ký thành công!" });
        }

        // 4. API Đăng Nhập (Giữ nguyên hoặc dùng code cũ của bạn)
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            var result = await _signInManager.PasswordSignInAsync(model.Username, model.Password, false, false);
            if (result.Succeeded)
            {
                var user = await _userManager.FindByNameAsync(model.Username);
                // Tìm thông tin Member để lấy FullName
                var member = _context.Members.FirstOrDefault(m => m.UserId == user.Id);
                
                return Ok(new 
                { 
                    UserId = user.Id,
                    FullName = member?.FullName ?? user.UserName, // Nếu chưa có member thì lấy username đỡ
                    Token = "fake-jwt-token-for-now" 
                });
            }
            return Unauthorized("Sai tài khoản hoặc mật khẩu");
        }
    }

    // Các class phụ trợ
    public class RegisterRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    public class LoginModel
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }
}