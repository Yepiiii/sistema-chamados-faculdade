// API Service
// Cliente HTTP centralizado para todas as chamadas à API

import { API_BASE, ERROR_MESSAGES, STORAGE_KEYS, ROUTES } from '../config/constants.js';

/**
 * Serviço centralizado para comunicação com a API
 */
export class ApiService {
  constructor() {
    this.baseUrl = API_BASE;
  }

  /**
   * Obtém o token de autenticação
   * @returns {string|null}
   */
  getToken() {
    return sessionStorage.getItem(STORAGE_KEYS.AUTH_TOKEN) || 
           localStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);
  }

  /**
   * Define o token de autenticação
   * @param {string} token - Token JWT
   */
  setToken(token) {
    sessionStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, token);
    localStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, token);
  }

  /**
   * Remove o token de autenticação
   */
  clearToken() {
    sessionStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.USER_DATA);
  }

  /**
   * Constrói headers para requisições
   * @param {boolean} includeAuth - Se deve incluir Authorization header
   * @returns {Object}
   */
  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    if (includeAuth) {
      const token = this.getToken();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    return headers;
  }

  /**
   * Trata erros HTTP
   * @param {Response} response - Resposta do fetch
   * @returns {Promise<never>}
   */
  async handleError(response) {
    let errorMessage = ERROR_MESSAGES.SERVER_ERROR;

    // Handle 401 Unauthorized - redireciona para login
    if (response.status === 401) {
      this.clearToken();
      window.location.href = ROUTES.LOGIN;
      throw new Error(ERROR_MESSAGES.UNAUTHORIZED);
    }

    // Handle 403 Forbidden
    if (response.status === 403) {
      errorMessage = ERROR_MESSAGES.FORBIDDEN;
    }

    // Handle 404 Not Found
    if (response.status === 404) {
      errorMessage = ERROR_MESSAGES.NOT_FOUND;
    }

    // Handle 400 Bad Request (validação)
    if (response.status === 400) {
      errorMessage = ERROR_MESSAGES.VALIDATION;
    }

    // Tenta extrair mensagem de erro do corpo da resposta
    try {
      const errorData = await response.json();
      if (errorData.message) {
        errorMessage = errorData.message;
      } else if (errorData.errors) {
        // Se houver múltiplos erros de validação
        errorMessage = Object.values(errorData.errors).flat().join(', ');
      }
    } catch {
      // Se não conseguir parsear JSON, usa mensagem padrão
    }

    throw new Error(errorMessage);
  }

  /**
   * Realiza uma requisição HTTP
   * @param {string} endpoint - Endpoint da API
   * @param {Object} options - Opções da requisição
   * @returns {Promise<*>}
   */
  async request(endpoint, options = {}) {
    const { 
      method = 'GET', 
      body = null, 
      includeAuth = true,
      customHeaders = {}
    } = options;

    const config = {
      method,
      headers: {
        ...this.getHeaders(includeAuth),
        ...customHeaders
      }
    };

    if (body) {
      config.body = JSON.stringify(body);
    }

    try {
      const url = endpoint.startsWith('http') ? endpoint : `${this.baseUrl}${endpoint}`;
      const response = await fetch(url, config);

      if (!response.ok) {
        await this.handleError(response);
      }

      // Se resposta não tiver conteúdo (204 No Content), retorna null
      if (response.status === 204) {
        return null;
      }

      return await response.json();
    } catch (error) {
      // Se for erro de rede (offline, timeout, etc)
      if (error instanceof TypeError) {
        throw new Error(ERROR_MESSAGES.NETWORK);
      }
      throw error;
    }
  }

  /**
   * GET request
   * @param {string} endpoint - Endpoint da API
   * @param {boolean} includeAuth - Se deve incluir autenticação
   * @returns {Promise<*>}
   */
  async get(endpoint, includeAuth = true) {
    return this.request(endpoint, { method: 'GET', includeAuth });
  }

  /**
   * POST request
   * @param {string} endpoint - Endpoint da API
   * @param {Object} body - Corpo da requisição
   * @param {boolean} includeAuth - Se deve incluir autenticação
   * @returns {Promise<*>}
   */
  async post(endpoint, body, includeAuth = true) {
    return this.request(endpoint, { method: 'POST', body, includeAuth });
  }

  /**
   * PUT request
   * @param {string} endpoint - Endpoint da API
   * @param {Object} body - Corpo da requisição
   * @param {boolean} includeAuth - Se deve incluir autenticação
   * @returns {Promise<*>}
   */
  async put(endpoint, body, includeAuth = true) {
    return this.request(endpoint, { method: 'PUT', body, includeAuth });
  }

  /**
   * PATCH request
   * @param {string} endpoint - Endpoint da API
   * @param {Object} body - Corpo da requisição
   * @param {boolean} includeAuth - Se deve incluir autenticação
   * @returns {Promise<*>}
   */
  async patch(endpoint, body, includeAuth = true) {
    return this.request(endpoint, { method: 'PATCH', body, includeAuth });
  }

  /**
   * DELETE request
   * @param {string} endpoint - Endpoint da API
   * @param {boolean} includeAuth - Se deve incluir autenticação
   * @returns {Promise<*>}
   */
  async delete(endpoint, includeAuth = true) {
    return this.request(endpoint, { method: 'DELETE', includeAuth });
  }
}

// Export singleton instance
export const apiService = new ApiService();
