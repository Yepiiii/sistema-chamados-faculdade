using System;

namespace SistemaChamados.Mobile.Models.DTOs;

public class AnexoDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string NomeArquivo { get; set; } = string.Empty;
    public string CaminhoArquivo { get; set; } = string.Empty;
    public string TipoConteudo { get; set; } = string.Empty; // MIME type: image/jpeg, image/png, application/pdf
    public long TamanhoBytes { get; set; }
    public DateTime DataUpload { get; set; }
    public UsuarioResumoDto? Usuario { get; set; }
    
    // UI Helpers
    public string TamanhoFormatado
    {
        get
        {
            if (TamanhoBytes < 1024)
                return $"{TamanhoBytes} B";
            if (TamanhoBytes < 1024 * 1024)
                return $"{TamanhoBytes / 1024:F1} KB";
            return $"{TamanhoBytes / (1024 * 1024):F1} MB";
        }
    }
    
    public string DataUploadFormatada => DataUpload.ToString("dd/MM/yyyy às HH:mm");
    
    public bool IsImagem => TipoConteudo.StartsWith("image/", StringComparison.OrdinalIgnoreCase);
    public bool IsPdf => TipoConteudo.Equals("application/pdf", StringComparison.OrdinalIgnoreCase);
    
    public string IconeArquivo
    {
        get
        {
            if (IsImagem) return "🖼️";
            if (IsPdf) return "📄";
            if (TipoConteudo.Contains("word")) return "📝";
            if (TipoConteudo.Contains("excel") || TipoConteudo.Contains("spreadsheet")) return "📊";
            if (TipoConteudo.Contains("zip") || TipoConteudo.Contains("rar")) return "🗜️";
            return "📎";
        }
    }
    
    public string ExtensaoArquivo
    {
        get
        {
            var extensao = System.IO.Path.GetExtension(NomeArquivo);
            return string.IsNullOrEmpty(extensao) ? "" : extensao.ToUpper().TrimStart('.');
        }
    }
    
    // Para exibição na galeria
    public string ImageSource => CaminhoArquivo;
}
