

# README — Curso Prático de SQL (PostgreSQL) com o dataset Olist

## Pré‑requisitos
- PostgreSQL instalado (psql ou pgAdmin).
- Tabelas já criadas (mesmos nomes dos CSVs):  
  olist_customers_dataset, olist_geolocation_dataset, olist_order_items_dataset,  
  olist_order_payments_dataset, olist_order_reviews_dataset, olist_orders_dataset,  
  olist_products_dataset, olist_sellers_dataset, product_category_name_translation.

### Relações úteis (chaves mais usadas)
- olist_orders_dataset.order_id ↔ olist_order_items_dataset.order_id
- olist_orders_dataset.customer_id ↔ olist_customers_dataset.customer_id
- olist_order_items_dataset.product_id ↔ olist_products_dataset.product_id
- olist_order_items_dataset.seller_id ↔ olist_sellers_dataset.seller_id
- olist_order_payments_dataset.order_id ↔ olist_orders_dataset.order_id
- olist_order_reviews_dataset.order_id ↔ olist_orders_dataset.order_id
- product_category_name_translation.product_category_name ↔ olist_products_dataset.product_category_name

---

## Aula 1 — Fundamentos (SELECT, WHERE, JOIN, GROUP BY, ORDER BY, DISTINCT)
### 1) SELECT básico
```sql
SELECT order_id, customer_id, order_status, order_purchase_timestamp
FROM olist_orders_dataset
LIMIT 10;
```

### 2) WHERE com filtros
```sql
SELECT order_id, order_purchase_timestamp::date AS order_date, order_status
FROM olist_orders_dataset
WHERE order_status IN ('delivered','shipped')
  AND order_purchase_timestamp::date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
ORDER BY order_date;
```

### 3) JOIN e receita bruta
```sql
SELECT o.order_purchase_timestamp::date AS order_date,
       SUM(oi.price + oi.freight_value) AS gross_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
GROUP BY order_date
ORDER BY order_date;
```

---

## Aula 2 — Intermédio/Avançado (CASE WHEN, HAVING, CTE, Window, DDL segura)
### 1) CASE WHEN
```sql
SELECT order_id, order_purchase_timestamp::date AS purchase_date,
       CASE
         WHEN order_delivered_customer_date IS NULL THEN 'not_delivered'
         WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
         ELSE 'late'
       END AS delivery_status
FROM olist_orders_dataset
LIMIT 15;
```

### 2) CTE + Window Functions
```sql
WITH revenue_by_cat_month AS (
  SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
         COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
         SUM(oi.price + oi.freight_value) AS revenue
  FROM olist_order_items_dataset oi
  JOIN olist_orders_dataset o USING (order_id)
  JOIN olist_products_dataset p USING (product_id)
  LEFT JOIN product_category_name_translation t
         ON t.product_category_name = p.product_category_name
  GROUP BY 1, 2
)
SELECT month, category_en, revenue,
       RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank_in_month
FROM revenue_by_cat_month
ORDER BY month, rank_in_month;
```

### 3) TEMP TABLE segura
```sql
CREATE TEMP TABLE tmp_orders_2017 AS
SELECT *
FROM olist_orders_dataset
WHERE order_purchase_timestamp::date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31';
ALTER TABLE tmp_orders_2017 ADD COLUMN purchase_date date;
UPDATE tmp_orders_2017 SET purchase_date = order_purchase_timestamp::date;
```

---

## Exercícios Sugeridos
**Aula 1**
1) Top 20 clientes por nº de pedidos *delivered*.
2) Top 10 sellers por receita total.
3) Receita diária de um intervalo de datas.
4) Média de review_score por categoria (mínimo 500 reviews).

**Aula 2**
1) Criar TEMP TABLE de pedidos delivered 2018 e marcar fins de semana.
2) Ranking mensal de categorias (HAVING >= 50000 revenue).
3) Média móvel 7 dias de receita.
4) Sequência de pedidos por cliente com LAG().

---

## Cheatsheet
- Conversões de data: `::date`, `DATE_TRUNC`, `EXTRACT`
- Funções de janela: `ROW_NUMBER`, `RANK`, `LAG`, `AVG OVER`
- Boas práticas: trabalhar com TEMP TABLES para não alterar dados originais.
