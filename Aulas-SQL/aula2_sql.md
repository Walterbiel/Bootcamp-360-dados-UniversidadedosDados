# 📘 Aula 2 — SQL Intermediário/Avançado (3h)

## 🎯 Objetivos
- Usar `CASE WHEN` para criar colunas condicionais  
- Aplicar **subqueries** (simples e correlacionadas)  
- Explorar **CTEs (Common Table Expressions)**  
- Criar e consultar **Views**  
- Dominar **Window Functions**  
- Combinar dados com `UNION`, `INTERSECT`, `EXCEPT`  
- Trabalhar com funções de texto e datas  

---

## ⏰ Estrutura
- Revisão: 5 min  
- CASE WHEN: 20 min  
- Subqueries: 30 min  
- CTEs: 25 min  
- Views: 15 min  
- Window Functions: 50 min  
- UNION/INTERSECT/EXCEPT: 20 min  
- Funções de Texto e Data: 15 min  
- Mini-projeto: 10 min  

---

## 1) CASE WHEN

### Exemplo
```sql
SELECT order_id,
       review_score,
       CASE 
         WHEN review_score >= 4 THEN 'Bom'
         WHEN review_score = 3 THEN 'Neutro'
         ELSE 'Ruim'
       END AS categoria
FROM olist.olist_order_reviews;
```

### Exercício
Classifique `payment_value` em: "Baixo" (<100), "Médio" (100–500), "Alto" (>500).  

#### Gabarito
```sql
SELECT order_id, payment_value,
       CASE 
         WHEN payment_value < 100 THEN 'Baixo'
         WHEN payment_value BETWEEN 100 AND 500 THEN 'Médio'
         ELSE 'Alto'
       END AS faixa_pagamento
FROM olist.olist_order_payments;
```

---

## 2) Subqueries

### Exemplos
```sql
-- Inline subquery
SELECT order_id, (SELECT AVG(payment_value) 
                  FROM olist.olist_order_payments p
                  WHERE p.order_id = o.order_id) AS media_pagamento
FROM olist.olist_orders o;

-- Correlated subquery
SELECT c.customer_id, c.customer_city
FROM olist.olist_customers c
WHERE EXISTS (
  SELECT 1
  FROM olist.olist_orders o
  WHERE o.customer_id = c.customer_id
    AND o.order_status = 'delivered'
);
```

### Exercícios
1. Liste os **clientes que gastaram acima da média geral**.  
2. Liste os **pedidos que tiveram valor de frete acima da média do próprio estado**.  

#### Gabarito
```sql
-- 1
SELECT c.customer_id, SUM(op.payment_value) AS gasto
FROM olist.olist_customers c
JOIN olist.olist_orders o ON o.customer_id = c.customer_id
JOIN olist.olist_order_payments op ON op.order_id = o.order_id
GROUP BY c.customer_id
HAVING SUM(op.payment_value) > (
    SELECT AVG(payment_value) FROM olist.olist_order_payments
);

-- 2
SELECT o.order_id, SUM(oi.freight_value) AS frete
FROM olist.olist_orders o
JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
GROUP BY o.order_id, c.customer_state
HAVING SUM(oi.freight_value) >
       (SELECT AVG(oi2.freight_value)
        FROM olist.olist_orders o2
        JOIN olist.olist_order_items oi2 ON oi2.order_id = o2.order_id
        JOIN olist.olist_customers c2 ON c2.customer_id = o2.customer_id
        WHERE c2.customer_state = c.customer_state);
```

---

## 3) CTEs (Common Table Expressions)

### Exemplo
```sql
WITH vendas_cliente AS (
  SELECT o.customer_id, SUM(oi.price + oi.freight_value) AS gasto
  FROM olist.olist_orders o
  JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
  GROUP BY o.customer_id
)
SELECT customer_id, gasto
FROM vendas_cliente
ORDER BY gasto DESC
LIMIT 10;
```

### Exercício
Liste os **5 estados com maior ticket médio de pedidos** usando CTE.  

#### Gabarito
```sql
WITH ticket_estado AS (
  SELECT c.customer_state,
         AVG(oi.price + oi.freight_value) AS ticket_medio
  FROM olist.olist_orders o
  JOIN olist.olist_customers c ON c.customer_id = o.customer_id
  JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
  GROUP BY c.customer_state
)
SELECT * FROM ticket_estado
ORDER BY ticket_medio DESC
LIMIT 5;
```

---

## 4) Views

### Exemplo
```sql
CREATE OR REPLACE VIEW vw_vendas_estado AS
SELECT c.customer_state,
       SUM(oi.price + oi.freight_value) AS receita
FROM olist.olist_orders o
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_state;
```

