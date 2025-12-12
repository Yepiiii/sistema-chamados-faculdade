// Priority Service
// Serviço para gerenciamento de prioridades de tickets

import { apiService } from './ApiService.js';

/**
 * Serviço de gerenciamento de prioridades
 */
export class PriorityService {
  /**
   * Obtém todas as prioridades
   * @returns {Promise<Array>}
   */
  async getAll() {
    return await apiService.get('/api/prioridades');
  }

  /**
   * Obtém prioridade por ID
   * @param {number} id - ID da prioridade
   * @returns {Promise<Object>}
   */
  async getById(id) {
    return await apiService.get(`/api/prioridades/${id}`);
  }

  /**
   * Cria nova prioridade (admin)
   * @param {Object} data - Dados da prioridade
   * @param {string} data.nome - Nome da prioridade
   * @param {number} data.nivel - Nível de urgência (1-4)
   * @param {string} data.cor - Cor da prioridade (hex)
   * @returns {Promise<Object>}
   */
  async create(data) {
    return await apiService.post('/api/prioridades', {
      Nome: data.nome,
      Nivel: data.nivel,
      Cor: data.cor
    });
  }

  /**
   * Atualiza prioridade (admin)
   * @param {number} id - ID da prioridade
   * @param {Object} data - Dados a serem atualizados
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    const payload = {};
    if (data.nome !== undefined) payload.Nome = data.nome;
    if (data.nivel !== undefined) payload.Nivel = data.nivel;
    if (data.cor !== undefined) payload.Cor = data.cor;

    return await apiService.put(`/api/prioridades/${id}`, payload);
  }

  /**
   * Deleta prioridade (admin)
   * @param {number} id - ID da prioridade
   * @returns {Promise<void>}
   */
  async delete(id) {
    return await apiService.delete(`/api/prioridades/${id}`);
  }
}

// Export singleton instance
export const priorityService = new PriorityService();
