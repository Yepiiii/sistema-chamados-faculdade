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
    if (!email || !password) return toast("Preencha todos os campos.");

    try {
      const response = await fetch(`${API_BASE}/api/usuarios/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email,
          password: password
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
        if (data.tipoUsuario === 3) {
          window.location.href = "admin-dashboard-desktop.html";
        } else {
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
    toast("Sessão expirada. Faça login novamente.");
    return go("login-desktop.html");
  }

  // Identificar a tabela correta para renderizar os dados
  const table = $("#tickets-table") || $("#tickets-body-admin");
  if (!table) return;

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
      const chamados = await response.json();
      
      // Renderizar os chamados na tabela
      renderTicketsTable(chamados, table);
    } else if (response.status === 401) {
      // Token inválido ou expirado
      sessionStorage.removeItem('authToken');
      toast("Sessão expirada. Faça login novamente.");
      return go("login-desktop.html");
    } else {
      // Outros erros da API
      toast("Erro ao carregar chamados.");
      console.error('Erro da API:', response.status, response.statusText);
    }
  } catch (error) {
    // Problemas de rede ou outros erros
    toast("Erro ao carregar chamados.");
    console.error('Erro de rede:', error);
  }
}

/* Renderização da tabela de chamados */
function renderTicketsTable(tickets, table) {
  const tbody = table.querySelector("tbody");
  tbody.innerHTML = "";

  if (!tickets.length) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;color:#64748b">Nenhum chamado encontrado.</td></tr>`;
    return;
  }

  tickets.forEach((t) => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>#${t.id}</td>
      <td>${t.title}</td>
      <td>${t.category}</td>
      <td><span class="badge status-${t.status}">${t.status}</span></td>
      <td><button class="btn btn-outline btn-sm" data-id="${t.id}">Abrir</button></td>
    `;
    tbody.appendChild(tr);
  });

  $$("button[data-id]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = Number(btn.dataset.id);
      const ticket = tickets.find((x) => x.id === id);
      save("currentTicket", ticket);
      go("ticket-detalhes-desktop.html");
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
   🧩 DETALHES DO CHAMADO
   =========================================================== */
function initTicketDetails() {
  const ticket = load("currentTicket", null);
  if (!ticket) return go("user-dashboard-desktop.html");

  $("#t-id").textContent = "#" + ticket.id;
  $("#t-title").textContent = ticket.title;
  $("#t-category").textContent = ticket.category;
  $("#t-priority").textContent = ticket.priority;
  $(
    "#t-status"
  ).innerHTML = `<span class="badge status-${ticket.status}">${ticket.status}</span>`;
  $("#t-desc").textContent = ticket.description;

  renderComments(ticket);

  const form = $("#comment-form");
  if (form) {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const text = $("#comment-text").value.trim();
      if (!text) return toast("Digite um comentário.");

      ticket.comments.push({
        author: "Você",
        text,
        date: new Date().toISOString(),
      });
      persistTicket(ticket);
      $("#comment-text").value = "";
      renderComments(ticket);
      toast("Comentário adicionado!");
    });
  }
}

/* Renderiza lista de comentários */
function renderComments(ticket) {
  const list = $("#comments");
  list.innerHTML = "";

  if (!ticket.comments.length) {
    list.innerHTML = `<li class="help">Nenhum comentário até o momento.</li>`;
    return;
  }

  ticket.comments.forEach((c) => {
    const li = document.createElement("li");
    li.className = "card";
    li.innerHTML = `<strong>${c.author}</strong> — ${new Date(
      c.date
    ).toLocaleString()}<br>${c.text}`;
    list.appendChild(li);
  });
}

/* Atualiza e salva o ticket */
function persistTicket(ticket) {
  const all = load("tickets");
  const i = all.findIndex((t) => t.id === ticket.id);
  if (i >= 0) all[i] = ticket;
  save("tickets", all);
  save("currentTicket", ticket);
}

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
   🧭 NAVEGAÇÃO GLOBAL
   =========================================================== */
function go(page) {
  window.location.href = page;
}

/* Botão de voltar */
function goBack() {
  window.history.back();
}

/* Logout global */
function logout() {
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
  }
});

