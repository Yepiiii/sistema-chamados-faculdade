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

/**
 * Atrasa a execução de uma função (para barras de busca)
 * @param {Function} func - A função a ser executada.
 * @param {number} delay - O tempo em milissegundos.
 */
function debounce(func, delay = 300) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}

// ===========================================================
// INÍCIO - LÓGICA DE TEMA (DARK MODE)
// ===========================================================

/**
 * Aplica o tema (light/dark) salvo assim que o script carrega.
 * Previne o "flash" de tema incorreto.
 */
function applyInitialTheme() {
  // Usamos a função 'load' existente, default 'light'
  const savedTheme = load('theme-preference', 'light'); 
  if (savedTheme === 'dark') {
    document.body.classList.add('dark-mode');
  } else {
    document.body.classList.remove('dark-mode');
  }
}
// Chama imediatamente para aplicar o tema ANTES da página renderizar
applyInitialTheme();

// ===========================================================
// FIM - LÓGICA DE TEMA (DARK MODE)
// ===========================================================

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
   🔑 ESQUECI SENHA
   =========================================================== */
async function initEsqueciSenha() {
  const form = $("#esqueci-senha-form");
  if (!form) return;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const email = $("#email").value.trim();
    
    // Validação simples de email
    if (!email) {
      return toast("Por favor, digite seu e-mail.");
    }
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return toast("Por favor, digite um e-mail válido.");
    }

    // Desativar botão e mostrar "Enviando..."
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = "Enviando...";

    try {
      const response = await fetch(`${API_BASE}/api/usuarios/esqueci-senha`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          Email: email
        })
      });

      // Independentemente da resposta, mostrar mensagem de segurança padrão
      toast("Se um usuário com este e-mail existir, um link de redefinição de senha foi enviado.");
      
      // Redirecionar para o login
      setTimeout(() => {
        go("login-desktop.html");
      }, 2000);

    } catch (error) {
      console.error('Erro ao solicitar recuperação de senha:', error);
      // Mesmo em caso de erro, mostrar a mensagem de segurança
      toast("Se um usuário com este e-mail existir, um link de redefinição de senha foi enviado.");
      
      // Redirecionar para o login
      setTimeout(() => {
        go("login-desktop.html");
      }, 2000);
    } finally {
      // Reativar botão
      submitBtn.disabled = false;
      submitBtn.textContent = originalText;
    }
  });
}

/* ===========================================================
   🔄 RESETAR SENHA
   =========================================================== */
async function initResetarSenha() {
  // 1. Ler o token da URL
  const urlParams = new URLSearchParams(window.location.search);
  const token = urlParams.get('token');
  
  // 2. Se o token não existir, mostrar erro e redirecionar
  if (!token) {
    toast("Token inválido ou em falta.");
    setTimeout(() => {
      go("login-desktop.html");
    }, 2000);
    return;
  }

  // 3. Encontrar o formulário
  const form = $("#resetar-senha-form");
  if (!form) return;

  // 4. Adicionar event listener para o submit
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    // 5. Ler os valores dos campos
    const novaSenha = $("#nova-senha").value.trim();
    const confirmarSenha = $("#confirmar-senha").value.trim();

    // 6. Validações
    if (!novaSenha || !confirmarSenha) {
      return toast("Preencha todos os campos.");
    }

    if (novaSenha.length < 6) {
      return toast("A senha deve ter pelo menos 6 caracteres.");
    }

    if (novaSenha !== confirmarSenha) {
      return toast("As senhas não coincidem.");
    }

    // 7. Desativar botão e mostrar "Alterando..."
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = "Alterando...";

    try {
      // 8. Fazer chamada para a API
      const response = await fetch(`${API_BASE}/api/usuarios/resetar-senha`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          Token: token,
          NovaSenha: novaSenha
        })
      });

      if (response.ok) {
        // 9. Sucesso - mostrar mensagem e redirecionar
        toast("Senha redefinida com sucesso!");
        setTimeout(() => {
          go("login-desktop.html");
        }, 2000);
      } else {
        // 10. Erro - mostrar mensagem de erro
        let errorMessage = "Erro ao redefinir a senha. O token pode ter expirado.";
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
      console.error('Erro ao redefinir senha:', error);
      toast("Erro de conexão. Verifique sua internet e tente novamente.");
    } finally {
      // 11. Reativar botão
      submitBtn.disabled = false;
      submitBtn.textContent = originalText;
    }
  });

  // Inicializar toggles de senha
  initPasswordToggles();
}

/* ===========================================================
   🧾 CADASTRO (Atualizado para API)
   =========================================================== */
