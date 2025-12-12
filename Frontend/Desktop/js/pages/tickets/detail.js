// Ticket Detail Page Controller
// Controla a lógica da página de detalhes do chamado

import { $, $$ } from '../../utils/dom.js';
import { formatDate, toast } from '../../utils/helpers.js';
import { ticketService } from '../../services/TicketService.js';
import { categoryService } from '../../services/CategoryService.js';
import { statusService } from '../../services/StatusService.js';
import { priorityService } from '../../services/PriorityService.js';
import { userService } from '../../services/UserService.js';
import { authService } from '../../services/AuthService.js';
import { themeManager } from '../../components/ThemeManager.js';
import { STATUS_IDS, USER_TYPES, ROUTES } from '../../config/constants.js';

/**
 * Controller da página de detalhes do chamado
 */
export class TicketDetail {
  constructor() {
    this.ticketId = null;
    this.ticket = null;
    this.comments = [];
    this.categorias = [];
    this.status = [];
    this.prioridades = [];
    this.tecnicos = [];
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

    // Obtém ID do ticket da URL
    const urlParams = new URLSearchParams(window.location.search);
    this.ticketId = urlParams.get('id');

    if (!this.ticketId) {
      toast('ID do chamado não fornecido', 'error');
      window.history.back();
      return;
    }

    await this.loadData();
    this.setupEventListeners();
  }

  /**
   * Carrega dados do ticket
   */
  async loadData() {
    try {
      this.showLoading();

      // Carrega dados em paralelo
      const promises = [
        ticketService.getById(this.ticketId),
        ticketService.getComments(this.ticketId),
        categoryService.getAll(),
        statusService.getAll(),
        priorityService.getAll()
      ];

      // Admin pode atribuir técnicos
      if (authService.isAdmin() || authService.isTecnico()) {
        promises.push(userService.getTecnicos());
      }

      const results = await Promise.all(promises);

      [this.ticket, this.comments, this.categorias, this.status, this.prioridades] = results;

      if (authService.isAdmin() || authService.isTecnico()) {
        this.tecnicos = results[5];
      }

      this.render();
      this.hideLoading();
    } catch (error) {
      console.error('Erro ao carregar chamado:', error);
      this.showError('Erro ao carregar chamado. Tente novamente.');
    }
  }

  /**
   * Renderiza a página completa
   */
  render() {
    this.renderTicketInfo();
    this.renderComments();
    this.renderActions();
    this.updateBreadcrumb();
  }

  /**
   * Renderiza informações do ticket
   */
  renderTicketInfo() {
    const container = $('#ticket-info');
    if (!container) return;

    const userData = authService.getUserData();
    const isOwner = this.ticket.solicitanteId === userData?.id;
    const isTecnico = authService.isTecnico() || authService.isAdmin();
    const isAdmin = authService.isAdmin();
    const canEdit = isAdmin || (isTecnico && this.ticket.tecnicoId === userData?.id);

    container.innerHTML = `
      <div class="ticket-header">
        <div class="ticket-title-section">
          <h1 class="ticket-title">
            ${this.escapeHtml(this.ticket.titulo)}
          </h1>
          <div class="ticket-badges">
            <span class="badge badge-${this.getStatusClass(this.ticket.statusId)}">
              ${this.ticket.status?.nome || 'Sem status'}
            </span>
            <span class="badge badge-${this.getPriorityClass(this.ticket.prioridadeId)}">
              ${this.ticket.prioridade?.nome || 'Sem prioridade'}
            </span>
            <span class="badge badge-secondary">
              #${this.ticket.id}
            </span>
          </div>
        </div>
        
        <div class="ticket-actions-header">
          ${canEdit ? this.renderEditButtons() : ''}
        </div>
      </div>

      <div class="ticket-body">
        <div class="ticket-meta-grid">
          <div class="meta-item">
            <label><i class="fas fa-tag"></i> Categoria</label>
            ${canEdit ? this.renderCategoriaSelect() : `
              <span class="meta-value">${this.ticket.categoria?.nome || 'Sem categoria'}</span>
            `}
          </div>

          <div class="meta-item">
            <label><i class="fas fa-flag"></i> Prioridade</label>
            ${canEdit ? this.renderPrioridadeSelect() : `
              <span class="meta-value">${this.ticket.prioridade?.nome || 'Sem prioridade'}</span>
            `}
          </div>

          <div class="meta-item">
            <label><i class="fas fa-info-circle"></i> Status</label>
            ${canEdit ? this.renderStatusSelect() : `
              <span class="meta-value">${this.ticket.status?.nome || 'Sem status'}</span>
            `}
          </div>

          <div class="meta-item">
            <label><i class="fas fa-user"></i> Solicitante</label>
            <span class="meta-value">${this.ticket.solicitante?.nomeCompleto || 'Desconhecido'}</span>
          </div>

          <div class="meta-item">
            <label><i class="fas fa-user-cog"></i> Técnico</label>
            ${isAdmin ? this.renderTecnicoSelect() : `
              <span class="meta-value">${this.ticket.tecnico?.nomeCompleto || 'Não atribuído'}</span>
            `}
          </div>

          <div class="meta-item">
            <label><i class="fas fa-calendar"></i> Data Abertura</label>
            <span class="meta-value">${formatDate(this.ticket.dataAbertura)}</span>
          </div>

          ${this.ticket.dataFechamento ? `
            <div class="meta-item">
              <label><i class="fas fa-calendar-check"></i> Data Fechamento</label>
              <span class="meta-value">${formatDate(this.ticket.dataFechamento)}</span>
            </div>
          ` : ''}
        </div>

        <div class="ticket-description">
          <h3><i class="fas fa-align-left"></i> Descrição</h3>
          <div class="description-content">
            ${this.escapeHtml(this.ticket.descricao)}
          </div>
        </div>
      </div>
    `;
  }

