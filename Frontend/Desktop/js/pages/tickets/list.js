// Ticket List Page Controller
// Controla a lógica da página de listagem de chamados

import { $, $$ } from '../../utils/dom.js';
import { formatDate, debounce } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { categoryService } from '../../services/CategoryService.js';
import { statusService } from '../../services/StatusService.js';
import { priorityService } from '../../services/PriorityService.js';
import { userService } from '../../services/UserService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { STATUS_IDS, ROUTES } from '../../config/constants.js';

/**
 * Controller da página de listagem de chamados
 */
export class TicketList {
  constructor() {
    this.tickets = [];
    this.filteredTickets = [];
    this.categorias = [];
    this.status = [];
    this.prioridades = [];
    this.tecnicos = [];
    
    // Filtros ativos
    this.filters = {
      search: '',
      categoria: null,
      status: null,
      prioridade: null,
      tecnico: null,
      dataInicio: null,
      dataFim: null
    };
    
    // Ordenação
    this.sortBy = 'dataAbertura';
    this.sortOrder = 'desc'; // 'asc' ou 'desc'
  }

  /**
   * Inicializa a página
   */
  async init() {
    // Verifica autenticação
    if (!authService.isAuthenticated()) {
      window.location.href = ROUTES.LOGIN;
      return;
    }

    // Inicializa tema
    themeManager.init();
    themeManager.registerToggleButton('[data-theme-toggle]');

    await this.loadData();
    this.setupEventListeners();
  }

  /**
   * Carrega todos os dados necessários
   */
  async loadData() {
    try {
      this.showLoading();
      
      // Carrega todos os dados em paralelo
      const promises = [
        ticketService.getAll(),
        categoryService.getAll(),
        statusService.getAll(),
        priorityService.getAll()
      ];

      // Adiciona técnicos se for admin
      if (authService.isAdmin()) {
        promises.push(userService.getTecnicos());
      }

      const results = await Promise.all(promises);
      
      [this.tickets, this.categorias, this.status, this.prioridades] = results;
      
      if (authService.isAdmin()) {
        this.tecnicos = results[4];
      }

      this.filteredTickets = [...this.tickets];
      this.renderFilters();
      this.renderTickets();
      this.hideLoading();
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
      this.showError('Erro ao carregar chamados. Tente novamente.');
    }
  }

  /**
   * Renderiza os filtros
   */
  renderFilters() {
    // Filtro de categoria
    const categoriaSelect = $('#filter-categoria');
    if (categoriaSelect) {
      categoriaSelect.innerHTML = `
        <option value="">Todas as Categorias</option>
        ${this.categorias.map(cat => `
          <option value="${cat.id}">${cat.nome}</option>
        `).join('')}
      `;
    }

    // Filtro de status
    const statusSelect = $('#filter-status');
    if (statusSelect) {
      statusSelect.innerHTML = `
        <option value="">Todos os Status</option>
        ${this.status.map(st => `
          <option value="${st.id}">${st.nome}</option>
        `).join('')}
      `;
    }

    // Filtro de prioridade
    const prioridadeSelect = $('#filter-prioridade');
    if (prioridadeSelect) {
      prioridadeSelect.innerHTML = `
        <option value="">Todas as Prioridades</option>
        ${this.prioridades.map(pr => `
          <option value="${pr.id}">${pr.nome}</option>
        `).join('')}
      `;
    }

    // Filtro de técnico (apenas admin)
    if (authService.isAdmin()) {
      const tecnicoSelect = $('#filter-tecnico');
      if (tecnicoSelect) {
        tecnicoSelect.innerHTML = `
          <option value="">Todos os Técnicos</option>
          <option value="sem-tecnico">Sem Técnico</option>
          ${this.tecnicos.map(tec => `
            <option value="${tec.id}">${tec.nomeCompleto}</option>
          `).join('')}
        `;
      }
    }
  }