### Exercício
Crie uma view com os **top 10 produtos mais vendidos**.  

#### Gabarito
```sql
CREATE OR REPLACE VIEW vw_top10_produtos AS
SELECT oi.product_id, COUNT(*) AS qtd_vendida
FROM olist.olist_order_items oi
GROUP BY oi.product_id
ORDER BY qtd_vendida DESC
LIMIT 10;
```

---

## 5) Window Functions

### Exemplos
```sql
-- ROW_NUMBER
SELECT customer_id, order_id,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS num_pedido
FROM olist.olist_orders;

-- RANK
SELECT seller_id, SUM(price) AS receita,
       RANK() OVER (ORDER BY SUM(price) DESC) AS posicao
FROM olist.olist_order_items
GROUP BY seller_id;

-- Média móvel
SELECT o.customer_id, o.order_id,
       AVG(oi.price) OVER (PARTITION BY o.customer_id ORDER BY o.order_purchase_timestamp ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media_movel
FROM olist.olist_orders o
JOIN olist.olist_order_items oi ON oi.order_id = o.order_id;
```

### Exercício
Liste os 3 produtos mais vendidos em cada estado (ranking por receita).  

#### Gabarito
```sql
SELECT c.customer_state, p.product_id,
       SUM(oi.price) AS receita,
       RANK() OVER (PARTITION BY c.customer_state ORDER BY SUM(oi.price) DESC) AS posicao
FROM olist.olist_orders o
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
JOIN olist.olist_products p ON p.product_id = oi.product_id
GROUP BY c.customer_state, p.product_id
HAVING SUM(oi.price) > 0;
```

---

## 6) UNION / INTERSECT / EXCEPT

### Exemplo
```sql
-- Clientes em comum
SELECT customer_id FROM olist.olist_orders
INTERSECT
SELECT customer_id FROM olist.olist_customers;
```

### Exercício
Liste clientes que estão na tabela de customers mas não em orders.  

#### Gabarito
```sql
SELECT customer_id FROM olist.olist_customers
EXCEPT
SELECT customer_id FROM olist.olist_orders;
```

---

## 7) Funções de Texto e Datas

### Exemplos
```sql
-- Texto
SELECT customer_city, UPPER(customer_city) AS cidade_maiuscula
FROM olist.olist_customers;

SELECT review_comment_message, LENGTH(review_comment_message) AS tamanho
FROM olist.olist_order_reviews
LIMIT 5;

-- Datas
SELECT order_id,
       DATE_PART('year', order_purchase_timestamp) AS ano,
       DATE_PART('month', order_purchase_timestamp) AS mes
FROM olist.olist_orders;

SELECT order_id,
       order_purchase_timestamp,
       order_delivered_customer_date,
       AGE(order_delivered_customer_date, order_purchase_timestamp) AS tempo_entrega
FROM olist.olist_orders
WHERE order_status = 'delivered'
LIMIT 5;
```

### Exercício
1. Liste os 5 clientes com o **nome da cidade em maiúsculo**.  
2. Calcule a **média de dias de entrega** por estado.  

#### Gabarito
```sql
-- 1
SELECT DISTINCT customer_city, UPPER(customer_city) AS cidade_maiuscula
FROM olist.olist_customers
LIMIT 5;

-- 2
SELECT c.customer_state,
       AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))) AS media_dias
FROM olist.olist_orders o
JOIN olist.olist_customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY media_dias;
```

---

## 8) Mini-projeto de fechamento

**Desafio:**  
Monte um relatório que traga, para cada estado:  
- Receita total  
- Top 3 produtos mais vendidos  
- Média de tempo de entrega  

#### Gabarito
```sql
WITH vendas_estado AS (
  SELECT c.customer_state, p.product_id,
         SUM(oi.price + oi.freight_value) AS receita,
         AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))) AS media_entrega
  FROM olist.olist_orders o
  JOIN olist.olist_customers c ON c.customer_id = o.customer_id
  JOIN olist.olist_order_items oi ON oi.order_id = o.order_id
  JOIN olist.olist_products p ON p.product_id = oi.product_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_state, p.product_id
)
SELECT customer_state, product_id, receita, media_entrega,
       RANK() OVER (PARTITION BY customer_state ORDER BY receita DESC) AS posicao
FROM vendas_estado
WHERE receita > 0
AND RANK() OVER (PARTITION BY customer_state ORDER BY receita DESC) <= 3
ORDER BY customer_state, posicao;
```