  /**
   * Renderiza botões de edição
   */
  renderEditButtons() {
    const isResolvido = this.ticket.statusId === STATUS_IDS.RESOLVIDO;
    const isFechado = this.ticket.statusId === STATUS_IDS.FECHADO;

    return `
      ${!isFechado && !isResolvido ? `
        <button class="btn btn-success" id="btn-resolver">
          <i class="fas fa-check"></i> Resolver
        </button>
      ` : ''}
      ${isResolvido ? `
        <button class="btn btn-primary" id="btn-fechar">
          <i class="fas fa-lock"></i> Fechar
        </button>
        <button class="btn btn-warning" id="btn-reabrir">
          <i class="fas fa-redo"></i> Reabrir
        </button>
      ` : ''}
      ${isFechado ? `
        <button class="btn btn-warning" id="btn-reabrir">
          <i class="fas fa-redo"></i> Reabrir
        </button>
      ` : ''}
      ${authService.isAdmin() ? `
        <button class="btn btn-danger" id="btn-excluir">
          <i class="fas fa-trash"></i> Excluir
        </button>
      ` : ''}
    `;
  }

  /**
   * Renderiza select de categoria
   */
  renderCategoriaSelect() {
    return `
      <select class="form-control" id="select-categoria">
        ${this.categorias.map(cat => `
          <option value="${cat.id}" ${this.ticket.categoriaId === cat.id ? 'selected' : ''}>
            ${cat.nome}
          </option>
        `).join('')}
      </select>
    `;
  }

  /**
   * Renderiza select de prioridade
   */
  renderPrioridadeSelect() {
    return `
      <select class="form-control" id="select-prioridade">
        ${this.prioridades.map(pr => `
          <option value="${pr.id}" ${this.ticket.prioridadeId === pr.id ? 'selected' : ''}>
            ${pr.nome}
          </option>
        `).join('')}
      </select>
    `;
  }

  /**
   * Renderiza select de status
   */
  renderStatusSelect() {
    return `
      <select class="form-control" id="select-status">
        ${this.status.map(st => `
          <option value="${st.id}" ${this.ticket.statusId === st.id ? 'selected' : ''}>
            ${st.nome}
          </option>
        `).join('')}
      </select>
    `;
  }

  /**
   * Renderiza select de técnico
   */
  renderTecnicoSelect() {
    return `
      <select class="form-control" id="select-tecnico">
        <option value="">Não atribuído</option>
        ${this.tecnicos.map(tec => `
          <option value="${tec.id}" ${this.ticket.tecnicoId === tec.id ? 'selected' : ''}>
            ${tec.nomeCompleto}
          </option>
        `).join('')}
      </select>
    `;
  }

