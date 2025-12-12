// User Dashboard Page Controller
// Controla a lógica do dashboard do usuário comum

import { $, $$ } from '../../utils/dom.js';
import { formatDate, debounce } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { USER_TYPES, STATUS_IDS, ROUTES } from '../../config/constants.js';

/**
 * Controller do dashboard de usuário
 */
export class UserDashboard {
  constructor() {
    this.tickets = [];
    this.filteredTickets = [];
    this.currentFilter = 'all';
    this.searchTerm = '';
  }

  /**
   * Inicializa o dashboard
   */
  async init() {
    // Verifica autenticação
    if (!authService.requireAuth([USER_TYPES.USER])) {
      return;
    }

    // Inicializa tema
    themeManager.init();
    themeManager.registerToggleButton('[data-theme-toggle]');

    await this.loadData();
    this.setupEventListeners();
    this.renderWelcome();
  }

  /**
   * Carrega dados do dashboard
   */
  async loadData() {
    try {
      this.showLoading();
      this.tickets = await ticketService.getAll();
      this.filteredTickets = [...this.tickets];
      this.renderDashboard();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      this.showError('Erro ao carregar chamados. Tente novamente.');
    }
  }

  /**
   * Renderiza mensagem de boas-vindas
   */
  renderWelcome() {
    const welcomeEl = $('#welcome-message');
    if (!welcomeEl) return;

    const userData = authService.getUserData();
    const nome = userData?.nomeCompleto || 'Usuário';
    const primeiroNome = nome.split(' ')[0];

    welcomeEl.innerHTML = `
      <h1>Olá, ${primeiroNome}! 👋</h1>
      <p>Bem-vindo ao seu painel de chamados.</p>
    `;
  }

  /**
   * Renderiza dashboard completo
   */
  renderDashboard() {
    this.renderStats();
    this.renderTickets();
    this.hideLoading();
  }

  /**
   * Renderiza estatísticas
   */
  renderStats() {
    const abertos = this.tickets.filter(t => t.statusId === STATUS_IDS.ABERTO).length;
    const emAndamento = this.tickets.filter(t => t.statusId === STATUS_IDS.EM_ANDAMENTO).length;
    const aguardando = this.tickets.filter(t => t.statusId === STATUS_IDS.AGUARDANDO_CLIENTE).length;
    const resolvidos = this.tickets.filter(t => t.statusId === STATUS_IDS.RESOLVIDO).length;

    const stats = [
      { id: 'abertos', value: abertos, label: 'Abertos', icon: 'folder-open', color: 'primary' },
      { id: 'em-andamento', value: emAndamento, label: 'Em Andamento', icon: 'cog', color: 'warning' },
      { id: 'aguardando', value: aguardando, label: 'Aguardando', icon: 'clock', color: 'info' },
      { id: 'resolvidos', value: resolvidos, label: 'Resolvidos', icon: 'check', color: 'success' }
    ];

    stats.forEach(stat => {
      const el = $(`#stat-${stat.id}`);
      if (el) {
        el.textContent = stat.value;
      }
    });
  }

