using System;

namespace SistemaChamados.Mobile.Models.DTOs;

public class ComentarioDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string Texto { get; set; } = string.Empty;
    
    // ✅ SIMPLIFICADO: Backend envia DataCriacao
    public DateTime DataCriacao { get; set; }
    
    // ✅ SIMPLIFICADO: Backend envia UsuarioNome como string
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; } = string.Empty;
    
    // ❌ REMOVIDO: Backend não envia objeto Usuario
    // ❌ REMOVIDO: Backend não envia IsInterno
    // ❌ REMOVIDO: DataHora (duplicado de DataCriacao)
    
    // UI Helpers - Usa DataCriacao em vez de DataHora
    private DateTime DataHoraLocal
    {
        get
        {
            // Se a data é UTC, converte para local
            if (DataCriacao.Kind == DateTimeKind.Utc)
                return DataCriacao.ToLocalTime();
            
            // Se não tem Kind definido, assume UTC (padrão da API)
            if (DataCriacao.Kind == DateTimeKind.Unspecified)
                return DateTime.SpecifyKind(DataCriacao, DateTimeKind.Utc).ToLocalTime();
            
            // Já é local
            return DataCriacao;
        }
    }
    
    public string DataHoraFormatada => DataHoraLocal.ToString("dd/MM/yyyy às HH:mm");
    
    public string TempoRelativo
    {
        get
        {
            var diferenca = DateTime.Now - DataHoraLocal;
            
            if (diferenca.TotalMinutes < 1)
                return "agora";
            if (diferenca.TotalMinutes < 60)
                return $"há {(int)diferenca.TotalMinutes} min";
            if (diferenca.TotalHours < 24)
                return $"há {(int)diferenca.TotalHours}h";
            if (diferenca.TotalDays < 7)
                return $"há {(int)diferenca.TotalDays}d";
            
            return DataHoraFormatada;
        }
    }
    
    // ✅ SIMPLIFICADO: Usa UsuarioNome diretamente
    public string NomeUsuario => string.IsNullOrWhiteSpace(UsuarioNome) ? "Usuário" : UsuarioNome;
    public string InicialUsuario => string.IsNullOrEmpty(NomeUsuario) ? "?" : NomeUsuario[0].ToString().ToUpper();
    
    // ✅ SIMPLIFICADO: Cor padrão (sem objeto Usuario para verificar tipo)
    public string CorAvatar => "#10B981"; // Verde padrão
    
    // ❌ REMOVIDO: Propriedades que dependiam de Usuario.TipoUsuario
    // public bool IsColaborador, IsTecnicoTI, IsAdmin
    // public string BadgeTipoUsuario
}
