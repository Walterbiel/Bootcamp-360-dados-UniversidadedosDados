# EBOOK — SQL DQL: 50 Exercícios Comentados e Resolvidos


**Base utilizada:** `Product`, `Reseller`, `Sales`, `Salesperson`, `SalespersonRegion`, `Targets`, `Region`  
> Observação: como algumas colunas possuem espaços e hífens no nome (ex.: `"Unit Price"`, `"State-Province"`), os exemplos usam **identificadores entre aspas duplas** para manter compatibilidade ANSI SQL.

### Dicas de uso
- Ajuste o nome do **schema** caso necessário (ex.: `public.Product`).
- Datas estão como texto no dataset de exemplo; quando precisar, converta usando funções da sua engine (ex.: `TO_DATE(OrderDate, 'Day, Month DD, YYYY')` no Postgres).
- Valores monetários (ex.: `"Sales"`, `"Unit Price"`, `"Target"`) vêm com `$` e `,`. Para cálculos, remova símbolos (ex.: `REPLACE(REPLACE("Sales",'$',''),',','')::numeric`).

---

    ## Exercício 03 — Top 10 linhas  
    **Enunciado.** Mostre as 10 primeiras linhas da tabela `Reseller`.

    ```sql
    SELECT * 
FROM Reseller
LIMIT 10;
    ```

    **Explicação.** `LIMIT` restringe o número de linhas retornadas.


    ## Exercício 04 — Filtrar por estado  
    **Enunciado.** Liste revendedores da Califórnia (`"State-Province" = 'California'`).

    ```sql
    SELECT "ResellerKey", "Reseller", "City", "State-Province"
FROM Reseller
WHERE "State-Province" = 'California';
    ```

    **Explicação.** Uso básico de `WHERE` para igualdade.


    ## Exercício 05 — Filtrar por múltiplos valores  
    **Enunciado.** Liste revendedores dos estados California **ou** Washington.

    ```sql
    SELECT "ResellerKey", "Reseller", "City", "State-Province"
FROM Reseller
WHERE "State-Province" IN ('California','Washington');
    ```

    **Explicação.** `IN` simplifica múltiplas comparações.