async function initRegister() {
  const form = $("#register-form");
  if (!form) return;
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const nomeCompleto = $("#r-name").value.trim();
    const email = $("#r-email").value.trim().toLowerCase();
    const senha = $("#r-pass").value.trim();
    const confirmarSenha = $("#r-confirm").value.trim();
    if (!nomeCompleto || !email || !senha || !confirmarSenha) {
      return toast("Preencha todos os campos.");
    }
    if (senha !== confirmarSenha) {
      return toast("As senhas não coincidem.");
    }
    const submitButton = form.querySelector("button[type='submit']");
    submitButton.disabled = true;
    submitButton.textContent = "A registar...";
    try {
      const response = await fetch(`${API_BASE}/api/usuarios/registrar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          NomeCompleto: nomeCompleto,
          Email: email,
          Senha: senha
        })
      });
      if (response.ok) {
        toast("Conta criada com sucesso! Por favor, faça o login.");
        go("login-desktop.html");
      } else {
        const errorData = await response.json();
        // Tenta extrair a mensagem de erro específica (ex: "Email já está em uso")
        const errorMessage = errorData?.message || errorData?.title || "Erro ao criar conta.";
        toast(errorMessage);
      }
    } catch (error) {
      console.error('Erro no registo:', error);
      toast("Erro de conexão ao tentar registar.");
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = "Criar conta";
    }
  });
}

/* ===========================================================
   📊 KPIs - ESTATÍSTICAS
   =========================================================== */
function atualizarKPIs(chamados) {
  if (!Array.isArray(chamados)) {
    chamados = []; // Garante que é uma lista
  }
  
  const total = chamados.length;
  const abertos = chamados.filter(c => c.statusNome.toLowerCase() === 'aberto').length;
  const emAndamento = chamados.filter(c => c.statusNome.toLowerCase() === 'em andamento').length;
  const resolvidos = chamados.filter(c => c.statusNome.toLowerCase() === 'fechado' || c.statusNome.toLowerCase() === 'resolvido').length;
  const pendentes = chamados.filter(c => c.statusNome.toLowerCase() === 'aguardando resposta').length;
  
  // Atualiza os elementos do DOM (ignora se não encontrar o elemento)
  (document.getElementById('kpi-total') || {}).textContent = total;
  (document.getElementById('kpi-aberto') || {}).textContent = abertos;
  (document.getElementById('kpi-andamento') || {}).textContent = emAndamento;
  (document.getElementById('kpi-resolvido') || {}).textContent = resolvidos;
  (document.getElementById('kpi-pendente') || {}).textContent = pendentes;
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

  // --- INÍCIO DA NOVA LÓGICA DE FILTRO ---
  let url = `${API_BASE}/api/chamados`; // URL padrão (para Admin)
  const path = window.location.pathname;

  // Se for a página do usuário comum, filtrar pelos chamados dele
  if (path.endsWith("user-dashboard-desktop.html")) {
    const payload = decodeJWT(token);
    const nameIdentifierClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";

    if (payload && payload[nameIdentifierClaim]) {
      const userId = parseInt(payload[nameIdentifierClaim]);
      url = `${API_BASE}/api/chamados?solicitanteId=${userId}`; // Adiciona o filtro
      console.log("initDashboard: Página de usuário detectada. Buscando chamados para o Solicitante ID:", userId);
    } else {
      console.error("initDashboard: Não foi possível obter o ID do usuário (solicitante) do token.");
      return go("login-desktop.html"); // Falha ao ler o token, força o login
    }
  }
  // --- FIM DA NOVA LÓGICA DE FILTRO ---

  try {
    // Fazer chamada para a API (agora com a URL correta)
    const response = await fetch(url, { // <-- Usa a URL modificada
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
      atualizarKPIs(chamados); // <-- ADICIONE ESTA LINHA
      
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
   🆕 NOVO CHAMADO (Atualizado para API com IA)
   =========================================================== */
async function initNewTicket() {
  console.log("--- DEBUG: initNewTicket() FOI CHAMADA ---"); // Log 1
  const form = $("#new-ticket-form");
  if (!form) {
      console.error("--- ERRO: Formulário #new-ticket-form NÃO encontrado. ---"); // Log 2
      return;
  }
  console.log("--- DEBUG: Formulário #new-ticket-form encontrado. ---"); // Log 3
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    console.error("--- ERRO: Token não encontrado, redirecionando para login. ---"); // Log 4
    toast("Sessão expirada. Faça login novamente.");
    return go("login-desktop.html");
  }
  console.log("--- DEBUG: Token encontrado. Adicionando listener de submit... ---"); // Log 5
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    console.log("--- DEBUG: Evento SUBMIT disparado! ---"); // Log 6
    const descricao = $("#description").value.trim();
    console.log("--- DEBUG: Descrição lida:", descricao, "---"); // Log 7
    if (!descricao) {
      console.warn("--- AVISO: Descrição está vazia. ---"); // Log 8
      return toast("Por favor, descreva o seu problema.");
    }
    const submitButton = form.querySelector("button[type='submit']");
    if (!submitButton) {
        console.error("--- ERRO: Botão Submit não encontrado dentro do formulário! ---"); // Log 9
        return;
    }
    submitButton.disabled = true;
    submitButton.textContent = "Analisando...";
    console.log("--- DEBUG: Botão desabilitado. A iniciar fetch... ---"); // Log 10
    try {
      const response = await fetch(`${API_BASE}/api/chamados/analisar`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          descricaoProblema: descricao
        })
      });
      
      console.log("--- DEBUG: Resposta do fetch recebida. Status:", response.status, "---"); // Log 11
      if (response.ok) {
        const chamadoCriado = await response.json();
        toast(`Chamado #${chamadoCriado.id} criado e classificado com sucesso!`);
        go("user-dashboard-desktop.html");
      } else {
        const errorData = await response.json();
        toast(`Erro ao criar chamado: ${errorData.message || 'Tente novamente.'}`);
      }
    } catch (error) {
      console.error('--- ERRO: Falha no fetch ou na análise do JSON:', error, "---"); // Log 12
      toast("Erro de conexão ao criar o chamado.");
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = "Registrar Chamado";
    }
  });
  console.log("--- DEBUG: Listener de submit adicionado com sucesso. ---"); // Log 13
}

/* ===========================================================
   🧩 DETALHES DO CHAMADO (Atualizado para API v2)
   =========================================================== */
