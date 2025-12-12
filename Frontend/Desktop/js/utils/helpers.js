// General Helpers
// Funções utilitárias gerais

/**
 * Exibe uma mensagem toast/alert para o usuário
 * @param {string} msg - Mensagem a ser exibida
 * @param {string} type - Tipo de mensagem (success, error, info)
 */
export const toast = (msg, type = 'info') => {
  // TODO: Implementar sistema de toast mais sofisticado
  // Por enquanto, usa alert simples
  alert(msg);
};

/**
 * Debounce - Atrasa a execução de uma função
 * @param {Function} func - Função a ser executada
 * @param {number} delay - Delay em milissegundos (padrão: 300ms)
 * @returns {Function}
 */
export function debounce(func, delay = 300) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func.apply(this, args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, delay);
  };
}

/**
 * Formata data para formato brasileiro
 * @param {string} dateString - String de data ISO
 * @returns {string}
 */
export function formatDate(dateString) {
  if (!dateString) return '';
  
  try {
    const date = new Date(dateString);
    return date.toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (error) {
    console.error('Erro ao formatar data:', error);
    return dateString;
  }
}

/**
 * Formata data apenas (sem hora)
 * @param {string} dateString - String de data ISO
 * @returns {string}
 */
export function formatDateOnly(dateString) {
  if (!dateString) return '';
  
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  } catch (error) {
    console.error('Erro ao formatar data:', error);
    return dateString;
  }
}

/**
 * Escapa caracteres HTML para prevenir XSS
 * @param {string} text - Texto a ser escapado
 * @returns {string}
 */
export function escapeHtml(text) {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, m => map[m]);
}

/**
 * Valida formato de email
 * @param {string} email - Email a ser validado
 * @returns {boolean}
 */
export function isValidEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

/**
 * Trunca texto em um número máximo de caracteres
 * @param {string} text - Texto a ser truncado
 * @param {number} maxLength - Comprimento máximo
 * @returns {string}
 */
export function truncate(text, maxLength = 100) {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
}