  /**
   * Renderiza a lista de tickets
   */
  renderTickets() {
    const container = $('#tickets-container');
    if (!container) return;

    // Atualiza contador
    const countEl = $('#tickets-count');
    if (countEl) {
      countEl.textContent = `${this.filteredTickets.length} chamado(s) encontrado(s)`;
    }

    // Lista vazia
    if (this.filteredTickets.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-search"></i>
          <h3>Nenhum chamado encontrado</h3>
          <p>${this.hasActiveFilters() 
            ? 'Tente ajustar os filtros ou fazer uma nova busca.' 
            : 'Não há chamados no sistema.'}</p>
          ${this.hasActiveFilters() ? `
            <button class="btn btn-primary" id="clear-filters-btn">
              <i class="fas fa-times"></i> Limpar Filtros
            </button>
          ` : ''}
        </div>
      `;
      
      // Event listener para limpar filtros
      const clearBtn = $('#clear-filters-btn');
      if (clearBtn) {
        clearBtn.addEventListener('click', () => this.clearFilters());
      }
      
      return;
    }

    // Renderiza os tickets
    container.innerHTML = `
      <div class="tickets-table">
        <table class="table">
          <thead>
            <tr>
              <th class="sortable" data-sort="id">
                # <i class="fas fa-sort"></i>
              </th>
              <th class="sortable" data-sort="titulo">
                Título <i class="fas fa-sort"></i>
              </th>
              <th class="sortable" data-sort="categoria">
                Categoria <i class="fas fa-sort"></i>
              </th>
              <th class="sortable" data-sort="status">
                Status <i class="fas fa-sort"></i>
              </th>
              <th class="sortable" data-sort="prioridade">
                Prioridade <i class="fas fa-sort"></i>
              </th>
              ${authService.isAdmin() || authService.isTecnico() ? `
                <th class="sortable" data-sort="solicitante">
                  Solicitante <i class="fas fa-sort"></i>
                </th>
              ` : ''}
              ${authService.isAdmin() ? `
                <th class="sortable" data-sort="tecnico">
                  Técnico <i class="fas fa-sort"></i>
                </th>
              ` : ''}
              <th class="sortable" data-sort="dataAbertura">
                Data Abertura <i class="fas fa-sort"></i>
              </th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody>
            ${this.filteredTickets.map(ticket => this.renderTicketRow(ticket)).join('')}
          </tbody>
        </table>
      </div>
    `;

    // Adiciona event listeners de ordenação
    $$('.sortable').forEach(th => {
      th.addEventListener('click', () => {
        const field = th.dataset.sort;
        this.toggleSort(field);
      });
    });
  }

  /**
   * Renderiza uma linha da tabela
   */
  renderTicketRow(ticket) {
    const isAdmin = authService.isAdmin();
    const isTecnico = authService.isTecnico();

    return `
      <tr class="ticket-row" data-id="${ticket.id}" onclick="window.location.href='${ROUTES.TICKET_DETALHES}?id=${ticket.id}'">
        <td>${ticket.id}</td>
        <td>
          <strong>${this.escapeHtml(ticket.titulo)}</strong>
        </td>
        <td>
          <span class="badge badge-secondary">
            ${ticket.categoria?.nome || 'Sem categoria'}
          </span>
        </td>
        <td>
          <span class="badge badge-${this.getStatusClass(ticket.statusId)}">
            ${ticket.status?.nome || 'Sem status'}
          </span>
        </td>
        <td>
          <span class="badge badge-${this.getPriorityClass(ticket.prioridadeId)}">
            ${ticket.prioridade?.nome || 'Sem prioridade'}
          </span>
        </td>
        ${isAdmin || isTecnico ? `
          <td>${ticket.solicitante?.nomeCompleto || 'Desconhecido'}</td>
        ` : ''}
        ${isAdmin ? `
          <td>${ticket.tecnico?.nomeCompleto || '<span class="text-muted">Sem técnico</span>'}</td>
        ` : ''}
        <td>${formatDate(ticket.dataAbertura)}</td>
        <td>
          <div class="action-buttons">
            <button class="btn btn-sm btn-primary" onclick="event.stopPropagation(); window.location.href='${ROUTES.TICKET_DETALHES}?id=${ticket.id}'" title="Ver Detalhes">
              <i class="fas fa-eye"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Busca
    const searchInput = $('#search-input');
    if (searchInput) {
      searchInput.addEventListener('input', debounce((e) => {
        this.filters.search = e.target.value.trim().toLowerCase();
        this.applyFilters();
      }, 300));
    }

    // Filtro de categoria
    const categoriaSelect = $('#filter-categoria');
    if (categoriaSelect) {
      categoriaSelect.addEventListener('change', (e) => {
        this.filters.categoria = e.target.value ? parseInt(e.target.value) : null;
        this.applyFilters();
      });
    }

    // Filtro de status
    const statusSelect = $('#filter-status');
    if (statusSelect) {
      statusSelect.addEventListener('change', (e) => {
        this.filters.status = e.target.value ? parseInt(e.target.value) : null;
        this.applyFilters();
      });
    }

    // Filtro de prioridade
    const prioridadeSelect = $('#filter-prioridade');
    if (prioridadeSelect) {
      prioridadeSelect.addEventListener('change', (e) => {
        this.filters.prioridade = e.target.value ? parseInt(e.target.value) : null;
        this.applyFilters();
      });
    }

    // Filtro de técnico (admin)
    const tecnicoSelect = $('#filter-tecnico');
    if (tecnicoSelect) {
      tecnicoSelect.addEventListener('change', (e) => {
        const value = e.target.value;
        this.filters.tecnico = value === 'sem-tecnico' ? 'sem-tecnico' : (value ? parseInt(value) : null);
        this.applyFilters();
      });
    }

    // Filtro de data
    const dataInicioInput = $('#filter-data-inicio');
    const dataFimInput = $('#filter-data-fim');
    
    if (dataInicioInput) {
      dataInicioInput.addEventListener('change', (e) => {
        this.filters.dataInicio = e.target.value || null;
        this.applyFilters();
      });
    }
    
    if (dataFimInput) {
      dataFimInput.addEventListener('change', (e) => {
        this.filters.dataFim = e.target.value || null;
        this.applyFilters();
      });
    }

    // Botão limpar filtros
    const clearFiltersBtn = $('#clear-all-filters-btn');
    if (clearFiltersBtn) {
      clearFiltersBtn.addEventListener('click', () => this.clearFilters());
    }

    // Botão atualizar
    const refreshBtn = $('#refresh-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', async () => {
        await this.loadData();
      });
    }

    // Botão novo chamado
    const newTicketBtn = $('#new-ticket-btn');
    if (newTicketBtn) {
      newTicketBtn.addEventListener('click', () => {
        window.location.href = ROUTES.TICKET_NOVO;
      });
    }
  }

