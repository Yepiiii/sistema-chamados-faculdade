// Constants and Configuration
// Valores constantes e configurações globais do sistema

/**
 * URL base da API
 * Pode ser sobrescrito por window.API_BASE
 */
export const API_BASE = window.API_BASE || 'http://localhost:5027';

/**
 * Rotas da aplicação
 */
export const ROUTES = {
  LOGIN: '/index.html',
  CADASTRO: '/cadastro-desktop.html',
  ESQUECI_SENHA: '/esqueci-senha-desktop.html',
  RESETAR_SENHA: '/resetar-senha-desktop.html',
  ADMIN_DASHBOARD: '/admin-dashboard-desktop.html',
  TECNICO_DASHBOARD: '/tecnico-dashboard.html',
  USER_DASHBOARD: '/user-dashboard-desktop.html',
  NOVO_CHAMADO: '/novo-chamado-desktop.html',
  TICKET_DETALHES: '/ticket-detalhes-desktop.html',
  ADMIN_CONFIG: '/admin-config-desktop.html',
  TECNICO_CONFIG: '/tecnico-config-desktop.html',
  USER_CONFIG: '/user-config-desktop.html'
};

/**
 * Tipos de usuário
 */
export const USER_TYPES = {
  USER: 1,
  TECNICO: 2,
  ADMIN: 3
};

/**
 * IDs dos Status
 */
export const STATUS_IDS = {
  ABERTO: 1,
  EM_ANDAMENTO: 2,
  AGUARDANDO_CLIENTE: 3,
  RESOLVIDO: 4,
  FECHADO: 5
};

/**
 * IDs das Prioridades
 */
export const PRIORITY_IDS = {
  BAIXA: 1,
  MEDIA: 2,
  ALTA: 3,
  URGENTE: 4
};

/**
 * Classes CSS para badges de status
 */
export const STATUS_BADGE_CLASSES = {
  [STATUS_IDS.ABERTO]: 'badge-aberto',
  [STATUS_IDS.EM_ANDAMENTO]: 'badge-em-andamento',
  [STATUS_IDS.AGUARDANDO_CLIENTE]: 'badge-aguardando',
  [STATUS_IDS.RESOLVIDO]: 'badge-resolvido',
  [STATUS_IDS.FECHADO]: 'badge-fechado'
};

/**
 * Classes CSS para badges de prioridade
 */
export const PRIORITY_BADGE_CLASSES = {
  [PRIORITY_IDS.BAIXA]: 'badge-baixa',
  [PRIORITY_IDS.MEDIA]: 'badge-media',
  [PRIORITY_IDS.ALTA]: 'badge-alta',
  [PRIORITY_IDS.URGENTE]: 'badge-urgente'
};

/**
 * Mensagens de erro padrão
 */
export const ERROR_MESSAGES = {
  NETWORK: 'Erro de conexão. Verifique sua internet e tente novamente.',
  UNAUTHORIZED: 'Sessão expirada. Faça login novamente.',
  FORBIDDEN: 'Você não tem permissão para realizar esta ação.',
  NOT_FOUND: 'Recurso não encontrado.',
  SERVER_ERROR: 'Erro no servidor. Tente novamente mais tarde.',
  VALIDATION: 'Dados inválidos. Verifique os campos e tente novamente.'
};

/**
 * Timeouts (em milissegundos)
 */
export const TIMEOUTS = {
  TOAST: 3000,
  DEBOUNCE_SEARCH: 300,
  AUTO_REFRESH: 30000 // 30 segundos
};

/**
 * Chaves de LocalStorage
 */
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'authToken',
  USER_DATA: 'userData',
  THEME: 'theme-preference',
  LAST_FILTER: 'lastFilter'
};
