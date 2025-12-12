// Admin Dashboard Page Controller
// Controla a lógica do dashboard do administrador

import { $, $$ } from '../../utils/dom.js';
import { formatDate, debounce } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { userService } from '../../services/UserService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { USER_TYPES, STATUS_IDS, ROUTES } from '../../config/constants.js';

/**
 * Controller do dashboard de administrador
 */
export class AdminDashboard {
  constructor() {
    this.tickets = [];
    this.users = [];
    this.filteredTickets = [];
    this.currentFilter = 'todos';
    this.searchTerm = '';
  }

  /**
   * Inicializa o dashboard
   */
  async init() {
    // Verifica autenticação
    if (!authService.requireAuth([USER_TYPES.ADMIN])) {
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
      
      // Carrega tickets e usuários em paralelo
      [this.tickets, this.users] = await Promise.all([
        ticketService.getAll(),
        userService.getAll()
      ]);

      this.filteredTickets = [...this.tickets];
      this.renderDashboard();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      this.showError('Erro ao carregar dados. Tente novamente.');
    }
  }

  /**
   * Renderiza mensagem de boas-vindas
   */
  renderWelcome() {
    const welcomeEl = $('#welcome-message');
    if (!welcomeEl) return;

    const userData = authService.getUserData();
    const nome = userData?.nomeCompleto || 'Administrador';
    const primeiroNome = nome.split(' ')[0];

    welcomeEl.innerHTML = `
      <h1>Olá, ${primeiroNome}! 👨‍💼</h1>
      <p>Painel completo de administração do sistema.</p>
    `;
  }

  /**
   * Renderiza dashboard completo
   */
  renderDashboard() {
    this.renderStats();
    this.renderUserStats();
    this.renderTickets();
    this.hideLoading();
  }

  /**
   * Renderiza estatísticas de chamados
   */
  renderStats() {
    const total = this.tickets.length;
    const abertos = this.tickets.filter(t => t.statusId === STATUS_IDS.ABERTO).length;
    const emAndamento = this.tickets.filter(t => t.statusId === STATUS_IDS.EM_ANDAMENTO).length;
    const resolvidos = this.tickets.filter(t => t.statusId === STATUS_IDS.RESOLVIDO).length;

    const stats = [
      { id: 'total', value: total, label: 'Total de Chamados', icon: 'ticket-alt', color: 'primary' },
      { id: 'abertos', value: abertos, label: 'Abertos', icon: 'folder-open', color: 'info' },
      { id: 'em-andamento', value: emAndamento, label: 'Em Andamento', icon: 'cog', color: 'warning' },
      { id: 'resolvidos', value: resolvidos, label: 'Resolvidos', icon: 'check-circle', color: 'success' }
    ];

    stats.forEach(stat => {
      const el = $(`#stat-${stat.id}`);
      if (el) {
        el.textContent = stat.value;
      }
    });
  }

