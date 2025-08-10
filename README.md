# 📘 Aula: Introdução à Engenharia de Dados com Azure

**Duração:** 3 horas  
**Público-alvo:** Iniciantes (0 conhecimento prévio)  
**Base:** Livro "Fundamentos da Engenharia de Dados"  
**Plataforma:** Microsoft Azure  
**Objetivo:** Apresentar de forma clara e prática os fundamentos da Engenharia de Dados e aplicar conceitos usando Azure SQL, Data Lake e Data Factory.

---

## 🧭 Roteiro Geral da Aula

| Bloco | Tema | Duração | Objetivo |
|-------|------|---------|----------|
| 1 | Abertura + Agenda + Introdução | 10 min | Engajar, alinhar expectativas |
| 2 | Diferenças entre Engenharia, Análise e Ciência de Dados | 15 min | Entender papéis e responsabilidades |
| 3 | Fundamentos da Engenharia de Dados | 30 min | Teoria: ciclo de vida e elementos essenciais |
| 4 | Demonstração 1: Azure Data Lake + Azure SQL | 25 min | Mostrar armazenamento e ingestão |
| 5 | Demonstração 2: Azure Data Factory | 25 min | Mostrar transformação e orquestração |
| 6 | Hands-on Orientado (Lab ou Guiado) | 40 min | Atividade prática básica no Azure |
| 7 | Conclusão + Dicas + Perguntas | 15 min | Recapitular e abrir para dúvidas |

---

## 👥 Diferença entre Engenharia, Análise e Ciência de Dados (15 min)

| Papel | Foco | Entregável | Ferramentas |
|-------|------|------------|-------------|
| **Engenheiro de Dados** | Infraestrutura e pipelines | Bases estruturadas e acessíveis | Spark, SQL, Data Factory |
| **Analista de Dados** | Exploração e relatórios | Dashboards e KPIs | Power BI, Excel, SQL |
| **Cientista de Dados** | Modelagem preditiva | Modelos e previsões | Python, ML, Jupyter |

> 💡 **Resumo:**  
> O engenheiro prepara e entrega os dados.  
> O analista consome e interpreta.  
> O cientista modela e prevê.

---

## ⚙️ Fundamentos da Engenharia de Dados (30 min)

### 🔁 Ciclo de Vida

1. **Geração de dados**: sistemas, sensores, APIs
2. **Armazenamento**: Data Lakes, bancos relacionais
3. **Ingestão**: movimentar dados (batch, streaming)
4. **Transformação**: limpeza, padronização, enriquecimento
5. **Disponibilização**: camadas de consumo (BI, APIs)

### 🔧 Elementos Subjacentes

- **Segurança**: controle de acesso, criptografia, compliance
- **Engenharia de Dados como Disciplina**: versionamento, testes
- **DataOps**: automação, deploy, CI/CD
- **Arquitetura de Dados**: modular, escalável, eficiente
- **Orquestração**: controle de fluxo e dependências
- **Engenharia de Software**: código limpo, funções reutilizáveis

---

## 💻 Demonstração 1 – Azure Data Lake + Azure SQL (25 min)

### Objetivo:
Mostrar armazenamento e ingestão de dados

### Etapas:
- Criar container no **Azure Data Lake Storage Gen2**
- Upload de um arquivo CSV
- Criar banco e tabela simples no **Azure SQL Database**
- Visualizar os dados carregados

> 💡 Conceitos explicados: Data Lake como Bronze, Azure SQL como Silver/Gold

---

## 🔄 Demonstração 2 – Azure Data Factory (25 min)

### Objetivo:
Mostrar orquestração e transformação

### Etapas:
- Criar pipeline no **Azure Data Factory**
  - Fonte: Data Lake (CSV)
  - Destino: Azure SQL
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

