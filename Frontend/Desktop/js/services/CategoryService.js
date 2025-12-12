// Category Service
// Serviço para gerenciamento de categorias

import { apiService } from './ApiService.js';

/**
 * Serviço de gerenciamento de categorias
 */
export class CategoryService {
  /**
   * Obtém todas as categorias
   * @returns {Promise<Array>}
   */
  async getAll() {
    return await apiService.get('/api/categorias');
  }

  /**
   * Obtém categoria por ID
   * @param {number} id - ID da categoria
   * @returns {Promise<Object>}
   */
  async getById(id) {
    return await apiService.get(`/api/categorias/${id}`);
  }

  /**
   * Cria nova categoria (admin)
   * @param {Object} data - Dados da categoria
   * @param {string} data.nome - Nome da categoria
   * @param {string} data.descricao - Descrição da categoria
   * @returns {Promise<Object>}
   */
  async create(data) {
    return await apiService.post('/api/categorias', {
      Nome: data.nome,
      Descricao: data.descricao
    });
  }

  /**
   * Atualiza categoria (admin)
   * @param {number} id - ID da categoria
   * @param {Object} data - Dados a serem atualizados
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    const payload = {};
    if (data.nome !== undefined) payload.Nome = data.nome;
    if (data.descricao !== undefined) payload.Descricao = data.descricao;

    return await apiService.put(`/api/categorias/${id}`, payload);
  }

  /**
   * Deleta categoria (admin)
   * @param {number} id - ID da categoria
   * @returns {Promise<void>}
   */
  async delete(id) {
    return await apiService.delete(`/api/categorias/${id}`);
  }
}

// Export singleton instance
export const categoryService = new CategoryService();