async function initTicketDetails() {
  console.log("--- DEBUG: Entrando em initTicketDetails ---");
  // Buscar o ID do chamado do sessionStorage
  const ticketId = sessionStorage.getItem('currentTicketId');
  if (!ticketId) {
    console.error("initTicketDetails: ID do chamado não encontrado no sessionStorage.");
    toast("Chamado não encontrado. Retornando ao dashboard.");
    // Tenta ir para o dashboard do técnico ou do user
    return go(document.referrer.includes("tecnico") ? "tecnico-dashboard.html" : "user-dashboard-desktop.html"); 
  }
  console.log("--- DEBUG: ID do chamado encontrado:", ticketId, "---");
  // Verificar se o token de autenticação existe
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    console.log("initTicketDetails: Token não encontrado, redirecionando para login.");
    toast("Sessão expirada. Faça login novamente.");
    return go("login-desktop.html");
  }
  console.log("--- DEBUG: Token encontrado, buscando detalhes da API ---");
  try {
    // Buscar os detalhes do chamado da API
    const url = `${API_BASE}/api/chamados/${ticketId}`;
    console.log("--- DEBUG: Fetching URL:", url, "---");
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    console.log("--- DEBUG: Resposta fetch Detalhes recebida. Status:", response.status, "---");
    if (response.ok) {
      const chamado = await response.json(); // A API retorna o objeto completo com $id/$values
      console.log("--- DEBUG: Detalhes do chamado recebidos:", chamado, "---");
      
      // Preencher os campos com os dados do chamado (leitura segura)
      $("#t-id").textContent = `#${chamado?.id ?? 'N/A'}`;
      $("#t-title").textContent = chamado?.titulo ?? 'Sem Título';
      $("#t-category").textContent = chamado?.categoria?.nome ?? 'N/A';
      $("#t-priority").textContent = chamado?.prioridade?.nome ?? 'N/A';
      $("#t-solicitante").textContent = chamado?.solicitante?.nomeCompleto ?? 'Desconhecido'; // Atualiza o solicitante
      
      // --- INÍCIO DO NOVO TRECHO ---
      // Preenche o nome do técnico
      const tecnicoElement = $("#t-tecnico"); 
      if (tecnicoElement) {
        // A API (GET /api/chamados/{id}) já inclui o objeto 'tecnico'
        // Se o objeto 'tecnico' for nulo (não atribuído), exibe 'Não atribuído'
        tecnicoElement.textContent = chamado?.tecnico?.nomeCompleto ?? 'Não atribuído';
      }
      // --- FIM DO NOVO TRECHO ---

      const statusNome = chamado?.status?.nome ?? 'N/A';
      const statusClass = String(statusNome).toLowerCase().replace(/\s+/g, '-');
      // Verifica se o elemento existe antes de tentar atualizar
      const statusElement = $("#t-status"); 
      if (statusElement) {
          statusElement.innerHTML = `<span class="badge status-${statusClass}">${statusNome}</span>`;
      } else {
          console.error("Elemento #t-status não encontrado no HTML.");
      }
      
      $("#t-desc").textContent = chamado?.descricao ?? 'Sem descrição';
      
      // Buscar e preencher os Status disponíveis
      try {
        const statusResponse = await fetch(`${API_BASE}/api/status`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        if (statusResponse.ok) {
          const statusList = await statusResponse.json();
          const statusSelect = $("#t-status-select");
          statusSelect.innerHTML = ""; // Limpa o "Carregando..."
          statusList.$values.forEach(status => {
            const option = document.createElement("option");
            option.value = status.id;
            option.textContent = status.nome;
            if (status.id === chamado.status.id) {
              option.selected = true; // Marca o status atual
            }
            statusSelect.appendChild(option);
          });
        }
      } catch (err) {
        console.error("Erro ao buscar lista de status:", err);
      }
      
      // Buscar e renderizar comentários (v2)
      fetchAndRenderComments(ticketId, token);
      // Configurar formulário de comentários (v2)
      const form = $("#comment-form");
      if (form) {
        // Remove listeners antigos para evitar duplicação (boa prática)
        form.replaceWith(form.cloneNode(true));
        const newForm = $("#comment-form");
        const submitButton = newForm.querySelector("button[type='submit']");
        const textArea = $("#comment-text");

        newForm.addEventListener("submit", async (e) => {
          e.preventDefault();
          const textoComentário = textArea.value.trim();
          if (!textoComentário) return toast("Digite um comentário.");

          const originalBtnText = submitButton.textContent;
          submitButton.disabled = true;
          submitButton.textContent = "Enviando...";

          try {
            const postResponse = await fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                Texto: textoComentário
              })
            });

            if (postResponse.ok) {
              const novoComentario = await postResponse.json();
              addCommentToUI(novoComentario); // Adiciona o novo comentário na tela
              textArea.value = ""; // Limpa o campo
            } else {
              toast("Erro ao enviar comentário. Tente novamente.");
            }
          } catch (error) {
            console.error("Erro no fetch de postar comentário:", error);
            toast("Erro de conexão ao enviar comentário.");
          } finally {
            submitButton.disabled = false;
            submitButton.textContent = originalBtnText;
          }
        });
      } else {
        console.error("Elemento #comment-form não encontrado no HTML.");
      }
      
      // Event listener para o botão de atualização de status
      const btnAtualizar = $("#btn-atualizar-status");
      if (btnAtualizar) {
        btnAtualizar.addEventListener("click", async () => {
          const novoStatusId = $("#t-status-select").value;
          const tecnicoId = chamado.tecnicoId; // Pega o tecnicoId do chamado atual
          console.log(`Atualizando chamado ${ticketId} para Status ID: ${novoStatusId}`);
          try {
            const updateResponse = await fetch(`${API_BASE}/api/chamados/${ticketId}`, {
              method: 'PUT',
              headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                statusId: parseInt(novoStatusId),
                tecnicoId: tecnicoId // Mantém o técnico atual
              })
            });
            if (updateResponse.ok) {
              toast("Status do chamado atualizado com sucesso!");
              initTicketDetails(); // Recarrega os detalhes da página
            } else {
              toast("Erro ao atualizar o status. Tente novamente.");
            }
          } catch (err) {
            console.error("Erro no fetch de atualização:", err);
            toast("Erro de conexão ao atualizar o status.");
          }
        });
      }

      
      // ===============================================
      // INÍCIO - LÓGICA DE ADMIN PARA REATRIBUIR TÉCNICO
      // ===============================================

      // 1. Verificar se o usuário é Admin (TipoUsuario 3)
      const payload = decodeJWT(token);
      const tipoUsuarioClaim = "TipoUsuario";
      const tipoUsuario = payload && payload[tipoUsuarioClaim] ? payload[tipoUsuarioClaim] : null;

      if (tipoUsuario === "3") {
        console.log("--- DEBUG: Usuário é Admin, habilitando controles ---");

        // 2. Tornar o bloco de admin visível
        const adminActionsBlock = $("#admin-actions");
        if (adminActionsBlock) {
          adminActionsBlock.style.display = "block";
        }

        // 3. Função para carregar os técnicos no dropdown
        const carregarTecnicos = async () => {
          const selectTecnico = $("#t-tecnico-select");
          if (!selectTecnico) return;

          try {
            const tecnicosResponse = await fetch(`${API_BASE}/api/usuarios/tecnicos`, {
              method: 'GET',
              headers: { 'Authorization': `Bearer ${token}` }
            });

            if (tecnicosResponse.ok) {
              const responseData = await tecnicosResponse.json();
              const tecnicosList = responseData.$values || responseData; // Lida com a estrutura $values
              
              selectTecnico.innerHTML = ""; // Limpa o "Carregando..."

              // Adiciona uma opção padrão "Selecione"
              const defaultOption = document.createElement("option");
              defaultOption.value = "";
              defaultOption.textContent = "Selecione para reatribuir...";
              selectTecnico.appendChild(defaultOption);

              // Adiciona os técnicos
              tecnicosList.forEach(tecnico => {
                const option = document.createElement("option");
                option.value = tecnico.id;
                option.textContent = tecnico.nomeCompleto;
                selectTecnico.appendChild(option);
              });

              // Pré-seleciona o técnico atual do chamado (se houver)
              if (chamado.tecnicoId) {
                selectTecnico.value = chamado.tecnicoId;
              }
              
            } else {
              selectTecnico.innerHTML = "<option value=''>Erro ao carregar técnicos</option>";
            }
          } catch (err) {
            console.error("Erro ao buscar lista de técnicos:", err);
            selectTecnico.innerHTML = "<option value=''>Erro de conexão</option>";
          }
        };

        // 4. Chamar a função para carregar os técnicos
        carregarTecnicos();

        // 5. Adicionar listener ao botão "Atualizar Técnico"
        const btnAtualizarTecnico = $("#btn-atualizar-tecnico");
        if (btnAtualizarTecnico) {
          btnAtualizarTecnico.addEventListener("click", async () => {
            
            const novoTecnicoId = $("#t-tecnico-select").value;
            // Pegar o StatusId ATUAL do chamado (que já carregamos na variável 'chamado')
            const statusIdAtual = chamado.status.id; 

            if (!novoTecnicoId) {
              toast("Por favor, selecione um técnico para atribuir.");
              return;
            }

            console.log(`Admin atualizando Chamado ${ticketId} - Novo Técnico ID: ${novoTecnicoId}, Status ID Atual: ${statusIdAtual}`);

            try {
              const updateResponse = await fetch(`${API_BASE}/api/chamados/${ticketId}`, {
                method: 'PUT',
                headers: {
                  'Authorization': `Bearer ${token}`,
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                  statusId: statusIdAtual, // <-- Envia o status atual
                  tecnicoId: parseInt(novoTecnicoId) // <-- Envia o novo técnico
                })
              });

              if (updateResponse.ok) {
                toast("Técnico atualizado com sucesso!");
                
                // Atualiza o nome do técnico na tela imediatamente
                const spanTecnicoNome = $("#t-tecnico");
                if (spanTecnicoNome) {
                   const select = $("#t-tecnico-select");
                   spanTecnicoNome.textContent = select.options[select.selectedIndex].text;
                }
                // Recarrega os dados da página para garantir consistência
                initTicketDetails();
              } else {
                toast("Erro ao atualizar o técnico. Tente novamente.");
              }
            } catch (err) {
              console.error("Erro no fetch de atualização do técnico:", err);
              toast("Erro de conexão ao atualizar o técnico.");
            }
          });
        }
      }
      // ===============================================
      // FIM - LÓGICA DE ADMIN
      // ===============================================

    } else if (response.status === 401) {
      console.log("initTicketDetails: Token inválido (401), redirecionando para login.");
      sessionStorage.removeItem('authToken');
      toast("Sessão expirada. Faça login novamente.");
      return go("login-desktop.html");
    } else if (response.status === 404) {
      console.error("initTicketDetails: Chamado não encontrado (404).");
      toast("Chamado não encontrado.");
      return go(document.referrer.includes("tecnico") ? "tecnico-dashboard.html" : "user-dashboard-desktop.html");
    } else {
      console.error('initTicketDetails: Erro da API:', response.status, response.statusText);
      toast("Erro ao carregar detalhes do chamado.");
    }
  } catch (error) {
    console.error('initTicketDetails: Erro de rede:', error);
    toast("Erro ao carregar detalhes do chamado.");
  }
  console.log("--- DEBUG: Saindo de initTicketDetails ---");
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

  const voltarBtn = $("#btn-voltar-dashboard");
  if (voltarBtn) {
    voltarBtn.addEventListener("click", () => {
      // Tenta descobrir para qual dashboard voltar
      const token = sessionStorage.getItem('authToken');
      if (!token) {
        return go("login-desktop.html"); // Segurança: se não há token, vai para o login
      }
      
      const payload = decodeJWT(token);
      const nameIdentifierClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name";
      const tipoUsuarioClaim = "TipoUsuario"; 
      
      let tipoUsuario = 1; // Padrão: Usuário Comum
      if (payload && payload[tipoUsuarioClaim]) {
        tipoUsuario = parseInt(payload[tipoUsuarioClaim]);
      }
      // Redireciona com base no TipoUsuario lido do token
      if (tipoUsuario === 3) {
        go("admin-dashboard-desktop.html");
      } else if (tipoUsuario === 2) {
        go("tecnico-dashboard.html");
      } else {
        go("user-dashboard-desktop.html");
      }
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

/* Função para atualizar saudação do usuário no cabeçalho */
function atualizarSaudacaoUsuario() {
  // Recuperar o token do sessionStorage
  const token = sessionStorage.getItem('authToken');
  
  // Se não houver token, sair da função
  if (!token) return;
  
  // Usar decodeJWT para obter o payload do token
  const payload = decodeJWT(token);
  
  // Extrair o nome completo do utilizador da claim name
  const nameClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name";
  const nomeUsuario = payload && payload[nameClaim] ? payload[nameClaim] : 'Utilizador';
  
  // Encontrar o elemento HTML no cabeçalho que deve exibir a saudação
  const userInfoElement = document.querySelector(".header .user-info");
  
  // Se o elemento for encontrado, atualizar o seu textContent
  if (userInfoElement) {
    userInfoElement.textContent = `Olá, ${nomeUsuario}`;
  }
}

/* Função principal do painel do técnico */
async function initTecnicoDashboard() {
  console.log("--- DEBUG: Entrando em initTecnicoDashboard ---"); // Log 1
  // Verificar autenticação
  const token = sessionStorage.getItem("authToken");
  if (!token) {
    console.log("--- DEBUG: Token NÃO encontrado, redirecionando para login ---"); // Log 2
    go("login-desktop.html");
    return;
  }
  console.log("--- DEBUG: Token encontrado ---"); // Log 3
  // Decodificar token para obter ID do técnico
  const payload = decodeJWT(token);
  let tecnicoId = null; // Inicializa como null
  const nameIdentifierClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";
  if (payload && payload[nameIdentifierClaim]) { // <-- Acede usando a chave correta
    tecnicoId = parseInt(payload[nameIdentifierClaim]); // <-- Usa a chave correta
    console.log("--- DEBUG: ID do técnico obtido do token:", tecnicoId, "---"); // Log 4
  } else {
    console.error("--- ERRO: Não foi possível obter o ID ('nameidentifier') do técnico do token. Payload:", payload, "---"); // Mensagem de erro mais específica
    // Considerar redirecionar ou mostrar erro, mas por agora continuamos para ver as chamadas fetch
  }
  // Headers para as requisições
  const headers = {
    "Authorization": `Bearer ${token}`,
    "Content-Type": "application/json"
  };
  console.log("--- DEBUG: Headers para fetch definidos ---"); // Log 6
  try {
    // 1. Buscar chamados não atribuídos
    const urlFila = `${API_BASE}/api/chamados?tecnicoId=0&statusId=1`;
    console.log("--- DEBUG: Iniciando fetch para FILA:", urlFila, "---"); // Log 7
    const filaResponse = await fetch(urlFila, { method: "GET", headers: headers });
    console.log("--- DEBUG: Resposta fetch FILA recebida. Status:", filaResponse.status, "---"); // Log 8
    if (filaResponse.status === 401) throw new Error("Token expirado (Fila)");
    if (!filaResponse.ok) throw new Error(`Erro API (Fila): ${filaResponse.status}`);
    const chamadosFila = await filaResponse.json();
    console.log("--- DEBUG: Dados da FILA recebidos:", chamadosFila, "---"); // Log 9
    // Renderizar tabela da fila
    const tabelaFila = $("#tabela-fila-chamados tbody");
    if (tabelaFila) {
      console.log("--- DEBUG: Renderizando tabela da FILA ---"); // Log 10
      renderTabelaFila(chamadosFila.$values || chamadosFila, tabelaFila); // Passa $values ou a lista
    } else {
      console.error("--- ERRO: tbody da tabela da FILA não encontrado ---"); // Log 11
    }
    // 2. Buscar chamados atribuídos ao técnico
    // Garantir que tecnicoId é um número antes de usar na URL
    if (typeof tecnicoId !== 'number' || isNaN(tecnicoId)) {
        console.error("--- ERRO: tecnicoId inválido para buscar 'Meus Chamados'. Abortando. ---"); // Log 12
        return; // Interrompe se não temos ID válido
    }
    const urlMeus = `${API_BASE}/api/chamados?tecnicoId=${tecnicoId}`;
    console.log("--- DEBUG: Iniciando fetch para MEUS CHAMADOS:", urlMeus, "---"); // Log 13
    const meusResponse = await fetch(urlMeus, { method: "GET", headers: headers });
    console.log("--- DEBUG: Resposta fetch MEUS CHAMADOS recebida. Status:", meusResponse.status, "---"); // Log 14
    if (meusResponse.status === 401) throw new Error("Token expirado (Meus Chamados)");
    if (!meusResponse.ok) throw new Error(`Erro API (Meus Chamados): ${meusResponse.status}`);
    const meusChamados = await meusResponse.json();
    console.log("--- DEBUG: Dados de MEUS CHAMADOS recebidos:", meusChamados, "---"); // Log 15
    
    // Combina as listas para os KPIs
    const todosChamadosDoTecnico = (meusChamados.$values || meusChamados)
        .concat(chamadosFila.$values || chamadosFila);
    atualizarKPIs(todosChamadosDoTecnico); // <-- ADICIONE ESTA LINHA
    
    // Renderizar tabela dos meus chamados
    const tabelaMeus = $("#tabela-meus-chamados tbody");
    if (tabelaMeus) {
      console.log("--- DEBUG: Renderizando tabela MEUS CHAMADOS ---"); // Log 16
      renderTabelaMeusChamados(meusChamados.$values || meusChamados, tabelaMeus); // Passa $values ou a lista
    } else {
      console.error("--- ERRO: tbody da tabela MEUS CHAMADOS não encontrado ---"); // Log 17
    }
  } catch (error) {
    console.error("--- ERRO GERAL em initTecnicoDashboard:", error, "---"); // Log 18
    if (error.message.includes("Token expirado")) {
        sessionStorage.removeItem("authToken");
        toast("Sessão expirada. Faça login novamente.");
        go("login-desktop.html");
    } else {
        toast("Erro ao carregar dados. Verifique o console para detalhes.");
    }
  }
  console.log("--- DEBUG: Saindo de initTecnicoDashboard ---"); // Log 19
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
      const prioridadeNome = chamado?.prioridadeNome ?? 'N/A';
      const dataAbertura = 'Hoje'; // TODO: Adicionar ao DTO quando disponível

      tr.innerHTML = `
        <td>${chamadoId === '#ERR' ? '#ERR' : `#${chamadoId}`}</td>
        <td>${titulo}</td>
        <td>${categoriaNome}</td>
        <td><span class="badge priority-normal">${prioridadeNome}</span></td>
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
      const prioridadeNome = chamado?.prioridadeNome ?? 'N/A';

      const statusClass = String(statusNome).toLowerCase().replace(/\s+/g, '-');

      tr.innerHTML = `
        <td>${chamadoId === '#ERR' ? '#ERR' : `#${chamadoId}`}</td>
        <td>${titulo}</td>
        <td>${categoriaNome}</td>
        <td><span class="badge status-${statusClass}">${statusNome}</span></td>
        <td><span class="badge priority-normal">${prioridadeNome}</span></td>
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
        go("tecnico-detalhes-desktop.html");
      } else {
        console.error("Tentativa de ver detalhes com ID inválido.");
        toast("Erro ao tentar abrir detalhes do chamado.");
      }
    });
  });
}

