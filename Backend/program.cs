using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SistemaChamados.Application.Services;
using SistemaChamados.Services;
using SistemaChamados.Data;
using SistemaChamados.Configuration;
using System.Text;
using SistemaChamados.Core.Entities;
using System.Linq;

LoadDotEnv();

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Configurar Entity Framework
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
    
// Registrar serviços
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IOpenAIService, GeminiService>();
builder.Services.AddScoped<IAIService, AIService>();
builder.Services.AddScoped<IHandoffService, HandoffService>();

// Configurar HttpClient para o GeminiService
builder.Services.AddHttpClient<IOpenAIService, GeminiService>();

// Configura a seção EmailSettings do appsettings.json
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));

// Registra o EmailService para injeção de dependência
builder.Services.AddTransient<IEmailService, EmailService>();

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
});

// Configurar CORS para permitir requisições do frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
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
builder.Services.AddAuthorization();

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

// Criar banco de dados em memória para demonstração
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();

    if (!context.Categorias.Any())
    {
        context.Categorias.AddRange(
            new Categoria { Nome = "Infraestrutura", Descricao = "Equipamentos, rede e hardware" },
            new Categoria { Nome = "Sistemas Acadêmicos", Descricao = "Erro ou acesso em portais e sistemas" },
            new Categoria { Nome = "Conta e Acesso", Descricao = "Senha, e-mail institucional e autenticação" }
        );
    }

    if (!context.Prioridades.Any())
    {
        context.Prioridades.AddRange(
            new Prioridade { Nome = "Baixa", Descricao = "Impacto mínimo, pode aguardar", Nivel = 1 },
            new Prioridade { Nome = "Média", Descricao = "Impacto moderado, resolver em breve", Nivel = 2 },
            new Prioridade { Nome = "Alta", Descricao = "Impacto crítico, resolver imediatamente", Nivel = 3 }
        );
    }

    if (!context.Status.Any())
    {
        context.Status.AddRange(
            new Status { Nome = "Aberto", Descricao = "Chamado recém criado" },
            new Status { Nome = "Em andamento", Descricao = "Equipe trabalhando na solicitação" },
            new Status { Nome = "Resolvido", Descricao = "Chamado encerrado" }
        );
    }

    context.SaveChanges();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Usar CORS
app.UseCors("AllowAll");

//app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

static void LoadDotEnv()
{
    var rootPath = Directory.GetCurrentDirectory();
    var candidatePaths = new[]
    {
        Path.Combine(rootPath, ".env"),
        Path.Combine(AppContext.BaseDirectory, ".env")
    };

    var envFilePath = candidatePaths.FirstOrDefault(File.Exists);
    if (string.IsNullOrEmpty(envFilePath))
    {
        Console.WriteLine("[AVISO] Arquivo .env não encontrado!");
        return;
    }

    Console.WriteLine($"[INFO] Carregando .env de: {envFilePath}");
    
    foreach (var rawLine in File.ReadAllLines(envFilePath))
    {
        var line = rawLine.Trim();
        if (string.IsNullOrEmpty(line) || line.StartsWith("#"))
        {
            continue;
        }

        var separatorIndex = line.IndexOf('=');
        if (separatorIndex <= 0)
        {
            continue;
        }

        var key = line.Substring(0, separatorIndex).Trim();
        var value = line.Substring(separatorIndex + 1).Trim();

        if (value.Length >= 2 && value.StartsWith("\"") && value.EndsWith("\""))
        {
            value = value.Substring(1, value.Length - 2);
        }

        Environment.SetEnvironmentVariable(key, value);
    }

    // Configurar GEMINI_API_KEY para usar diretamente
    var geminiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
    if (!string.IsNullOrWhiteSpace(geminiKey))
    {
        // Garante que a chave do Gemini esteja disponível
        Console.WriteLine($"[OK] Chave do Gemini carregada: {geminiKey.Substring(0, 10)}...");
    }
    else
    {
        Console.WriteLine("[ERRO] Chave do Gemini NÃO foi carregada!");
    }
}
