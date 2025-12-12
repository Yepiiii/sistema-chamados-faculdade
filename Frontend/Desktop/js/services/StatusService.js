// Status Service
// Serviço para gerenciamento de status de tickets

import { apiService } from './ApiService.js';

/**
 * Serviço de gerenciamento de status
 */
export class StatusService {
  /**
   * Obtém todos os status
   * @returns {Promise<Array>}
   */
  async getAll() {
    return await apiService.get('/api/status');
  }

  /**
   * Obtém status por ID
   * @param {number} id - ID do status
   * @returns {Promise<Object>}
   */
  async getById(id) {
    return await apiService.get(`/api/status/${id}`);
  }

  /**
   * Cria novo status (admin)
   * @param {Object} data - Dados do status
   * @param {string} data.nome - Nome do status
   * @param {string} data.cor - Cor do status (hex)
   * @returns {Promise<Object>}
   */
  async create(data) {
    return await apiService.post('/api/status', {
      Nome: data.nome,
      Cor: data.cor
    });
  }

  /**
   * Atualiza status (admin)
   * @param {number} id - ID do status
   * @param {Object} data - Dados a serem atualizados
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    const payload = {};
    if (data.nome !== undefined) payload.Nome = data.nome;
    if (data.cor !== undefined) payload.Cor = data.cor;

    return await apiService.put(`/api/status/${id}`, payload);
  }

  /**
   * Deleta status (admin)
   * @param {number} id - ID do status
   * @returns {Promise<void>}
   */
  async delete(id) {
    return await apiService.delete(`/api/status/${id}`);
  }
}

// Export singleton instance
export const statusService = new StatusService();
