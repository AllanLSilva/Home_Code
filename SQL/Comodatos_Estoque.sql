WITH DeParaDeEntrada AS (
    
    -- Criado lógica com CTE (Common Table Expression) para estruturar um DE/PARA dos códigos antigos de Injetoras para os novos caso houver relação entre os códigos
    SELECT 
        REPLACE(BEM.DESCRBEM, 'LOTE=', '') AS LOTE, -- Utilizado mesmo insight da fórmula REPLACE para aproveitar campo DESCRBEM da tabela de imobilizados
        BEM.DTCOMPRA AS DATA_ENTRADA_ANTIGA -- Sendo a data da compra dessas injetoras com os códigos antigos
    FROM 
        TCIBEM BEM
    INNER JOIN
        TGFCAB CAB ON CAB.NUMNOTA = BEM.NUMNOTA
    WHERE 
        CAB.TIPMOV = 'C'  -- Movimentação de entrada
)

-- Criado a CTE para execução do código, parto para a estrutura geral que irá validar as injetoras em Estoque apenas, que já deixaram de ser Imobilizados

SELECT DISTINCT

-- Campos vindo diretamente do Estoque para conflitar menos com a busca de informações
E.CODPROD,
E.CONTROLE AS LOTE,
-- Case que concatena CODPROD com CONTROLE para criação de chave única
CASE
    WHEN E.CONTROLE IS NOT NULL THEN E.CODPROD ||'_'|| E.CONTROLE
    ELSE '-'
END AS COD_LOTE,
-- Campos vindo direto de Produtos igualados pela chave única de código de produto
P.DESCRPROD AS "DESCRIÇÃO DO PRODUTO",
P.MARCA,

-- Subconsulta que retorna NF de Entrada mas igualada a 0 pois essa informação não existe na planilha
(
    SELECT
        CASE
            WHEN TO_CHAR(CAB.NUMNOTA) IS NOT NULL THEN '0'
            ELSE '-'
        END AS NUMNOTA

    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'C'
        
) AS "NF Entrada",
-- COALESCE função usada para retornar o primeiro valor não nulo em uma lista de expressões, analisando o resultado da CTE e alocando na coluna
COALESCE(
            (SELECT
                TO_CHAR(DATA_ENTRADA_ANTIGA, 'DD/MM/YYYY')
            FROM
                DeParaDeEntrada DP
            WHERE
                DP.LOTE = E.CONTROLE), -- Caso houver ligação entre lote bem e lote estoque, então houve troca de código do produto, isso garantirá a data de entrada como a antiga
            (SELECT
                TO_CHAR(CAB.DTNEG, 'DD/MM/YYYY')
            FROM
                TGFCAB CAB
            INNER JOIN
                TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
            WHERE 
                ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'C'), -- Caso não houver ligação, a data de entrada vem da cab onde o lote estoque é o mesmo da ite
            '-'  -- Caso nenhum valor seja encontrado
    ) AS "Data Entrada",
-- Para o Valor de Compra, fiz questão de puxar o ITE.VLRUNIT já que todos os itens entraram na mesma nota no Estoque, assim VLRNOTA não cabia
(
    SELECT
        TO_CHAR(ITE.VLRUNIT, '999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''')	

    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'C'
        
) AS "Valor de Compra",
-- CASE que calcula o VLRPATRIMONIAL dos imbolizados (trazido apenas pela lógica da planilha visto que não há valor para os mesmos)
    CASE
        WHEN NVL(SAL.SALDO, 0) <> 0 AND NVL(SAL.TOTALDEP, 0) <> 0 THEN TO_CHAR(SAL.SALDO - SAL.TOTALDEP, '999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''')	
        ELSE '-'
    END AS "Valor Patrimonial",

-- A partir desse ponto, foi iniciado o modelo de CASE com NUNOTADEV IS NOT NULL AND NUNOTADEV > NUNOTASAIDA

/*
A lógica parte de uma View (VW_COMODATOS_ESTSAID) que capta campos de subconsultas com TIPMOV = 'D' e LOCALORIG = 801, assim
novos produtos adicionados também serão visualizados pela VIEW, também capta os movimentos 'V', assim trazendo os números únicos desses movimentos

a partir disso, a análise é que se o número único de devolução não for vazio e for maior que o número único de saída, assim, o item se encontra 
em estoque, caso não, o próprio campo é retornado, exibindo onde o produto está comodatado;
*/

