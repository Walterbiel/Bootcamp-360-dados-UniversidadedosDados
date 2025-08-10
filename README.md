
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

### 7) Power BI — DAX Avançado, RLS e What If (Walter)
**Objetivo:** Realizar análises avançadas com DAX, aplicar segurança a nível de linha (RLS) e criar cenários de simulação (What If).

**Conteúdos:**
- **DAX Avançado**
  - Variáveis: `VAR`/`RETURN` para clareza e performance.
  - Funções iteradoras: `SUMX`, `AVERAGEX`, `COUNTX` em tabelas virtuais.
  - Distintos e contagens: `DISTINCTCOUNT`, `VALUES`.
  - Controlo de contexto: `CALCULATE`, `FILTER`, `ALL`, `ALLEXCEPT`, `REMOVEFILTERS`, `KEEPFILTERS`.
  - Datas (time intelligence): `DATEADD`, `SAMEPERIODLASTYEAR`, `TOTALYTD`, `DATESYTD`, `PARALLELPERIOD`.
  - Relações inativas: `USERELATIONSHIP` (ex.: usar data de entrega vs data de compra).
  - Métricas acumuladas (running totals) e variação MoM/YoY.
- **RLS — Row Level Security**
  - Criar papéis (Roles) e expressões de filtro no Model view.
  - Herança via relacionamentos (filtrar por `olist_sellers_dataset` → restringe fatos relacionados).
  - Boas práticas: tabela de utilizadores/disconectada para mapeamento (opcional).
- **What If**
  - Parâmetros com slider para simular aumento/redução de preço, desconto de frete, etc.
  - Medidas que usam o parâmetro para recalcular KPIs (receita, ticket médio, margem).

**Exemplos de medidas (DAX):**
```DAX
-- Receita bruta (price + freight)
m_Revenue := SUM('olist_order_items_dataset'[price]) + SUM('olist_order_items_dataset'[freight_value])

-- Receita YTD (data de compra)
m_Revenue_YTD := TOTALYTD([m_Revenue], 'Calendar'[Date])

-- Receita YoY (variação %)
m_Revenue_PY := CALCULATE([m_Revenue], DATEADD('Calendar'[Date], -1, YEAR))
m_Revenue_YoY_% := DIVIDE([m_Revenue] - [m_Revenue_PY], [m_Revenue_PY])

-- Receita por data de entrega (usar relação inativa Orders(delivered)->Calendar)
m_Revenue_Delivered := CALCULATE(
    [m_Revenue],
    USERELATIONSHIP('olist_orders_dataset'[order_delivered_customer_date], 'Calendar'[Date])
)

-- Ticket médio
m_Ticket := DIVIDE([m_Revenue], DISTINCTCOUNT('olist_orders_dataset'[order_id]))

-- Receita acumulada (running total por mês)
m_Revenue_Cum := CALCULATE(
    [m_Revenue],
    FILTER(ALL('Calendar'[Date]), 'Calendar'[Date] <= MAX('Calendar'[Date]))
)
```

**Parâmetro What If (exemplo):**
1. Modelagem → Parâmetros → **Novo parâmetro (What if)**  
   - Nome: `p_Price_Uplift_%`  
   - Mín: 0, Máx: 20, Incremento: 0.5, Valor padrão: 0  
   - Criar slicer no relatório com o campo `[p_Price_Uplift_% Value]`.
2. Medida de cenário:
```DAX
m_Revenue_Adjusted :=
VAR uplift = SELECTEDVALUE('p_Price_Uplift_%'[p_Price_Uplift_% Value], 0)
RETURN [m_Revenue] * (1 + uplift/100.0)
```
3. Opcional: simular **desconto de frete** com outro parâmetro e combinar cenários.

**RLS (exemplo por estado do seller):**
1. Model view → **Manage roles** → New.  
2. Selecionar tabela `'olist_sellers_dataset'` e aplicar filtro:
```DAX
'olist_sellers_dataset'[seller_state] = "SP"
```
3. Garantir relacionamentos da tabela de sellers com fatos (`order_items`) para propagar o filtro.  
4. Testar o papel (View as role) e no Service atribuir utilizadores ao papel.

**Exercícios:**
- Criar medidas **MoM** e **YoY** de receita e pedidos entregues.
- Implementar `USERELATIONSHIP` para comparar KPIs por **data de compra** vs **data de entrega**.
- Criar dois parâmetros What If (uplift de preço e desconto de frete) e um visual que compare KPIs originais vs ajustados.
- Configurar **RLS por seller_state** com dois papéis (ex.: SP e RJ) e validar a filtragem nos visuais.

-------------------------------------------------------------------------------------------------------------------------------------------

# Base de Dados Usada

<img width="2486" height="1496" alt="image" src="https://github.com/user-attachments/assets/82ab47d0-064e-4629-b17d-2600613aa7e4" />

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

