
# Aulas Walter - Bootcamp universidade dos Dados

Este projeto é um curso prático dividido em **módulos sequenciais** usando a base de dados **Olist** (e-commerce brasileiro).

O objetivo é capacitar o aluno desde a **introdução à engenharia de dados**, passando por **consultas SQL** (básicas e avançadas) até a **criação de dashboards no Power BI**.

---

## Estrutura do Curso

### 1) Introdução à Engenharia de Dados (Walter)
**Objetivo:** Compreender o papel da engenharia de dados e seu ciclo de trabalho.

**Conteúdos:**
- Conceito de Engenharia de Dados.
- Diferença entre dados operacionais e analíticos.
- Arquitetura de pipelines (ETL/ELT).
- Bancos de dados relacionais vs não relacionais.
- Conceitos de Data Warehouse e Data Lake.

**Atividade Prática:**
- Explorar a base Olist e entender a função de cada tabela.

---

### 2) SQL Básico e Data Warehouse (Walter)
**Objetivo:** Consultar dados e gerar insights básicos.

**Conteúdos:**
- `SELECT`, `WHERE`, `ORDER BY`.
- Funções de agregação: `SUM`, `COUNT`, `AVG`, `MIN`, `MAX`.
- Agrupamento com `GROUP BY`.
- Uso de `DISTINCT`.
- Junções (`INNER JOIN`, `LEFT JOIN`).

**Atividade Prática:**
- Consultas para calcular receita por mês.
- Top 10 produtos por receita.
- Número de pedidos por estado.

---

### 3) SQL Avançado — CTE, Window Function, CASE WHEN (Walter)
**Objetivo:** Criar análises complexas e preparações para BI.

**Conteúdos:**
- `CASE WHEN` para categorizar dados.
- `HAVING` para filtrar grupos.
- CTEs (`WITH`) para organizar consultas.
- Funções de janela: `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, `NTILE`.
- Boas práticas com tabelas temporárias.

**Atividade Prática:**
- Ranking mensal de categorias.
- Receita acumulada e variação percentual mês a mês.
- Segmentação de sellers em quartis.

---

### 4) Power BI — ETL com Power Query (Walter)
**Objetivo:** Transformar e preparar dados para análise.

**Conteúdos:**
- Importar dados do Postgres.
- Renomear e tipificar colunas.
- Criar colunas derivadas (Ano, Mês, Trimestre).
- Mesclar consultas (merge).
- Tratar valores nulos e dados inválidos.

**Atividade Prática:**
- Criar tabela de receita por Ano-Mês.
- Criar tabela limpa de geolocalização.

---

### 5) Power BI — Modelagem de Dados e Gráficos (Walter)
**Objetivo:** Criar modelo relacional e primeiros visuais.

**Conteúdos:**
- Relacionamentos e cardinalidade.
- Tabela calendário.
- Separação entre fatos e dimensões.
- Criação de gráficos (linha, barra, mapa, matriz).

**Atividade Prática:**
- Receita mensal acumulada.
- Top categorias e top sellers.

---

### 6) Power BI — Dashboards, DAX Básico e Deploy (Walter)
**Objetivo:** Construir dashboard interativo e publicar.

**Conteúdos:**
- Medidas simples com `SUM`, `COUNTROWS`, `CALCULATE`.
- Segmentadores e KPIs.
- Publicação no Power BI Service.
- Criação de dashboard no serviço.

**Atividade Prática:**
- Ticket médio.
- % de entregas atrasadas.

---

## Base de Dados Usada
A base **Olist** contém dados de pedidos de e-commerce no Brasil, incluindo:
- Clientes
- Vendedores
- Produtos e categorias
- Pedidos e itens
- Pagamentos
- Avaliações
- Geolocalização

**Fonte:** Kaggle — Olist Brazilian E-Commerce Public Dataset.

---

## Ferramentas Necessárias
- PostgreSQL (para SQL)
- Power BI Desktop (para ETL, modelagem e dashboards)
- Power BI Service (para publicação)

---

## Metodologia
- Cada módulo combina teoria + prática.
- Exercícios progressivos usando os mesmos dados.
- Foco em **análise de negócio real**.

---

## Resultado Esperado
Ao final, o aluno será capaz de:
- Entender conceitos de engenharia de dados.
- Criar consultas SQL otimizadas e avançadas.
- Modelar dados para BI.
- Construir dashboards interativos no Power BI.
- Publicar e compartilhar relatórios.

