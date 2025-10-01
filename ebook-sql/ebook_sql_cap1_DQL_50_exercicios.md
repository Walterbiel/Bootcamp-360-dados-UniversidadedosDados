# EBOOK — SQL DQL: 50 Exercícios Comentados e Resolvidos


**Base utilizada:** `Product`, `Reseller`, `Sales`, `Salesperson`, `SalespersonRegion`, `Targets`, `Region`  
> Observação: como algumas colunas possuem espaços e hífens no nome (ex.: `"Unit Price"`, `"State-Province"`), os exemplos usam **identificadores entre aspas duplas** para manter compatibilidade ANSI SQL.

### Dicas de uso
- Ajuste o nome do **schema** caso necessário (ex.: `public.Product`).
- Datas estão como texto no dataset de exemplo; quando precisar, converta usando funções da sua engine (ex.: `TO_DATE(OrderDate, 'Day, Month DD, YYYY')` no Postgres).
- Valores monetários (ex.: `"Sales"`, `"Unit Price"`, `"Target"`) vêm com `$` e `,`. Para cálculos, remova símbolos (ex.: `REPLACE(REPLACE("Sales",'$',''),',','')::numeric`).

---
## Seção A — Básico


## Exercício 01 — Listar todos os produtos
**Enunciado.** Exiba todas as colunas da tabela `Product`.

```sql
SELECT * FROM Product;
```

**Explicação.** Consulta direta com `SELECT *`. Útil para reconhecer o esquema rapidamente.


## Exercício 02 — Selecionar colunas específicas
**Enunciado.** Liste `ProductKey`, `Product`, `Category`.

```sql
SELECT "ProductKey", "Product", "Category" FROM Product;
```

**Explicação.** Seleciona apenas colunas relevantes, reduzindo leitura/transferência.


    ## Exercício 03 — Top 10 linhas
    **Enunciado.** Mostre as 10 primeiras linhas da tabela `Reseller`.

    ```sql
    SELECT * FROM Reseller
LIMIT 10;
    ```

    **Explicação.** `LIMIT` restringe o número de linhas retornadas.


    ## Exercício 04 — Filtrar por estado
    **Enunciado.** Liste revendedores da Califórnia (`"State-Province" = 'California'`).

    ```sql
    SELECT "ResellerKey","Reseller","City","State-Province"
FROM Reseller
WHERE "State-Province" = 'California';
    ```

    **Explicação.** Uso básico de `WHERE` para igualdade.


    ## Exercício 05 — Filtrar por múltiplos valores
    **Enunciado.** Liste revendedores dos estados California **ou** Washington.

    ```sql
    SELECT "ResellerKey","Reseller","City","State-Province"
FROM Reseller
WHERE "State-Province" IN ('California','Washington');
    ```

    **Explicação.** `IN` simplifica múltiplas comparações.


    ## Exercício 06 — Ordenação ascendente/descendente
    **Enunciado.** Liste produtos ordenados por nome crescente e depois por `Standard Cost` decrescente.

    ```sql
    SELECT "ProductKey","Product","Standard Cost"
FROM Product
ORDER BY "Product" ASC, "Standard Cost" DESC;
    ```

    **Explicação.** `ORDER BY` aceita múltiplas chaves e direções.


## Exercício 07 — Distinct
**Enunciado.** Quais são as categorias únicas de produtos?

```sql
SELECT DISTINCT "Category" FROM Product;
```

**Explicação.** `DISTINCT` remove duplicatas do conjunto de resultados.


    ## Exercício 08 — Filtro por padrão (LIKE)
    **Enunciado.** Liste revendedores cujo nome contém a palavra `Sports`.

    ```sql
    SELECT "ResellerKey","Reseller"
FROM Reseller
WHERE "Reseller" ILIKE '%Sports%';
    ```

    **Explicação.** `LIKE`/`ILIKE` busca padrões; `ILIKE` é case-insensitive (Postgres).


## Exercício 09 — Contagem simples
**Enunciado.** Quantos vendedores (linhas) há em `Salesperson`?

```sql
SELECT COUNT(*) AS total_vendedores FROM Salesperson;
```

