using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SistemaChamados.Application.Services;
using SistemaChamados.Services;
using SistemaChamados.Data;
using SistemaChamados.Configuration;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.AI;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Core.UseCases.Tickets;
using SistemaChamados.Infrastructure.AI.OpenAI;
using SistemaChamados.Infrastructure.Persistence.Repositories;
using SistemaChamados.Infrastructure.Persistence.Seeders;
using SistemaChamados.Infrastructure.Persistence.Seed;
using SistemaChamados.Infrastructure.Extensions;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Configurar Entity Framework
// Para produção: SQL Server
// Para desenvolvimento/demonstração: SQLite (quando SQL Server não estiver disponível)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var useSqlite = builder.Configuration.GetValue<bool>("UseSqliteForDemo", false);

if (useSqlite || string.IsNullOrEmpty(connectionString))
{
    // Usar SQLite apenas para demonstração
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlite("Data Source=sistemachamados_demo.db"));
}
else
{
    // Usar SQL Server para produção
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString));
}
    
// ========================================
// REFATORAÇÃO: Clean Architecture DI
// ========================================

// MediatR (CQRS Pattern)
builder.Services.AddMediatR(cfg => 
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

// Identity & Authentication Services
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<SistemaChamados.Core.Interfaces.IUserContextService, 
    SistemaChamados.Infrastructure.Identity.UserContextService>();
// NEW: Anti-Corruption Layer for User Context (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.1)
builder.Services.AddScoped<SistemaChamados.Core.Interfaces.Auth.ICurrentUserService,
    SistemaChamados.Infrastructure.Identity.CurrentUserService>();
builder.Services.AddScoped<SistemaChamados.Core.Interfaces.Auth.IPasswordHasher,
    SistemaChamados.Infrastructure.Identity.BCryptPasswordHasher>();

// Domain Services (Pure Business Logic)
builder.Services.AddScoped<SistemaChamados.Core.Domain.Services.SlaCalculationService>();

// Repositories (Data Access Layer)
builder.Services.AddScoped<ITicketRepository, TicketRepository>();
builder.Services.AddScoped<ICommentRepository, CommentRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
// Phase 2.4 - Separated metadata repositories
builder.Services.AddScoped<IStatusRepository, StatusRepository>();
builder.Services.AddScoped<IPriorityRepository, PriorityRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();

// Context Mapping Services (Bridge between Bounded Contexts)
// AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2 (Context Mapping)
builder.Services.AddScoped<SistemaChamados.Core.Tickets.Interfaces.IUserLookupService,
    SistemaChamados.Infrastructure.Services.UserLookupService>();

// Use Cases (Business Logic Layer - DEPRECATED: use MediatR Handlers instead)
builder.Services.AddScoped<CreateTicketWithAIAnalysisUseCase>();

// Application Services (Use Case Orchestration - Phase 3)
// Phase 3.1 - Authentication Service
builder.Services.AddScoped<SistemaChamados.Application.Services.Auth.IAuthenticationService,
    SistemaChamados.Application.Services.Auth.AuthenticationService>();
// Phase 3.2 - User Registration Service
builder.Services.AddScoped<SistemaChamados.Application.Services.Users.IUserRegistrationService,
    SistemaChamados.Application.Services.Users.UserRegistrationService>();
// Phase 3.3 - Password Reset Service
builder.Services.AddScoped<SistemaChamados.Application.Services.Auth.IPasswordResetService,
    SistemaChamados.Application.Services.Auth.PasswordResetService>();

// External Services (Infrastructure Layer)
builder.Services.AddScoped<ITokenService, TokenService>();

// AI Services (Typed Client com IHttpClientFactory)
builder.Services.AddScoped<AIPromptBuilder>(); // Phase 2.2 - Prompt builder separated from adapter
builder.Services.AddHttpClient<IAIAnalysisService, OpenAIAdapter>(client =>
{
    client.BaseAddress = new Uri("https://api.openai.com/v1/");
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Email Services
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("Email"));
builder.Services.AddTransient<IEmailService, EmailService>();

// ========================================
// Database Seeding Infrastructure (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3)
// Modular Seeding System: IContextSeeder + DatabaseSeedRunner
// ========================================
builder.Services.AddDatabaseSeeding(); // Registers all seeders automatically:
                                       // - DatabaseSeedRunner (orchestrator)
                                       // - AuthContextSeeder (Order 1)
                                       // - TicketMetadataSeeder (Order 2)
                                       // - TicketDemoDataSeeder (Order 3)
// ========================================

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
});

// Configurar CORS para permitir o frontend (Live Server) E A NOVA APLICAÇÃO WEB
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.WithOrigins(
                  "http://127.0.0.1:5500", "http://localhost:5500", // Live Server antigo
                  "http://localhost:5027", "https://localhost:7086", // Portas padrão do ASP.NET MVC Web App
                  "http://localhost:8080", "http://127.0.0.1:8080"   // Frontend atual
              ) 
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configurar autenticação JWT
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireClaim("TipoUsuario", "3"));
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Adiciona a definição de segurança para o Swagger
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Insira o token JWT desta forma: Bearer {seu token}"
    });

    // Adiciona o requisito de segurança que aplica a definição acima
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

var app = builder.Build();

// ========================================
// REFATORAÇÃO: Database Initialization & Seeding
// Modular Seeding Infrastructure (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3)
// ========================================
await app.UseDatabaseSeedingAsync();
// ========================================

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Static files removed - frontend served separately on localhost:8080
// app.UseDefaultFiles();
// app.UseStaticFiles();

// Usar CORS para permitir frontend em porta diferente
app.UseCors("AllowAll");

//app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
