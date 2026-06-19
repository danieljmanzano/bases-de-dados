// ── Dados mockados — remover inteiramente na integração com o backend ──

/**
 * Mapa de CPF/CNPJ formatado → nome do produtor.
 * TODO: GET /api/produtores?cpf_cnpj=:valor
 * Resposta esperada: { nome: string } em caso de sucesso, ou 404 se não encontrado.
 */
const PRODUTORES = {
  "123.456.789-00":     "João da Silva Agropecuária",
  "98.765.432/0001-10": "Maria Oliveira Farming",
  "111.222.333-44":     "Carlos Souza Produções",
};

/**
 * Lista de produtos disponíveis para cadastro.
 * TODO: GET /api/produtos
 * Resposta esperada: [{ nome: string }]
 */
const PRODUTOS = ["Alface", "Batata", "Cenoura", "Milho", "Soja", "Tomate"];

/**
 * Lotes de excedentes cadastrados.
 * TODO: GET /api/lotes?classificacao=:valor
 * Resposta esperada: [{ id, produto, produtor, quantidade, validade, localizacao, classificacao }]
 */
const LOTES = [
  { id: 42, produto: "Batata",  produtor: "João da Silva Agropecuária",
    quantidade: 500,  validade: "20/06/2026", localizacao: "CBD São Carlos",
    classificacao: "Consumo humano" },
  { id: 57, produto: "Cenoura", produtor: "Maria Oliveira Farming",
    quantidade: 300,  validade: "18/06/2026", localizacao: "CBD São Carlos",
    classificacao: "Consumo humano" },
  { id: 63, produto: "Milho",   produtor: "Carlos Souza Produções",
    quantidade: 800,  validade: "25/06/2026", localizacao: "Armazém Central",
    classificacao: "Consumo animal" },
  { id: 71, produto: "Soja",    produtor: "João da Silva Agropecuária",
    quantidade: 1200, validade: "30/06/2026", localizacao: "Centro de Compostagem",
    classificacao: "Compostagem" },
];

/**
 * Contador local usado para simular a geração de ID de um novo lote.
 * TODO: ID gerado pelo banco via RETURNING id_lote no INSERT
 */
let PROXIMO_ID = 100;
