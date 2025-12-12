// LocalStorage Utilities
// Wrapper para manipulação segura de LocalStorage

/**
 * Salva dados no LocalStorage
 * @param {string} key - Chave de armazenamento
 * @param {*} value - Valor a ser armazenado (será convertido para JSON)
 */
export const save = (key, value) => {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (error) {
    console.error('Erro ao salvar no localStorage:', error);
  }
};

/**
 * Carrega dados do LocalStorage
 * @param {string} key - Chave de armazenamento
 * @param {*} fallback - Valor padrão caso não exista ou ocorra erro
 * @returns {*}
 */
export const load = (key, fallback = []) => {
  try {
    const data = localStorage.getItem(key);
    return data ? JSON.parse(data) : fallback;
  } catch (error) {
    console.error('Erro ao carregar do localStorage:', error);
    return fallback;
  }
};

/**
 * Remove dados do LocalStorage
 * @param {string} key - Chave de armazenamento
 */
export const remove = (key) => {
  try {
    localStorage.removeItem(key);
  } catch (error) {
    console.error('Erro ao remover do localStorage:', error);
  }
};

/**
 * Limpa todo o LocalStorage
 */
export const clear = () => {
  try {
    localStorage.clear();
  } catch (error) {
    console.error('Erro ao limpar localStorage:', error);
  }
};