  /**
   * Renderiza lista de tickets
   */
  renderTickets() {
    const container = $('#tickets-list');
    if (!container) return;

    if (this.filteredTickets.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-inbox"></i>
          <h3>Nenhum chamado encontrado</h3>
          <p>
            ${this.searchTerm 
              ? 'Tente ajustar sua busca ou filtros.' 
              : 'Você ainda não possui chamados. Crie seu primeiro chamado!'}
          </p>
          <a href="${ROUTES.NOVO_CHAMADO}" class="btn btn-primary">
            <i class="fas fa-plus"></i> Novo Chamado
          </a>
        </div>
      `;
      return;
    }

    container.innerHTML = this.filteredTickets.map(ticket => `
      <div class="ticket-card" data-id="${ticket.id}" onclick="window.location.href='${ROUTES.TICKET_DETALHES}?id=${ticket.id}'">
        <div class="ticket-header">
          <h3 class="ticket-title">${this.escapeHtml(ticket.titulo)}</h3>
          <span class="badge badge-${this.getStatusClass(ticket.statusId)}">
            ${ticket.status?.nome || 'Sem status'}
          </span>
        </div>
        <div class="ticket-body">
          <p class="ticket-description">${this.truncate(ticket.descricao, 150)}</p>
          <div class="ticket-meta">
            <span class="meta-item">
              <i class="fas fa-tag"></i>
              ${ticket.categoria?.nome || 'Sem categoria'}
            </span>
            <span class="meta-item">
              <i class="fas fa-exclamation-circle"></i>
              ${ticket.prioridade?.nome || 'Sem prioridade'}
            </span>
            ${ticket.tecnico ? `
              <span class="meta-item">
                <i class="fas fa-user"></i>
                ${ticket.tecnico.nomeCompleto}
              </span>
            ` : ''}
            <span class="meta-item">
              <i class="fas fa-calendar"></i>
              ${formatDate(ticket.dataAbertura)}
            </span>
          </div>
        </div>
      </div>
    `).join('');
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Botão de logout
    const logoutBtn = $('#logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', (e) => {
        e.preventDefault();
        authService.logout();
      });
    }

    // Botão de novo chamado
    const novoChamadoBtn = $('#novo-chamado-btn');
    if (novoChamadoBtn) {
      novoChamadoBtn.addEventListener('click', () => {
        window.location.href = ROUTES.NOVO_CHAMADO;
      });
    }

    // Busca
    const searchInput = $('#search-input');
    if (searchInput) {
      searchInput.addEventListener('input', debounce((e) => {
        this.searchTerm = e.target.value.trim().toLowerCase();
        this.applyFilters();
      }, 300));
    }

    // Filtros de status
    $$('[data-filter]').forEach(filterBtn => {
      filterBtn.addEventListener('click', () => {
        const filter = filterBtn.dataset.filter;
        this.currentFilter = filter;
        
        // Atualiza estado ativo dos botões
        $$('[data-filter]').forEach(btn => btn.classList.remove('active'));
        filterBtn.classList.add('active');
        
        this.applyFilters();
      });
    });

    // Botão de atualizar
    const refreshBtn = $('#refresh-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', async () => {
        await this.loadData();
      });
    }
  }

  /**
   * Aplica filtros e busca
   */
  applyFilters() {
    this.filteredTickets = this.tickets.filter(ticket => {
      // Filtro de status
      let matchesFilter = true;
      if (this.currentFilter !== 'all') {
        switch (this.currentFilter) {
          case 'abertos':
            matchesFilter = ticket.statusId === STATUS_IDS.ABERTO;
            break;
          case 'em-andamento':
            matchesFilter = ticket.statusId === STATUS_IDS.EM_ANDAMENTO;
            break;
          case 'aguardando':
            matchesFilter = ticket.statusId === STATUS_IDS.AGUARDANDO_CLIENTE;
            break;
          case 'resolvidos':
            matchesFilter = ticket.statusId === STATUS_IDS.RESOLVIDO;
            break;
        }
      }

      // Busca textual
      let matchesSearch = true;
      if (this.searchTerm) {
        const searchLower = this.searchTerm.toLowerCase();
        matchesSearch = 
          ticket.titulo?.toLowerCase().includes(searchLower) ||
          ticket.descricao?.toLowerCase().includes(searchLower) ||
          ticket.categoria?.nome?.toLowerCase().includes(searchLower) ||
          ticket.status?.nome?.toLowerCase().includes(searchLower);
      }

      return matchesFilter && matchesSearch;
    });

    this.renderTickets();
  }

  /**
   * Obtém classe CSS para status
   */
  getStatusClass(statusId) {
    switch (statusId) {
      case STATUS_IDS.ABERTO: return 'primary';
      case STATUS_IDS.EM_ANDAMENTO: return 'warning';
      case STATUS_IDS.AGUARDANDO_CLIENTE: return 'info';
      case STATUS_IDS.RESOLVIDO: return 'success';
      case STATUS_IDS.FECHADO: return 'secondary';
      default: return 'secondary';
    }
  }

  /**
   * Trunca texto
   */
  truncate(text, maxLength) {
    if (!text || text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  }

  /**
   * Escapa HTML
   */
  escapeHtml(text) {
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
   * Exibe loading
   */
  showLoading() {
    const container = $('#tickets-list');
    if (!container) return;

    container.innerHTML = `
      <div class="loading-state">
        <i class="fas fa-spinner fa-spin"></i>
        <p>Carregando chamados...</p>
      </div>
    `;
  }

  /**
   * Esconde loading
   */
  hideLoading() {
    // Loading é substituído pelo conteúdo no render
  }

  /**
   * Exibe erro
   */
  showError(message) {
    const container = $('#tickets-list');
    if (!container) return;

    container.innerHTML = `
      <div class="error-state">
        <i class="fas fa-exclamation-triangle"></i>
        <h3>Erro</h3>
        <p>${message}</p>
        <button class="btn btn-primary" onclick="location.reload()">
          <i class="fas fa-redo"></i> Tentar Novamente
        </button>
      </div>
    `;
  }
}

// Auto-inicialização
if (window.location.pathname.includes('user-dashboard-desktop.html')) {
  const dashboard = new UserDashboard();
  dashboard.init();
}

export default UserDashboard;
