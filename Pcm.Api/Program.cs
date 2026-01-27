using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Diagnostics;
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
builder.Services.AddHostedService<Pcm.Api.Services.AutoCancelService>();
// Cấu hình DB Context
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Cấu hình Identity
builder.Services.AddIdentity<Member, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// --- 2. KÍCH HOẠT CORS (Phải đặt TRƯỚC UseAuthorization) ---
app.UseCors("AllowAll"); 
// -------------------------------------------------------------

app.UseAuthorization();
app.MapHub<Pcm.Api.Hubs.PcmHub>("/pcmHub"); // Đường dẫn socket
app.MapControllers();
app.UseStaticFiles(); // <--- THÊM DÒNG NÀY
app.Run();