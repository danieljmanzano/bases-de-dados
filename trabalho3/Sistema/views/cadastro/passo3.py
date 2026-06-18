"""Tela 1.3 do fluxo de cadastro — confirmação dos dados informados."""

import tkinter as tk

import data.mock_data as mock_data
from config import CORES, FONTES, ESPACAMENTO
from components.widgets import botao_voltar, botao_primario, botao_secundario, indicador_progresso


class Passo3Frame(tk.Frame):
    """Terceiro passo do cadastro de lote: exibe um resumo dos dados
    preenchidos e simula a inserção do novo lote no banco de dados."""

    LINHAS_RESUMO = (
        ("Produtor", "produtor_nome", ""),
        ("Produto", "produto", ""),
        ("Quantidade", "quantidade", " kg"),
        ("Colheita", "data_colheita", ""),
        ("Validade", "validade", ""),
        ("Localização", "localizacao", ""),
    )

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app

        topo = tk.Frame(self, bg=CORES["fundo"])
        botao_voltar(topo, lambda: self.app.show_frame("passo2")).pack(anchor="w")

        corpo = tk.Frame(self, bg=CORES["fundo"])

        indicador_progresso(corpo, 3).pack(anchor="w")
        tk.Label(
            corpo, text="Confirme os dados", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["titulo"],
        ).pack(anchor="w", pady=(2, 20))

        self.card_resumo = tk.Frame(
            corpo, bg=CORES["branco"], highlightbackground=CORES["borda"],
            highlightthickness=1, padx=18, pady=4,
        )
        self.card_resumo.pack(fill="x")

        self.labels_valor = {}
        total_linhas = len(self.LINHAS_RESUMO)
        for indice, (rotulo, chave, _sufixo) in enumerate(self.LINHAS_RESUMO):
            linha = tk.Frame(self.card_resumo, bg=CORES["branco"])
            linha.pack(fill="x", pady=10)

            tk.Label(
                linha, text=rotulo, bg=CORES["branco"],
                fg=CORES["texto_secundario"], font=FONTES["corpo"],
            ).pack(side="left")

            label_valor = tk.Label(
                linha, text="", bg=CORES["branco"],
                fg=CORES["texto_principal"], font=(FONTES["corpo"][0], FONTES["corpo"][1], "bold"),
            )
            label_valor.pack(side="right")
            self.labels_valor[chave] = label_valor

            if indice < total_linhas - 1:
                tk.Frame(self.card_resumo, bg=CORES["borda"], height=1).pack(fill="x")

        rodape = tk.Frame(self, bg=CORES["fundo"])
        botao_primario(rodape, "Confirmar cadastro", self._confirmar).pack(fill="x", pady=(0, 8))
        botao_secundario(rodape, "Cancelar", self._cancelar).pack(fill="x")

        lateral = ESPACAMENTO["lateral"]
        topo.pack(fill="x", padx=lateral, pady=(ESPACAMENTO["topo"], 0))
        corpo.pack(fill="x", padx=lateral, pady=10)
        rodape.pack(fill="x", padx=lateral, pady=(0, 20), side="bottom")

    def on_show(self):
        """Lê os dados acumulados na sessão e atualiza o card de resumo."""
        for rotulo, chave, sufixo in self.LINHAS_RESUMO:
            valor = self.app.session.get(chave, "")
            self.labels_valor[chave].config(text=f"{valor}{sufixo}" if valor != "" else "")

    def _confirmar(self):
        """Simula o INSERT do novo lote na base de dados (dados mockados em memória).

        TODO (integração banco): substituir a simulação abaixo por:
            try:
                conn = get_connection()
                cur = conn.cursor()
                cur.execute('''
                    INSERT INTO lote_de_produto
                      (produto, cpf_cnpj_produtor, data_hora_cadastro,
                       quantidade, data_colheita, validade, localizacao_atual)
                    VALUES (%s, %s, NOW(), %s, %s, %s, %s)
                    RETURNING id_lote
                ''', (session["produto"], session["cpf_cnpj"], session["quantidade"],
                      session["data_colheita"], session["validade"], session["localizacao"]))
                session["id_gerado"] = cur.fetchone()[0]
                conn.commit()
            except Exception as e:
                conn.rollback()
                messagebox.showerror("Erro", "Não foi possível salvar o lote.")
                return
        """
        session = self.app.session
        novo_lote = {
            "id": mock_data.PROXIMO_ID,
            "produto": session.get("produto"),
            "produtor": session.get("produtor_nome"),
            "quantidade": session.get("quantidade"),
            "validade": session.get("validade"),
            "localizacao": session.get("localizacao"),
            # Recém-cadastrado: ainda não passou pela triagem, logo não tem classificação.
            "classificacao": "Não classificado",
        }
        mock_data.LOTES.append(novo_lote)
        session["id_gerado"] = mock_data.PROXIMO_ID
        mock_data.PROXIMO_ID += 1

        self.app.show_frame("sucesso")

    def _cancelar(self):
        """Descarta os dados preenchidos e volta ao menu principal."""
        self.app.limpar_session()
        self.app.show_frame("menu")
