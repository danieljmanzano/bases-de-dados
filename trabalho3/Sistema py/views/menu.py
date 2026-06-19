"""Tela 0 — Menu principal do sistema."""

import tkinter as tk

from config import CORES, FONTES
from components.widgets import botao_menu


class MenuFrame(tk.Frame):
    """Tela inicial com acesso às duas funcionalidades do protótipo: cadastrar
    um lote de produto e consultar os lotes disponíveis."""

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app

        conteudo = tk.Frame(self, bg=CORES["fundo"])
        conteudo.place(relx=0.5, rely=0.42, anchor="center")

        tk.Label(
            conteudo, text="SOS Abobrinha", bg=CORES["fundo"],
            fg=CORES["verde_principal"], font=(FONTES["titulo"][0], 20, "bold"),
        ).pack(pady=(0, 6))

        tk.Label(
            conteudo, text="Redistribuição de excedentes agrícolas",
            bg=CORES["fundo"], fg=CORES["texto_secundario"], font=FONTES["subtitulo"],
        ).pack(pady=(0, 30))

        opcoes = tk.Frame(conteudo, bg=CORES["fundo"])
        opcoes.pack(fill="x")

        botao_menu(
            opcoes, "Cadastrar lote de produto",
            "Registrar novo excedente agrícola",
            lambda: self.app.show_frame("passo1"),
        ).pack(fill="x", pady=(0, 12))

        botao_menu(
            opcoes, "Consultar lotes disponíveis",
            "Ver excedentes disponíveis para solicitação",
            lambda: self.app.show_frame("consulta"),
        ).pack(fill="x")