  /**
   * Renderiza comentários
   */
  renderComments() {
    const container = $('#comments-section');
    if (!container) return;

    container.innerHTML = `
      <h3><i class="fas fa-comments"></i> Comentários (${this.comments.length})</h3>
      
      <div class="comments-list">
        ${this.comments.length === 0 ? `
          <div class="empty-state">
            <i class="fas fa-comment-slash"></i>
            <p>Nenhum comentário ainda. Seja o primeiro a comentar!</p>
          </div>
        ` : this.comments.map(comment => `
          <div class="comment-card">
            <div class="comment-header">
              <div class="comment-author">
                <i class="fas fa-user-circle"></i>
                <strong>${comment.usuario?.nomeCompleto || 'Usuário'}</strong>
              </div>
              <div class="comment-date">
                ${formatDate(comment.dataCriacao)}
              </div>
            </div>
            <div class="comment-body">
              ${this.escapeHtml(comment.conteudo)}
            </div>
          </div>
        `).join('')}
      </div>

      <div class="comment-form">
        <h4>Adicionar Comentário</h4>
        <form id="form-comment">
          <textarea 
            id="comment-text" 
            class="form-control" 
            rows="3" 
            placeholder="Escreva seu comentário..."
            required
          ></textarea>
          <button type="submit" class="btn btn-primary">
            <i class="fas fa-paper-plane"></i> Enviar
          </button>
        </form>
      </div>
    `;
  }

  /**
   * Renderiza ações rápidas
   */
  renderActions() {
    const container = $('#quick-actions');
    if (!container) return;

    const userData = authService.getUserData();
    const isTecnico = authService.isTecnico();
    const isAdmin = authService.isAdmin();
    const isMyTicket = this.ticket.tecnicoId === userData?.id;
    const isOpen = this.ticket.statusId === STATUS_IDS.ABERTO;

    container.innerHTML = `
      <div class="actions-card">
        <h4><i class="fas fa-bolt"></i> Ações Rápidas</h4>
        <div class="actions-list">
          ${isTecnico && !isMyTicket && isOpen && !this.ticket.tecnicoId ? `
            <button class="btn btn-primary btn-block" id="btn-assumir">
              <i class="fas fa-hand-paper"></i> Assumir Chamado
            </button>
          ` : ''}
          ${(isTecnico || isAdmin) && !isOpen ? `
            <button class="btn btn-info btn-block" id="btn-andamento">
              <i class="fas fa-play"></i> Iniciar Atendimento
            </button>
          ` : ''}
          <button class="btn btn-secondary btn-block" id="btn-voltar">
            <i class="fas fa-arrow-left"></i> Voltar
          </button>
        </div>
      </div>
    `;
  }

  /**
   * Atualiza breadcrumb
   */
  updateBreadcrumb() {
    const breadcrumb = $('#breadcrumb');
    if (breadcrumb) {
      breadcrumb.innerHTML = `
        <a href="${ROUTES.DASHBOARD}">Dashboard</a> /
        <a href="${ROUTES.TICKETS_LIST}">Chamados</a> /
        <span>Chamado #${this.ticket.id}</span>
      `;
    }
  }

