using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SistemaChamados.Application.Services;
using SistemaChamados.Services;
using SistemaChamados.Data;
using SistemaChamados.Configuration;
using SistemaChamados.Core.Entities;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Configurar Entity Framework
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
    
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
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.WriteIndented = false;
});

// Configurar CORS para permitir o frontend (Live Server)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.WithOrigins("http://127.0.0.1:5500", "http://localhost:5500") // Permite o Live Server
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

// Criar banco de dados em memória para demonstração
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
    SeedDatabase(context);
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

static void SeedDatabase(ApplicationDbContext context)
{
    if (!context.Status.Any())
    {
        context.Status.AddRange(
            new Status { Nome = "Aberto", Descricao = "Chamado recém criado e aguardando atribuição." },
            new Status { Nome = "Em Andamento", Descricao = "Um técnico já está trabalhando no chamado." },
            new Status { Nome = "Aguardando Resposta", Descricao = "Aguardando mais informações do usuário." },
            new Status { Nome = "Fechado", Descricao = "O chamado foi resolvido." },
            new Status { Nome = "Violado", Descricao = "O prazo de resolução (SLA) do chamado foi excedido." }
        );
    }

    if (!context.Prioridades.Any())
    {
        context.Prioridades.AddRange(
            new Prioridade { Nome = "Baixa", Nivel = 1, Descricao = "Resolver quando possível." },
            new Prioridade { Nome = "Média", Nivel = 2, Descricao = "Prioridade normal." },
            new Prioridade { Nome = "Alta", Nivel = 3, Descricao = "Resolver com urgência." }
        );
    }

    if (!context.Categorias.Any())
    {
        context.Categorias.AddRange(
            new Categoria { Nome = "Hardware", Descricao = "Problemas com peças físicas do computador." },
            new Categoria { Nome = "Software", Descricao = "Problemas com programas e sistemas." },
            new Categoria { Nome = "Rede", Descricao = "Problemas de conexão com a internet ou rede interna." },
            new Categoria { Nome = "Acesso/Login", Descricao = "Problemas de senha ou acesso a sistemas." }
        );
    }

    context.SaveChanges();

    var defaultPassword = "admin123";
    var defaultUsers = new[]
    {
        new Usuario
        {
            NomeCompleto = "Administrador Neuro Help",
            Email = "admin@helpdesk.com",
            TipoUsuario = 3
        },
        new Usuario
        {
            NomeCompleto = "Técnico Suporte",
            Email = "tecnico@helpdesk.com",
            TipoUsuario = 2,
            EspecialidadeCategoriaId = context.Categorias.FirstOrDefault()?.Id
        },
        new Usuario
        {
            NomeCompleto = "Usuário de Teste",
            Email = "usuario@helpdesk.com",
            TipoUsuario = 1
        }
    };

    foreach (var userTemplate in defaultUsers)
    {
        var existingUser = context.Usuarios.FirstOrDefault(u => u.Email == userTemplate.Email);
        if (existingUser == null)
        {
            userTemplate.SenhaHash = BCrypt.Net.BCrypt.HashPassword(defaultPassword);
            userTemplate.Ativo = true;
            userTemplate.DataCadastro = DateTime.UtcNow;
            context.Usuarios.Add(userTemplate);
        }
        else
        {
            if (!BCrypt.Net.BCrypt.Verify(defaultPassword, existingUser.SenhaHash))
            {
                existingUser.SenhaHash = BCrypt.Net.BCrypt.HashPassword(defaultPassword);
            }

            existingUser.TipoUsuario = userTemplate.TipoUsuario;
            existingUser.EspecialidadeCategoriaId = userTemplate.EspecialidadeCategoriaId;
            existingUser.Ativo = true;
        }
    }

    context.SaveChanges();
}
