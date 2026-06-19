// ── TELA 1.1: Cadastro — Passo 1 (Produtor e produto) ──

/**
 * Monta a estrutura HTML da tela de passo 1 e a insere em #app.
 */
function construirTelaPasso1() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-passo1";
  screen.className = "screen";

  screen.innerHTML = `
    <button class="btn-voltar" id="p1-voltar">← Voltar</button>
    <p class="progresso">Passo 1 de 3</p>
    <p class="titulo-tela">Produtor e produto</p>
    <p class="subtitulo-tela">Informe o CPF do produtor e o produto do excedente.</p>

    <div class="form-group">
      <label class="form-label" for="p1-cpf">CPF do produtor</label>
      <input type="text" id="p1-cpf" placeholder="000.000.000-00">
      <p class="label-erro" id="p1-cpf-erro">✗ Produtor não encontrado.</p>
      <p class="label-sucesso-inline" id="p1-cpf-sucesso"></p>
    </div>

    <div class="form-group">
      <label class="form-label" for="p1-produto">Produto</label>
      <select id="p1-produto">
        <option value="">Selecione um produto</option>
      </select>
      <p class="label-erro" id="p1-produto-erro">Selecione um produto.</p>
    </div>

    <button class="btn-primario" id="p1-continuar">Continuar</button>
  `;

  app.appendChild(screen);

  carregarProdutos();

  screen.querySelector("#p1-voltar").addEventListener("click", () => {
    App.navegarPara("menu");
  });

  const inputCpf = screen.querySelector("#p1-cpf");
  inputCpf.addEventListener("input", () => {
    inputCpf.value = aplicarMascaraCpf(inputCpf.value);
  });
  inputCpf.addEventListener("blur", validarProdutor);

  screen.querySelector("#p1-continuar").addEventListener("click", avancarParaPasso2);
}

/**
 * Remove caracteres não numéricos e formata como CPF (000.000.000-00).
 * @param {string} valor - Valor digitado pelo usuário.
 * @returns {string} Valor formatado.
 */
function aplicarMascaraCpf(valor) {
  const digitos = valor.replace(/\D/g, "").slice(0, 11);

  return digitos
    .replace(/(\d{3})(\d)/, "$1.$2")
    .replace(/(\d{3})(\d)/, "$1.$2")
    .replace(/(\d{3})(\d{1,2})$/, "$1-$2");
}

/**
 * Busca a lista de produtos disponíveis na API e popula o <select>.
 */
async function carregarProdutos() {
  const select = document.querySelector("#screen-passo1 #p1-produto");

  try {
    const res = await fetch("/api/produtos");
    const produtos = await res.json();

    produtos.forEach(({ nome }) => {
      const opcao = document.createElement("option");
      opcao.value = nome;
      opcao.textContent = nome;
      select.appendChild(opcao);
    });
  } catch (erro) {
    console.error("Não foi possível carregar os produtos.", erro);
  }
}

/**
 * Busca o produtor correspondente ao CPF informado e atualiza
 * os feedbacks visuais (sucesso ou erro) e o estado da sessão.
 */
async function validarProdutor() {
  const screen = document.getElementById("screen-passo1");
  const input = screen.querySelector("#p1-cpf");
  const erro = screen.querySelector("#p1-cpf-erro");
  const sucesso = screen.querySelector("#p1-cpf-sucesso");

  const valor = input.value.trim();
  erro.classList.remove("visivel");
  sucesso.classList.remove("visivel");
  input.classList.remove("erro-campo");

  if (!valor) {
    return;
  }

  try {
    const res = await fetch(`/api/produtores?cpf=${encodeURIComponent(valor)}`);
    if (!res.ok) {
      throw new Error("Produtor não encontrado.");
    }
    const data = await res.json();

    App.session.cpf = valor;
    App.session.produtor_nome = data.nome;
    sucesso.textContent = `✓ Produtor: ${data.nome}`;
    sucesso.classList.add("visivel");
  } catch {
    delete App.session.cpf;
    delete App.session.produtor_nome;
    input.classList.add("erro-campo");
    erro.classList.add("visivel");
  }
}

/**
 * Valida os campos do passo 1 e, se corretos, avança para o passo 2.
 */
function avancarParaPasso2() {
  const screen = document.getElementById("screen-passo1");
  const selectProduto = screen.querySelector("#p1-produto");
  const erroProduto = screen.querySelector("#p1-produto-erro");

  erroProduto.classList.remove("visivel");

  let valido = true;

  if (!App.session.produtor_nome) {
    valido = false;
    screen.querySelector("#p1-cpf-erro").classList.add("visivel");
    screen.querySelector("#p1-cpf").classList.add("erro-campo");
  }

  if (!selectProduto.value) {
    valido = false;
    erroProduto.classList.add("visivel");
  }

  if (!valido) {
    return;
  }

  App.session.produto = selectProduto.value;
  App.navegarPara("passo2");
}

construirTelaPasso1();

App.registrarTela("passo1", {
  /**
   * Reinicia o formulário e a sessão sempre que esta tela é exibida.
   */
  onShow() {
    App.limparSession();

    const screen = document.getElementById("screen-passo1");
    screen.querySelector("#p1-cpf").value = "";
    screen.querySelector("#p1-cpf").classList.remove("erro-campo");
    screen.querySelector("#p1-produto").value = "";
    screen.querySelector("#p1-cpf-erro").classList.remove("visivel");
    screen.querySelector("#p1-cpf-sucesso").classList.remove("visivel");
    screen.querySelector("#p1-produto-erro").classList.remove("visivel");
  },
});
