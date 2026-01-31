using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MembersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MembersController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetMembers([FromQuery] string? search)
        {
            var query = _context.Members.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(m => 
                    m.FullName.Contains(search) || 
                    m.UserName!.Contains(search) || 
                    m.Email!.Contains(search));
            }

            var members = await query
                .OrderBy(m => m.FullName)
                .Select(m => new 
                {
                    m.Id,
                    m.FullName,
                    m.UserName,
                    m.AvatarUrl,
                    m.DuprRating,
                    Tier = m.Tier.ToString()
                })
                .Take(20) // Limit results
                .ToListAsync();

            return Ok(members);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetMember(string id)
        {
            var member = await _context.Members
                .Where(m => m.Id == id)
                .Select(m => new 
                {
                    m.Id,
                    m.FullName,
                    m.UserName,
                    m.AvatarUrl,
                    m.DuprRating,
                    Tier = m.Tier.ToString(),
                    m.TotalMatches,
                    m.MatchesWon,
                    m.WinRate
                })
                .FirstOrDefaultAsync();

            if (member == null) return NotFound();

            return Ok(member);
        }
    }
}
