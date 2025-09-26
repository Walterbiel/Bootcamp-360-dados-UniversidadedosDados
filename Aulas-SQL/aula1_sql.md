# 📘 Aula 1 — SQL (3h)

## 🎯 Objetivos
- Dominar consultas SQL básicas e intermediárias:  
  `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, `ORDER BY`, `DISTINCT`, `HAVING`  
- Aplicar funções de agregação: `SUM`, `AVG`, `COUNT`, `MAX`, `MIN`  
- Gerenciar estruturas de tabelas: `CREATE`, `ALTER`, `DROP`, `DELETE`, `TRUNCATE`  
- Compreender chaves primárias, constraints e índices  

---

## ⏰ Estrutura
- Introdução: 10 min  
- SELECT + WHERE: 25 min  
- JOINs: 40 min  
- GROUP BY + HAVING: 35 min  
- ORDER BY + DISTINCT: 15 min  
- DDL/DML (CREATE, ALTER, DROP...): 30 min  
- Constraints e Índices: 20 min  
- Encerramento: 5 min  

---

## 1) SELECT + WHERE

### Exemplos
```sql
SELECT customer_id, customer_city, customer_state
FROM olist.olist_customers;

SELECT * FROM olist.olist_orders
WHERE order_status = 'delivered';

SELECT order_id, order_purchase_timestamp
FROM olist.olist_orders
WHERE order_purchase_timestamp BETWEEN '2017-01-01' AND '2017-12-31';
```

### Exercícios
1. Liste `order_id`, `order_status` de pedidos de 2017.  
2. Traga clientes do estado **SP** e cidade começando por "Sao".  
3. Liste pedidos entregues ou enviados (`delivered/shipped`) que tenham itens com `price > 500`.

#### Gabarito
```sql
-- 1
SELECT order_id, order_status
FROM olist.olist_orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp < '2018-01-01';

-- 2
SELECT customer_id, customer_city, customer_state
FROM olist.olist_customers
WHERE customer_state = 'SP'
  AND customer_city ILIKE 'sao%';

-- 3
SELECT o.order_id, o.order_status
FROM olist.olist_orders o
WHERE o.order_status IN ('delivered','shipped')
  AND EXISTS (
    SELECT 1
    FROM olist.olist_order_items i
    WHERE i.order_id = o.order_id
      AND i.price > 500
  );
```

---

## 2) JOINs

### Exemplos
```sql
-- INNER JOIN
SELECT o.order_id, c.customer_state
FROM olist.olist_orders o
INNER JOIN olist.olist_customers c ON c.customer_id = o.customer_id;

-- LEFT JOIN
SELECT o.order_id, r.review_score
FROM olist.olist_orders o
LEFT JOIN olist.olist_order_reviews r ON r.order_id = o.order_id;
```

### Exercícios
1. Traga `order_id`, `seller_id`, `price` juntando `olist_order_items` e `olist_sellers`.  
2. Liste produtos sem pedidos.  
3. Liste clientes sem pedidos.

#### Gabarito
```sql
-- 1
SELECT oi.order_id, oi.seller_id, oi.price
FROM olist.olist_order_items oi
JOIN olist.olist_sellers s ON s.seller_id = oi.seller_id;

-- 2
SELECT p.product_id, p.product_category_name
FROM olist.olist_products p
LEFT JOIN olist.olist_order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- 3
SELECT c.customer_id, c.customer_city, c.customer_state
FROM olist.olist_customers c
LEFT JOIN olist.olist_orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
```

---

## 3) ORDER BY + DISTINCT

### Exemplos
```sql
SELECT DISTINCT customer_city
FROM olist.olist_customers
ORDER BY customer_city;

SELECT order_id, order_purchase_timestamp
FROM olist.olist_orders
ORDER BY order_purchase_timestamp DESC
LIMIT 10;
```

### Exercícios
1. Liste os estados únicos dos vendedores, em ordem alfabética.  
2. Traga as 5 categorias com maior peso médio.

#### Gabarito
```sql
-- 1
SELECT DISTINCT seller_state
FROM olist.olist_sellers
ORDER BY seller_state;

-- 2
SELECT product_category_name,
       AVG(product_weight_g)::numeric(12,2) AS peso_medio
FROM olist.olist_products
GROUP BY product_category_name
ORDER BY peso_medio DESC
LIMIT 5;
```

---

## 4) GROUP BY + HAVING

### Exemplos
```sql
SELECT c.customer_state, COUNT(*) AS total_pedidos
FROM olist.olist_orders o
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_pedidos DESC;
```

### Exercícios
1. Média de frete por estado (somente > 20).  
2. Top 5 produtos por quantidade vendida.  
3. Categorias com mais de 1000 itens vendidos.

#### Gabarito
```sql
-- 1
SELECT c.customer_state,
       AVG(oi.freight_value)::numeric(12,2) AS frete_medio
