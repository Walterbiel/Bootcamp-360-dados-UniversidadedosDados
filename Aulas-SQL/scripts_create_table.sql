-- =========================================================
-- OLIST - Estruturas PostgreSQL
-- Cria schema, tabelas, chaves e índices
-- =========================================================

-- (Opcional) crie o database antes, caso ainda não exista:
-- CREATE DATABASE olist WITH ENCODING 'UTF8' TEMPLATE template1;

-- Use o banco desejado e crie um schema dedicado
-- \c olist;
CREATE SCHEMA IF NOT EXISTS olist;
SET search_path TO olist, public;

-- =========================================================
-- Tabela: customers
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.customers (
    customer_id               VARCHAR(50)  PRIMARY KEY,
    customer_unique_id        VARCHAR(50),
    customer_zip_code_prefix  INTEGER,
    customer_city             VARCHAR(255),
    customer_state            VARCHAR(2)
);

CREATE INDEX IF NOT EXISTS idx_customers_zip ON olist.customers(customer_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_customers_state ON olist.customers(customer_state);

-- =========================================================
-- Tabela: geolocation
-- Observação: um CEP pode ter múltiplas coordenadas.
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            VARCHAR(255),
    geolocation_state           VARCHAR(2),
    -- chave técnica opcional
    geolocation_id              BIGSERIAL PRIMARY KEY
);

CREATE INDEX IF NOT EXISTS idx_geo_zip ON olist.geolocation(geolocation_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_geo_city ON olist.geolocation(geolocation_city);
CREATE INDEX IF NOT EXISTS idx_geo_state ON olist.geolocation(geolocation_state);

-- =========================================================
-- Tabela: orders
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.orders (
    order_id                       VARCHAR(50) PRIMARY KEY,
    customer_id                    VARCHAR(50) NOT NULL,
    order_status                   VARCHAR(50),
    order_purchase_timestamp       TIMESTAMP WITHOUT TIME ZONE,
    order_approved_at              TIMESTAMP WITHOUT TIME ZONE,
    order_delivered_carrier_date   TIMESTAMP WITHOUT TIME ZONE,
    order_delivered_customer_date  TIMESTAMP WITHOUT TIME ZONE,
    order_estimated_delivery_date  TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES olist.customers(customer_id)
);

CREATE INDEX IF NOT EXISTS idx_orders_customer ON olist.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON olist.orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_purchase_ts ON olist.orders(order_purchase_timestamp);

-- =========================================================
-- Tabela: order_items
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.order_items (
    order_id            VARCHAR(50) NOT NULL,
    order_item_id       INTEGER     NOT NULL,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date TIMESTAMP WITHOUT TIME ZONE,
    price               NUMERIC(12,2),
    freight_value       NUMERIC(12,2),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_oi_order   FOREIGN KEY (order_id)  REFERENCES olist.orders(order_id),
    CONSTRAINT fk_oi_product FOREIGN KEY (product_id) REFERENCES olist.products(product_id),
    CONSTRAINT fk_oi_seller  FOREIGN KEY (seller_id)  REFERENCES olist.sellers(seller_id)
);

CREATE INDEX IF NOT EXISTS idx_oi_product ON olist.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_oi_seller  ON olist.order_items(seller_id);

-- =========================================================
-- Tabela: order_payments
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.order_payments (
    order_id             VARCHAR(50) NOT NULL,
    payment_sequential   INTEGER     NOT NULL,
    payment_type         VARCHAR(50),
    payment_installments INTEGER,
    payment_value        NUMERIC(12,2),
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_op_order FOREIGN KEY (order_id) REFERENCES olist.orders(order_id)
);

CREATE INDEX IF NOT EXISTS idx_op_type ON olist.order_payments(payment_type);

-- =========================================================
-- Tabela: order_reviews
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.order_reviews (
    review_id               VARCHAR(50) PRIMARY KEY,
    order_id                VARCHAR(50),
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP WITHOUT TIME ZONE,
    review_answer_timestamp TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT fk_or_order FOREIGN KEY (order_id) REFERENCES olist.orders(order_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_order ON olist.order_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_reviews_score ON olist.order_reviews(review_score);

-- =========================================================
-- Tabela: products
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name       VARCHAR(255),
    product_name_length         INTEGER,
    product_description_length  INTEGER,
    product_photos_qty          INTEGER,
    product_weight_g            INTEGER,
    product_length_cm           INTEGER,
    product_height_cm           INTEGER,
    product_width_cm            INTEGER
);

CREATE INDEX IF NOT EXISTS idx_products_category ON olist.products(product_category_name);

-- =========================================================
-- Tabela: sellers
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.sellers (
    seller_id               VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix  INTEGER,
    seller_city             VARCHAR(255),
    seller_state            VARCHAR(2)
);

CREATE INDEX IF NOT EXISTS idx_sellers_zip ON olist.sellers(seller_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_sellers_state ON olist.sellers(seller_state);

-- =========================================================
-- Tabela: product_category_name_translation
-- =========================================================
CREATE TABLE IF NOT EXISTS olist.product_category_name_translation (
    product_category_name         VARCHAR(255) PRIMARY KEY,
    product_category_name_english VARCHAR(255)
);

-- (Opcional) FK de products -> translations (nem todas as categorias têm tradução em alguns dumps)
-- Se seu dataset garantir cobertura total, descomente:
-- ALTER TABLE olist.products
-- ADD CONSTRAINT fk_products_category_translation
-- FOREIGN KEY (product_category_name)
-- REFERENCES olist.product_category_name_translation(product_category_name);

-- =========================================================
-- Vistas úteis (opcionais)
-- =========================================================

-- Valor total do pedido (itens + frete)
CREATE OR REPLACE VIEW olist.vw_order_totals AS
SELECT
    oi.order_id,
    SUM(oi.price)        AS items_total,
    SUM(oi.freight_value) AS freight_total,
    SUM(oi.price + oi.freight_value) AS order_total
FROM olist.order_items oi
GROUP BY oi.order_id;

-- Fato de pagamentos por pedido
CREATE OR REPLACE VIEW olist.vw_order_payments_agg AS
SELECT
    op.order_id,
    COUNT(*)                  AS payments_count,
    SUM(op.payment_value)     AS payments_value,
    MAX(op.payment_installments) AS max_installments
FROM olist.order_payments op
GROUP BY op.order_id;

-- =========================================================
-- Índices adicionais úteis para análises
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_orders_delivered_customer_date
    ON olist.orders(order_delivered_customer_date);

CREATE INDEX IF NOT EXISTS idx_oi_shipping_limit
    ON olist.order_items(shipping_limit_date);

-- =========================================================
-- FIM
-- =========================================================
