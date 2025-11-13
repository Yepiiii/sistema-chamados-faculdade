namespace SistemaChamados.Mobile.Helpers;

/// <summary>
/// Constantes para IDs de Status de Chamados
/// Sincronizado com o Backend e Banco de Dados SQL Server
/// 
/// ✅ CORRIGIDO: Backend usa StatusId = 4 para marcar chamado como Fechado
/// Ver: Backend/API/Controllers/ChamadosController.cs linha 256
/// Última sincronização: 13/11/2025
/// 
/// IMPORTANTE: Backend verifica "if (request.StatusId == 4)" para definir DataFechamento
/// Portanto, StatusConstants.Fechado DEVE ser 4
/// </summary>
public static class StatusConstants
{
    // IDs dos Status (sincronizados com Backend)
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int Aguardando = 3;
    public const int Fechado = 4;  // ✅ CORRIGIDO: Backend espera 4 para fechar
    public const int Violado = 5;  // Status quando SLA é excedido
    
    /// <summary>
    /// Nomes dos Status (para comparações case-insensitive)
    /// </summary>
    public static class Nomes
    {
        public const string Aberto = "Aberto";
        public const string EmAndamento = "Em Andamento";
        public const string Aguardando = "Aguardando Cliente";
        public const string Fechado = "Fechado";
        public const string Violado = "SLA Violado";
    }
}


