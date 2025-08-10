/*
AULA 2 — TÓPICOS INTERMÉDIOS/AVANÇADOS (PostgreSQL)

Objetivo:
- CASE WHEN
- HAVING
- CTEs (WITH)
- Window functions (ROW_NUMBER, RANK, DENSE_RANK, LAG/LEAD, SUM OVER, média móvel, NTILE)
- Boas práticas de manipulação: CREATE TABLE AS, TEMP tables, ALTER TABLE, UPDATE, DELETE, TRUNCATE, DROP
- Exercícios práticos (com soluções comentadas)
*/

/* 1) CASE WHEN — categorizar tempo de entrega real vs estimado */
SELECT
  o.order_id,
  o.order_purchase_timestamp::date AS purchase_date,
  o.order_delivered_customer_date::date AS delivered_date,
  o.order_estimated_delivery_date::date AS estimated_date,
  CASE
    WHEN o.order_delivered_customer_date IS NULL THEN 'not_delivered'
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'on_time'
    ELSE 'late'
  END AS delivery_status
FROM olist_orders_dataset o
LIMIT 15;

/* 2) HAVING — filtrar grupos após agregação */
SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS delivered_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c USING (customer_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 1000
ORDER BY delivered_orders DESC;

/* 3) CTE + Window: ranking de categorias por receita mensal */
WITH revenue_by_cat_month AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM olist_order_items_dataset oi
  JOIN olist_orders_dataset o USING (order_id)
  JOIN olist_products_dataset p USING (product_id)
  LEFT JOIN product_category_name_translation t
         ON t.product_category_name = p.product_category_name
  GROUP BY 1, 2
)
SELECT
  month,
  category_en,
  revenue,
  RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank_in_month
FROM revenue_by_cat_month
ORDER BY month, rank_in_month
LIMIT 50;

/* 4) Window: LAG/LEAD — variação mensal da receita total */
WITH monthly AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM olist_order_items_dataset oi
  JOIN olist_orders_dataset o USING (order_id)
  GROUP BY 1
)
SELECT
  month,
  revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
  (revenue - LAG(revenue) OVER (ORDER BY month)) AS abs_change,
  ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month),0), 2) AS pct_change
FROM monthly
ORDER BY month;

/* 5) Window: SUM OVER (rolling) — média móvel de 3 meses */
WITH monthly AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM olist_order_items_dataset oi
  JOIN olist_orders_dataset o USING (order_id)
  GROUP BY 1
)
SELECT
  month,
  revenue,
  ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::numeric, 2) AS ma3
FROM monthly
ORDER BY month;

/* 6) Window por cliente — recência e n.º de pedidos */
WITH orders_by_client AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp::date AS order_date
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c USING (customer_id)
  WHERE o.order_status IN ('delivered','shipped','invoiced','processing','created','approved')
)
SELECT
  customer_unique_id,
  order_id,
  order_date,
  ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY order_date) AS order_seq,
  MAX(order_date) OVER (PARTITION BY customer_unique_id) AS last_order_date,
  COUNT(*) OVER (PARTITION BY customer_unique_id) AS total_orders
FROM orders_by_client
ORDER BY customer_unique_id, order_seq
LIMIT 50;

/* 7) NTILE — segmentação de sellers por receita (quartis) */
WITH seller_rev AS (
  SELECT
    s.seller_id,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM olist_order_items_dataset oi
  JOIN olist_sellers_dataset s USING (seller_id)
  GROUP BY s.seller_id
)
SELECT
  seller_id,
  revenue,
  NTILE(4) OVER (ORDER BY revenue DESC) AS quartile
FROM seller_rev
ORDER BY revenue DESC
LIMIT 50;

/* 8) CREATE TABLE AS (cópia de trabalho) + ALTER/UPDATE/DELETE/TRUNCATE/DROP
   (Boas práticas: trabalhar numa TABELA TEMPORÁRIA para não mexer nos dados base)
*/
DROP TABLE IF EXISTS tmp_orders_sample;
CREATE TEMP TABLE tmp_orders_sample AS
SELECT *
FROM olist_orders_dataset
WHERE order_purchase_timestamp::date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31';

-- ALTER TABLE: adicionar coluna e renomear
ALTER TABLE tmp_orders_sample ADD COLUMN purchase_date date;
UPDATE tmp_orders_sample
SET purchase_date = order_purchase_timestamp::date;

