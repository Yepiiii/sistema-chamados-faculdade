using System;

namespace SistemaChamados.Mobile.Models.DTOs;

public class ComentarioDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataHora { get; set; }
    public UsuarioResumoDto? Usuario { get; set; }
    public bool IsInterno { get; set; } // Comentário interno (apenas técnicos/admin)
    
    // UI Helpers - Converte UTC para horário local
    private DateTime DataHoraLocal
    {
        get
        {
            // Se a data é UTC, converte para local
            if (DataHora.Kind == DateTimeKind.Utc)
                return DataHora.ToLocalTime();
            
            // Se não tem Kind definido, assume UTC (padrão da API)
            if (DataHora.Kind == DateTimeKind.Unspecified)
                return DateTime.SpecifyKind(DataHora, DateTimeKind.Utc).ToLocalTime();
            
            // Já é local
            return DataHora;
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
    
    public string NomeUsuario => Usuario?.NomeCompleto ?? "Usuário";
    public string InicialUsuario => string.IsNullOrEmpty(NomeUsuario) ? "?" : NomeUsuario[0].ToString().ToUpper();
    
    // Cor do avatar baseada no tipo de usuário
    public string CorAvatar
    {
        get
        {
            if (Usuario?.TipoUsuario == 3) return "#8B5CF6"; // Admin - Roxo
            if (Usuario?.TipoUsuario == 2) return "#2A5FDF"; // Técnico TI - Azul
            return "#10B981"; // Colaborador - Verde
        }
    }
    
    public bool IsColaborador => Usuario?.TipoUsuario == 1;
    public bool IsTecnicoTI => Usuario?.TipoUsuario == 2;
    public bool IsAdmin => Usuario?.TipoUsuario == 3;
    
    // Badge do tipo de usuário
    public string BadgeTipoUsuario
    {
        get
        {
            if (IsAdmin) return "👑 Admin";
            if (IsTecnicoTI) return "🔧 Técnico TI";
            return "💼 Colaborador";
        }
    }
}
