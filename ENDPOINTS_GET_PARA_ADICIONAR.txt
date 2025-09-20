// ========================================
// ENDPOINTS GET PARA ADICIONAR NO ChamadosController.cs
// ========================================
// 
// Adicione estes dois métodos dentro da classe ChamadosController,
// após o método CriarChamado (POST) existente:

[HttpGet]
public async Task<IActionResult> GetChamados()
{
    var chamados = await _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .ToListAsync();

    return Ok(chamados);
}

[HttpGet("{id}")]
public async Task<IActionResult> GetChamadoPorId(int id)
{
    var chamado = await _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico) // Inclui o técnico também, se houver
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .FirstOrDefaultAsync(c => c.Id == id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    return Ok(chamado);
}

// ========================================
// INSTRUÇÕES:
// ========================================
// 
// 1. Abra o arquivo: API/Controllers/ChamadosController.cs
// 
// 2. Localize o final do método CriarChamado (que termina com "return Ok(novoChamado);")
// 
// 3. Adicione os dois métodos acima após o método CriarChamado
// 
// 4. Salve o arquivo
// 
// 5. Pare o servidor (Ctrl+C) e execute novamente: dotnet run
// 
// 6. Acesse o Swagger e você verá os novos endpoints GET
//
// ========================================
// FUNCIONALIDADES DOS ENDPOINTS:
// ========================================
//
// GET /api/chamados
// - Lista todos os chamados do sistema
// - Inclui dados das tabelas relacionadas (Solicitante, Status, Prioridade, Categoria)
// - Usa .Include() para evitar propriedades nulas
//
// GET /api/chamados/{id}
// - Busca um chamado específico por ID
// - Inclui dados das tabelas relacionadas (Solicitante, Técnico, Status, Prioridade, Categoria)
// - Retorna 404 se o chamado não for encontrado
// - Usa .Include() para carregar todos os relacionamentos
//
// ========================================