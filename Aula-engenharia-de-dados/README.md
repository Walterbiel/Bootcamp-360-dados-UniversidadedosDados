# 📘 Aula: Introdução à Engenharia de Dados com Azure

**Duração:** 3 horas  
**Público-alvo:** Iniciantes (0 conhecimento prévio)  
**Base:** Livro "Fundamentos da Engenharia de Dados"  

**Objetivo:** Apresentar de forma clara e prática os fundamentos da Engenharia de Dados e aplicar conceitos usando Azure data factory, apache hop,postgres, dbeaver e Data Lake.

---

## 🧭 Roteiro Geral da Aula

| Bloco | Tema | Duração | Objetivo |
|-------|------|---------|----------|
| 1 | Abertura + Agenda + Introdução | 15 min | Engajar, alinhar expectativas |
| 2 | Teoria dos fundamentos da engenharia de dados Slide 1 a 7| 30 min | Entender papéis e responsabilidades |
| 3 | Questões sobre fundamentos da engenharia de dados | 10 min | Quiz |
| 4 | Introdução a bancos de dados relacionais | 15 min |Criação dos metadados DW Olist e entendimento dos relacionamentos|
| 5 | Demonstração 1: Pipeline com Apache Hop | 35 min | Mostrar transformação e orquestração |
| 6 | Demonstração 2: Pipeline amazon com Azure Data Factory e Data lake (Arquitetura medallion) | 60 min | Atividade prática básica no Azure |
| 7 | Conclusão + Dicas + Perguntas | 15 min | Recapitular e abrir para dúvidas |

---


---

## 💻 Introdução a bancos de dados e criação dos metadados

### Objetivo:
Mostrar armazenamento e infra do sqleu sa

### Scripts SQL e Explicações para PostgreSQL
**Objetivo:** Reunir scripts SQL completos para criar tabelas baseadas no dataset Olist, com chaves primárias, índices e orientações de carga.

## Conteúdo

1. Recomendações e Fluxo de Carga
2. `create_db.sql`
3. `schema.sql` — criação de tabelas com PKs
4. `indexes.sql` — índices secundários
5. `foreign_keys.sql` — chaves estrangeiras
6. `load_data.sql` — carregamento de dados
7. Observações finais

---

## 1) Recomendações e Fluxo de Carga

- Criar base e schema primeiro.
- Criar tabelas apenas com PKs.
- Carregar dados via `\copy` ou `COPY`.
- Criar índices depois da carga.
- Adicionar FKs apenas se necessário.
- Rodar `VACUUM ANALYZE` no final.

---

## 2) `create_db.sql`

```sql
CREATE DATABASE olist_db WITH ENCODING='UTF8' LC_COLLATE='pt_BR.UTF-8' LC_CTYPE='pt_BR.UTF-8' TEMPLATE=template0;
-- \c olist_db
CREATE SCHEMA IF NOT EXISTS public;
```

---

## 3) `schema.sql`

