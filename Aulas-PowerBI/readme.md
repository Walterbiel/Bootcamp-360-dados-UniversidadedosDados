
# README — Curso Prático de Power BI com o dataset Olist

Este módulo é dividido em **4 aulas de 3 horas cada** usando a base de dados Olist (as mesmas tabelas importadas no módulo SQL).

---

## Aula 1 — ETL no Power Query (3h)

**Objetivo:** Extrair, Transformar e Carregar dados.

### Passos:
1. **Importar os CSVs** diretamente no Power BI ou a partir do Postgres.
2. **Power Query**:
   - Renomear tabelas e colunas para nomes amigáveis.
   - Corrigir tipos de dados (Data, Texto, Número, Moeda).
   - Criar colunas derivadas (ex.: `Ano`, `Mês`, `Ano-Mês` a partir de `order_purchase_timestamp`).
   - Remover colunas desnecessárias para a análise.
   - Tratar valores nulos (substituir ou remover).
   - Juntar tabelas (Merge) e adicionar dados relacionados (ex.: categorias traduzidas).
3. **Boas práticas de ETL**:
   - Documentar transformações no editor avançado.
   - Nomear etapas de forma descritiva.

**Exercícios:**
- Criar tabela de **Pedidos por Ano e Mês** com receita (`price + freight_value`).
- Limpar tabela de geolocalização, mantendo apenas colunas de cidade e estado.

---

## Aula 2 — Modelagem de Dados e Gráficos (3h)

**Objetivo:** Criar um modelo relacional otimizado e primeiros visuais.

### Passos:
1. **Definir relacionamentos**:
   - Chaves primárias e estrangeiras entre tabelas (Pedidos, Itens, Clientes, Vendedores, Produtos).
   - Cardinalidade (1:1, 1:*).
2. **Criar tabelas auxiliares**:
   - Tabela calendário (com colunas Ano, Mês, Trimestre, Nome do mês).
3. **Organizar o modelo**:
   - Fatos (ex.: Pedidos, Itens, Pagamentos) e Dimensões (Clientes, Produtos, Categorias, Datas).
4. **Primeiros visuais**:
   - Gráfico de colunas com receita mensal.
   - Tabela com top 10 categorias por receita.
   - Mapa com receita por estado.

**Exercícios:**
- Criar um **Gráfico de Linha** mostrando evolução de pedidos entregues por mês.
- Criar **Gráfico de Barras** com top 10 sellers.

---

## Aula 3 — Dashboards, DAX Básico e Deploy (3h)

**Objetivo:** Criar dashboards funcionais e publicar.

### Passos:
1. **DAX Básico**:
   - Medidas simples (`SUM`, `COUNTROWS`, `AVERAGE`).
   - Filtragem com `CALCULATE`.
2. **Criação de Dashboard**:
   - KPI cards (Receita total, Nº pedidos, Ticket médio).
   - Segmentadores (Ano, Categoria, Estado).
   - Visuais interativos (matrizes, mapas, gráficos combinados).
3. **Publicação no Power BI Service**:
   - Conectar e publicar relatório.
   - Criar dashboard no serviço com pins de visuais.
   - Configurar atualização agendada.

**Exercícios:**
- Criar medida **Ticket Médio** = Receita total / Nº pedidos.
- Criar KPI para % de entregas atrasadas.

---

## Aula 4 — DAX Avançado, RLS e What If (3h)

**Objetivo:** Criar análises mais complexas e controlar acesso.

### Passos:
1. **DAX Avançado**:
   - Funções de tempo: `DATEADD`, `SAMEPERIODLASTYEAR`, `TOTALYTD`.
   - Cálculos com contexto: `ALL`, `FILTER`.
   - Métricas acumuladas (running totals).
2. **RLS (Row Level Security)**:
   - Criar funções de filtro para restringir dados por vendedor ou estado.
   - Testar papéis no Power BI Desktop e Service.
3. **Parâmetros "What If"**:
   - Criar parâmetro para simular aumento de preço (%).
   - Aplicar parâmetro em medida para ver impacto na receita.

**Exercícios:**
- Criar medida Receita Acumulada (mês a mês).
- Criar comparação de receita com mesmo período do ano anterior.
- Criar RLS para permitir que cada vendedor veja apenas seus pedidos.

---

## Boas práticas gerais:
- Nomear medidas com padrão claro (prefixos como `m_` para medidas).
- Criar pastas de campos para organizar medidas e dimensões.
- Sempre validar relacionamento antes de criar medidas complexas.


