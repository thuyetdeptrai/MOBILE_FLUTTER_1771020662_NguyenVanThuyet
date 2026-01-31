using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Pcm.Api.Data;
using Pcm.Api.Entities;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// --- 1. THÊM DỊCH VỤ CORS (Cho phép mọi nơi truy cập) ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});
// -------------------------------------------------------

// SignalR cho real-time notifications
builder.Services.AddSignalR();

// builder.Services.AddHostedService<Pcm.Api.Services.AutoCancelService>(); // TẠM TẮT - gây crash
// Cấu hình DB Context
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
           .ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning)));

// Cấu hình Identity - Dùng Member (kế thừa IdentityUser)
builder.Services.AddIdentity<Member, IdentityRole>()
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

// --- JWT Authentication Configuration ---
var jwtKey = builder.Configuration["Jwt:Key"] ?? "PcmPickleballSuperSecretKey12345678!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "PcmApi";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "PcmMobile";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});
// -----------------------------------------

// Register Background Services
builder.Services.AddHostedService<Pcm.Api.Services.AutoCancelService>();
builder.Services.AddHostedService<Pcm.Api.Services.AutoRemindService>();

var app = builder.Build();

// Seed dữ liệu mẫu (Admin, Users, Courts, Tournaments)
try 
{
    await Pcm.Api.Services.DbSeeder.SeedData(app.Services);
    Console.WriteLine("✅ Database seeded successfully!");
}
catch (Exception ex)
{
    Console.WriteLine($"⚠️ Database seeding skipped: {ex.Message}");
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();

// --- 2. KÍCH HOẠT CORS (Phải đặt TRƯỚC UseAuthorization) ---
app.UseCors("AllowAll"); 
// -------------------------------------------------------------

app.UseAuthentication(); // <-- PHẢI ĐẶT TRƯỚC UseAuthorization
app.UseAuthorization();
app.MapHub<Pcm.Api.Hubs.PcmHub>("/pcmHub"); // Đường dẫn socket
app.MapControllers();
app.UseStaticFiles(); // <--- THÊM DÒNG NÀY
app.Run();