**Explicação.** `COUNT(*)` conta linhas independentemente de nulos.


    ## Exercício 10 — Filtrar por data (texto)
    **Enunciado.** Liste vendas do dia 25/08/2017 (texto exato no campo `OrderDate`).

    ```sql
    SELECT * FROM Sales
WHERE "OrderDate" = 'Friday, August 25, 2017';
    ```

    **Explicação.** Como a data está em texto no dataset, aqui comparamos a string literal. Em produção, prefira colunas de data/timestamp.


## Seção B — Operadores e Funções Simples


    ## Exercício 11 — Intervalo (BETWEEN) em valores numéricos tratados
    **Enunciado.** Liste itens de venda com quantidade entre 2 e 5 (inclusive).

    ```sql
    SELECT "SalesOrderNumber","ProductKey","Quantity"
FROM Sales
WHERE "Quantity" BETWEEN 2 AND 5;
    ```

    **Explicação.** `BETWEEN a AND b` inclui as extremidades.


    ## Exercício 12 — Não igual (!=)
    **Enunciado.** Liste pedidos cujo `SalesTerritoryKey` não seja 4.

    ```sql
    SELECT "SalesOrderNumber","SalesTerritoryKey"
FROM Sales
WHERE "SalesTerritoryKey" <> 4;
    ```

    **Explicação.** `<>` representa diferente (ANSI SQL).


    ## Exercício 13 — Ordenação + Limite
    **Enunciado.** Traga as 5 vendas com maior valor de `Sales` (converter texto para número).

    ```sql
    SELECT "SalesOrderNumber","Sales"
FROM (
  SELECT "SalesOrderNumber",
         REPLACE(REPLACE("Sales", '$', ''), ',', '')::numeric AS sales_value
  FROM Sales
) t
ORDER BY sales_value DESC
LIMIT 5;
    ```

    **Explicação.** Transformamos texto monetário em `numeric` removendo `$` e `,` e usamos alias para ordenar.


    ## Exercício 14 — Projeção com alias
    **Enunciado.** Exiba `ProductKey` e um alias `is_high_cost` que vale `TRUE` se `Standard Cost` > 500.

    ```sql
    SELECT "ProductKey", "Product",
       (REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric > 500) AS is_high_cost
FROM Product;
    ```

    **Explicação.** Cria-se uma expressão booleana e apelida com `AS`.


    ## Exercício 15 — Concatenação de colunas
    **Enunciado.** Exiba `Reseller` + cidade em uma única coluna `reseller_city`.

    ```sql
    SELECT "ResellerKey", ("Reseller" || ' - ' || "City") AS reseller_city
FROM Reseller;
    ```

    **Explicação.** Operador `||` concatena strings no Postgres/ANSI.


    ## Exercício 16 — Filtro com LIKE no início e fim
    **Enunciado.** Resellers cujo nome começa com `The` e termina com `Company`.

    ```sql
    SELECT "ResellerKey","Reseller"
FROM Reseller
WHERE "Reseller" LIKE 'The%Company';
    ```

    **Explicação.** `%` representa qualquer sequência; combinamos prefixo e sufixo.


## Exercício 17 — UPPER/LOWER
**Enunciado.** Mostre `Reseller` em maiúsculas.

```sql
SELECT UPPER("Reseller") AS reseller_upper FROM Reseller;
```

**Explicação.** Funções de texto para normalização.


    ## Exercício 18 — COALESCE
    **Enunciado.** Mostre `Color` ou, se nulo, escreva `'N/A'`.

    ```sql
    SELECT "ProductKey","Product", COALESCE("Color", 'N/A') AS color_norm
FROM Product;
    ```

    **Explicação.** `COALESCE` retorna o primeiro argumento não nulo.


    ## Exercício 19 — CASE simples
    **Enunciado.** Classifique produtos em `Faixa` por custo: `Baixo` (<100), `Médio` (100–500), `Alto` (>500).

    ```sql
    SELECT "ProductKey","Product",
CASE 
  WHEN REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric < 100 THEN 'Baixo'
  WHEN REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric <= 500 THEN 'Médio'
  ELSE 'Alto'
END AS "Faixa"
FROM Product;
    ```

    **Explicação.** `CASE` cria categorias derivadas a partir de condições numéricas.


    ## Exercício 20 — Extração de parte de string
    **Enunciado.** Pegue apenas o primeiro nome do `Salesperson` (antes do espaço).

    ```sql
    SELECT "Salesperson", split_part("Salesperson", ' ', 1) AS first_name
FROM Salesperson;
    ```

    **Explicação.** `split_part` (Postgres) facilita dividir strings; em ANSI puro, use funções equivalentes da sua engine.