FROM olist.olist_orders o
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_state
HAVING AVG(oi.freight_value) > 20
ORDER BY frete_medio DESC;

-- 2
SELECT oi.product_id, COUNT(*) AS qtd_itens
FROM olist.olist_order_items oi
GROUP BY oi.product_id
ORDER BY qtd_itens DESC
LIMIT 5;

-- 3
SELECT p.product_category_name, COUNT(*) AS itens_vendidos
FROM olist.olist_order_items oi
JOIN olist.olist_products p ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING COUNT(*) > 1000
ORDER BY itens_vendidos DESC;
```

---

## 5) DDL/DML (CREATE, ALTER, DROP, DELETE, TRUNCATE)

### Exemplos
```sql
CREATE TABLE treino.test_orders (
  id SERIAL PRIMARY KEY,
  order_id TEXT NOT NULL,
  total_value NUMERIC(12,2) CHECK (total_value >= 0),
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE treino.test_orders ADD COLUMN is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE treino.test_orders DROP COLUMN is_active;

TRUNCATE TABLE treino.test_orders;
DROP TABLE treino.test_orders;
```

### Exercícios
1. Crie `tmp_customers` com `id SERIAL PK`, `customer_id TEXT UNIQUE NOT NULL`, `created_at TIMESTAMP DEFAULT NOW()`.  
2. Adicione coluna `source TEXT`, depois remova.  
3. Insira 3 linhas e trunque a tabela.

#### Gabarito
```sql
-- 1
CREATE TABLE treino.tmp_customers (
  id SERIAL PRIMARY KEY,
  customer_id TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2
ALTER TABLE treino.tmp_customers ADD COLUMN source TEXT;
ALTER TABLE treino.tmp_customers DROP COLUMN source;

-- 3
INSERT INTO treino.tmp_customers (customer_id) VALUES
 ('cust_001'), ('cust_002'), ('cust_003');

TRUNCATE TABLE treino.tmp_customers;
```

---

## 6) Constraints e Índices

### Exemplos
```sql
CREATE TABLE treino.order_line (
  order_id TEXT,
  item_id INT,
  product_id TEXT NOT NULL,
  qty INT CHECK (qty > 0),
  price NUMERIC(12,2) CHECK (price >= 0),
  PRIMARY KEY (order_id, item_id),
  FOREIGN KEY (product_id) REFERENCES olist.olist_products(product_id)
);

CREATE INDEX idx_order_line_product ON treino.order_line(product_id);
```

### Exercícios
1. Crie `customer_email` com `id SERIAL PK`, `customer_id TEXT NOT NULL`, `email TEXT UNIQUE NOT NULL` e `CHECK (position('@' in email) > 1)`.  
2. Adicione FK para `olist_customers(customer_id)`.  
3. Crie índices em `email` e `(customer_id,email)`.

#### Gabarito
```sql
-- 1
CREATE TABLE treino.customer_email (
  id SERIAL PRIMARY KEY,
  customer_id TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  CONSTRAINT chk_email CHECK (position('@' in email) > 1)
);

-- 2
ALTER TABLE treino.customer_email
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id)
REFERENCES olist.olist_customers(customer_id);

-- 3
CREATE INDEX idx_customer_email_email
  ON treino.customer_email(email);

CREATE INDEX idx_customer_email_comp
  ON treino.customer_email(customer_id, email);
```

---

## 7) Mini-projeto de fechamento

**Desafio:** Relatório com top 10 sellers por receita, número de pedidos, ticket médio e % de entregues.

#### Gabarito
```sql
WITH receita_seller AS (
  SELECT seller_id, SUM(price + freight_value) AS receita
  FROM olist.olist_order_items
  GROUP BY seller_id
),
top10 AS (
  SELECT seller_id
  FROM receita_seller
  ORDER BY receita DESC
  LIMIT 10
),
pedidos_por_seller AS (
  SELECT oi.seller_id, oi.order_id,
         SUM(oi.price + oi.freight_value) AS valor_pedido
  FROM olist.olist_order_items oi
  GROUP BY oi.seller_id, oi.order_id
),
status_pedidos AS (
  SELECT order_id,
         CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END AS entregue
  FROM olist.olist_orders
)
SELECT pps.seller_id,
       COUNT(DISTINCT pps.order_id) AS pedidos,
       SUM(pps.valor_pedido) AS receita_total,
       (SUM(pps.valor_pedido)/COUNT(DISTINCT pps.order_id))::numeric(12,2) AS ticket_medio,
       (SUM(sp.entregue)::numeric / COUNT(sp.entregue))::numeric(5,2) AS pct_entregue
FROM pedidos_por_seller pps
JOIN top10 t ON t.seller_id = pps.seller_id
JOIN status_pedidos sp ON sp.order_id = pps.order_id
GROUP BY pps.seller_id
ORDER BY receita_total DESC;
```
