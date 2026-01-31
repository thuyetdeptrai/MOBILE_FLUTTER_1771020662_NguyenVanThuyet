using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<Member> _userManager;
        private readonly SignInManager<Member> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;

        public AuthController(
            UserManager<Member> userManager,
            SignInManager<Member> signInManager,
            IConfiguration configuration,
            ApplicationDbContext context)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _context = context;
        }

        // API Đăng Ký - Tạo Member trực tiếp (vì Member kế thừa IdentityUser)
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest req)
        {
            // Tạo Member (bao gồm cả Identity fields)
            var member = new Member
            {
                UserName = req.Username,
                Email = req.Email,
                FullName = req.FullName,
                Tier = Tier.Bronze,
                JoinDate = DateTime.Now,
                WalletBalance = 0,
                RankLevel = 0
            };

            var result = await _userManager.CreateAsync(member, req.Password);

            if (!result.Succeeded)
                return BadRequest(result.Errors);

            // Gán role Member
            await _userManager.AddToRoleAsync(member, "Member");

            return Ok(new { Message = "Đăng ký thành công!" });
        }

        // API Đăng Nhập
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            try
            {
                var result = await _signInManager.PasswordSignInAsync(model.Username, model.Password, false, false);
                
                if (result.Succeeded)
                {
                    var member = await _userManager.FindByNameAsync(model.Username);
                    var roles = await _userManager.GetRolesAsync(member!);
                    
                    // Generate JWT Token
                    var token = GenerateJwtToken(member!, roles);

                    return Ok(new
                    {
                        UserId = member!.Id,
                        Username = member.UserName,
                        FullName = member.FullName,
                        Email = member.Email,
                        Role = roles.FirstOrDefault() ?? "Member",
                        Tier = member.Tier.ToString(),
                        WalletBalance = member.WalletBalance,
                        RankLevel = member.RankLevel,
                        Token = token
                    });
                }
                
                return Unauthorized("Sai tài khoản hoặc mật khẩu");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi Đăng nhập: {ex.Message} | Stack: {ex.StackTrace}");
            }
        }
        
        private string GenerateJwtToken(Member member, IList<string> roles)
        {
            var jwtKey = _configuration["Jwt:Key"] ?? "PcmPickleballSuperSecretKey12345678!";
            var jwtIssuer = _configuration["Jwt:Issuer"] ?? "PcmApi";
            var jwtAudience = _configuration["Jwt:Audience"] ?? "PcmMobile";
            
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, member.Id),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.NameIdentifier, member.Id),
                new Claim(ClaimTypes.Name, member.UserName ?? ""),
                new Claim(ClaimTypes.Email, member.Email ?? "")
            };
            
            // Add role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }
            
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            
            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: DateTime.Now.AddDays(7), // Token hết hạn sau 7 ngày
                signingCredentials: creds
            );
            
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class RegisterRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }

    public class LoginModel
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}