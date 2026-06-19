// ── TELA 1.3: Cadastro — Passo 3 (Confirmação) ──

/**
 * Monta a estrutura HTML da tela de passo 3 e a insere em #app.
 */
function construirTelaPasso3() {
  const app = document.getElementById("app");

  const screen = document.createElement("div");
  screen.id = "screen-passo3";
  screen.className = "screen";

  screen.innerHTML = `
    <button class="btn-voltar" id="p3-voltar">← Voltar</button>
    <p class="progresso">Passo 3 de 3</p>
    <p class="titulo-tela">Confirme os dados</p>
    <p class="subtitulo-tela">Revise as informações antes de concluir o cadastro.</p>

    <div class="card-resumo">
      <div class="linha"><span class="chave">Produtor</span><span class="valor" id="p3-produtor"></span></div>
      <div class="linha"><span class="chave">Produto</span><span class="valor" id="p3-produto"></span></div>
      <div class="linha"><span class="chave">Quantidade</span><span class="valor" id="p3-quantidade"></span></div>
      <div class="linha"><span class="chave">Colheita</span><span class="valor" id="p3-colheita"></span></div>
      <div class="linha"><span class="chave">Validade</span><span class="valor" id="p3-validade"></span></div>
      <div class="linha"><span class="chave">Localização</span><span class="valor" id="p3-localizacao"></span></div>
    </div>

    <p class="label-erro" id="p3-erro-geral">Não foi possível salvar o lote. Tente novamente.</p>

    <button class="btn-primario" id="p3-confirmar">Confirmar cadastro</button>
    <button class="btn-secundario" id="p3-cancelar">Cancelar</button>
  `;

  app.appendChild(screen);

  screen.querySelector("#p3-voltar").addEventListener("click", () => {
    App.navegarPara("passo2");
  });

  screen.querySelector("#p3-cancelar").addEventListener("click", () => {
    App.limparSession();
    App.navegarPara("menu");
  });

  screen.querySelector("#p3-confirmar").addEventListener("click", confirmarCadastro);
}

/**
 * Exibe uma mensagem de erro geral na tela de confirmação.
 * @param {string} mensagem - Texto a ser exibido ao usuário.
 */
function exibirErroGeral(mensagem) {
  const erro = document.getElementById("p3-erro-geral");
  erro.textContent = mensagem;
  erro.classList.add("visivel");
}

/**
 * Envia o lote para a API (INSERT) e avança para a tela de sucesso.
 */
async function confirmarCadastro() {
  document.getElementById("p3-erro-geral").classList.remove("visivel");

  try {
    const res = await fetch("/api/lotes", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        produto:       App.session.produto,
        cpf_cnpj:      App.session.cpf_cnpj,
        quantidade:    App.session.quantidade,
        data_colheita: App.session.data_colheita,
        validade:      App.session.validade,
        localizacao:   App.session.localizacao,
      }),
    });

    if (!res.ok) {
      exibirErroGeral("Não foi possível salvar o lote. Tente novamente.");
      return;
    }

    const data = await res.json();
    App.session.id_gerado = data.id_lote;
    App.navegarPara("sucesso");
  } catch (erro) {
    exibirErroGeral("Não foi possível salvar o lote. Tente novamente.");
  }
}

construirTelaPasso3();

App.registrarTela("passo3", {
  /**
   * Preenche o card de resumo com os dados acumulados na sessão.
   */
  onShow() {
    const screen = document.getElementById("screen-passo3");
    screen.querySelector("#p3-produtor").textContent = App.session.produtor_nome ?? "";
    screen.querySelector("#p3-produto").textContent = App.session.produto ?? "";
    screen.querySelector("#p3-quantidade").textContent = `${App.session.quantidade ?? ""} kg`;
    screen.querySelector("#p3-colheita").textContent = App.session.data_colheita ?? "";
    screen.querySelector("#p3-validade").textContent = App.session.validade ?? "";
    screen.querySelector("#p3-localizacao").textContent = App.session.localizacao ?? "";
    screen.querySelector("#p3-erro-geral").classList.remove("visivel");
  },
});