/* Função para assumir um chamado */
async function assumirChamado(chamadoId) {
  try {
    console.log("Assumindo chamado:", chamadoId);
    
    // Recuperar o token JWT do sessionStorage
    const token = sessionStorage.getItem('authToken');
    if (!token) {
      toast("Erro: Token de autenticação não encontrado. Faça login novamente.");
      return;
    }
    
    // Decodificar o token para obter o ID do técnico logado
    const payload = decodeJWT(token);
    if (!payload) {
      toast("Erro: Token inválido. Faça login novamente.");
      return;
    }
    
    // Obter o ID do técnico da claim nameidentifier
    const nameIdentifierClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";
    const idDoTecnicoLogado = payload[nameIdentifierClaim];
    
    if (!idDoTecnicoLogado) {
      toast("Erro: Não foi possível obter o ID do técnico. Faça login novamente.");
      return;
    }
    
    // Definir o novo status ID como 2 (Em Andamento)
    const novoStatusId = 2;
    
    // Montar o objeto body para a requisição PUT
    const body = {
      statusId: novoStatusId,
      tecnicoId: parseInt(idDoTecnicoLogado)
    };
    
    console.log("Enviando requisição para assumir chamado:", { chamadoId, body });
    
    // Fazer a chamada fetch para o endpoint PUT
    const response = await fetch(`${API_BASE}/api/chamados/${chamadoId}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    });
    
    // Verificar a resposta
    if (response.ok) {
      toast("Chamado assumido com sucesso!");
      // Recarregar ambas as tabelas com os dados atualizados
      initTecnicoDashboard();
    } else if (response.status === 401) {
      // Token expirado
      sessionStorage.removeItem('authToken');
      toast("Sessão expirada. Faça login novamente.");
      go("login-desktop.html");
    } else {
      // Outros erros (400, 404, 500)
      console.error('Erro ao assumir chamado:', response.status, response.statusText);
      toast("Erro ao tentar assumir o chamado.");
    }
    
  } catch (error) {
    console.error('Erro na função assumirChamado:', error);
    toast("Erro ao tentar assumir o chamado.");
  }
}

/* ===========================================================
   💬 COMENTÁRIOS (v2 - API)
   =========================================================== */

/**
 * Busca comentários da API e chama a função para renderizá-los.
 * @param {string} ticketId - O ID do chamado.
 * @param {string} token - O token JWT.
 */
async function fetchAndRenderComments(ticketId, token) {
  const list = $("#comments");
  if (!list) return;

  list.innerHTML = `<li class="help">Carregando comentários...</li>`;

  try {
    const response = await fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.ok) {
      const responseData = await response.json();
      const comentarios = responseData.$values || responseData; // Lida com $values
      renderCommentsUI(comentarios);
    } else {
      list.innerHTML = `<li class="help" style="color:var(--danger)">Erro ao carregar comentários.</li>`;
    }
  } catch (error) {
    console.error("Erro no fetch de comentários:", error);
    list.innerHTML = `<li class="help" style="color:var(--danger)">Erro de conexão ao buscar comentários.</li>`;
  }
}

/**
 * Renderiza a lista de comentários na UI.
 * @param {Array} comentarios - A lista de objetos de comentário.
 */
function renderCommentsUI(comentarios) {
  const list = $("#comments");
  if (!list) return;

  list.innerHTML = ""; // Limpa o "Carregando..."

  if (!Array.isArray(comentarios) || comentarios.length === 0) {
    list.innerHTML = `<li class="help">Nenhum comentário até o momento.</li>`;
    return;
  }

  comentarios.forEach((comentario) => {
    addCommentToUI(comentario);
  });
}

/**
 * Adiciona um único comentário ao final da lista na UI.
 * @param {object} comentario - O objeto de comentário (formato ComentarioResponseDto).
 */
function addCommentToUI(comentario) {
  const list = $("#comments");
  if (!list) return;

  // Se a mensagem "Nenhum comentário" estiver presente, remove-a
  const helpText = list.querySelector(".help");
  if (helpText) {
    list.innerHTML = "";
  }

  const li = document.createElement("li");
  li.className = "card"; // Reutiliza a classe 'card' para um bom estilo
  li.style.marginBottom = "10px"; // Adiciona um espaçamento

  const autor = comentario.usuarioNome || 'Usuário';
  const data = new Date(comentario.dataCriacao).toLocaleString('pt-BR');
  const texto = comentario.texto || 'Comentário sem texto';

  // Usar .textContent para segurança contra XSS
  const strong = document.createElement("strong");
  strong.textContent = `${autor} `;
  
  const spanData = document.createElement("span");
  spanData.style.color = "var(--muted)";
  spanData.style.fontSize = "12px";
  spanData.textContent = `— ${data}`;
  
  const pTexto = document.createElement("p");
  pTexto.style.marginTop = "4px";
  pTexto.textContent = texto;

  li.appendChild(strong);
  li.appendChild(spanData);
  li.appendChild(pTexto);
  
  list.appendChild(li);
}

/* ===========================================================
   🎫 PÁGINA DE GERENCIAMENTO DE TICKETS (ADMIN)
   =========================================================== */
async function initAdminTicketsPage() {
  console.log("--- DEBUG: Entrando em initAdminTicketsPage ---");
  const token = sessionStorage.getItem("authToken");
  if (!token) {
    go("login-desktop.html");
    return;
  }

  // Referências aos elementos do DOM
  const selectStatus = $("#flt-status-admin");
  const selectPrioridade = $("#flt-prio-admin");
  const inputSearch = $("#flt-search-admin");
  const tableBody = $("#tickets-body-admin tbody");

  if (!selectStatus || !selectPrioridade || !inputSearch || !tableBody) {
    console.error("Erro: Elementos de filtro ou tabela não encontrados.");
    return;
  }

  /**
   * Preenche os dropdowns de Status e Prioridade com dados da API.
   */
  async function populateFilterDropdowns() {
    try {
      // 1. Buscar Status
      const statusResponse = await fetch(`${API_BASE}/api/status`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (statusResponse.ok) {
        const statusList = await statusResponse.json();
        (statusList.$values || statusList).forEach(status => {
          const option = document.createElement("option");
          option.value = status.id;
          option.textContent = status.nome;
          selectStatus.appendChild(option);
        });
      }

      // 2. Buscar Prioridades
      const prioResponse = await fetch(`${API_BASE}/api/prioridades`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (prioResponse.ok) {
        const prioList = await prioResponse.json();
        (prioList.$values || prioList).forEach(prio => {
          const option = document.createElement("option");
          option.value = prio.id;
          option.textContent = prio.nome;
          selectPrioridade.appendChild(option);
        });
      }
    } catch (error) {
      console.error("Erro ao popular dropdowns:", error);
    }
  }

  /**
   * Busca os chamados na API com base nos filtros e renderiza a tabela.
   */
  async function fetchAndRenderAdminTickets() {
    // 1. Obter valores dos filtros
    const statusId = selectStatus.value;
    const prioridadeId = selectPrioridade.value;
    const termoBusca = inputSearch.value.trim();

    // 2. Construir a URL com parâmetros de busca
    const params = new URLSearchParams();
    if (statusId) params.append("statusId", statusId);
    if (prioridadeId) params.append("prioridadeId", prioridadeId);
    if (termoBusca) params.append("termoBusca", termoBusca);

    const url = `${API_BASE}/api/chamados?${params.toString()}`;
    console.log("--- DEBUG: Buscando URL de filtros:", url, "---");

    tableBody.innerHTML = `<tr><td colspan="6" style="text-align:center;">Carregando...</td></tr>`;

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const responseData = await response.json();
        const chamados = responseData.$values || responseData;
        // Reutiliza a função de renderização de tabela que já existe!
        renderTicketsTable(chamados, tableBody); 
      } else {
         tableBody.innerHTML = `<tr><td colspan="6" style="text-align:center;color:var(--danger)">Erro ao carregar chamados.</td></tr>`;
      }
    } catch (error) {
      console.error("Erro no fetch de chamados (admin):", error);
      tableBody.innerHTML = `<tr><td colspan="6" style="text-align:center;color:var(--danger)">Erro de conexão.</td></tr>`;
    }
  }

  // 3. Criar uma versão "debounce" da função de busca para o campo de texto
  const debouncedFetch = debounce(fetchAndRenderAdminTickets, 500);

  // 4. Adicionar Event Listeners
  selectStatus.addEventListener("change", fetchAndRenderAdminTickets);
  selectPrioridade.addEventListener("change", fetchAndRenderAdminTickets);
  inputSearch.addEventListener("keyup", debouncedFetch);

  // 5. Carga Inicial
  await populateFilterDropdowns(); // Espera os filtros carregarem
  fetchAndRenderAdminTickets();  // Busca os chamados
}

/* ===========================================================
   🎨 SELETOR DE TEMA (DARK MODE)
   =========================================================== */
function initThemeSwitcher() {
  const toggle = $("#theme-toggle");
  if (!toggle) {
    // Não está na página de configurações, não faz nada.
    return;
  }

  // 1. Definir o estado inicial do toggle
  const currentTheme = load('theme-preference', 'light');
  toggle.checked = (currentTheme === 'dark');

  // 2. Adicionar o listener para mudanças
  toggle.addEventListener('change', () => {
    if (toggle.checked) {
      // Mudar para Dark Mode
      document.body.classList.add('dark-mode');
      save('theme-preference', 'dark'); // Usa a função 'save' existente
    } else {
      // Mudar para Light Mode
      document.body.classList.remove('dark-mode');
      save('theme-preference', 'light');
    }
  });
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
   🧑‍🔧 CADASTRAR TÉCNICO (ADMIN)
   =========================================================== */
async function initCadastrarTecnico() {
  console.log("--- DEBUG: Entrando em initCadastrarTecnico ---");
  
  // a. Recuperar o token do sessionStorage e usar decodeJWT para ler o payload
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    toast("Acesso negado. Token não encontrado.");
    go("login-desktop.html");
    return;
  }

  const payload = decodeJWT(token);
  if (!payload) {
    toast("Acesso negado. Token inválido.");
    go("login-desktop.html");
    return;
  }

  // b. Verificar a permissão de Admin
  const tipoUsuario = payload && payload["TipoUsuario"] ? payload["TipoUsuario"] : null;
  
  console.log("--- DEBUG: TipoUsuario do token:", tipoUsuario);
  console.log("--- DEBUG: Payload completo:", payload);
  
  if (tipoUsuario !== "3") {
    toast("Acesso negado. Apenas administradores podem cadastrar técnicos.");
    go("login-desktop.html");
    return;
  }

  // c. Preencher o Dropdown de Especialidades
  try {
    console.log("--- DEBUG: Carregando categorias ---");
    const response = await fetch(`${API_BASE}/api/categorias`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (response.ok) {
      const responseData = await response.json();
      const categoriasList = responseData.$values || responseData; // Extrai de $values
      console.log("--- DEBUG: Resposta completa:", responseData);
      console.log("--- DEBUG: Categorias extraídas:", categoriasList);
      
      const selectEspecialidade = $("#t-especialidade");
      if (selectEspecialidade) {
        selectEspecialidade.innerHTML = ""; // Limpa o "Carregando..."
        
        // Verifica se categoriasList é realmente uma lista antes de iterar
        if (Array.isArray(categoriasList)) {
          // Adiciona uma opção "Selecione"
          const defaultOption = document.createElement("option");
          defaultOption.value = "";
          defaultOption.textContent = "Selecione uma especialidade";
          selectEspecialidade.appendChild(defaultOption);
          
          // Preenche com as categorias
          categoriasList.forEach(categoria => {
            const option = document.createElement("option");
            option.value = categoria.id;
            option.textContent = categoria.nome;
            selectEspecialidade.appendChild(option);
          });
        } else {
          console.error("A resposta de /api/categorias não é uma lista válida:", categoriasList);
          toast("Erro ao processar a lista de especialidades.");
        }
      }
    } else {
      console.error("Erro ao carregar categorias:", response.status);
      toast("Erro ao carregar especialidades.");
    }
  } catch (error) {
    console.error("Erro ao carregar categorias:", error);
    toast("Erro ao carregar especialidades.");
  }

  // d. Adicionar o Listener do Formulário
  const form = $("#register-tecnico-form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      
      console.log("--- DEBUG: Formulário submetido ---");
      
      // Ler os valores dos campos
      const nome = $("#t-nome")?.value?.trim();
      const email = $("#t-email")?.value?.trim();
      const senha = $("#t-senha")?.value;
      const confirmarSenha = $("#t-confirmar-senha")?.value;
      const especialidadeId = $("#t-especialidade")?.value;
      
      // Validações básicas
      if (!nome || !email || !senha || !confirmarSenha || !especialidadeId) {
        toast("Por favor, preencha todos os campos.");
        return;
      }
      
      // Verificar se as senhas coincidem
      if (senha !== confirmarSenha) {
        toast("As senhas não coincidem.");
        return;
      }
      
      // Preparar dados para envio
      const dadosTecnico = {
        NomeCompleto: nome,
        Email: email,
        Senha: senha,
        EspecialidadeCategoriaId: parseInt(especialidadeId)
      };
      
      console.log("--- DEBUG: Dados do técnico:", dadosTecnico);
      
      try {
        // Fazer chamada para a API
        const response = await fetch(`${API_BASE}/api/usuarios/registrar-tecnico`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(dadosTecnico)
        });
        
        if (response.ok) {
          const resultado = await response.json();
          console.log("--- DEBUG: Técnico registado com sucesso:", resultado);
          toast("Técnico registado com sucesso!");
          
          // Limpar o formulário
          form.reset();
          $("#t-especialidade").selectedIndex = 0;
        } else {
          const errorData = await response.json().catch(() => ({}));
          console.error("Erro ao registar técnico:", response.status, errorData);
          
          if (errorData.message) {
            toast(`Erro: ${errorData.message}`);
          } else if (response.status === 400) {
            toast("Dados inválidos. Verifique os campos e tente novamente.");
          } else if (response.status === 401) {
            toast("Acesso negado. Faça login novamente.");
            go("login-desktop.html");
          } else {
            toast("Erro ao registar técnico. Tente novamente.");
          }
        }
      } catch (error) {
        console.error("Erro na requisição:", error);
        toast("Erro de conexão. Verifique sua internet e tente novamente.");
      }
    });
  }
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
  } else if (path.endsWith("esqueci-senha-desktop.html")) {
    initEsqueciSenha();
  } else if (path.endsWith("resetar-senha-desktop.html")) {
    initResetarSenha();
  } else if (path.endsWith("admin-dashboard-desktop.html")) {
    initDashboard();
    initConfig();
    atualizarSaudacaoUsuario(); // <-- CHAMADA ADICIONADA
  } else if (path.endsWith("user-dashboard-desktop.html")) {
    initDashboard();
    initConfig();
    atualizarSaudacaoUsuario(); // <-- CHAMADA ADICIONADA
  } else if (path.endsWith("cadastro-desktop.html")) {
    initRegister();
  } else if (path.endsWith("novo-ticket-desktop.html")) {
    initNewTicket();
  } else if (path.endsWith("ticket-detalhes-desktop.html")) {
    initTicketDetails();
  } else if (path.endsWith("tecnico-detalhes-desktop.html")) {
    initTicketDetails(); // Reutiliza a mesma função de detalhes
  } else if (path.endsWith("config-desktop.html")) { // Página do Utilizador Comum
    initConfig();
    atualizarSaudacaoUsuario();
    initThemeSwitcher(); // <-- ADICIONAR ESTA LINHA
  } else if (path.endsWith("tecnico-config-desktop.html")) { // Página do Técnico
    initConfig();
    atualizarSaudacaoUsuario();
    initThemeSwitcher(); // <-- ADICIONAR ESTA LINHA
  } else if (path.endsWith("tecnico-dashboard.html")) {
    initTecnicoDashboard(); 
    initConfig(); // Mantém o logout
    atualizarSaudacaoUsuario(); // <-- CHAMADA ADICIONADA
  } else if (path.endsWith("admin-cadastrar-tecnico.html")) {
    initCadastrarTecnico();
    initConfig(); // Mantém o logout
  } else if (path.endsWith("admin-tickets-desktop.html")) { // <-- ADICIONAR ESTE BLOCO
    initAdminTicketsPage();
    initConfig(); // Para o logout funcionar
  }
});

