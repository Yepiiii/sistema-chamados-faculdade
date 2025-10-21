using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Comentarios;

public class ComentarioService
{
    // Mock data - em produção, isso viria da API
    private static List<ComentarioDto> _comentariosMock = new();
    private static int _nextId = 1;

    public async Task<List<ComentarioDto>> GetComentariosByChamadoIdAsync(int chamadoId)
    {
        await Task.Delay(100); // Simula latência de rede
        
        return _comentariosMock
            .Where(c => c.ChamadoId == chamadoId)
            .OrderBy(c => c.DataHora)
            .ToList();
    }

    public async Task<ComentarioDto?> AddComentarioAsync(int chamadoId, string texto, UsuarioResumoDto usuario, bool isInterno = false)
    {
        await Task.Delay(200); // Simula latência de rede
        
        if (string.IsNullOrWhiteSpace(texto))
            return null;

        var comentario = new ComentarioDto
        {
            Id = _nextId++,
            ChamadoId = chamadoId,
            Texto = texto.Trim(),
            DataHora = DateTime.Now,
            Usuario = usuario,
            IsInterno = isInterno
        };

        _comentariosMock.Add(comentario);
        return comentario;
    }

    public async Task<bool> DeleteComentarioAsync(int comentarioId)
    {
        await Task.Delay(100);
        
        var comentario = _comentariosMock.FirstOrDefault(c => c.Id == comentarioId);
        if (comentario != null)
        {
            _comentariosMock.Remove(comentario);
            return true;
        }
        
        return false;
    }

    public async Task<ComentarioDto?> UpdateComentarioAsync(int comentarioId, string novoTexto)
    {
        await Task.Delay(100);
        
        var comentario = _comentariosMock.FirstOrDefault(c => c.Id == comentarioId);
        if (comentario != null && !string.IsNullOrWhiteSpace(novoTexto))
        {
            comentario.Texto = novoTexto.Trim();
            return comentario;
        }
        
        return null;
    }

    // Método para gerar comentários mock de teste
    public void GerarComentariosMock(int chamadoId, UsuarioResumoDto aluno, UsuarioResumoDto? tecnico)
    {
        if (_comentariosMock.Any(c => c.ChamadoId == chamadoId))
            return; // Já tem comentários para este chamado

        var baseTime = DateTime.Now.AddHours(-3);

        // Comentário inicial do aluno
        _comentariosMock.Add(new ComentarioDto
        {
            Id = _nextId++,
            ChamadoId = chamadoId,
            Texto = "Olá, estou com dificuldades para acessar o sistema. Quando tento fazer login, aparece uma mensagem de erro.",
            DataHora = baseTime,
            Usuario = aluno,
            IsInterno = false
        });

        if (tecnico != null)
        {
            // Resposta do técnico
            _comentariosMock.Add(new ComentarioDto
            {
                Id = _nextId++,
                ChamadoId = chamadoId,
                Texto = "Olá! Vou verificar o problema. Você pode me informar qual navegador está utilizando?",
                DataHora = baseTime.AddMinutes(15),
                Usuario = tecnico,
                IsInterno = false
            });

            // Resposta do aluno
            _comentariosMock.Add(new ComentarioDto
            {
                Id = _nextId++,
                ChamadoId = chamadoId,
                Texto = "Estou usando o Chrome, versão mais recente.",
                DataHora = baseTime.AddMinutes(20),
                Usuario = aluno,
                IsInterno = false
            });

            // Comentário interno do técnico
            _comentariosMock.Add(new ComentarioDto
            {
                Id = _nextId++,
                ChamadoId = chamadoId,
                Texto = "Verificado no sistema. Problema identificado no servidor de autenticação. Encaminhando para a equipe de infraestrutura.",
                DataHora = baseTime.AddMinutes(30),
                Usuario = tecnico,
                IsInterno = true
            });

            // Atualização para o aluno
            _comentariosMock.Add(new ComentarioDto
            {
                Id = _nextId++,
                ChamadoId = chamadoId,
                Texto = "Identifiquei o problema. Nossa equipe está trabalhando na solução. Você deve conseguir acessar em breve. Vou atualizá-lo assim que o problema for resolvido.",
                DataHora = baseTime.AddMinutes(35),
                Usuario = tecnico,
                IsInterno = false
            });
        }
    }

    // Limpa os comentários mock (útil para testes)
    public void LimparComentariosMock()
    {
        _comentariosMock.Clear();
        _nextId = 1;
    }
}
