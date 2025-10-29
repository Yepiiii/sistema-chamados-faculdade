/* ===========================================================
   🔧 FUNÇÕES UTILITÁRIAS (HELPERS)
   =========================================================== */
const $ = (sel, p = document) => p.querySelector(sel);
const $$ = (sel, p = document) => [...p.querySelectorAll(sel)];
const save = (key, value) => localStorage.setItem(key, JSON.stringify(value));
const load = (key, fallback = []) => {
  try {
    const data = localStorage.getItem(key);
    return data ? JSON.parse(data) : fallback;
  } catch {
    return fallback;
  }
};
const toast = (msg) => alert(msg);

/* URL base da API */
const API_BASE = "http://localhost:5246";

/* ===========================================================
   🚀 SEED DE DEMONSTRAÇÃO (DADOS INICIAIS)
   =========================================================== */
(function seed() {
  if (!load("users").length) {
    save("users", [
      {
        id: 1,
        name: "Administrador",
        email: "admin@h2o.com",
        password: "123",
        role: "admin",
      },
      {
        id: 2,
        name: "Usuário Demo",
        email: "demo@h2o.com",
        password: "123",
        role: "user",
      },
    ]);
  }

  if (!load("tickets").length) {
    save("tickets", [
      {
        id: 1,
        title: "Erro ao abrir planilha",
        category: "software",
        priority: "media",
        status: "aberto",
        description: "Arquivo Excel não abre corretamente.",
        ownerId: 2,
        createdAt: new Date().toISOString(),
        comments: [
          {
            author: "Suporte",
            text: "Verificar compatibilidade do Office.",
            date: new Date().toISOString(),
          },
        ],
      },
    ]);
  }
})();

/* ===========================================================
   🔐 LOGIN
   =========================================================== */