## Seção C — Agregações e GROUP BY


    ## Exercício 21 — Clientes por estado (aqui: revendedores)
    **Enunciado.** Conte quantos revendedores há por estado.

    ```sql
    SELECT "State-Province", COUNT(*) AS total
FROM Reseller
GROUP BY "State-Province"
ORDER BY total DESC;
    ```

    **Explicação.** Agrupamos pela dimensão e contamos linhas por grupo.


    ## Exercício 22 — Média de custo por categoria
    **Enunciado.** Calcule a média de `Standard Cost` por `Category`.

    ```sql
    SELECT "Category", AVG(REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric) AS avg_cost
FROM Product
GROUP BY "Category"
ORDER BY avg_cost DESC;
    ```

    **Explicação.** Conversão para numérico é necessária antes do `AVG`.


    ## Exercício 23 — Pedidos por território
    **Enunciado.** Quantidade de linhas de venda por `SalesTerritoryKey`.

    ```sql
    SELECT "SalesTerritoryKey", COUNT(*) AS total
FROM Sales
GROUP BY "SalesTerritoryKey"
ORDER BY total DESC;
    ```

    **Explicação.** Contagem por chave geográfica de vendas.


    ## Exercício 24 — Pedidos por vendedor
    **Enunciado.** Conte quantas linhas de venda cada `EmployeeKey` tem em `Sales`.

    ```sql
    SELECT "EmployeeKey", COUNT(*) AS linhas
FROM Sales
GROUP BY "EmployeeKey"
ORDER BY linhas DESC;
    ```

    **Explicação.** Útil para volume bruto por vendedor (sem consolidar valores).


    ## Exercício 25 — Top 5 estados por número de revendedores
    **Enunciado.** Traga os 5 estados com mais revendedores.

    ```sql
    SELECT "State-Province", COUNT(*) AS total
FROM Reseller
GROUP BY "State-Province"
ORDER BY total DESC
LIMIT 5;
    ```

    **Explicação.** Ordenamos por contagem e limitamos a 5 resultados.


    ## Exercício 26 — Soma de vendas por pedido
    **Enunciado.** Compute o total de `Sales` por `SalesOrderNumber`.

    ```sql
    SELECT "SalesOrderNumber",
       SUM(REPLACE(REPLACE("Sales",'$',''),',','')::numeric) AS total_sales
FROM Sales
GROUP BY "SalesOrderNumber"
ORDER BY total_sales DESC;
    ```

    **Explicação.** Agregamos linhas do mesmo pedido somando os valores depurados.


    ## Exercício 27 — Vendedores por território (via relação)
    **Enunciado.** Conte quantos vendedores estão associados a cada território na `SalespersonRegion`.

    ```sql
    SELECT "SalesTerritoryKey", COUNT(DISTINCT "EmployeeKey") AS vendedores
FROM SalespersonRegion
GROUP BY "SalesTerritoryKey"
ORDER BY vendedores DESC;
    ```

    **Explicação.** `COUNT(DISTINCT ...)` evita contar o mesmo vendedor duas vezes por território.


    ## Exercício 28 — Média de preço unitário
    **Enunciado.** Calcule a média de `Unit Price` global.

    ```sql
    SELECT AVG(REPLACE(REPLACE("Unit Price",'$',''),',','')::numeric) AS avg_unit_price
FROM Sales;
    ```

    **Explicação.** Conversão para numérico para permitir agregação.


    ## Exercício 29 — Filtro com HAVING
    **Enunciado.** Liste categorias com média de custo acima de 300.

    ```sql
    SELECT "Category", AVG(REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric) AS avg_cost
FROM Product
GROUP BY "Category"
HAVING AVG(REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric) > 300;
    ```

    **Explicação.** `HAVING` filtra **após** o `GROUP BY` com base em agregações.


    ## Exercício 30 — Top 3 produtos mais caros (pelo custo)
    **Enunciado.** Traga os 3 maiores `Standard Cost`.

    ```sql
    SELECT "ProductKey","Product", REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric AS cost
FROM Product
ORDER BY cost DESC
LIMIT 3;
    ```

    **Explicação.** Ordenação por coluna calculada e limitação do resultado.


