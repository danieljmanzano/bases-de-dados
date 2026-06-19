"""Tela 1.1 do fluxo de cadastro — seleção do produtor e do produto."""

import re
import tkinter as tk

from config import CORES, FONTES, ESPACAMENTO
from components.widgets import (
    botao_voltar, botao_primario, combobox_padrao, entry_padrao,
    indicador_progresso, label_erro,
)
from data.mock_data import PRODUTORES, PRODUTOS

PLACEHOLDER_CPF = "000.000.000-00 ou 00.000.000/0001-00"


class Passo1Frame(tk.Frame):
    """Primeiro passo do cadastro de lote: identifica o produtor pelo
    CPF/CNPJ (com busca e máscara automáticas) e define qual produto está
    sendo registrado."""

    def __init__(self, parent, app):
        super().__init__(parent, bg=CORES["fundo"])
        self.app = app

        topo = tk.Frame(self, bg=CORES["fundo"])
        botao_voltar(topo, lambda: self.app.show_frame("menu")).pack(anchor="w")

        corpo = tk.Frame(self, bg=CORES["fundo"])

        indicador_progresso(corpo, 1).pack(anchor="w")
        tk.Label(
            corpo, text="Produtor e produto", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["titulo"],
        ).pack(anchor="w", pady=(2, 20))

        # Campo CPF/CNPJ
        tk.Label(
            corpo, text="CPF/CNPJ do produtor", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["label"],
        ).pack(anchor="w")

        self.var_cpf = tk.StringVar()
        self.entry_cpf = entry_padrao(corpo, self.var_cpf)
        self.entry_cpf.pack(fill="x", pady=(4, 2), ipady=6)
        self.entry_cpf.bind("<FocusIn>", self._ao_focar_cpf)
        self.entry_cpf.bind("<FocusOut>", self._ao_desfocar_cpf)
        self.var_cpf.trace_add("write", self._aplicar_mascara_cpf)

        self.label_sucesso_produtor = tk.Label(
            corpo, text="", bg=CORES["fundo"], fg=CORES["verde_escuro"],
            font=FONTES["pequena"], anchor="w",
        )
        self.label_sucesso_produtor.pack(fill="x")

        self.label_erro_produtor = label_erro(corpo)
        self.label_erro_produtor.pack(fill="x")

        # Campo produto
        tk.Label(
            corpo, text="Produto", bg=CORES["fundo"],
            fg=CORES["texto_principal"], font=FONTES["label"],
        ).pack(anchor="w", pady=(14, 0))

        self.var_produto = tk.StringVar()
        # TODO (integração banco): SELECT nome FROM produto ORDER BY nome
        self.combo_produto = combobox_padrao(corpo, self.var_produto, PRODUTOS)
        self.combo_produto.pack(fill="x", pady=(4, 0), ipady=4)

        self.label_erro_geral = label_erro(corpo)
        self.label_erro_geral.pack(fill="x", pady=(10, 0))

        rodape = tk.Frame(self, bg=CORES["fundo"])
        botao_primario(rodape, "Continuar", self._continuar).pack(fill="x")

        lateral = ESPACAMENTO["lateral"]
        topo.pack(fill="x", padx=lateral, pady=(ESPACAMENTO["topo"], 0))
        corpo.pack(fill="x", padx=lateral, pady=14)
        rodape.pack(fill="x", padx=lateral, pady=(0, 20), side="bottom")

    def on_show(self):
        """Limpa todos os campos e a sessão compartilhada ao entrar nesta tela."""
        self.app.limpar_session()
        self.var_cpf.set(PLACEHOLDER_CPF)
        self.entry_cpf.config(fg=CORES["texto_secundario"])
        self.var_produto.set("")
        self.label_sucesso_produtor.config(text="")
        self.label_erro_produtor.config(text="")
        self.label_erro_geral.config(text="")

    def _ao_focar_cpf(self, _event=None):
        """Remove o placeholder ao focar o campo, se ele ainda estiver vazio."""
        if self.var_cpf.get() == PLACEHOLDER_CPF:
            self.var_cpf.set("")
            self.entry_cpf.config(fg=CORES["texto_principal"])

    def _ao_desfocar_cpf(self, _event=None):
        """Restaura o placeholder se o campo ficou vazio, ou valida o produtor."""
        if not self.var_cpf.get():
            self.var_cpf.set(PLACEHOLDER_CPF)
            self.entry_cpf.config(fg=CORES["texto_secundario"])
        else:
            self._validar_produtor()

    def _aplicar_mascara_cpf(self, *_args):
        """Formata o CPF/CNPJ automaticamente conforme a quantidade de dígitos digitados."""
        valor = self.var_cpf.get()
        if valor == PLACEHOLDER_CPF:
            return
        digitos = re.sub(r"\D", "", valor)
        if len(digitos) == 11:
            novo = f"{digitos[0:3]}.{digitos[3:6]}.{digitos[6:9]}-{digitos[9:11]}"
        elif len(digitos) == 14:
            novo = f"{digitos[0:2]}.{digitos[2:5]}.{digitos[5:8]}/{digitos[8:12]}-{digitos[12:14]}"
        else:
            novo = digitos
        if novo != valor:
            self.var_cpf.set(novo)
            self.entry_cpf.icursor(tk.END)

    def _validar_produtor(self):
        """Busca o CPF/CNPJ informado entre os produtores cadastrados (mock)."""
        cpf_cnpj = self.var_cpf.get()
        if cpf_cnpj == PLACEHOLDER_CPF or not cpf_cnpj.strip():
            # Campo ainda não preenchido: não tenta buscar nem exibe "não encontrado".
            self.app.session.pop("produtor_nome", None)
            self.label_sucesso_produtor.config(text="")
            self.label_erro_produtor.config(text="")
            return

        # TODO (integração banco): SELECT nome FROM produtor_rural WHERE cpf_cnpj = %s
        nome = PRODUTORES.get(cpf_cnpj)
        if nome:
            self.app.session["cpf_cnpj"] = cpf_cnpj
            self.app.session["produtor_nome"] = nome
            self.label_sucesso_produtor.config(text=f"✓ Produtor: {nome}")
            self.label_erro_produtor.config(text="")
        else:
            self.app.session.pop("produtor_nome", None)
            self.label_sucesso_produtor.config(text="")
            self.label_erro_produtor.config(text="✗ Produtor não encontrado.")

    def _continuar(self):
        """Valida produtor e produto selecionados antes de avançar para o passo 2."""
        self._validar_produtor()
        produto = self.var_produto.get()

        if "produtor_nome" not in self.app.session:
            self.label_erro_geral.config(text="Informe um CPF/CNPJ de produtor válido.")
            return
        if produto not in PRODUTOS:
            self.label_erro_geral.config(text="Selecione um produto.")
            return

        self.label_erro_geral.config(text="")
        self.app.session["produto"] = produto
        self.app.show_frame("passo2")
