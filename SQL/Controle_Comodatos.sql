SELECT
    -- CODPROD puxado da TCIBEM
    B.CODPROD AS COD_PROD,
    -- REPLACE no DESCRBEM coluna que exibe 'LOTE=XXXXXXXX', removendo esse prefixo e deixando apenas o CONTROLE
    REPLACE(B.DESCRBEM, 'LOTE=', '') AS LOTE,
    -- CASE para concatenar CODPROD + a lógica do CONTROLE feita acima, criando um identificador único
    CASE
        WHEN B.DESCRBEM IS NOT NULL THEN B.CODPROD ||'_'|| REPLACE(B.DESCRBEM, 'LOTE=', '')
        ELSE '-'
    END AS COD_LOTE,
    -- Campos MARCA e DESCRPROD da TGFPRO
    P.DESCRPROD AS "DESCRIÇÃO DO PRODUTO",
    P.MARCA,
    -- CASE para NFENTRADA caso seja NULL, apareça 0
    CASE
        WHEN TO_CHAR(B.NUMNOTA) IS NULL THEN '0'
        ELSE TO_CHAR(B.NUMNOTA)
    END AS "NF Entrada",
    -- Alinhamento da Data de Compra para exibição + VLRAQUISICAO como VLRCOMPRA
    TO_CHAR(B.DTCOMPRA, 'DD/MM/YYYY') AS "Data Entrada",
    B.VLRAQUISICAO AS "Valor de Compra",
    -- CASE com cálculo de saldo de valor patrimonial dos produtos baseado em campo calculado da TCIBEM
    CASE
        WHEN NVL(SAL.SALDO, 0) <> 0 AND NVL(SAL.TOTALDEP, 0) <> 0 THEN TO_CHAR(SAL.SALDO - SAL.TOTALDEP, '999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''')	
        ELSE '-'
    END AS "Valor Patrimonial",

    -- Início dos CASES com a condição a ser satisfeita NUNOTADEV (Nro Único da Devolução) > NUNOTA (Nro Único da Saída) 
    -- Utilização de COALESCE para assegurar '-' em caso de valores NULL
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE(TO_CHAR(C.NUMNOTA), '-')
    END AS "NF Saída",
    
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE(TO_CHAR(C.DTNEG, 'DD/MM/YYYY'), '-')
    END AS "Data Saída",
    
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '0'
        ELSE COALESCE(TO_CHAR(C.VLRNOTA, '999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.'''), '0')
    END AS "Valor do Contrato",
    
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '0'
        ELSE COALESCE(TO_CHAR(C.CODPARC), '0')
    END AS COD_PARC,
    
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE(PC.NOMEPARC, '-')
    END AS PARCEIRO,
    
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE(U.UF, '-')
    END AS UF,
    
    -- CASE para concatenar Endereço do Parceiro com todas as informações NOMEEND, NUMEND, NOMEBAI, CEP, NOMECID
    CASE
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE((
            SELECT DISTINCT
                EN.NOMEEND || ', ' || PAR.NUMEND || ', ' || BAI.NOMEBAI || ', ' || PAR.CEP || ', ' || CID.NOMECID AS ENDERECO_COMPLETO
            FROM
                TGFPAR PAR
            INNER JOIN
                TSIEND EN ON EN.CODEND = PAR.CODEND
            INNER JOIN
                TSIBAI BAI ON BAI.CODBAI = PAR.CODBAI
            INNER JOIN
                TSICID CID ON CID.CODCID = PAR.CODCID
            WHERE
                PAR.CODPARC = C.CODPARC 
        ), '-')
    END AS "Endereço",

    -- CASE com lógica de PERFIL de Parceiro baseado no Perfil apresentado na Planilha de Comodatos
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        WHEN PC.NOMEPARC LIKE 'HAPVIDA%' THEN 'HAPVIDA'
        WHEN PC.CODTIPPARC IN (100, 101, 102, 104, 501) THEN 'Privado'
        WHEN PC.CODTIPPARC IN (200, 201) THEN 'Publico'
        ELSE '-'
    END AS "Perfil",

    -- CASE com lógica para formatar CNPJ do parceiro na formatação padrão
    CASE 
        WHEN B.NUNOTADEV IS NOT NULL AND B.NUNOTADEV > C.NUNOTA THEN '-'
        ELSE COALESCE(TO_CHAR(SUBSTR(PC.CGC_CPF, 1,2) || '.' || SUBSTR(PC.CGC_CPF, 3,3) || '.' || SUBSTR(PC.CGC_CPF, 6,3) || '/' || SUBSTR(PC.CGC_CPF, 9,4) || '-' || SUBSTR(PC.CGC_CPF, 13,2)), '-')
    END AS "CNPJ Cliente",
    
    -- CASE para estruturar subcategoria do produto seguindo lógica da planilha de comodatos
    CASE
        WHEN P.AD_SUBCATEGORIA = 'TOMOGRAFIA' THEN 'TC'
        WHEN P.AD_SUBCATEGORIA = 'HEMODINÂMICA' THEN 'HEMO'
        WHEN P.AD_SUBCATEGORIA = 'HÍBRIDA TC HEMO' THEN 'TC/HEMO'
        WHEN P.AD_SUBCATEGORIA = 'RESSONÂNCIA MAGNÉTICA' THEN 'RM'
        WHEN P.AD_SUBCATEGORIA = 'AQUECEDOR DE CONTRASTES' THEN 'AQUECEDOR'    
        ELSE '-'    
    END AS "Categoria Equipamentos"