```sql
CREATE TABLE olist.olist_customers (
  customer_id TEXT PRIMARY KEY,
  customer_unique_id TEXT,
  customer_zip_code_prefix INTEGER,
  customer_city TEXT,
  customer_state TEXT
);

CREATE TABLE olist.olist_geolocation (
  geolocation_zip_code_prefix INTEGER,
  geolocation_lat NUMERIC(10,6),
  geolocation_lng NUMERIC(10,6),
  geolocation_city TEXT,
  geolocation_state TEXT,
  PRIMARY KEY (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng)
);



CREATE TABLE olist.olist_order_items (
  order_id TEXT,
  order_item_id INTEGER,
  product_id TEXT,
  seller_id TEXT,
  shipping_limit_date TIMESTAMP,
  price NUMERIC(12,2),
  freight_value NUMERIC(12,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE olist.olist_order_payments (
  order_id TEXT,
  payment_sequential INTEGER,
  payment_type TEXT,
  payment_installments INTEGER,
  payment_value NUMERIC(12,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE olist.olist_order_reviews (
  review_id TEXT PRIMARY KEY,
  order_id TEXT,
  review_score SMALLINT,
  review_comment_title TEXT,
  review_comment_message TEXT,
  review_creation_date TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);

CREATE TABLE olist.olist_orders (
  order_id TEXT PRIMARY KEY,
  customer_id TEXT,
  order_status TEXT,
  order_purchase_timestamp TIMESTAMP,
  order_approved_at TIMESTAMP,
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist.olist_products (
  product_id TEXT PRIMARY KEY,
  product_category_name TEXT,
  product_name_lenght INTEGER,
  product_description_lenght INTEGER,
  product_photos_qty INTEGER,
  product_weight_g INTEGER,
  product_length_cm INTEGER,
  product_height_cm INTEGER,
  product_width_cm INTEGER
);

CREATE TABLE olist.olist_sellers (
  seller_id TEXT PRIMARY KEY,
  seller_zip_code_prefix INTEGER,
  seller_city TEXT,
  seller_state TEXT
);

CREATE TABLE olist.product_category_name_translation (
  product_category_name TEXT PRIMARY KEY,
  product_category_name_english TEXT
);
```
Rodar pipeline do hop para popular as tabelas, com esse create table vai dar erro em 2 tabelas, que devem ser corrigidas, mostrando a impoportancia da chave primaria e dos tipos de dados corretos:
<img width="1391" height="994" alt="image" src="https://github.com/user-attachments/assets/72d5779e-1361-48a8-b200-9fc361e4c5ac" />

Rodar:
```
-- 1. Remove a constraint de PK atual
ALTER TABLE olist.olist_geolocation
  DROP CONSTRAINT olist_geolocation_pkey;

-- 2. Cria uma nova PK com todas as colunas
ALTER TABLE olist.olist_geolocation
  ADD CONSTRAINT olist_geolocation_pkey
  PRIMARY KEY (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
  );
```
Retirar lazy conversion do olist_order_review e na geolocation:
Arredondar casas decimais em novas colunas > retirar as colunas antigas > renomear as novas > retirar duplicatas:

<img width="1246" height="591" alt="image" src="https://github.com/user-attachments/assets/058b8e49-456d-40af-a1b3-4ed23bf78c03" />

Depois criar as etapas a seguir para corrigir a retirada de duplicadas da tabela de geolocalização:
<img width="1190" height="181" alt="image" src="https://github.com/user-attachments/assets/8f15859f-4ed8-4c65-a50b-3a5c597c0688" />

<img width="1083" height="279" alt="image" src="https://github.com/user-attachments/assets/a2957314-d09f-432c-aaf3-fe1224ebdccf" />

<img width="347" height="251" alt="image" src="https://github.com/user-attachments/assets/b349528d-a8e1-48a4-81f1-c5e66a522ec6" />

<img width="548" height="278" alt="image" src="https://github.com/user-attachments/assets/799557f9-bfb8-432a-a896-f985b7cd4f5f" />

<img width="1013" height="378" alt="image" src="https://github.com/user-attachments/assets/dc7bd4c3-5a8a-4491-bbf0-d19fb27b5fd4" />








---

## 4) `indexes.sql`

```sql
CREATE INDEX idx_customers_unique_id ON public.olist_customers (customer_unique_id);
CREATE INDEX idx_customers_zip ON public.olist_customers (customer_zip_code_prefix);
CREATE INDEX idx_geo_city_state ON public.olist_geolocation (geolocation_city, geolocation_state);
CREATE INDEX idx_order_items_product_id ON public.olist_order_items (product_id);
CREATE INDEX idx_order_items_seller_id ON public.olist_order_items (seller_id);
CREATE INDEX idx_order_payments_type ON public.olist_order_payments (payment_type);
CREATE INDEX idx_order_reviews_order_id ON public.olist_order_reviews (order_id);
CREATE INDEX idx_orders_customer_id ON public.olist_orders (customer_id);
CREATE INDEX idx_orders_purchase_ts ON public.olist_orders (order_purchase_timestamp);
CREATE INDEX idx_products_category ON public.olist_products (product_category_name);
CREATE INDEX idx_sellers_zip ON public.olist_sellers (seller_zip_code_prefix);
```

---

## 5) `foreign_keys.sql`

