using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Enums;

namespace SistemaChamados.Application.Services;

/// <summary>
/// Serviço centralizado para gerenciamento de permissões de chamados
/// </summary>
public class PermissoesService
{
    /// <summary>
    /// Verifica se o usuário pode visualizar o chamado
    /// </summary>
    /// <param name="chamado">Chamado a ser verificado</param>
    /// <param name="usuarioId">ID do usuário logado</param>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode visualizar, False caso contrário</returns>
    public static bool PodeVisualizarChamado(Chamado chamado, int usuarioId, TipoUsuario tipoUsuario)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => chamado.SolicitanteId == usuarioId, // Só seus próprios
            TipoUsuario.TecnicoTI => chamado.TecnicoId == usuarioId,       // Só atribuídos a ele
            TipoUsuario.Admin => true,                                      // Todos
            _ => false
        };
    }

    /// <summary>
    /// Verifica se o usuário pode criar um chamado
    /// </summary>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode criar, False caso contrário</returns>
    public static bool PodeCriarChamado(TipoUsuario tipoUsuario)
    {
        // Colaborador, Técnico e Admin podem criar chamados
        return tipoUsuario == TipoUsuario.Colaborador || 
               tipoUsuario == TipoUsuario.TecnicoTI || 
               tipoUsuario == TipoUsuario.Admin;
    }

    /// <summary>
    /// Verifica se o usuário pode editar o chamado
    /// </summary>
    /// <param name="chamado">Chamado a ser editado</param>
    /// <param name="usuarioId">ID do usuário logado</param>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode editar, False caso contrário</returns>
    public static bool PodeEditarChamado(Chamado chamado, int usuarioId, TipoUsuario tipoUsuario)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => chamado.SolicitanteId == usuarioId && chamado.StatusId != 3, // Seu próprio e não encerrado
            TipoUsuario.TecnicoTI => false,  // Técnico não pode editar
            TipoUsuario.Admin => true,       // Admin pode editar tudo
            _ => false
        };
    }

    /// <summary>
    /// Verifica se o usuário pode encerrar o chamado
    /// </summary>
    /// <param name="chamado">Chamado a ser encerrado</param>
    /// <param name="usuarioId">ID do usuário logado</param>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode encerrar, False caso contrário</returns>
    public static bool PodeEncerrarChamado(Chamado chamado, int usuarioId, TipoUsuario tipoUsuario)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => false,                               // Colaborador não pode encerrar
            TipoUsuario.TecnicoTI => chamado.TecnicoId == usuarioId,       // Só seus próprios
            TipoUsuario.Admin => true,                                      // Admin pode encerrar todos
            _ => false
        };
    }

    /// <summary>
    /// Verifica se o usuário pode atribuir/reatribuir técnico ao chamado
    /// </summary>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode atribuir, False caso contrário</returns>
    public static bool PodeAtribuirTecnico(TipoUsuario tipoUsuario)
    {
        // Apenas Admin pode atribuir/reatribuir técnicos
        return tipoUsuario == TipoUsuario.Admin;
    }

    /// <summary>
    /// Verifica se o usuário pode adicionar comentários ao chamado
    /// </summary>
    /// <param name="chamado">Chamado para adicionar comentário</param>
    /// <param name="usuarioId">ID do usuário logado</param>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode comentar, False caso contrário</returns>
    public static bool PodeComentarChamado(Chamado chamado, int usuarioId, TipoUsuario tipoUsuario)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => chamado.SolicitanteId == usuarioId, // Só seus próprios
            TipoUsuario.TecnicoTI => chamado.TecnicoId == usuarioId,       // Só atribuídos a ele
            TipoUsuario.Admin => true,                                      // Todos
            _ => false
        };
    }

    /// <summary>
    /// Verifica se o usuário pode deletar o chamado
    /// </summary>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <returns>True se pode deletar, False caso contrário</returns>
    public static bool PodeDeletarChamado(TipoUsuario tipoUsuario)
    {
        // Apenas Admin pode deletar chamados
        return tipoUsuario == TipoUsuario.Admin;
    }

    /// <summary>
    /// Verifica se o usuário pode mudar o status do chamado
    /// </summary>
    /// <param name="chamado">Chamado para mudar status</param>
    /// <param name="usuarioId">ID do usuário logado</param>
    /// <param name="tipoUsuario">Tipo do usuário logado</param>
    /// <param name="novoStatusId">Novo status a ser aplicado</param>
    /// <returns>True se pode mudar status, False caso contrário</returns>
    public static bool PodeMudarStatus(Chamado chamado, int usuarioId, TipoUsuario tipoUsuario, int novoStatusId)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => false, // Colaborador não pode mudar status
            TipoUsuario.TecnicoTI => chamado.TecnicoId == usuarioId && novoStatusId == 3, // Só pode encerrar (status 3)
            TipoUsuario.Admin => true, // Admin pode mudar qualquer status
            _ => false
        };
    }

    /// <summary>
    /// Obtém descrição das permissões do tipo de usuário
    /// </summary>
    /// <param name="tipoUsuario">Tipo do usuário</param>
    /// <returns>String com descrição das permissões</returns>
    public static string ObterDescricaoPermissoes(TipoUsuario tipoUsuario)
    {
        return tipoUsuario switch
        {
            TipoUsuario.Colaborador => "Pode criar chamados e visualizar apenas seus próprios chamados",
            TipoUsuario.TecnicoTI => "Pode criar chamados, visualizar chamados atribuídos a ele e encerrá-los",
            TipoUsuario.Admin => "Acesso total: criar, editar, atribuir, encerrar e visualizar todos os chamados",
            _ => "Sem permissões"
        };
    }
}
