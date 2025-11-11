var builder = WebApplication.CreateBuilder(args);

// Configurar caminho personalizado para wwwroot
builder.Environment.WebRootPath = Path.Combine(builder.Environment.ContentRootPath, "..", "wwwroot");

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}

// Redirecionar HTTP para HTTPS (opcional, pode remover se quiser só HTTP)
// app.UseHttpsRedirection();

// Servir arquivos estáticos (HTML, CSS, JS, imagens)
app.UseDefaultFiles(); // Serve index.html automaticamente
app.UseStaticFiles();

// Fallback para SPA - todas as rotas retornam index.html
app.MapFallbackToFile("index.html");

app.Run();