  /**
   * Aplica todos os filtros
   */
  applyFilters() {
    let filtered = [...this.tickets];

    // Filtro de busca textual
    if (this.filters.search) {
      const search = this.filters.search;
      filtered = filtered.filter(t =>
        t.titulo?.toLowerCase().includes(search) ||
        t.descricao?.toLowerCase().includes(search) ||
        t.categoria?.nome?.toLowerCase().includes(search) ||
        t.solicitante?.nomeCompleto?.toLowerCase().includes(search)
      );
    }

    // Filtro de categoria
    if (this.filters.categoria) {
      filtered = filtered.filter(t => t.categoriaId === this.filters.categoria);
    }

    // Filtro de status
    if (this.filters.status) {
      filtered = filtered.filter(t => t.statusId === this.filters.status);
    }

    // Filtro de prioridade
    if (this.filters.prioridade) {
      filtered = filtered.filter(t => t.prioridadeId === this.filters.prioridade);
    }

    // Filtro de técnico
    if (this.filters.tecnico) {
      if (this.filters.tecnico === 'sem-tecnico') {
        filtered = filtered.filter(t => !t.tecnicoId);
      } else {
        filtered = filtered.filter(t => t.tecnicoId === this.filters.tecnico);
      }
    }

    // Filtro de data
    if (this.filters.dataInicio) {
      const dataInicio = new Date(this.filters.dataInicio);
      filtered = filtered.filter(t => new Date(t.dataAbertura) >= dataInicio);
    }
    
    if (this.filters.dataFim) {
      const dataFim = new Date(this.filters.dataFim);
      dataFim.setHours(23, 59, 59, 999); // Fim do dia
      filtered = filtered.filter(t => new Date(t.dataAbertura) <= dataFim);
    }

    // Aplica ordenação
    filtered = this.sortTickets(filtered);

    this.filteredTickets = filtered;
    this.renderTickets();
  }