ALTER TABLE tmp_orders_sample RENAME COLUMN order_status TO status;

-- DELETE: remover linhas com status cancelado
DELETE FROM tmp_orders_sample
WHERE status = 'canceled';

-- TRUNCATE: (exemplo; comentado por segurança)
-- TRUNCATE TABLE tmp_orders_sample;

-- DROP: (no fim desta secção, vamos eliminar a tabela temporária)
-- DROP TABLE tmp_orders_sample;

/* 9) Pagamentos: consolidar valor total pago por pedido + nº de parcelas (máximo) com window */
WITH pay AS (
  SELECT
    order_id,
    SUM(payment_value) AS total_paid,
    MAX(payment_installments) AS max_installments
  FROM olist_order_payments_dataset
  GROUP BY order_id
)
SELECT
  o.order_id,
  o.order_purchase_timestamp::date AS order_date,
  pay.total_paid,
  pay.max_installments,
  SUM(oi.price + oi.freight_value) AS gross_value,
  CASE
    WHEN pay.total_paid IS NULL THEN 'no_payment'
    WHEN pay.total_paid >= SUM(oi.price + oi.freight_value) THEN 'paid_full_or_more'
    ELSE 'paid_less'
  END AS payment_flag
FROM olist_orders_dataset o
LEFT JOIN pay USING (order_id)
LEFT JOIN olist_order_items_dataset oi USING (order_id)
GROUP BY o.order_id, o.order_purchase_timestamp::date, pay.total_paid, pay.max_installments
ORDER BY o.order_purchase_timestamp::date
LIMIT 50;

/* 10) Juntar reviews e calcular NPS simples (CASE WHEN) por mês */
WITH review_scored AS (
  SELECT
    r.order_id,
    r.review_score,
    CASE
      WHEN r.review_score IN (4,5) THEN 'promoter'
      WHEN r.review_score = 3 THEN 'neutral'
      ELSE 'detractor'
    END AS nps_bucket
  FROM olist_order_reviews_dataset r
),
monthly_nps AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(*) FILTER (WHERE nps_bucket='promoter') AS promoters,
    COUNT(*) FILTER (WHERE nps_bucket='detractor') AS detractors,
    COUNT(*) AS total_reviews
  FROM olist_orders_dataset o
  JOIN review_scored rs USING (order_id)
  GROUP BY 1
)
SELECT
  month,
  promoters,
  detractors,
  total_reviews,
  ROUND(100.0 * (promoters::numeric - detractors::numeric) / NULLIF(total_reviews,0), 2) AS nps
FROM monthly_nps
ORDER BY month;

/* 11) Encerramento da secção de DDL temporária */
DROP TABLE IF EXISTS tmp_orders_sample;