  /**
   * Configura event listeners
   */
  setupEventListeners() {
    // Formulário de comentário
    const commentForm = $('#form-comment');
    if (commentForm) {
      commentForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        await this.handleAddComment();
      });
    }

    // Selects de edição
    const categoriaSelect = $('#select-categoria');
    if (categoriaSelect) {
      categoriaSelect.addEventListener('change', async (e) => {
        await this.updateTicket({ categoriaId: parseInt(e.target.value) });
      });
    }

    const prioridadeSelect = $('#select-prioridade');
    if (prioridadeSelect) {
      prioridadeSelect.addEventListener('change', async (e) => {
        await this.updateTicket({ prioridadeId: parseInt(e.target.value) });
      });
    }

    const statusSelect = $('#select-status');
    if (statusSelect) {
      statusSelect.addEventListener('change', async (e) => {
        await this.updateTicket({ statusId: parseInt(e.target.value) });
      });
    }

    const tecnicoSelect = $('#select-tecnico');
    if (tecnicoSelect) {
      tecnicoSelect.addEventListener('change', async (e) => {
        const tecnicoId = e.target.value ? parseInt(e.target.value) : null;
        if (tecnicoId) {
          await ticketService.assignTo(this.ticketId, tecnicoId);
        }
        await this.loadData();
      });
    }

    // Botões de ação
    const btnResolver = $('#btn-resolver');
    if (btnResolver) {
      btnResolver.addEventListener('click', async () => {
        await this.updateTicket({ statusId: STATUS_IDS.RESOLVIDO });
      });
    }

    const btnFechar = $('#btn-fechar');
    if (btnFechar) {
      btnFechar.addEventListener('click', async () => {
        await this.closeTicket();
      });
    }

    const btnReabrir = $('#btn-reabrir');
    if (btnReabrir) {
      btnReabrir.addEventListener('click', async () => {
        await this.reopenTicket();
      });
    }

    const btnExcluir = $('#btn-excluir');
    if (btnExcluir) {
      btnExcluir.addEventListener('click', async () => {
        if (confirm('Tem certeza que deseja excluir este chamado? Esta ação não pode ser desfeita.')) {
          await this.deleteTicket();
        }
      });
    }

    const btnAssumir = $('#btn-assumir');
    if (btnAssumir) {
      btnAssumir.addEventListener('click', async () => {
        await this.assumeTicket();
      });
    }

    const btnAndamento = $('#btn-andamento');
    if (btnAndamento) {
      btnAndamento.addEventListener('click', async () => {
        await this.updateTicket({ statusId: STATUS_IDS.EM_ANDAMENTO });
      });
    }

    const btnVoltar = $('#btn-voltar');
    if (btnVoltar) {
      btnVoltar.addEventListener('click', () => {
        window.history.back();
      });
    }
  }

  /**
   * Adiciona comentário
   */
  async handleAddComment() {
    const textarea = $('#comment-text');
    const conteudo = textarea.value.trim();

    if (!conteudo) {
      toast('Digite um comentário', 'warning');
      return;
    }

    try {
      await ticketService.addComment(this.ticketId, conteudo);
      toast('Comentário adicionado com sucesso', 'success');
      textarea.value = '';
      await this.loadData();
    } catch (error) {
      toast('Erro ao adicionar comentário', 'error');
    }
  }

  /**
   * Atualiza ticket
   */
  async updateTicket(data) {
    try {
      await ticketService.update(this.ticketId, data);
      toast('Chamado atualizado com sucesso', 'success');
      await this.loadData();
    } catch (error) {
      toast('Erro ao atualizar chamado', 'error');
    }
  }

  /**
   * Fecha ticket
   */
  async closeTicket() {
    try {
      await ticketService.close(this.ticketId);
      toast('Chamado fechado com sucesso', 'success');
      await this.loadData();
    } catch (error) {
      toast('Erro ao fechar chamado', 'error');
    }
  }

  /**
   * Reabre ticket
   */
  async reopenTicket() {
    try {
      await ticketService.reopen(this.ticketId);
      toast('Chamado reaberto com sucesso', 'success');
      await this.loadData();
    } catch (error) {
      toast('Erro ao reabrir chamado', 'error');
    }
  }

  /**
   * Exclui ticket
   */
  async deleteTicket() {
    try {
      await ticketService.delete(this.ticketId);
      toast('Chamado excluído com sucesso', 'success');
      setTimeout(() => {
        window.location.href = ROUTES.TICKETS_LIST;
      }, 1000);
    } catch (error) {
      toast('Erro ao excluir chamado', 'error');
    }
  }

  /**
   * Assume ticket
   */
  async assumeTicket() {
    try {
      await ticketService.assignToMe(this.ticketId);
      toast('Chamado assumido com sucesso', 'success');
      await this.loadData();
    } catch (error) {
      toast('Erro ao assumir chamado', 'error');
    }
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
    const container = $('#ticket-container');
    if (!container) return;
    container.innerHTML = `
      <div class="loading-state">
        <i class="fas fa-spinner fa-spin"></i>
        <p>Carregando chamado...</p>
      </div>
    `;
  }

  hideLoading() {}

  showError(message) {
    const container = $('#ticket-container');
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
if (window.location.pathname.includes('ticket') && (window.location.pathname.includes('detail') || window.location.search.includes('id='))) {
  const ticketDetail = new TicketDetail();
  ticketDetail.init();
}

export default TicketDetail;
