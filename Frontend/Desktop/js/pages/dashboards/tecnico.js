// Técnico Dashboard Page Controller
// Controla a lógica do dashboard do técnico

import { $, $$ } from '../../utils/dom.js';
import { formatDate, debounce } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { authService } from '../../services/AuthService.js';
import { categoryService } from '../../services/CategoryService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { USER_TYPES, STATUS_IDS, ROUTES } from '../../config/constants.js';

/**
 * Controller do dashboard de técnico
 */
export class TecnicoDashboard {
  constructor() {
    this.tickets = [];
    this.filteredTickets = [];
    this.categorias = [];
    this.currentFilter = 'meus';
    this.searchTerm = '';
    this.selectedCategoria = null;
  }

  /**
   * Inicializa o dashboard
   */
  async init() {
    // Verifica autenticação
    if (!authService.requireAuth([USER_TYPES.TECNICO])) {
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
      
      // Carrega tickets e categorias em paralelo
      [this.tickets, this.categorias] = await Promise.all([
        ticketService.getAll(),
        categoryService.getAll()
      ]);

      this.filteredTickets = this.getMyTickets();
      this.renderDashboard();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      this.showError('Erro ao carregar chamados. Tente novamente.');
    }
  }

  /**
   * Obtém tickets atribuídos ao técnico
   */
  getMyTickets() {
    const userData = authService.getUserData();
    // Assumindo que userData.id ou similar identifica o técnico
    return this.tickets.filter(t => t.tecnicoId === userData?.id);
  }

  /**
   * Renderiza mensagem de boas-vindas
   */
  renderWelcome() {
    const welcomeEl = $('#welcome-message');
    if (!welcomeEl) return;

    const userData = authService.getUserData();
    const nome = userData?.nomeCompleto || 'Técnico';
    const primeiroNome = nome.split(' ')[0];

    welcomeEl.innerHTML = `
      <h1>Olá, ${primeiroNome}! 🔧</h1>
      <p>Gerencie seus chamados e atenda os clientes.</p>
    `;
  }

  /**
   * Renderiza dashboard completo
   */
  renderDashboard() {
    this.renderStats();
    this.renderCategoriaFilter();
    this.renderTickets();
    this.hideLoading();
  }

  /**
   * Renderiza estatísticas
   */
  renderStats() {
    const meus = this.getMyTickets().length;
    const abertos = this.tickets.filter(t => 
      t.statusId === STATUS_IDS.ABERTO && !t.tecnicoId
    ).length;
    const emAndamento = this.getMyTickets().filter(t => 
      t.statusId === STATUS_IDS.EM_ANDAMENTO
    ).length;
    const aguardando = this.getMyTickets().filter(t => 
      t.statusId === STATUS_IDS.AGUARDANDO_CLIENTE
    ).length;

    const stats = [
      { id: 'meus', value: meus, label: 'Meus Chamados', icon: 'user', color: 'primary' },
      { id: 'disponiveis', value: abertos, label: 'Disponíveis', icon: 'folder-open', color: 'info' },
      { id: 'em-andamento', value: emAndamento, label: 'Em Andamento', icon: 'cog', color: 'warning' },
      { id: 'aguardando', value: aguardando, label: 'Aguardando', icon: 'clock', color: 'secondary' }
    ];

    stats.forEach(stat => {
      const el = $(`#stat-${stat.id}`);
      if (el) {
        el.textContent = stat.value;
      }
    });
  }