function initLogin() {
  const form = $("#login-form");
  if (!form) return;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const email = $("#email").value.trim().toLowerCase();
    const password = $("#password").value.trim();
    console.log("Senha lida do campo:", password);
    if (!email || !password) return toast("Preencha todos os campos.");

    try {
      const response = await fetch(`${API_BASE}/api/usuarios/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          Email: email,
          Senha: password
        })
      });

      if (response.ok) {
        const data = await response.json();
        
        // Guardar o token no sessionStorage
        if (data.token) {
          sessionStorage.setItem('authToken', data.token);
        }
        
        toast("Login realizado com sucesso!");
        
        // Determinar redirecionamento baseado na resposta da API
        if (data.tipoUsuario === 3) { // Admin
          window.location.href = "admin-dashboard-desktop.html";
        } else if (data.tipoUsuario === 2) { // Técnico
          window.location.href = "tecnico-dashboard.html"; // <-- Redirecionamento CORRETO para técnico
        } else { // Usuário Comum (TipoUsuario 1 ou outro)
          window.location.href = "user-dashboard-desktop.html";
        }
      } else {
        // Tratar erro de autenticação
        let errorMessage = "E-mail ou senha incorretos.";
        try {
          const errorData = await response.json();
          if (errorData.message) {
            errorMessage = errorData.message;
          }
        } catch (e) {
          // Se não conseguir ler a mensagem de erro, usar a mensagem padrão
        }
        toast(errorMessage);
      }
    } catch (error) {
      // Tratar erros de rede ou outros problemas
      console.error('Erro na autenticação:', error);
      toast("Erro de conexão. Verifique sua internet e tente novamente.");
    }
  });
}

/* ===========================================================
   🧾 CADASTRO
   =========================================================== */
function initRegister() {
  const form = $("#register-form");
  if (!form) return;

  form.addEventListener("submit", (e) => {
    e.preventDefault();

    const name = $("#r-name").value.trim();
    const email = $("#r-email").value.trim().toLowerCase();
    const pass = $("#r-pass").value.trim();
    const confirm = $("#r-confirm").value.trim();

    if (!name || !email || !pass || !confirm)
      return toast("Preencha todos os campos.");
    if (pass !== confirm) return toast("As senhas não coincidem.");

    const users = load("users");
    if (users.some((u) => u.email === email))
      return toast("E-mail já cadastrado.");

    users.push({ id: Date.now(), name, email, password: pass, role: "user" });
    save("users", users);
    toast("Conta criada com sucesso!");
    go("login-desktop.html");
  });
}

/* ===========================================================
   📊 DASHBOARD
   =========================================================== */
async function initDashboard() {
  // Verificar se o token de autenticação existe
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    console.log("initDashboard: Token não encontrado, redirecionando para login.");
    return go("login-desktop.html");
  }
  console.log("initDashboard: Token encontrado, buscando chamados da API...");
  
  try {
    // Fazer chamada para a API para buscar os chamados
    const response = await fetch(`${API_BASE}/api/chamados`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    // Verificar se a resposta é bem-sucedida
    if (response.ok) {
      const responseData = await response.json();
      console.log("initDashboard: Dados recebidos da API:", responseData);
      
      // Extrai a lista de chamados de '$values' se existir, senão usa a resposta direta
      const chamados = responseData.$values || responseData; 
      
      // Identificar o tbody da tabela na página atual
      const tbody = document.querySelector("#tickets-table tbody") || document.querySelector("#tickets-body-admin tbody");
      if (!tbody) {
          console.error("initDashboard: Elemento tbody da tabela não encontrado!");
          return;
      }
      
      // Renderizar os chamados na tabela (passa a lista extraída)
      renderTicketsTable(chamados, tbody); 
    } else if (response.status === 401) {
      // Token inválido ou expirado
      console.log("initDashboard: Token inválido (401), redirecionando para login.");
      sessionStorage.removeItem('authToken');
      toast("Sessão expirada. Faça login novamente.");
      return go("login-desktop.html");
    } else {
      // Outros erros da API
      console.error('initDashboard: Erro da API:', response.status, response.statusText);
      toast("Erro ao carregar chamados.");
    }
  } catch (error) {
    // Problemas de rede ou outros erros
    console.error('initDashboard: Erro de rede:', error);
    toast("Erro ao carregar chamados.");
  }
}

/* Renderização da tabela de chamados (v5 - Simplificada e Segura) */
function renderTicketsTable(chamados, tbody) { // Recebe a lista 'chamados' diretamente
  tbody.innerHTML = ""; // Limpa a tabela

  // Verifica apenas se a lista é válida e tem itens
  if (!Array.isArray(chamados) || chamados.length === 0) {
    console.log("renderTicketsTable: A lista de chamados está vazia ou inválida.", chamados);
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;color:var(--muted)">Nenhum chamado encontrado.</td></tr>`;
    return;
  }

  console.log("renderTicketsTable: Recebeu chamados para renderizar:", chamados);

  chamados.forEach((chamado, index) => {
    // Adiciona um try...catch para isolar erros em chamados individuais
    try {
      console.log(`--- Processando Chamado #${index + 1} ---`);
      console.log("Objeto Chamado:", chamado);

      const tr = document.createElement("tr");

      // Leitura segura das propriedades
      const chamadoId = chamado?.id ?? '#ERR';
      const titulo = chamado?.titulo ?? 'Sem Título';
      const categoriaNome = chamado?.categoriaNome ?? 'N/A'; // Usa a propriedade direta do DTO
      const statusNome = chamado?.statusNome ?? 'N/A';       // Usa a propriedade direta do DTO

      const statusClass = String(statusNome).toLowerCase().replace(/\s+/g, '-');

      console.log(`ID Lido: ${chamadoId}, Título: ${titulo}, Categoria: ${categoriaNome}, Status: ${statusNome}`);

      tr.innerHTML = `
        <td>${chamadoId === '#ERR' ? '#ERR' : `#${chamadoId}`}</td>
        <td>${titulo}</td>
        <td>${categoriaNome}</td>
        <td><span class="badge status-${statusClass}">${statusNome}</span></td>
        <td><button class="btn btn-outline btn-sm" data-id="${chamadoId}">Abrir</button></td>
      `;
      tbody.appendChild(tr);
    } catch (error) {
      console.error(`Erro ao processar o chamado no índice ${index}:`, chamado, error);
      // Opcional: Adicionar uma linha de erro na tabela
      const trError = document.createElement("tr");
      trError.innerHTML = `<td colspan="5" style="color: red; text-align: center;">Erro ao renderizar este chamado. Verifique o console.</td>`;
      tbody.appendChild(trError);
    }
  });

  // Lógica dos botões "Abrir" (não muda)
  $$("button[data-id]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = btn.dataset.id;
      if (id && id !== '#ERR') {
        sessionStorage.setItem('currentTicketId', id);
        go("ticket-detalhes-desktop.html");
      } else {
        console.error("Tentativa de abrir chamado com ID inválido.");
        toast("Erro ao tentar abrir detalhes do chamado.");
      }
    });
  });
}

/* ===========================================================
   🆕 NOVO CHAMADO
   =========================================================== */
function initNewTicket() {
  const form = $("#new-ticket-form");
  if (!form) return;

  form.addEventListener("submit", (e) => {
    e.preventDefault();

    const title = $("#title").value.trim();
    const category = $("#category").value;
    const priority = $("#priority").value;
    const desc = $("#description").value.trim();

    if (!title || !category || !priority || !desc)
      return toast("Preencha todos os campos.");

    const user = load("user", null);
    const all = load("tickets");

    const newTicket = {
      id: Date.now(),
      title,
      category,
      priority,
      description: desc,
      status: "aberto",
      ownerId: user ? user.id : null,
      createdAt: new Date().toISOString(),
      comments: [],
    };

    all.push(newTicket);
    save("tickets", all);
    toast("Chamado criado com sucesso!");
    go("user-dashboard-desktop.html");
  });
}

/* ===========================================================
   🧩 DETALHES DO CHAMADO (Atualizado para API)
   =========================================================== */
async function initTicketDetails() {
  // Buscar o ID do chamado do sessionStorage (novo sistema)
  const ticketId = sessionStorage.getItem('currentTicketId');
  if (!ticketId) {
    toast("Chamado não encontrado.");
    return go("user-dashboard-desktop.html");
  }

  // Verificar se o token de autenticação existe
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    toast("Sessão expirada. Faça login novamente.");
    return go("login-desktop.html");
  }

  try {
    // Buscar os detalhes do chamado da API
    const response = await fetch(`${API_BASE}/api/chamados/${ticketId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (response.ok) {
      const chamado = await response.json();
      
      // Preencher os campos com os dados do chamado
      $("#t-id").textContent = "#" + chamado.id;
      $("#t-title").textContent = chamado.titulo || 'Sem Título';
      $("#t-category").textContent = chamado.categoria ? chamado.categoria.nome : 'N/A';
      $("#t-priority").textContent = chamado.prioridade ? chamado.prioridade.nome : 'N/A';
      
      const statusNome = chamado.status ? chamado.status.nome : 'N/A';
      const statusClass = statusNome.toLowerCase().replace(/\s+/g, '-');
      $("#t-status").innerHTML = `<span class="badge status-${statusClass}">${statusNome}</span>`;
      
      $("#t-desc").textContent = chamado.descricao || 'Sem descrição';

      // Renderizar comentários (se existirem)
      renderComments(chamado);

      // Configurar formulário de comentários
      const form = $("#comment-form");
      if (form) {
        form.addEventListener("submit", async (e) => {
          console.log("--- DEBUG: Evento SUBMIT do login foi disparado! ---");
          e.preventDefault();
          const text = $("#comment-text").value.trim();
          if (!text) return toast("Digite um comentário.");

          // TODO: Implementar adição de comentários via API
          // Por enquanto, apenas mostra uma mensagem
          toast("Funcionalidade de comentários será implementada em breve.");
          $("#comment-text").value = "";
        });
      }
    } else if (response.status === 401) {
      sessionStorage.removeItem('authToken');
      toast("Sessão expirada. Faça login novamente.");
      return go("login-desktop.html");
    } else if (response.status === 404) {
      toast("Chamado não encontrado.");
      return go("user-dashboard-desktop.html");
    } else {
      toast("Erro ao carregar detalhes do chamado.");
      console.error('Erro da API:', response.status, response.statusText);
    }
  } catch (error) {
    toast("Erro ao carregar detalhes do chamado.");
    console.error('Erro de rede:', error);
  }
}

/* Renderiza lista de comentários (Atualizada para API) */
function renderComments(chamado) {
  const list = $("#comments");
  list.innerHTML = "";

  // Verificar se existem comentários
  if (!chamado.comentarios || !chamado.comentarios.length) {
    list.innerHTML = `<li class="help">Nenhum comentário até o momento.</li>`;
    return;
  }

  chamado.comentarios.forEach((comentario) => {
    const li = document.createElement("li");
    li.className = "card";
    
    // Adaptar para a estrutura da API
    const autor = comentario.usuario ? comentario.usuario.nome : 'Usuário';
    const data = comentario.dataComentario ? new Date(comentario.dataComentario).toLocaleString() : 'Data não disponível';
    const texto = comentario.texto || 'Comentário sem texto';
    
    li.innerHTML = `<strong>${autor}</strong> — ${data}<br>${texto}`;
    list.appendChild(li);
  });
}

/* Função persistTicket removida - não é mais necessária com a API */

/* ===========================================================
   ⚙️ CONFIGURAÇÕES
   =========================================================== */
function initConfig() {
  const logoutBtn = $("#logout-btn");
  if (logoutBtn) {
    logoutBtn.addEventListener("click", () => {
      if (confirm("Deseja realmente sair?")) logout();
    });
  }
}

/* ===========================================================
   🔧 PAINEL DO TÉCNICO
   =========================================================== */

/* Função auxiliar para decodificar JWT (payload) */
function decodeJWT(token) {
  try {
    const payload = token.split('.')[1];
    const decoded = atob(payload);
    return JSON.parse(decoded);
  } catch (error) {
    console.error("Erro ao decodificar JWT:", error);
    return null;
  }
}

/* Função principal do painel do técnico */
async function initTecnicoDashboard() {
  console.log("=== Inicializando Painel do Técnico ===");

  // Verificar autenticação
  const token = sessionStorage.getItem("authToken");
  if (!token) {
    console.log("Token não encontrado, redirecionando para login");
    go("login-desktop.html");
    return;
  }

  // Decodificar token para obter ID do técnico
  const payload = decodeJWT(token);
  let tecnicoId;
  
  if (payload && payload.nameid) {
    tecnicoId = parseInt(payload.nameid);
    console.log("ID do técnico obtido do token:", tecnicoId);
  } else {
    // Para teste, usar ID fixo se não conseguir decodificar
    tecnicoId = 1;
    console.log("Usando ID de técnico fixo para teste:", tecnicoId);
  }

  // Headers para as requisições
  const headers = {
    "Authorization": `Bearer ${token}`,
    "Content-Type": "application/json"
  };

  try {
    // 1. Buscar chamados não atribuídos (fila de atendimento)
    console.log("Buscando chamados da fila de atendimento...");
    const filaResponse = await fetch(`${API_BASE}/api/chamados?tecnicoId=0&statusId=1`, {
      method: "GET",
      headers: headers
    });

    if (filaResponse.status === 401) {
      console.log("Token expirado, redirecionando para login");
      sessionStorage.removeItem("authToken");
      go("login-desktop.html");
      return;
    }

    if (!filaResponse.ok) {
      throw new Error(`Erro ao buscar fila: ${filaResponse.status} ${filaResponse.statusText}`);
    }

    const chamadosFila = await filaResponse.json();
    console.log("Chamados da fila recebidos:", chamadosFila);

    // Renderizar tabela da fila
    const tabelaFila = $("#tabela-fila-chamados tbody");
    if (tabelaFila) {
      renderTabelaFila(chamadosFila, tabelaFila);
    }

    // 2. Buscar chamados atribuídos ao técnico
    console.log("Buscando meus chamados atribuídos...");
    const meusResponse = await fetch(`${API_BASE}/api/chamados?tecnicoId=${tecnicoId}`, {
      method: "GET",
      headers: headers
    });

    if (meusResponse.status === 401) {
      console.log("Token expirado, redirecionando para login");
      sessionStorage.removeItem("authToken");
      go("login-desktop.html");
      return;
    }

    if (!meusResponse.ok) {
      throw new Error(`Erro ao buscar meus chamados: ${meusResponse.status} ${meusResponse.statusText}`);
    }

    const meusChamados = await meusResponse.json();
    console.log("Meus chamados recebidos:", meusChamados);

    // Renderizar tabela dos meus chamados
    const tabelaMeus = $("#tabela-meus-chamados tbody");
    if (tabelaMeus) {
      renderTabelaMeusChamados(meusChamados, tabelaMeus);
    }

  } catch (error) {
    console.error("Erro ao carregar dados do painel do técnico:", error);
    toast("Erro ao carregar dados. Verifique sua conexão e tente novamente.");
  }
}

/* Renderizar tabela da fila de atendimento */
function renderTabelaFila(chamados, tbody) {
  tbody.innerHTML = ""; // Limpa a tabela

  if (!Array.isArray(chamados) || chamados.length === 0) {
    console.log("Nenhum chamado na fila de atendimento");
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;color:var(--muted)">Nenhum chamado na fila de atendimento.</td></tr>`;
    return;
  }

  console.log("Renderizando fila de atendimento:", chamados);

  chamados.forEach((chamado, index) => {
    try {
      const tr = document.createElement("tr");

      // Leitura segura das propriedades
      const chamadoId = chamado?.id ?? '#ERR';
      const titulo = chamado?.titulo ?? 'Sem Título';
      const categoriaNome = chamado?.categoriaNome ?? 'N/A';
      const prioridade = 'Normal'; // TODO: Adicionar ao DTO quando disponível
      const dataAbertura = 'Hoje'; // TODO: Adicionar ao DTO quando disponível

      tr.innerHTML = `
        <td>${chamadoId === '#ERR' ? '#ERR' : `#${chamadoId}`}</td>
        <td>${titulo}</td>
        <td>${categoriaNome}</td>
        <td><span class="badge priority-normal">${prioridade}</span></td>
        <td>${dataAbertura}</td>
        <td><button class="btn btn-primary btn-sm" data-id="${chamadoId}" data-action="assumir">Assumir</button></td>
      `;
      tbody.appendChild(tr);
    } catch (error) {
      console.error(`Erro ao processar chamado da fila no índice ${index}:`, chamado, error);
    }
  });

  // Event listeners para botões "Assumir"
  $$("button[data-action='assumir']").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = btn.dataset.id;
      if (id && id !== '#ERR') {
        assumirChamado(id);
      } else {
        console.error("Tentativa de assumir chamado com ID inválido.");
        toast("Erro ao tentar assumir chamado.");
      }
    });
  });
}

/* Renderizar tabela dos meus chamados */
function renderTabelaMeusChamados(chamados, tbody) {
  tbody.innerHTML = ""; // Limpa a tabela

  if (!Array.isArray(chamados) || chamados.length === 0) {
    console.log("Nenhum chamado atribuído");
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;color:var(--muted)">Nenhum chamado atribuído.</td></tr>`;
    return;
  }

  console.log("Renderizando meus chamados:", chamados);

  chamados.forEach((chamado, index) => {
    try {
      const tr = document.createElement("tr");

      // Leitura segura das propriedades
      const chamadoId = chamado?.id ?? '#ERR';
      const titulo = chamado?.titulo ?? 'Sem Título';
      const categoriaNome = chamado?.categoriaNome ?? 'N/A';
      const statusNome = chamado?.statusNome ?? 'N/A';
      const prioridade = 'Normal'; // TODO: Adicionar ao DTO quando disponível

      const statusClass = String(statusNome).toLowerCase().replace(/\s+/g, '-');

      tr.innerHTML = `
        <td>${chamadoId === '#ERR' ? '#ERR' : `#${chamadoId}`}</td>
        <td>${titulo}</td>
        <td>${categoriaNome}</td>
        <td><span class="badge status-${statusClass}">${statusNome}</span></td>
        <td><span class="badge priority-normal">${prioridade}</span></td>
        <td><button class="btn btn-outline btn-sm" data-id="${chamadoId}" data-action="detalhes">Ver Detalhes</button></td>
      `;
      tbody.appendChild(tr);
    } catch (error) {
      console.error(`Erro ao processar meu chamado no índice ${index}:`, chamado, error);
    }
  });

  // Event listeners para botões "Ver Detalhes"
  $$("button[data-action='detalhes']").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = btn.dataset.id;
      if (id && id !== '#ERR') {
        sessionStorage.setItem('currentTicketId', id);
        go("ticket-detalhes-desktop.html");
      } else {
        console.error("Tentativa de ver detalhes com ID inválido.");
        toast("Erro ao tentar abrir detalhes do chamado.");
      }
    });
  });
}

/* Função para assumir um chamado (placeholder) */
async function assumirChamado(chamadoId) {
  console.log("Assumindo chamado:", chamadoId);
  // TODO: Implementar endpoint para atribuir chamado ao técnico
  toast(`Funcionalidade de assumir chamado #${chamadoId} será implementada em breve.`);
  
  // Por enquanto, apenas recarregar os dados
  setTimeout(() => {
    initTecnicoDashboard();
  }, 1000);
}

/* ===========================================================
   🧭 NAVEGAÇÃO GLOBAL
   =========================================================== */
function go(page) {
  window.location.href = page;
}

/* Botão de voltar */
function goBack() {
  window.history.back();
}

/* Logout global (Atualizado para API) */
function logout() {
  // Limpar dados de autenticação
  sessionStorage.removeItem("authToken");
  sessionStorage.removeItem("currentTicketId");
  localStorage.removeItem("user");
  go("login-desktop.html");
}

/* ===========================================================
   👁️ MOSTRAR / OCULTAR SENHA
   =========================================================== */
function initPasswordToggles() {
  $$(".toggle-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = btn.dataset.target;
      const input = document.getElementById(id);
      if (!input) return;
      const show = input.type === "password";
      input.type = show ? "text" : "password";
      btn.textContent = show ? "🙈" : "👁️";
    });
  });
}

/* ===========================================================
   🚀 INICIALIZAÇÃO GLOBAL
   =========================================================== */
document.addEventListener("DOMContentLoaded", () => {
  const path = window.location.pathname;

  if (path.endsWith("login-desktop.html")) {
    initLogin();
    initPasswordToggles();
  } else if (
    path.endsWith("admin-dashboard-desktop.html") ||
    path.endsWith("user-dashboard-desktop.html")
  ) {
    initDashboard();
    initConfig();
  } else if (path.endsWith("cadastro-desktop.html")) {
    initRegister();
  } else if (path.endsWith("new-ticket-desktop.html")) {
    initNewTicket();
  } else if (path.endsWith("ticket-detalhes-desktop.html")) {
    initTicketDetails();
  } else if (path.endsWith("tecnico-dashboard.html")) {
    initTecnicoDashboard(); 
    initConfig(); // Mantém o logout
  }
});