## Seção D — JOINs


    ## Exercício 31 — Orders + Reseller
    **Enunciado.** Mostre `SalesOrderNumber`, `Reseller`, `City`, `OrderDate`.

    ```sql
    SELECT s."SalesOrderNumber", r."Reseller", r."City", s."OrderDate"
FROM Sales s
JOIN Reseller r ON r."ResellerKey" = s."ResellerKey";
    ```

    **Explicação.** `JOIN` por chave estrangeira entre vendas e revendedores.


    ## Exercício 32 — Items + Product
    **Enunciado.** Liste `SalesOrderNumber`, `Product`, `Category`.

    ```sql
    SELECT s."SalesOrderNumber", p."Product", p."Category"
FROM Sales s
JOIN Product p ON p."ProductKey" = s."ProductKey";
    ```

    **Explicação.** Relaciona item vendido ao cadastro do produto.


    ## Exercício 33 — Valor do pedido (linha)
    **Enunciado.** Traga linhas de venda com valor numérico de `Sales` e `Cost`.

    ```sql
    SELECT s."SalesOrderNumber", s."ProductKey",
       REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric AS sales_value,
       REPLACE(REPLACE(s."Cost",'$',''),',','')::numeric  AS cost_value
FROM Sales s;
    ```

    **Explicação.** Preparação para análises financeiras (receita x custo).


    ## Exercício 34 — Pedidos por vendedor (JOIN com Salesperson)
    **Enunciado.** Quantidade de pedidos por `Salesperson`.

    ```sql
    SELECT sp."Salesperson", COUNT(*) AS pedidos
FROM Sales s
JOIN Salesperson sp ON sp."EmployeeKey" = s."EmployeeKey"
GROUP BY sp."Salesperson"
ORDER BY pedidos DESC;
    ```

    **Explicação.** Agregamos após juntar a dimensão de pessoas.


    ## Exercício 35 — Receita por vendedor
    **Enunciado.** Receita total (`SUM(Sales)`) por `Salesperson`.

    ```sql
    SELECT sp."Salesperson",
       SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS receita
FROM Sales s
JOIN Salesperson sp ON sp."EmployeeKey" = s."EmployeeKey"
GROUP BY sp."Salesperson"
ORDER BY receita DESC;
    ```

    **Explicação.** Conversão textual e soma por agrupamento.


    ## Exercício 36 — Sales + Product + Reseller
    **Enunciado.** Liste `SalesOrderNumber`, produto e revendedor.

    ```sql
    SELECT s."SalesOrderNumber", p."Product", r."Reseller"
FROM Sales s
JOIN Product p  ON p."ProductKey"   = s."ProductKey"
JOIN Reseller r ON r."ResellerKey"  = s."ResellerKey";
    ```

    **Explicação.** Juntando 3 tabelas via suas chaves.


    ## Exercício 37 — Total gasto por revendedor
    **Enunciado.** Soma de `Sales` por `Reseller`.

    ```sql
    SELECT r."Reseller",
       SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS total_sales
FROM Sales s
JOIN Reseller r ON r."ResellerKey" = s."ResellerKey"
GROUP BY r."Reseller"
ORDER BY total_sales DESC;
    ```

    **Explicação.** Consolidação de vendas por parceiro revendedor.


    ## Exercício 38 — Vendedores com mais de N pedidos
    **Enunciado.** Traga vendedores com 3+ linhas em `Sales`.

    ```sql
    SELECT sp."Salesperson", COUNT(*) AS linhas
FROM Sales s
JOIN Salesperson sp ON sp."EmployeeKey" = s."EmployeeKey"
GROUP BY sp."Salesperson"
HAVING COUNT(*) >= 3
ORDER BY linhas DESC;
    ```

    **Explicação.** Uso de `HAVING` com contagem por grupo.


    ## Exercício 39 — Ticket médio por revendedor
    **Enunciado.** Calcule o ticket médio (`média de Sales por pedido`) por `Reseller`.

    ```sql
    WITH vendas AS (
  SELECT s."SalesOrderNumber", s."ResellerKey",
         SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS pedido_total
  FROM Sales s
  GROUP BY s."SalesOrderNumber", s."ResellerKey"
)
SELECT r."Reseller", AVG(v.pedido_total) AS ticket_medio
FROM vendas v
JOIN Reseller r ON r."ResellerKey" = v."ResellerKey"
GROUP BY r."Reseller"
ORDER BY ticket_medio DESC;
    ```

    **Explicação.** Primeiro somamos por pedido, depois tiramos a média por revendedor.


    ## Exercício 40 — Clientes (revendedores) sem vendas
    **Enunciado.** Liste revendedores que **não aparecem** na tabela `Sales`.

    ```sql
    SELECT r."ResellerKey", r."Reseller"
FROM Reseller r
LEFT JOIN Sales s ON s."ResellerKey" = r."ResellerKey"
WHERE s."ResellerKey" IS NULL;
    ```

    **Explicação.** `LEFT JOIN` + `IS NULL` identifica chaves sem correspondência (anti-join).