FROM 
    TCIBEM B
    -- Tabela de Imobilizado
INNER JOIN
    TGFPRO P ON P.CODPROD = B.CODPROD
    -- Tabela de Produtos
INNER JOIN
    TCISAL_ATUAL SAL ON SAL.CODBEM = B.CODBEM
    -- Tabela de Saldo
LEFT JOIN  
    TGFCAB C ON C.NUNOTA = B.NUNOTASAIDA AND P.CODPROD = B.CODPROD
    -- Tabela de Cabeçalho da nota igualando NUNOTA a NUNOTASAIDA com mesmo CODPROD de Produtos e Imobilizados
    -- Aqui foi feito um LEFT JOIN para trazer registros sem comprometer a integridade dos dados
LEFT JOIN
    TGFPAR PC ON PC.CODPARC = C.CODPARC
    -- Tabela de Parceiros
LEFT JOIN
    TSIUFS U ON U.CODUF = C.CODUFDESTINO
    -- Tabela de UFs

WHERE
    -- Condições de Filtro por código de produto em:
    B.CODPROD IN (1401, 1447, 1232, 2783, 1448, 62, 63, 71, 69, 1760, 1735, 1734, 1387, 1733, 1731, 1703, 77, 78, 79, 3249, 81)
    -- Lotes e Códigos de Produtos a não serem considerados com condições e critérios para limitar linhas duplicadas
    AND NOT REPLACE(B.DESCRBEM, 'LOTE=', '') IN ('C1013C025X', 'C0921R941R', 'C0921R942R', 'C0921R962R','862020275','862020305','862020233','CI0208D024','C0920C625C','862020307','C0620C437C','C1220B806G','C0820B934G','862020302','862019272','C1120C725C','C1220B796G','C0820B935G','C1220B810G','862020303','862020276','880019174','C1219D195G','C1220B792G','C1220B797G','C1220B795G')
    AND NOT (B.CODPROD = 69 AND REPLACE(B.DESCRBEM, 'LOTE=', '') = 'C1012B016X')
    AND NOT (B.CODPROD = 1760 AND TO_CHAR(B.DTCOMPRA, 'DD/MM/YYYY') = '19/08/2019')
    AND NOT (B.CODPROD = 81 AND (NVL(SAL.SALDO, 0) - NVL(SAL.TOTALDEP, 0) IN (216.79, 219.37))) -- CI0912Q008 lote duplicado
    
ORDER BY
    B.CODPROD