  /**
   * Renderiza estatísticas de usuários
   */
  renderUserStats() {
    const totalUsers = this.users.length;
    const tecnicos = this.users.filter(u => u.tipoUsuarioId === USER_TYPES.TECNICO).length;
    const usuarios = this.users.filter(u => u.tipoUsuarioId === USER_TYPES.USER).length;
    const ativos = this.users.filter(u => u.ativo).length;

    const stats = [
      { id: 'users-total', value: totalUsers, label: 'Total de Usuários', icon: 'users', color: 'primary' },
      { id: 'tecnicos', value: tecnicos, label: 'Técnicos', icon: 'user-cog', color: 'info' },
      { id: 'usuarios', value: usuarios, label: 'Usuários', icon: 'user', color: 'warning' },
      { id: 'ativos', value: ativos, label: 'Ativos', icon: 'user-check', color: 'success' }
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
          <p>${this.getEmptyMessage()}</p>
        </div>
      `;
      return;
    }

    container.innerHTML = this.filteredTickets.map(ticket => `
      <div class="ticket-card admin-view" 
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
              Solicitante: ${ticket.solicitante?.nomeCompleto || 'Desconhecido'}
            </span>
            ${ticket.tecnico ? `
              <span class="meta-item">
                <i class="fas fa-user-cog"></i>
                Técnico: ${ticket.tecnico.nomeCompleto}
              </span>
            ` : `
              <span class="meta-item">
                <i class="fas fa-user-slash"></i>
                Sem técnico atribuído
              </span>
            `}
            <span class="meta-item">
              <i class="fas fa-calendar"></i>
              ${formatDate(ticket.dataAbertura)}
            </span>
          </div>
        </div>
        <div class="ticket-actions admin-actions">
          ${!ticket.tecnicoId && ticket.statusId === STATUS_IDS.ABERTO ? `
            <button class="btn btn-sm btn-primary" onclick="event.stopPropagation(); atribuirTecnico(${ticket.id})">
              <i class="fas fa-user-plus"></i> Atribuir
            </button>
          ` : ''}
          ${ticket.statusId !== STATUS_IDS.FECHADO ? `
            <button class="btn btn-sm btn-warning" onclick="event.stopPropagation(); alterarStatus(${ticket.id})">
              <i class="fas fa-exchange-alt"></i> Status
            </button>
          ` : ''}
          <button class="btn btn-sm btn-danger" onclick="event.stopPropagation(); excluirChamado(${ticket.id})">
            <i class="fas fa-trash"></i> Excluir
          </button>
        </div>
      </div>
    `).join('');
  }

  /**
   * Mensagem para lista vazia
   */
  getEmptyMessage() {
    if (this.searchTerm) {
      return 'Nenhum chamado encontrado com esses critérios.';
    }
    switch (this.currentFilter) {
      case 'abertos':
        return 'Não há chamados abertos no momento.';
      case 'em-andamento':
        return 'Não há chamados em andamento no momento.';
      case 'resolvidos':
        return 'Não há chamados resolvidos no momento.';
      default:
        return 'Não há chamados no sistema.';
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

    // Atualizar
    const refreshBtn = $('#refresh-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', async () => {
        await this.loadData();
      });
    }

    // Navegação para usuários
    const usersBtn = $('#users-btn');
    if (usersBtn) {
      usersBtn.addEventListener('click', () => {
        window.location.href = ROUTES.USUARIOS;
      });
    }

    // Funções globais para ações admin
    window.atribuirTecnico = async (ticketId) => {
      const tecnicoId = prompt('Digite o ID do técnico:');
      if (tecnicoId) {
        try {
          await ticketService.assignTo(ticketId, parseInt(tecnicoId));
          await this.loadData();
        } catch (error) {
          alert('Erro ao atribuir técnico: ' + error.message);
        }
      }
    };

    window.alterarStatus = async (ticketId) => {
      const statusId = prompt('Digite o ID do novo status:\n1-Aberto\n2-Em Andamento\n3-Aguardando\n4-Resolvido\n5-Fechado');
      if (statusId) {
        try {
          await ticketService.update(ticketId, { statusId: parseInt(statusId) });
          await this.loadData();
        } catch (error) {
          alert('Erro ao alterar status: ' + error.message);
        }
      }
    };

    window.excluirChamado = async (ticketId) => {
      if (confirm('Tem certeza que deseja excluir este chamado? Esta ação não pode ser desfeita.')) {
        try {
          await ticketService.delete(ticketId);
          await this.loadData();
        } catch (error) {
          alert('Erro ao excluir chamado: ' + error.message);
        }
      }
    };
  }

  /**
   * Aplica filtros
   */
  applyFilters() {
    let filtered = [...this.tickets];

    // Filtro de status
    switch (this.currentFilter) {
      case 'abertos':
        filtered = filtered.filter(t => t.statusId === STATUS_IDS.ABERTO);
        break;
      case 'em-andamento':
        filtered = filtered.filter(t => t.statusId === STATUS_IDS.EM_ANDAMENTO);
        break;
      case 'resolvidos':
        filtered = filtered.filter(t => t.statusId === STATUS_IDS.RESOLVIDO);
        break;
      // 'todos' não filtra
    }

    // Busca textual
    if (this.searchTerm) {
      const searchLower = this.searchTerm;
      filtered = filtered.filter(t =>
        t.titulo?.toLowerCase().includes(searchLower) ||
        t.descricao?.toLowerCase().includes(searchLower) ||
        t.categoria?.nome?.toLowerCase().includes(searchLower) ||
        t.solicitante?.nomeCompleto?.toLowerCase().includes(searchLower) ||
        t.tecnico?.nomeCompleto?.toLowerCase().includes(searchLower) ||
        t.status?.nome?.toLowerCase().includes(searchLower)
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
        <p>Carregando dados...</p>
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
if (window.location.pathname.includes('admin-dashboard')) {
  const dashboard = new AdminDashboard();
  dashboard.init();
}

export default AdminDashboard;