## Seção E — Consultas Avançadas


    ## Exercício 41 — Subquery — vendedores com mais de X pedidos
    **Enunciado.** Traga `Salesperson` com mais de 5 linhas em `Sales`.

    ```sql
    SELECT "Salesperson"
FROM Salesperson sp
WHERE sp."EmployeeKey" IN (
  SELECT s."EmployeeKey"
  FROM Sales s
  GROUP BY s."EmployeeKey"
  HAVING COUNT(*) > 5
);
    ```

    **Explicação.** Subconsulta retorna chaves de interesse, filtrando a dimensão.


    ## Exercício 42 — Produto mais caro por categoria
    **Enunciado.** Para cada `Category`, liste o produto de maior `Standard Cost`.

    ```sql
    WITH base AS (
  SELECT "ProductKey","Product","Category",
         REPLACE(REPLACE("Standard Cost",'$',''),',','')::numeric AS cost
  FROM Product
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY "Category" ORDER BY cost DESC) AS rk
  FROM base
)
SELECT "Category","Product",cost
FROM ranked
WHERE rk = 1;
    ```

    **Explicação.** Usamos CTE + `ROW_NUMBER()` particionado por categoria.


    ## Exercício 43 — Top 5 clientes (revendedores) que mais compraram
    **Enunciado.** Liste os 5 `Reseller` com maior soma de `Sales`.

    ```sql
    SELECT r."Reseller", SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS total
FROM Sales s
JOIN Reseller r ON r."ResellerKey" = s."ResellerKey"
GROUP BY r."Reseller"
ORDER BY total DESC
LIMIT 5;
    ```

    **Explicação.** Agregação simples e ordenação decrescente.


    ## Exercício 44 — Média de venda por território
    **Enunciado.** Calcule a média do valor **por pedido** em cada território.

    ```sql
    WITH pedido AS (
  SELECT "SalesOrderNumber","SalesTerritoryKey",
         SUM(REPLACE(REPLACE("Sales",'$',''),',','')::numeric) AS total
  FROM Sales
  GROUP BY "SalesOrderNumber","SalesTerritoryKey"
)
SELECT "SalesTerritoryKey", AVG(total) AS media_pedido
FROM pedido
GROUP BY "SalesTerritoryKey";
    ```

    **Explicação.** Primeiro consolidamos por pedido; depois agregamos por território.


    ## Exercício 45 — Vendas mensais (converter data texto)
    **Enunciado.** Some o total de `Sales` por ano-mês do `OrderDate`.

    ```sql
    SELECT to_char(to_date("OrderDate", 'Day, Month DD, YYYY'), 'YYYY-MM') AS ano_mes,
       SUM(REPLACE(REPLACE("Sales",'$',''),',','')::numeric) AS total
FROM Sales
GROUP BY 1
ORDER BY 1;
    ```

    **Explicação.** Convertemos a string para data e agrupamos por formato `YYYY-MM`.


    ## Exercício 46 — CTE — número de pedidos por vendedor (>2)
    **Enunciado.** Traga vendedores com mais de dois pedidos somados.

    ```sql
    WITH pedidos_por_vendedor AS (
  SELECT "EmployeeKey", COUNT(DISTINCT "SalesOrderNumber") AS pedidos
  FROM Sales
  GROUP BY "EmployeeKey"
)
SELECT sp."Salesperson", p.pedidos
FROM pedidos_por_vendedor p
JOIN Salesperson sp ON sp."EmployeeKey" = p."EmployeeKey"
WHERE p.pedidos > 2
ORDER BY p.pedidos DESC;
    ```

    **Explicação.** CTE facilita reutilização e leitura da consulta.


    ## Exercício 47 — % de participação de cada vendedor na receita total
    **Enunciado.** Para cada `Salesperson`, calcule a participação na receita total.

    ```sql
    WITH receita AS (
  SELECT sp."Salesperson",
         SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS total
  FROM Sales s
  JOIN Salesperson sp ON sp."EmployeeKey" = s."EmployeeKey"
  GROUP BY sp."Salesperson"
), total_receita AS (
  SELECT SUM(total) AS t FROM receita
)
SELECT r."Salesperson", r.total,
       ROUND(100.0 * r.total / tr.t, 2) AS perc_total
FROM receita r CROSS JOIN total_receita tr
ORDER BY perc_total DESC;
    ```

    **Explicação.** Usamos CTE para receita por vendedor e `CROSS JOIN` para dividir pelo total geral.


    ## Exercício 48 — Tempo médio de entrega (proxy)
    **Enunciado.** Como `Sales` não tem datas de entrega, demonstre a extração de **dias do pedido** (exercício didático).

    ```sql
    SELECT EXTRACT(DAY FROM to_date("OrderDate", 'Day, Month DD, YYYY')) AS dia,
       COUNT(*) AS linhas
FROM Sales
GROUP BY 1
ORDER BY 1;
    ```

    **Explicação.** Exemplo de uso de funções de data; adapte para suas colunas reais de entrega quando disponíveis.


    ## Exercício 49 — Produto mais vendido por território
    **Enunciado.** Para cada `SalesTerritoryKey`, retorne o `ProductKey` mais vendido em quantidade.

    ```sql
    WITH qty AS (
  SELECT "SalesTerritoryKey","ProductKey",
         SUM("Quantity") AS q
  FROM Sales
  GROUP BY "SalesTerritoryKey","ProductKey"
), rk AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY "SalesTerritoryKey" ORDER BY q DESC) AS rk
  FROM qty
)
SELECT * FROM rk WHERE rk = 1;
    ```

    **Explicação.** Somamos quantidades e usamos `ROW_NUMBER()` particionado por território.


    ## Exercício 50 — Top 3 vendedores por mês (receita)
    **Enunciado.** Para cada ano-mês, traga os 3 vendedores com maior soma de `Sales`.

    ```sql
    WITH vendas AS (
  SELECT to_char(to_date(s."OrderDate", 'Day, Month DD, YYYY'), 'YYYY-MM') AS ano_mes,
         sp."Salesperson",
         SUM(REPLACE(REPLACE(s."Sales",'$',''),',','')::numeric) AS total
  FROM Sales s
  JOIN Salesperson sp ON sp."EmployeeKey" = s."EmployeeKey"
  GROUP BY 1,2
), r AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY ano_mes ORDER BY total DESC) AS rk
  FROM vendas
)
SELECT * FROM r WHERE rk <= 3
ORDER BY ano_mes, rk;
    ```

    **Explicação.** CTE + `ROW_NUMBER()` para rankeamento por partições temporais.
