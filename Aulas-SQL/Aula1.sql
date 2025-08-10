/*
AULA 1 — FUNDAMENTOS SQL COM OLIST (PostgreSQL)

Objetivo:
- SELECT, WHERE, operadores, funções de data/número/string
- DISTINCT, ORDER BY, LIMIT
- JOINs mais comuns (INNER/LEFT)
- GROUP BY + agregações
- Exercícios práticos no fim (com soluções comentadas)
*/

/* 0) Aquecimento: quantas linhas há em cada tabela? */
SELECT 'customers' AS tabela, COUNT(*) AS n FROM olist_customers_dataset UNION ALL
SELECT 'geolocation', COUNT(*) FROM olist_geolocation_dataset UNION ALL
SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset UNION ALL
SELECT 'order_payments', COUNT(*) FROM olist_order_payments_dataset UNION ALL
SELECT 'order_reviews', COUNT(*) FROM olist_order_reviews_dataset UNION ALL
SELECT 'orders', COUNT(*) FROM olist_orders_dataset UNION ALL
SELECT 'products', COUNT(*) FROM olist_products_dataset UNION ALL
SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset UNION ALL
SELECT 'category_translation', COUNT(*) FROM product_category_name_translation
ORDER BY 1;

/* 1) SELECT básico + LIMIT */
SELECT *
FROM olist_orders_dataset
LIMIT 10;

/* 2) Projeção de colunas + alias + tipos */
SELECT
  order_id,
  customer_id,
  order_status,
  order_purchase_timestamp,
  CAST(order_purchase_timestamp AS date) AS order_date
FROM olist_orders_dataset
LIMIT 5;

/* 3) WHERE com operadores lógicos e BETWEEN/IN/LIKE */
SELECT
  order_id, order_status, order_purchase_timestamp::date AS order_date
FROM olist_orders_dataset
WHERE order_status IN ('delivered','shipped')
  AND order_purchase_timestamp::date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
ORDER BY order_date
LIMIT 10;

/* 4) DISTINCT — quantos estados de cliente existem? */
SELECT DISTINCT customer_state
FROM olist_customers_dataset
ORDER BY 1;

/* 5) ORDER BY múltiplas colunas */
SELECT
  customer_city, customer_state
FROM olist_customers_dataset
ORDER BY customer_state, customer_city
LIMIT 20;

/* 6) Funções de string e datas */
SELECT
  order_id,
  order_status,
  order_purchase_timestamp,
  DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
  EXTRACT(dow FROM order_purchase_timestamp) AS weekday, -- 0=Domingo
  UPPER(order_status) AS status_upper
FROM olist_orders_dataset
LIMIT 10;

/* 7) JOIN básico: items + orders (receita bruta = price + freight) */
SELECT
  oi.order_id,
  o.order_purchase_timestamp::date AS order_date,
  SUM(oi.price + oi.freight_value) AS gross_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
GROUP BY oi.order_id, o.order_purchase_timestamp::date
ORDER BY gross_revenue DESC
LIMIT 10;

/* 8) JOIN com produtos e tradução de categoria */
SELECT
  oi.order_id,
  p.product_id,
  COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
  oi.price, oi.freight_value
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t
       ON t.product_category_name = p.product_category_name
LIMIT 10;

/* 9) GROUP BY + agregações: receita por mês */
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
  ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
GROUP BY 1
ORDER BY 1;

/* 10) Métricas por estado do cliente */
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS num_orders,
  ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
  ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_gross
FROM olist_orders_dataset o
JOIN olist_customers_dataset c USING (customer_id)
JOIN olist_order_items_dataset oi USING (order_id)
GROUP BY c.customer_state
ORDER BY total_gross DESC
LIMIT 10;

/* 11) TOP categorias por receita (com tradução) */
SELECT
  COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
  ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
  COUNT(*) AS items_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t
       ON t.product_category_name = p.product_category_name
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;