-- SUBSELECT que retorna NF de Saída
(
    SELECT
        CASE 
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
            ELSE TO_CHAR(CAB.NUMNOTA)
        END AS NUMNOTA
    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS "NF Saída",
-- SUBSELECT que retorna DT de Saída
(
    SELECT
        CASE 
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
            ELSE TO_CHAR(CAB.DTNEG, 'DD/MM/YYYY')
        END AS DTNEG
    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS "Data Saída",
-- SUBSELECT que retorna o Valor da Nota de Saída
(
    SELECT
        CASE 
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '0'
            ELSE TO_CHAR(CAB.VLRNOTA, '999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''')
        END AS VLRNOTA
    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS "Valor do Contrato",
-- SUBSELECT que retorna Código do Parceiro na nota de saída
(
    SELECT
        CASE 
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '0'
            ELSE TO_CHAR(CAB.CODPARC)
        END AS CODPARC
    FROM
        TGFCAB CAB
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS COD_PARC,
-- SUBSELECT que retorna Nome do Parceiro na nota de saída
(
    SELECT
        CASE
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
            ELSE PAR.NOMEPARC
        END AS NOMEPARC
    FROM
        TGFPAR PAR
    INNER JOIN
        TGFCAB CAB ON PAR.CODPARC = CAB.CODPARC
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS PARCEIRO,
-- SUBSELECT que retorna UF da nota de saída
(
    SELECT
        CASE
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
            ELSE U.UF
        END AS UF
    FROM
        TGFPAR PAR
    INNER JOIN
        TGFCAB CAB ON PAR.CODPARC = CAB.CODPARC
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    INNER JOIN
        TSIUFS U ON U.CODUF = CAB.CODUFDESTINO
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V'
        
) AS UF,
-- SUBSELECT com lógica de concatenação de elementos de endereço das suas instâncias adaptada para essa consulta
(
    SELECT DISTINCT
        CASE
            WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
            ELSE EN.NOMEEND || ', ' || PAR.NUMEND || ', ' || BAI.NOMEBAI || ', ' || PAR.CEP || ', ' || CID.NOMECID
        END AS ENDERECO_COMPLETO
    FROM
        TGFPAR PAR
    INNER JOIN
        TSIEND EN ON EN.CODEND = PAR.CODEND
    INNER JOIN
        TSIBAI BAI ON BAI.CODBAI = PAR.CODBAI
    INNER JOIN
        TSICID CID ON CID.CODCID = PAR.CODCID
        
    INNER JOIN
        TGFCAB CAB ON CAB.CODPARC = PAR.CODPARC
    INNER JOIN
        TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    WHERE
        ITE.CONTROLE = E.CONTROLE AND ITE.CODPROD = E.CODPROD AND CAB.TIPMOV = 'V' 

) AS "Endereço",
-- CASE que opera o Perfil do Parceiro a partir dos códigos ou da formatação do Nome do Parceiro para HAPVIDA
    CASE
        WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
        WHEN PC.NOMEPARC LIKE 'HAPVIDA%' THEN 'HAPVIDA'
        WHEN PC.CODTIPPARC IN (100, 101, 102, 104, 501) THEN 'Privado'
        WHEN PC.CODTIPPARC IN (200, 201) THEN 'Publico'
        ELSE '-'
    END AS "Perfil",
-- CASE que formata CNPJ do parceiro para padrão de exibição
    CASE
        WHEN S.NUNOTADEV IS NOT NULL AND S.NUNOTADEV > S.NUNOTASAIDA THEN '-'
        ELSE TO_CHAR(SUBSTR(PC.CGC_CPF,
                        1,2) || '.' || 
        SUBSTR(PC.CGC_CPF,
                        3,3) || '.' || 
        SUBSTR(PC.CGC_CPF,
                        6,3) || '/' || 
        SUBSTR(PC.CGC_CPF,
                        9,4) || '-' || 
        SUBSTR(PC.CGC_CPF,
                        13,2)) 
    END AS "CNPJ Cliente",
-- CASE que aloca os produtos em suas respectivas Subcategorias a partir de AD_SUBCATEGORIA vindo de Produtos
    CASE
        WHEN
            P.AD_SUBCATEGORIA = 'TOMOGRAFIA' THEN 'TC'
        WHEN
            P.AD_SUBCATEGORIA = 'HEMODINÂMICA' THEN 'HEMO'
        WHEN
            P.AD_SUBCATEGORIA = 'HÍBRIDA TC HEMO' THEN 'TC/HEMO'
        WHEN
            P.AD_SUBCATEGORIA = 'RESSONÂNCIA MAGNÉTICA' THEN 'RM'
        WHEN
            P.AD_SUBCATEGORIA = 'AQUECEDOR DE CONTRASTES' THEN 'AQUECEDOR'    
        ELSE '-'    
    END AS "Categoria Equipamentos"


FROM 
    TGFEST E

INNER JOIN
    TGFPRO P ON P.CODPROD = E.CODPROD
INNER JOIN
    VW_COMODATOS_ESTSAID S ON S.CONTROLE = E.CONTROLE -- Inner join da VIEW que determina saidas e retornos para comparar o NUNOTADEV com NUNOTASAIDA, assim tendo a lógica de preenchimento de comodatos

LEFT JOIN
    TCISAL_ATUAL SAL ON SAL.CODPROD = E.CODPROD
LEFT JOIN
    TGFPAR PC ON PC.CODPARC = E.CODPARC


WHERE
    -- Mais condições podem se fazer necessárias futuramente mas por agora, essas informações já bastam visto extensas SUBSELECTs realizadas
    E.CODLOCAL IN (801, 802) AND NOT E.CODPARC = 0

ORDER BY
    -- Ordenando por Código de Produtos
    E.CODPROD