  /**
   * Ordena tickets
   */
  sortTickets(tickets) {
    const sorted = [...tickets];
    
    sorted.sort((a, b) => {
      let aVal, bVal;
      
      switch (this.sortBy) {
        case 'id':
          aVal = a.id;
          bVal = b.id;
          break;
        case 'titulo':
          aVal = a.titulo?.toLowerCase() || '';
          bVal = b.titulo?.toLowerCase() || '';
          break;
        case 'categoria':
          aVal = a.categoria?.nome?.toLowerCase() || '';
          bVal = b.categoria?.nome?.toLowerCase() || '';
          break;
        case 'status':
          aVal = a.status?.nome?.toLowerCase() || '';
          bVal = b.status?.nome?.toLowerCase() || '';
          break;
        case 'prioridade':
          aVal = a.prioridadeId || 0;
          bVal = b.prioridadeId || 0;
          break;
        case 'solicitante':
          aVal = a.solicitante?.nomeCompleto?.toLowerCase() || '';
          bVal = b.solicitante?.nomeCompleto?.toLowerCase() || '';
          break;
        case 'tecnico':
          aVal = a.tecnico?.nomeCompleto?.toLowerCase() || '';
          bVal = b.tecnico?.nomeCompleto?.toLowerCase() || '';
          break;
        case 'dataAbertura':
          aVal = new Date(a.dataAbertura).getTime();
          bVal = new Date(b.dataAbertura).getTime();
          break;
        default:
          return 0;
      }
      
      if (aVal < bVal) return this.sortOrder === 'asc' ? -1 : 1;
      if (aVal > bVal) return this.sortOrder === 'asc' ? 1 : -1;
      return 0;
    });
    
    return sorted;
  }

  /**
   * Alterna ordenação
   */
  toggleSort(field) {
    if (this.sortBy === field) {
      this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortBy = field;
      this.sortOrder = 'asc';
    }
    
    this.applyFilters();
  }

  /**
   * Limpa todos os filtros
   */
  clearFilters() {
    this.filters = {
      search: '',
      categoria: null,
      status: null,
      prioridade: null,
      tecnico: null,
      dataInicio: null,
      dataFim: null
    };

    // Limpa campos do formulário
    const searchInput = $('#search-input');
    if (searchInput) searchInput.value = '';
    
    const categoriaSelect = $('#filter-categoria');
    if (categoriaSelect) categoriaSelect.value = '';
    
    const statusSelect = $('#filter-status');
    if (statusSelect) statusSelect.value = '';
    
    const prioridadeSelect = $('#filter-prioridade');
    if (prioridadeSelect) prioridadeSelect.value = '';
    
    const tecnicoSelect = $('#filter-tecnico');
    if (tecnicoSelect) tecnicoSelect.value = '';
    
    const dataInicioInput = $('#filter-data-inicio');
    if (dataInicioInput) dataInicioInput.value = '';
    
    const dataFimInput = $('#filter-data-fim');
    if (dataFimInput) dataFimInput.value = '';

    this.applyFilters();
  }

  /**
   * Verifica se há filtros ativos
   */
  hasActiveFilters() {
    return !!(
      this.filters.search ||
      this.filters.categoria ||
      this.filters.status ||
      this.filters.prioridade ||
      this.filters.tecnico ||
      this.filters.dataInicio ||
      this.filters.dataFim
    );
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
    const container = $('#tickets-container');
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
    const container = $('#tickets-container');
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
if (window.location.pathname.includes('tickets') && window.location.pathname.includes('list')) {
  const ticketList = new TicketList();
  ticketList.init();
}

export default TicketList;