```sql
ALTER TABLE public.olist_orders ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES public.olist_customers (customer_id);
ALTER TABLE public.olist_order_items ADD CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES public.olist_orders (order_id);
ALTER TABLE public.olist_order_items ADD CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES public.olist_products (product_id);
ALTER TABLE public.olist_order_items ADD CONSTRAINT fk_order_items_sellers FOREIGN KEY (seller_id) REFERENCES public.olist_sellers (seller_id);
ALTER TABLE public.olist_order_payments ADD CONSTRAINT fk_payments_orders FOREIGN KEY (order_id) REFERENCES public.olist_orders (order_id);
ALTER TABLE public.olist_order_reviews ADD CONSTRAINT fk_reviews_orders FOREIGN KEY (order_id) REFERENCES public.olist_orders (order_id);
ALTER TABLE public.olist_products ADD CONSTRAINT fk_products_category_translation FOREIGN KEY (product_category_name) REFERENCES public.product_category_name_translation (product_category_name);
```

---

## 6) `load_data.sql`

```sql
COPY public.olist_customers FROM '/path/to/olist_customers_dataset.csv' CSV HEADER;
COPY public.olist_orders FROM '/path/to/olist_orders_dataset.csv' CSV HEADER;
```

**No cliente psql:**

```sh
\copy public.olist_customers FROM 'local/path/olist_customers_dataset.csv' CSV HEADER
\copy public.olist_orders FROM 'local/path/olist_orders_dataset.csv' CSV HEADER
```

---

## 7) Observações finais

- IDs como `TEXT` por serem hashes.
- `NUMERIC(12,2)` para valores monetários.
- Criar índices somente após carga massiva.
- Validar contagem de registros antes de FKs.
---

## 🔄 Demonstração 2 – Azure Data Factory (25 min)

### Objetivo:
Mostrar orquestração e transformação

### Etapas:
- Criar pipeline no **Azure Data Factory**
  - Fonte: Data Lake (CSV) ou API
  - Destino: Postgres SQL
- Configurar Linked Services, Datasets e Activities
- Executar e monitorar

> 💡 Pipeline simples mas didático mostrando ETL no Azure

---

## 🛠️ Hands-on Orientado (40 min)

<img width="2486" height="1496" alt="image" src="https://github.com/user-attachments/assets/b8ee926d-70d1-43a7-a5b5-6c2aaec74c92" />
> ### Brazilian E-Commerce Public Dataset by Olist
> https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

```python
# Install dependencies as needed:
# pip install kagglehub[pandas-datasets]
import kagglehub
from kagglehub import KaggleDatasetAdapter

# Set the path to the file you'd like to load
file_path = ""

# Load the latest version
df = kagglehub.load_dataset(
  KaggleDatasetAdapter.PANDAS,
  "olistbr/brazilian-ecommerce",
  file_path,
  # Provide any additional arguments like 
  # sql_query or pandas_kwargs. See the 
  # documenation for more information:
  # https://github.com/Kaggle/kagglehub/blob/main/README.md#kaggledatasetadapterpandas
)

print("First 5 records:", df.head())
```

### Tarefa: Executar como tutorial guiado caso os alunos não tenham acesso.
1. Criar container no Data Lake
2. Fazer upload de CSV ou extrair via API Kaggle
3. Criar pipeline no ADF
4. Ingerir dados para Postgres SQL
5. Verificar resultado via query

---

## ✅ Conclusão e Recomendações (15 min)

### Recapitulação:
- Diferenças entre os papéis de dados
- Ciclo de vida da Engenharia de Dados
- Ferramentas usadas: Data Lake, SQL, Data Factory
- Demonstrações práticas realizadas

### 📚 Materiais para Estudo:
- Livro **"Fundamentos da Engenharia de Dados"**
- Curso Microsoft Learn – **Azure Fundamentals**
- Curso gratuito: **DP-900** (Azure Data Fundamentals)

---

## 🧾 Materiais de Apoio

- Slides com resumo teórico (PDF ou PPT)
- Scripts SQL utilizados
- JSON de pipeline do ADF (exportável)
- Dataset CSV de exemplo
- Passo a passo das demonstrações

---

### ✉️ Frase final:

> “Engenharia de dados é o que torna possível transformar dados brutos em decisões valiosas. Sem estrutura, não há valor.”