/* ==============================
   EXERCÍCIOS — AULA 1
   ==============================

E1) Listar os 20 clientes mais “ativos” por número de pedidos (apenas pedidos 'delivered').
    Mostrar: customer_unique_id, total_orders.

E2) Top 10 vendedores por receita total (price + freight), com o número de pedidos distintos.

E3) Receita diária de 2018-01-01 a 2018-06-30 (0 se não houver), ordenada por data.

E4) Média de review_score por categoria (em inglês), apenas com pelo menos 500 reviews.

E5) Para cada estado de vendedor (seller_state), quantos sellers distintos existem e a receita total gerada.

E6) Quais os 15 CEPs (prefixo) com maior número de clientes? Trazer city e state a partir da tabela geolocation.

E7) Em 2017, quais 10 cidades de cliente geraram mais pedidos entregues? Trazer também o estado.

-- SOLUÇÕES SUGERIDAS (descomentar para ver):

-- E1)
-- SELECT
--   c.customer_unique_id,
--   COUNT(DISTINCT o.order_id) AS total_orders
-- FROM olist_orders_dataset o
-- JOIN olist_customers_dataset c USING (customer_id)
-- WHERE o.order_status = 'delivered'
-- GROUP BY c.customer_unique_id
-- ORDER BY total_orders DESC
-- LIMIT 20;

-- E2)
-- SELECT
--   s.seller_id,
--   s.seller_state,
--   COUNT(DISTINCT oi.order_id) AS distinct_orders,
--   ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
-- FROM olist_order_items_dataset oi
-- JOIN olist_sellers_dataset s USING (seller_id)
-- GROUP BY s.seller_id, s.seller_state
-- ORDER BY revenue DESC
-- LIMIT 10;

-- E3)
-- WITH daily AS (
--   SELECT
--     o.order_purchase_timestamp::date AS dt,
--     SUM(oi.price + oi.freight_value) AS revenue
--   FROM olist_orders_dataset o
--   JOIN olist_order_items_dataset oi USING (order_id)
--   WHERE o.order_purchase_timestamp::date BETWEEN DATE '2018-01-01' AND DATE '2018-06-30'
--   GROUP BY o.order_purchase_timestamp::date
-- )
-- SELECT d::date AS dt,
--        COALESCE(daily.revenue, 0) AS revenue
-- FROM GENERATE_SERIES(DATE '2018-01-01', DATE '2018-06-30', INTERVAL '1 day') AS d
-- LEFT JOIN daily ON daily.dt = d
-- ORDER BY dt;

-- E4)
-- SELECT
--   COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
--   ROUND(AVG(r.review_score)::numeric, 2) AS avg_score,
--   COUNT(*) AS n_reviews
-- FROM olist_order_reviews_dataset r
-- JOIN olist_order_items_dataset oi USING (order_id)
-- JOIN olist_products_dataset p USING (product_id)
-- LEFT JOIN product_category_name_translation t
--        ON t.product_category_name = p.product_category_name
-- GROUP BY 1
-- HAVING COUNT(*) >= 500
-- ORDER BY avg_score DESC;

-- E5)
-- SELECT
--   s.seller_state,
--   COUNT(DISTINCT s.seller_id) AS sellers,
--   ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
-- FROM olist_sellers_dataset s
-- JOIN olist_order_items_dataset oi USING (seller_id)
-- GROUP BY s.seller_state
-- ORDER BY revenue DESC;

-- E6)
-- SELECT
--   c.customer_zip_code_prefix,
--   g.geolocation_city,
--   g.geolocation_state,
--   COUNT(*) AS n_customers
-- FROM olist_customers_dataset c
-- LEFT JOIN olist_geolocation_dataset g
--        ON g.geolocation_zip_code_prefix = c.customer_zip_code_prefix
-- GROUP BY c.customer_zip_code_prefix, g.geolocation_city, g.geolocation_state
-- ORDER BY n_customers DESC
-- LIMIT 15;

-- E7)
-- SELECT
--   c.customer_city,
--   c.customer_state,
--   COUNT(DISTINCT o.order_id) AS delivered_orders_2017
-- FROM olist_orders_dataset o
-- JOIN olist_customers_dataset c USING (customer_id)
-- WHERE o.order_status = 'delivered'
--   AND o.order_purchase_timestamp::date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
-- GROUP BY c.customer_city, c.customer_state
-- ORDER BY delivered_orders_2017 DESC
-- LIMIT 10;

*/
