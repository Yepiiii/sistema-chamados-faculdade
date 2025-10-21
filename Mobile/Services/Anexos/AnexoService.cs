using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Maui.Media;
using Microsoft.Maui.Storage;
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Anexos;

public class AnexoService
{
    private static readonly List<AnexoDto> _anexosMock = new();
    private static int _nextId = 1;

    /// <summary>
    /// Permite o usuário selecionar uma imagem da galeria
    /// </summary>
    public async Task<FileResult?> SelecionarImagemAsync()
    {
        try
        {
            var resultado = await MediaPicker.Default.PickPhotoAsync(new MediaPickerOptions
            {
                Title = "Selecione uma imagem"
            });

            return resultado;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao selecionar imagem: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Permite o usuário tirar uma foto com a câmera
    /// </summary>
    public async Task<FileResult?> TirarFotoAsync()
    {
        try
        {
            if (!MediaPicker.Default.IsCaptureSupported)
            {
                return null;
            }

            var resultado = await MediaPicker.Default.CapturePhotoAsync();
            return resultado;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao tirar foto: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Salva o arquivo localmente e cria o DTO
    /// </summary>
    public async Task<AnexoDto?> SalvarAnexoAsync(FileResult arquivo, int chamadoId, UsuarioResumoDto usuario)
    {
        try
        {
            if (arquivo == null) return null;

            // Copia o arquivo para o diretório local da app
            var caminhoLocal = Path.Combine(FileSystem.CacheDirectory, $"{Guid.NewGuid()}{Path.GetExtension(arquivo.FileName)}");
            
            using (var stream = await arquivo.OpenReadAsync())
            using (var fileStream = File.Create(caminhoLocal))
            {
                await stream.CopyToAsync(fileStream);
            }

            // Obtém informações do arquivo
            var fileInfo = new FileInfo(caminhoLocal);

            var anexo = new AnexoDto
            {
                Id = _nextId++,
                ChamadoId = chamadoId,
                NomeArquivo = arquivo.FileName,
                CaminhoArquivo = caminhoLocal,
                TipoConteudo = arquivo.ContentType ?? "application/octet-stream",
                TamanhoBytes = fileInfo.Length,
                DataUpload = DateTime.Now,
                Usuario = usuario
            };

            _anexosMock.Add(anexo);
            return anexo;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao salvar anexo: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Obtém todos os anexos de um chamado
    /// </summary>
    public async Task<List<AnexoDto>> GetAnexosByChamadoIdAsync(int chamadoId)
    {
        await Task.Delay(100); // Simula latência
        
        return _anexosMock
            .Where(a => a.ChamadoId == chamadoId)
            .OrderBy(a => a.DataUpload)
            .ToList();
    }

    /// <summary>
    /// Remove um anexo
    /// </summary>
    public async Task<bool> RemoverAnexoAsync(int anexoId)
    {
        await Task.Delay(100);
        
        var anexo = _anexosMock.FirstOrDefault(a => a.Id == anexoId);
        if (anexo != null)
        {
            // Remove o arquivo físico
            try
            {
                if (File.Exists(anexo.CaminhoArquivo))
                {
                    File.Delete(anexo.CaminhoArquivo);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Erro ao deletar arquivo: {ex.Message}");
            }

            _anexosMock.Remove(anexo);
            return true;
        }

        return false;
    }

    /// <summary>
    /// Abre o arquivo no visualizador padrão do sistema
    /// </summary>
    public async Task AbrirAnexoAsync(AnexoDto anexo)
    {
        try
        {
            if (File.Exists(anexo.CaminhoArquivo))
            {
                await Launcher.Default.OpenAsync(new OpenFileRequest
                {
                    File = new ReadOnlyFile(anexo.CaminhoArquivo)
                });
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao abrir anexo: {ex.Message}");
        }
    }

    /// <summary>
    /// Compartilha o arquivo
    /// </summary>
    public async Task CompartilharAnexoAsync(AnexoDto anexo)
    {
        try
        {
            if (File.Exists(anexo.CaminhoArquivo))
            {
                await Share.Default.RequestAsync(new ShareFileRequest
                {
                    Title = anexo.NomeArquivo,
                    File = new ShareFile(anexo.CaminhoArquivo)
                });
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao compartilhar anexo: {ex.Message}");
        }
    }

    /// <summary>
    /// Limpa todos os anexos mock (útil para testes)
    /// </summary>
    public void LimparAnexosMock()
    {
        foreach (var anexo in _anexosMock.ToList())
        {
            try
            {
                if (File.Exists(anexo.CaminhoArquivo))
                {
                    File.Delete(anexo.CaminhoArquivo);
                }
            }
            catch { }
        }

        _anexosMock.Clear();
        _nextId = 1;
    }
}
