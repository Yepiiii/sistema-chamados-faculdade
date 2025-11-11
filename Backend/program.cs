using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SistemaChamados.Application.Services;
using SistemaChamados.Services;
using SistemaChamados.Data;
using SistemaChamados.Data.Seed;
using SistemaChamados.Configuration;
using SistemaChamados.Core.Entities;
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
    
// Registrar serviços
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IOpenAIService, OpenAIService>();

// Configurar HttpClient para o OpenAIService
builder.Services.AddHttpClient<IOpenAIService, OpenAIService>();

// Configura a seção EmailSettings do appsettings.json
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));

// Registra o EmailService para injeção de dependência
builder.Services.AddTransient<IEmailService, EmailService>();

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.Preserve;
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

// Criar banco de dados e popular com dados iniciais
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    // context.Database.Migrate(); // TEMPORARIAMENTE COMENTADO - Script SQL será aplicado manualmente
    DatabaseSeed.Seed(context); // Popula dados iniciais
}

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