/* ==============================
   EXERCÍCIOS — AULA 2
   ==============================

E1) Criar uma TEMP TABLE com pedidos 'delivered' de 2018. Adicionar colunas:
    - order_date (date)
    - is_weekend (CASE WHEN EXTRACT(dow)=0 OU 6 então 1 senão 0)
    Remover (DELETE) linhas com order_date NULL. Listar 10 linhas.

E2) Por categoria (em inglês), trazer receita de 2018-01 a 2018-12 e o RANK dentro de cada mês.
    Mostrar: month, category_en, revenue, rank_in_month. Filtrar categorias com revenue >= 50k/mês (HAVING).

E3) Calcular receita diária com média móvel de 7 dias (AVG OVER ... ROWS BETWEEN 6 PRECEDING AND CURRENT ROW).

E4) Para cada cliente (customer_unique_id), numerar os pedidos por ordem de compra e trazer também o LAG do order_date.

E5) Classificar sellers em 5 NTILEs por receita total. Para o top NTILE (1), obter as 10 categorias mais vendidas.

E6) Criar uma tabela de trabalho (CREATE TABLE AS) com os 1000 pedidos mais recentes.
    ALTER TABLE para adicionar coluna 'items_count' e preencher com o número de itens do pedido.
    Depois TRUNCATE essa tabela e finalmente DROP.

-- SOLUÇÕES SUGERIDAS (descomentar por partes):

-- E1)
-- DROP TABLE IF EXISTS tmp_delivered_2018;
-- CREATE TEMP TABLE tmp_delivered_2018 AS
-- SELECT *
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_purchase_timestamp::date BETWEEN DATE '2018-01-01' AND DATE '2018-12-31';
-- ALTER TABLE tmp_delivered_2018 ADD COLUMN order_date date;
-- UPDATE tmp_delivered_2018 SET order_date = order_purchase_timestamp::date;
-- ALTER TABLE tmp_delivered_2018 ADD COLUMN is_weekend int2;
-- UPDATE tmp_delivered_2018
-- SET is_weekend = CASE WHEN EXTRACT(dow FROM order_date) IN (0,6) THEN 1 ELSE 0 END;
-- DELETE FROM tmp_delivered_2018 WHERE order_date IS NULL;
-- SELECT * FROM tmp_delivered_2018 LIMIT 10;

-- E2)
-- WITH base AS (
--   SELECT
--     DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
--     COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
--     SUM(oi.price + oi.freight_value) AS revenue
--   FROM olist_order_items_dataset oi
--   JOIN olist_orders_dataset o USING (order_id)
--   JOIN olist_products_dataset p USING (product_id)
--   LEFT JOIN product_category_name_translation t
--          ON t.product_category_name = p.product_category_name
--   WHERE o.order_purchase_timestamp::date BETWEEN DATE '2018-01-01' AND DATE '2018-12-31'
--   GROUP BY 1,2
-- ), filtered AS (
--   SELECT * FROM base
--   HAVING revenue >= 50000
-- )
-- SELECT
--   month, category_en, revenue,
--   RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank_in_month
-- FROM filtered
-- ORDER BY month, rank_in_month;

-- E3)
-- WITH daily AS (
--   SELECT
--     o.order_purchase_timestamp::date AS day,
--     SUM(oi.price + oi.freight_value) AS revenue
--   FROM olist_orders_dataset o
--   JOIN olist_order_items_dataset oi USING (order_id)
--   GROUP BY 1
-- )
-- SELECT
--   day, revenue,
--   ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)::numeric, 2) AS ma7
-- FROM daily
-- ORDER BY day;

-- E4)
-- WITH orders_by_client AS (
--   SELECT
--     c.customer_unique_id,
--     o.order_id,
--     o.order_purchase_timestamp::date AS order_date
--   FROM olist_orders_dataset o
--   JOIN olist_customers_dataset c USING (customer_id)
-- )
-- SELECT
--   customer_unique_id,
--   order_id,
--   order_date,
--   ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY order_date) AS rn,
--   LAG(order_date) OVER (PARTITION BY customer_unique_id ORDER BY order_date) AS prev_order_date
-- FROM orders_by_client
-- ORDER BY customer_unique_id, rn
-- LIMIT 50;

-- E5)
-- WITH seller_rev AS (
--   SELECT s.seller_id, SUM(oi.price + oi.freight_value) AS revenue
--   FROM olist_order_items_dataset oi
--   JOIN olist_sellers_dataset s USING (seller_id)
--   GROUP BY s.seller_id
-- ), ranked AS (
--   SELECT seller_id, revenue, NTILE(5) OVER (ORDER BY revenue DESC) AS tile
--   FROM seller_rev
-- )
-- SELECT
--   COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
--   SUM(oi.price + oi.freight_value) AS revenue_top_sellers
-- FROM ranked r
-- JOIN olist_order_items_dataset oi USING (seller_id)
-- JOIN olist_products_dataset p USING (product_id)
-- LEFT JOIN product_category_name_translation t
--        ON t.product_category_name = p.product_category_name
-- WHERE r.tile = 1
-- GROUP BY 1
-- ORDER BY revenue_top_sellers DESC
-- LIMIT 10;

-- E6)
-- DROP TABLE IF EXISTS work_recent_orders;
-- CREATE TABLE work_recent_orders AS
-- SELECT *
-- FROM olist_orders_dataset
-- ORDER BY order_purchase_timestamp DESC
-- LIMIT 1000;
-- ALTER TABLE work_recent_orders ADD COLUMN items_count int;
-- UPDATE work_recent_orders w
-- SET items_count = sub.cnt
-- FROM (
--   SELECT order_id, COUNT(*) AS cnt
--   FROM olist_order_items_dataset
--   GROUP BY order_id
-- ) sub
-- WHERE sub.order_id = w.order_id;
-- -- Revisão rápida:
-- SELECT COUNT(*) AS linhas, SUM(items_count) AS total_itens FROM work_recent_orders;
-- TRUNCATE TABLE work_recent_orders;
-- DROP TABLE work_recent_orders;

*/
