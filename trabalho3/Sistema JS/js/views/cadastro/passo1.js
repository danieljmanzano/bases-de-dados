// ── TELA 1.1: Cadastro — Passo 1 (Produtor e produto) ──

/**
 * Monta a estrutura HTML da tela de passo 1 e a insere em #app.
 */
function construirTelaPasso1() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-passo1";
  screen.className = "screen";

  const opcoesProduto = PRODUTOS
    .map((nome) => `<option value="${nome}">${nome}</option>`)
    .join("");
  // TODO: GET /api/produtos
  // Resposta esperada: [{ nome: string }] — usar para popular este <select>

  screen.innerHTML = `
    <button class="btn-voltar" id="p1-voltar">← Voltar</button>
    <p class="progresso">Passo 1 de 3</p>
    <p class="titulo-tela">Produtor e produto</p>
    <p class="subtitulo-tela">Informe o CPF/CNPJ do produtor e o produto do excedente.</p>

    <div class="form-group">
      <label class="form-label" for="p1-cpf-cnpj">CPF/CNPJ do produtor</label>
      <input type="text" id="p1-cpf-cnpj" placeholder="000.000.000-00 ou 00.000.000/0001-00">
      <p class="label-erro" id="p1-cpf-erro">✗ Produtor não encontrado.</p>
      <p class="label-sucesso-inline" id="p1-cpf-sucesso"></p>
    </div>

    <div class="form-group">
      <label class="form-label" for="p1-produto">Produto</label>
      <select id="p1-produto">
        <option value="">Selecione um produto</option>
        ${opcoesProduto}
      </select>
      <p class="label-erro" id="p1-produto-erro">Selecione um produto.</p>
    </div>

    <button class="btn-primario" id="p1-continuar">Continuar</button>
  `;

  app.appendChild(screen);

  screen.querySelector("#p1-voltar").addEventListener("click", () => {
    App.navegarPara("menu");
  });

  const inputCpf = screen.querySelector("#p1-cpf-cnpj");
  inputCpf.addEventListener("input", () => {
    inputCpf.value = aplicarMascaraCpfCnpj(inputCpf.value);
  });
  inputCpf.addEventListener("blur", validarProdutor);

  screen.querySelector("#p1-continuar").addEventListener("click", avancarParaPasso2);
}

/**
 * Remove caracteres não numéricos e formata como CPF (000.000.000-00)
 * ou CNPJ (00.000.000/0000-00), de acordo com a quantidade de dígitos.
 * @param {string} valor - Valor digitado pelo usuário.
 * @returns {string} Valor formatado.
 */
function aplicarMascaraCpfCnpj(valor) {
  const digitos = valor.replace(/\D/g, "").slice(0, 14);

  if (digitos.length <= 11) {
    return digitos
      .replace(/(\d{3})(\d)/, "$1.$2")
      .replace(/(\d{3})(\d)/, "$1.$2")
      .replace(/(\d{3})(\d{1,2})$/, "$1-$2");
  }

  return digitos
    .replace(/(\d{2})(\d)/, "$1.$2")
    .replace(/(\d{3})(\d)/, "$1.$2")
    .replace(/(\d{3})(\d)/, "$1/$2")
    .replace(/(\d{4})(\d{1,2})$/, "$1-$2");
}

/**
 * Busca o produtor correspondente ao CPF/CNPJ informado e atualiza
 * os feedbacks visuais (sucesso ou erro) e o estado da sessão.
 */
function validarProdutor() {
  const screen = document.getElementById("screen-passo1");
  const input = screen.querySelector("#p1-cpf-cnpj");
  const erro = screen.querySelector("#p1-cpf-erro");
  const sucesso = screen.querySelector("#p1-cpf-sucesso");

  const valor = input.value.trim();
  erro.classList.remove("visivel");
  sucesso.classList.remove("visivel");
  input.classList.remove("erro-campo");

  if (!valor) {
    return;
  }

  // TODO: await fetch(`/api/produtores?cpf_cnpj=${valor}`)
  //   const data = await res.json();
  //   if (!res.ok) { /* produtor não encontrado */ }
  const nomeProdutor = PRODUTORES[valor];

  if (nomeProdutor) {
    App.session.cpf_cnpj = valor;
    App.session.produtor_nome = nomeProdutor;
    sucesso.textContent = `✓ Produtor: ${nomeProdutor}`;
    sucesso.classList.add("visivel");
  } else {
    delete App.session.cpf_cnpj;
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
    screen.querySelector("#p1-cpf-cnpj").classList.add("erro-campo");
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
    screen.querySelector("#p1-cpf-cnpj").value = "";
    screen.querySelector("#p1-cpf-cnpj").classList.remove("erro-campo");
    screen.querySelector("#p1-produto").value = "";
    screen.querySelector("#p1-cpf-erro").classList.remove("visivel");
    screen.querySelector("#p1-cpf-sucesso").classList.remove("visivel");
    screen.querySelector("#p1-produto-erro").classList.remove("visivel");
  },
});
