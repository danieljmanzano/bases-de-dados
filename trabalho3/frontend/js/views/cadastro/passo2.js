// ── TELA 1.2: Cadastro — Passo 2 (Detalhes do lote) ──

/**
 * Monta a estrutura HTML da tela de passo 2 e a insere em #app.
 */
function construirTelaPasso2() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-passo2";
  screen.className = "screen";

  screen.innerHTML = `
    <button class="btn-voltar" id="p2-voltar">← Voltar</button>
    <p class="progresso">Passo 2 de 3</p>
    <p class="titulo-tela">Detalhes do lote</p>
    <p class="subtitulo-tela">Informe a quantidade, as datas e a localização do excedente.</p>

    <div class="form-group">
      <label class="form-label" for="p2-quantidade">Quantidade (kg)</label>
      <input type="number" id="p2-quantidade" min="1">
      <p class="label-erro" id="p2-quantidade-erro">Informe uma quantidade válida maior que zero.</p>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label class="form-label" for="p2-colheita">Data de colheita</label>
        <input type="text" id="p2-colheita" placeholder="dd/mm/aaaa">
        <p class="label-erro" id="p2-colheita-erro">Data inválida. Use o formato dd/mm/aaaa.</p>
      </div>

      <div class="form-group">
        <label class="form-label" for="p2-validade">Validade</label>
        <input type="text" id="p2-validade" placeholder="dd/mm/aaaa">
        <p class="label-erro" id="p2-validade-erro">Data inválida. Use o formato dd/mm/aaaa.</p>
      </div>
    </div>

    <div class="form-group">
      <label class="form-label" for="p2-localizacao">Localização atual</label>
      <input type="text" id="p2-localizacao">
      <p class="label-erro" id="p2-localizacao-erro">Informe a localização atual.</p>
    </div>

    <button class="btn-primario" id="p2-continuar">Continuar</button>
  `;

  app.appendChild(screen);

  screen.querySelector("#p2-voltar").addEventListener("click", () => {
    App.navegarPara("passo1");
  });

  screen.querySelector("#p2-continuar").addEventListener("click", avancarParaPasso3);
}

/**
 * Converte uma string no formato "dd/mm/aaaa" em um objeto Date.
 * @param {string} str - Data no formato brasileiro.
 * @returns {Date|null} Data convertida, ou null se o formato for inválido.
 */
function parseDateBR(str) {
  const match = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec((str || "").trim());
  if (!match) {
    return null;
  }

  const dia = Number(match[1]);
  const mes = Number(match[2]);
  const ano = Number(match[3]);
  const data = new Date(ano, mes - 1, dia);

  const valida =
    data.getFullYear() === ano &&
    data.getMonth() === mes - 1 &&
    data.getDate() === dia;

  return valida ? data : null;
}

/**
 * Valida todos os campos do passo 2, exibindo mensagens de erro inline
 * para cada inconsistência encontrada.
 * @returns {boolean} true se todos os campos são válidos.
 */
function validarCamposPasso2() {
  const screen = document.getElementById("screen-passo2");
  let valido = true;

  const quantidadeInput = screen.querySelector("#p2-quantidade");
  const quantidadeErro = screen.querySelector("#p2-quantidade-erro");
  const quantidade = Number(quantidadeInput.value);
  quantidadeErro.classList.remove("visivel");
  quantidadeInput.classList.remove("erro-campo");
  if (!quantidadeInput.value || quantidade <= 0) {
    quantidadeErro.classList.add("visivel");
    quantidadeInput.classList.add("erro-campo");
    valido = false;
  }

  const colheitaInput = screen.querySelector("#p2-colheita");
  const colheitaErro = screen.querySelector("#p2-colheita-erro");
  const dataColheita = parseDateBR(colheitaInput.value);
  colheitaErro.classList.remove("visivel");
  colheitaInput.classList.remove("erro-campo");
  if (!dataColheita) {
    colheitaErro.classList.add("visivel");
    colheitaInput.classList.add("erro-campo");
    valido = false;
  }

  const validadeInput = screen.querySelector("#p2-validade");
  const validadeErro = screen.querySelector("#p2-validade-erro");
  const dataValidade = parseDateBR(validadeInput.value);
  validadeErro.classList.remove("visivel");
  validadeInput.classList.remove("erro-campo");
  if (!dataValidade) {
    validadeErro.textContent = "Data inválida. Use o formato dd/mm/aaaa.";
    validadeErro.classList.add("visivel");
    validadeInput.classList.add("erro-campo");
    valido = false;
  } else if (dataColheita && dataValidade <= dataColheita) {
    validadeErro.textContent = "A validade deve ser posterior à data de colheita.";
    validadeErro.classList.add("visivel");
    validadeInput.classList.add("erro-campo");
    valido = false;
  }

  const localizacaoInput = screen.querySelector("#p2-localizacao");
  const localizacaoErro = screen.querySelector("#p2-localizacao-erro");
  localizacaoErro.classList.remove("visivel");
  localizacaoInput.classList.remove("erro-campo");
  if (!localizacaoInput.value.trim()) {
    localizacaoErro.classList.add("visivel");
    localizacaoInput.classList.add("erro-campo");
    valido = false;
  }

  return valido;
}

/**
 * Valida os campos do passo 2 e, se corretos, salva os dados na sessão
 * e avança para o passo 3.
 */
function avancarParaPasso3() {
  if (!validarCamposPasso2()) {
    return;
  }

  const screen = document.getElementById("screen-passo2");
  App.session.quantidade = Number(screen.querySelector("#p2-quantidade").value);
  App.session.data_colheita = screen.querySelector("#p2-colheita").value.trim();
  App.session.validade = screen.querySelector("#p2-validade").value.trim();
  App.session.localizacao = screen.querySelector("#p2-localizacao").value.trim();

  App.navegarPara("passo3");
}

construirTelaPasso2();

App.registrarTela("passo2", {
  /**
   * Limpa os campos e mensagens de erro sempre que esta tela é exibida.
   */
  onShow() {
    const screen = document.getElementById("screen-passo2");
    ["#p2-quantidade", "#p2-colheita", "#p2-validade", "#p2-localizacao"].forEach((seletor) => {
      const input = screen.querySelector(seletor);
      input.value = "";
      input.classList.remove("erro-campo");
    });
    screen.querySelectorAll(".label-erro").forEach((el) => el.classList.remove("visivel"));
  },
});
