"""Tela 1.4 do fluxo de cadastro — confirmação de sucesso."""

import tkinter as tk

from config import CORES, FONTES
from components.widgets import botao_primario, botao_secundario


class SucessoFrame(tk.Frame):
    """Tela final do cadastro: confirma visualmente que o lote foi salvo e
    oferece atalhos para cadastrar outro lote ou voltar ao menu."""

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app

        conteudo = tk.Frame(self, bg=CORES["fundo"])
        conteudo.place(relx=0.5, rely=0.45, anchor="center")

        card = tk.Frame(conteudo, bg=CORES["verde_claro"], padx=40, pady=30)
        card.pack()

        tk.Label(
            card, text="✓", bg=CORES["verde_claro"], fg=CORES["verde_escuro"],
            font=("Helvetica", 36, "bold"),
        ).pack()

        tk.Label(
            card, text="Lote cadastrado com sucesso!", bg=CORES["verde_claro"],
            fg=CORES["verde_escuro"], font=FONTES["label"],
        ).pack(pady=(8, 4))

        self.label_id = tk.Label(
            card, text="", bg=CORES["verde_claro"],
            fg=CORES["verde_escuro"], font=FONTES["corpo"],
        )
        self.label_id.pack()

        botoes = tk.Frame(conteudo, bg=CORES["fundo"])
        botoes.pack(fill="x", pady=(24, 0))

        botao_primario(
            botoes, "Cadastrar outro lote", self._cadastrar_outro
        ).pack(fill="x", pady=(0, 8))

        botao_secundario(
            botoes, "Voltar ao menu", self._voltar_menu
        ).pack(fill="x")

    def on_show(self):
        """Exibe o ID do lote gerado na simulação de cadastro."""
        id_gerado = self.app.session.get("id_gerado", "—")
        self.label_id.config(text=f"ID do lote: #{id_gerado}")

    def _cadastrar_outro(self):
        self.app.limpar_session()
        self.app.show_frame("passo1")

    def _voltar_menu(self):
        self.app.limpar_session()
        self.app.show_frame("menu")
