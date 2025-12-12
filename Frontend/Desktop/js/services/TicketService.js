// Ticket Service
// Serviço para gerenciamento de chamados/tickets

import { apiService } from './ApiService.js';

/**
 * Serviço de gerenciamento de tickets
 */
export class TicketService {
  /**
   * Obtém todos os tickets com filtros opcionais
   * @param {Object} filters - Filtros para busca
   * @param {number} filters.statusId - ID do status
   * @param {number} filters.tecnicoId - ID do técnico
   * @param {number} filters.solicitanteId - ID do solicitante
   * @param {number} filters.prioridadeId - ID da prioridade
   * @param {number} filters.categoriaId - ID da categoria
   * @param {string} filters.search - Termo de busca
   * @returns {Promise<Array>}
   */
  async getAll(filters = {}) {
    const params = new URLSearchParams();
    
    if (filters.statusId) params.append('statusId', filters.statusId);
    if (filters.tecnicoId) params.append('tecnicoId', filters.tecnicoId);
    if (filters.solicitanteId) params.append('solicitanteId', filters.solicitanteId);
    if (filters.prioridadeId) params.append('prioridadeId', filters.prioridadeId);
    if (filters.categoriaId) params.append('categoriaId', filters.categoriaId);
    if (filters.search) params.append('search', filters.search);

    const query = params.toString();
    const endpoint = query ? `/api/chamados?${query}` : '/api/chamados';

    return await apiService.get(endpoint);
  }

  /**
   * Obtém ticket por ID
   * @param {number} id - ID do ticket
   * @returns {Promise<Object>}
   */
  async getById(id) {
    return await apiService.get(`/api/chamados/${id}`);
  }

  /**
   * Cria novo ticket
   * @param {Object} ticketData - Dados do ticket
   * @param {string} ticketData.titulo - Título do ticket
   * @param {string} ticketData.descricao - Descrição do ticket
   * @param {number} ticketData.categoriaId - ID da categoria
   * @param {number} ticketData.prioridadeId - ID da prioridade
   * @returns {Promise<Object>}
   */
  async create(ticketData) {
    return await apiService.post('/api/chamados', {
      Titulo: ticketData.titulo,
      Descricao: ticketData.descricao,
      CategoriaId: ticketData.categoriaId,
      PrioridadeId: ticketData.prioridadeId
    });
  }

  /**
   * Cria ticket com análise de IA
   * @param {string} descricao - Descrição do problema
   * @returns {Promise<Object>}
   */
  async createWithAI(descricao) {
    return await apiService.post('/api/chamados/analisar', {
      DescricaoProblema: descricao
    });
  }

  /**
   * Atualiza ticket existente
   * @param {number} id - ID do ticket
   * @param {Object} updateData - Dados a serem atualizados
   * @returns {Promise<Object>}
   */
  async update(id, updateData) {
    // Converte chaves para PascalCase para API
    const payload = {};
    if (updateData.titulo !== undefined) payload.Titulo = updateData.titulo;
    if (updateData.descricao !== undefined) payload.Descricao = updateData.descricao;
    if (updateData.statusId !== undefined) payload.StatusId = updateData.statusId;
    if (updateData.categoriaId !== undefined) payload.CategoriaId = updateData.categoriaId;
    if (updateData.prioridadeId !== undefined) payload.PrioridadeId = updateData.prioridadeId;
    if (updateData.tecnicoId !== undefined) payload.TecnicoId = updateData.tecnicoId;

    return await apiService.put(`/api/chamados/${id}`, payload);
  }

  /**
   * Fecha um ticket
   * @param {number} id - ID do ticket
   * @returns {Promise<Object>}
   */
  async close(id) {
    return await apiService.put(`/api/chamados/${id}`, {
      StatusId: 5 // Fechado
    });
  }

  /**
   * Reabre um ticket
   * @param {number} id - ID do ticket
   * @returns {Promise<Object>}
   */
  async reopen(id) {
    return await apiService.put(`/api/chamados/${id}`, {
      StatusId: 1 // Aberto
    });
  }

  /**
   * Assume um ticket (técnico)
   * @param {number} id - ID do ticket
   * @returns {Promise<Object>}
   */
  async assignToMe(id) {
    return await apiService.put(`/api/chamados/${id}/assumir`, {});
  }

  /**
   * Atribui ticket a um técnico específico (admin)
   * @param {number} id - ID do ticket
   * @param {number} tecnicoId - ID do técnico
   * @returns {Promise<Object>}
   */
  async assignTo(id, tecnicoId) {
    return await apiService.put(`/api/chamados/${id}`, {
      TecnicoId: tecnicoId,
      StatusId: 2 // Em andamento
    });
  }

  /**
   * Obtém comentários de um ticket
   * @param {number} chamadoId - ID do ticket
   * @returns {Promise<Array>}
   */
  async getComments(chamadoId) {
    return await apiService.get(`/api/ticketcomments/${chamadoId}/comentarios`);
  }

  /**
   * Adiciona comentário a um ticket
   * @param {number} chamadoId - ID do ticket
   * @param {string} texto - Texto do comentário
   * @param {boolean} isInterno - Se é comentário interno (apenas técnicos/admin)
   * @returns {Promise<Object>}
   */
  async addComment(chamadoId, texto, isInterno = false) {
    return await apiService.post(`/api/ticketcomments/${chamadoId}/comentarios`, {
      Texto: texto,
      IsInterno: isInterno
    });
  }

  /**
   * Deleta um ticket (admin)
   * @param {number} id - ID do ticket
   * @returns {Promise<void>}
   */
  async delete(id) {
    return await apiService.delete(`/api/chamados/${id}`);
  }

  /**
   * Obtém estatísticas de tickets
   * @returns {Promise<Object>}
   */
  async getStats() {
    // Se API não tiver endpoint específico, calcula localmente
    const tickets = await this.getAll();
    
    return {
      total: tickets.length,
      abertos: tickets.filter(t => t.statusId === 1).length,
      emAndamento: tickets.filter(t => t.statusId === 2).length,
      aguardandoCliente: tickets.filter(t => t.statusId === 3).length,
      resolvidos: tickets.filter(t => t.statusId === 4).length,
      fechados: tickets.filter(t => t.statusId === 5).length,
      porPrioridade: this.groupByPriority(tickets),
      porCategoria: this.groupByCategory(tickets)
    };
  }

  /**
   * Agrupa tickets por prioridade
   * @private
   */
  groupByPriority(tickets) {
    return tickets.reduce((acc, ticket) => {
      const prioridade = ticket.prioridade?.nome || 'Sem prioridade';
      acc[prioridade] = (acc[prioridade] || 0) + 1;
      return acc;
    }, {});
  }

  /**
   * Agrupa tickets por categoria
   * @private
   */
  groupByCategory(tickets) {
    return tickets.reduce((acc, ticket) => {
      const categoria = ticket.categoria?.nome || 'Sem categoria';
      acc[categoria] = (acc[categoria] || 0) + 1;
      return acc;
    }, {});
  }
}

// Export singleton instance
export const ticketService = new TicketService();