  /**
   * Renderiza filtro de categorias
   */
  renderCategoriaFilter() {
    const container = $('#categoria-filter');
    if (!container) return;

    container.innerHTML = `
      <option value="">Todas as Categorias</option>
      ${this.categorias.map(cat => `
        <option value="${cat.id}">${cat.nome}</option>
      `).join('')}
    `;
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
          <p>${this.getEmptyMessage()}</p>
        </div>
      `;
      return;
    }

    container.innerHTML = this.filteredTickets.map(ticket => `
      <div class="ticket-card ${this.isMyTicket(ticket) ? 'my-ticket' : ''}" 
           data-id="${ticket.id}" 
           onclick="window.location.href='${ROUTES.TICKET_DETALHES}?id=${ticket.id}'">
        <div class="ticket-header">
          <h3 class="ticket-title">${this.escapeHtml(ticket.titulo)}</h3>
          <div class="ticket-badges">
            <span class="badge badge-${this.getStatusClass(ticket.statusId)}">
              ${ticket.status?.nome || 'Sem status'}
            </span>
            <span class="badge badge-${this.getPriorityClass(ticket.prioridadeId)}">
              ${ticket.prioridade?.nome || 'Sem prioridade'}
            </span>
          </div>
        </div>
        <div class="ticket-body">
          <p class="ticket-description">${this.truncate(ticket.descricao, 120)}</p>
          <div class="ticket-meta">
            <span class="meta-item">
              <i class="fas fa-tag"></i>
              ${ticket.categoria?.nome || 'Sem categoria'}
            </span>
            <span class="meta-item">
              <i class="fas fa-user"></i>
              ${ticket.solicitante?.nomeCompleto || 'Desconhecido'}
            </span>
            <span class="meta-item">
              <i class="fas fa-calendar"></i>
              ${formatDate(ticket.dataAbertura)}
            </span>
          </div>
        </div>
        ${!this.isMyTicket(ticket) && ticket.statusId === STATUS_IDS.ABERTO ? `
          <div class="ticket-actions">
            <button class="btn btn-sm btn-primary" onclick="event.stopPropagation(); assumirChamado(${ticket.id})">
              <i class="fas fa-hand-paper"></i> Assumir
            </button>
          </div>
        ` : ''}
      </div>
    `).join('');
  }

  /**
   * Verifica se é ticket do técnico
   */
  isMyTicket(ticket) {
    const userData = authService.getUserData();
    return ticket.tecnicoId === userData?.id;
  }

  /**
   * Mensagem para lista vazia
   */
  getEmptyMessage() {
    switch (this.currentFilter) {
      case 'meus':
        return 'Você ainda não possui chamados atribuídos.';
      case 'disponiveis':
        return 'Não há chamados disponíveis no momento.';
      case 'todos':
        return this.searchTerm 
          ? 'Nenhum chamado encontrado com esses critérios.' 
          : 'Não há chamados no sistema.';
      default:
        return 'Nenhum chamado encontrado.';
    }
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Logout
    const logoutBtn = $('#logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', (e) => {
        e.preventDefault();
        authService.logout();
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

    // Filtros
    $$('[data-filter]').forEach(filterBtn => {
      filterBtn.addEventListener('click', () => {
        const filter = filterBtn.dataset.filter;
        this.currentFilter = filter;
        
        $$('[data-filter]').forEach(btn => btn.classList.remove('active'));
        filterBtn.classList.add('active');
        
        this.applyFilters();
      });
    });

    // Filtro de categoria
    const categoriaFilter = $('#categoria-filter');
    if (categoriaFilter) {
      categoriaFilter.addEventListener('change', (e) => {
        this.selectedCategoria = e.target.value ? parseInt(e.target.value) : null;
        this.applyFilters();
      });
    }

    // Atualizar
    const refreshBtn = $('#refresh-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', async () => {
        await this.loadData();
      });
    }

    // Função global para assumir chamado
    window.assumirChamado = async (ticketId) => {
      if (confirm('Deseja assumir este chamado?')) {
        try {
          await ticketService.assignToMe(ticketId);
          await this.loadData();
        } catch (error) {
          alert('Erro ao assumir chamado: ' + error.message);
        }
      }
    };
  }

  /**
   * Aplica filtros
   */
  applyFilters() {
    let filtered = [...this.tickets];

    // Filtro de tipo
    switch (this.currentFilter) {
      case 'meus':
        filtered = this.getMyTickets();
        break;
      case 'disponiveis':
        filtered = filtered.filter(t => 
          t.statusId === STATUS_IDS.ABERTO && !t.tecnicoId
        );
        break;
      // 'todos' não filtra
    }

    // Filtro de categoria
    if (this.selectedCategoria) {
      filtered = filtered.filter(t => t.categoriaId === this.selectedCategoria);
    }

    // Busca textual
    if (this.searchTerm) {
      const searchLower = this.searchTerm;
      filtered = filtered.filter(t =>
        t.titulo?.toLowerCase().includes(searchLower) ||
        t.descricao?.toLowerCase().includes(searchLower) ||
        t.solicitante?.nomeCompleto?.toLowerCase().includes(searchLower)
      );
    }

    this.filteredTickets = filtered;
    this.renderTickets();
  }

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

  getPriorityClass(prioridadeId) {
    switch (prioridadeId) {
      case 1: return 'low';
      case 2: return 'medium';
      case 3: return 'high';
      case 4: return 'urgent';
      default: return 'medium';
    }
  }

  truncate(text, maxLength) {
    if (!text || text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  }

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

  hideLoading() {}

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
if (window.location.pathname.includes('tecnico-dashboard')) {
  const dashboard = new TecnicoDashboard();
  dashboard.init();
}

export default TecnicoDashboard;
