namespace SistemaChamados.Mobile.Helpers;

/// <summary>
/// Constantes para IDs de Status de Chamados
/// Sincronizado com o Backend e Banco de Dados SQL Server
/// 
/// ✅ BANCO RESETADO: IDs agora começam em 1 (script ResetarIDsSequenciais.sql executado)
/// Última sincronização: 11/11/2025 - 23:45
/// 
/// Verificado com: SELECT Id, Nome FROM Status ORDER BY Id
/// Resultado:
///   1 - Aberto
///   2 - Em Andamento
///   3 - Aguardando Cliente
///   4 - Resolvido
///   5 - Fechado
/// </summary>
public static class StatusConstants
{
    // IDs dos Status
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int Aguardando = 3;
    public const int Resolvido = 4;
    public const int Fechado = 5;
    
    // Status especial: SLA Violado (não existe como status separado no banco)
    // É determinado pela lógica: SlaDataExpiracao < DateTime.Now && !Fechado
    public const int Violado = -1; // ID fictício para lógica de UI
    
    /// <summary>
    /// Nomes dos Status (para comparações case-insensitive)
    /// </summary>
    public static class Nomes
    {
        public const string Aberto = "Aberto";
        public const string EmAndamento = "Em Andamento";
        public const string Aguardando = "Aguardando Cliente";
        public const string Resolvido = "Resolvido";
        public const string Fechado = "Fechado";
        public const string Violado = "SLA Violado";
    }
}


