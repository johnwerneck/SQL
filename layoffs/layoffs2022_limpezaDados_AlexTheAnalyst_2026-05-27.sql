/* Origem: Os dados foram obtidos do repositório: 
https://github.com/AlexTheAnalyst/MySQL-YouTube-Series 
Acessado em 05/2026

Objetivo: Executar limpeza de dados
	(remover espaços, corrigir ortografia, remover - quando possível - dados nulos/vazios, 
	remover duplicadastas e colunas desnecessárias)
e realizar algumas análises.

Considerações:
1 - já se deve ter o banco de dados original na máquina;
2 - foram deixados os comandos (selects) para demonstrar a lógica envolvida no processo
	ao invés de apenas executar os comandos.
3 - Ao final, há 3 visualizações* (*análises) realizadas como exemplos

Exercício por John Werneck
Atualizado em 05/2026

*/

-- 01 Duplicar a tabela como boa prática para não mexer nos dados originais (e ter backup)
USE layoffs2022;

CREATE TABLE IF NOT EXISTS Demissoes LIKE layoffs;

INSERT INTO Demissoes
    (SELECT * FROM layoffs);
    
-- 02 Avaliar amostra de dados
SELECT * FROM Demissoes LIMIT 30;
    
-- 03 Alterar o nome da coluna 'date' para fugir da palavra chave do MySQL, além de corrigir o tipo de dado para DATE
-- 03.1 Conferindo resultado antes da atualização
SELECT `date`, STR_TO_DATE(`date`, "%m/%d/%Y") FROM Demissoes LIMIT 30;

-- 03.2 Atualizando a formatação (evitando possível valor nulo e em branco)
UPDATE Demissoes SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y") WHERE `date` IS NOT NULL AND `date` != "";

-- 03.3 Atualziando o nome e tipo de dado
ALTER TABLE Demissoes CHANGE `date` data_demissao DATE;

-- 04 Conferindo e removendo caracteres indevidos ou inválidos em cada coluna (com TRIM() e REGEX)
-- 04.1 Coluna [company]
-- 04.1.1 Conferindo se existe e removendo caracteres de espaços indevidos
SELECT company, TRIM(company) FROM Demissoes WHERE company != TRIM(company);
UPDATE Demissoes SET company = TRIM(company);

-- 04.1.2 Conferindo possíveis caracteres inválidos
SELECT DISTINCT(company)
FROM Demissoes 
WHERE company NOT REGEXP "^[a-zA-Z0-9  \.]+$"
ORDER BY 1;

-- 04.1.2.1 Conferindo e corrigindo "UalÃ¡"por "Ualá" 
-- (aparente nome correto baseado nos dados da tabela e em pesquisa online)
SELECT company
FROM Demissoes
WHERE company LIKE "Ual%" 
ORDER BY 1;

UPDATE Demissoes SET company = "Ualá" WHERE company = "UalÃ¡";

-- 04.2 Coluna [location]
SELECT location, TRIM(location) FROM Demissoes WHERE location != TRIM(location);

SELECT DISTINCT(location)
FROM Demissoes 
WHERE location NOT REGEXP "^[a-zA-Z0-9  \.]+$"
ORDER BY 1;

-- 04.1.1 Conferir: 'DÃ¼sseldorf', 'FlorianÃ³polis', 'MalmÃ¶' e 'Non-U.S.'
SELECT location FROM Demissoes WHERE location LIKE "%sseldorf" ORDER BY 1;

-- 04.1.2 Confirmando e corrigindo 'DÃ¼sseldorf' por 'Dusseldorf'
SELECT * FROM Demissoes WHERE location LIKE "%sseldorf" ORDER BY 1;
UPDATE Demissoes SET location = "Dusseldorf" WHERE location = "DÃ¼sseldorf";

-- 04.1.3 Confirmando e corrigindo 'FlorianÃ³polis' por 'Florianópolis'
SELECT * FROM Demissoes WHERE location LIKE "Floria%polis" ORDER BY 1;
UPDATE Demissoes SET location = "Florianópolis" WHERE location = "FlorianÃ³polis";

-- 04.1.4 Confirmando e corrigindo 'MalmÃ¶' por 'Malmo''
SELECT * FROM Demissoes WHERE location LIKE "Malm%" ORDER BY 1;
UPDATE Demissoes SET location = "Malmo" WHERE location = "MalmÃ¶";

-- 04.1.5 Confirmando 'Non-U.S.'
SELECT * FROM Demissoes WHERE location LIKE "Non%" ORDER BY 1;
SELECT * FROM Demissoes WHERE location = 'Non-U.S.';

-- 04.3 Coluna [industry]
SELECT industry, TRIM(industry) FROM Demissoes WHERE industry != TRIM(industry);

SELECT DISTINCT(industry)
FROM Demissoes 
WHERE industry NOT REGEXP "^[a-zA-Z0-9  \.]+$"
ORDER BY 1;

SELECT industry FROM Demissoes WHERE industry = "";
SELECT * FROM Demissoes WHERE industry = "";

SELECT DISTINCT(industry)
FROM Demissoes 
WHERE industry NOT REGEXP "^[a-zA-Z0-9  \.-]+$"
ORDER BY 1;

-- 04.4 Coluna [total_laid_off] - conferindo apenas números
SELECT DISTINCT(total_laid_off)
FROM Demissoes 
WHERE total_laid_off NOT REGEXP "^[0-9]+$"
ORDER BY 1;

-- 04.5 Coluna [percentage_laid_off]
SELECT DISTINCT(percentage_laid_off)
FROM Demissoes 
WHERE percentage_laid_off NOT REGEXP "^[0-9\.]+$"
ORDER BY 1;

-- 04.6 Coluna [data_demissao] 
-- não conferida como as outras por ela já ter passado por transformassão (item 03)

-- 04.7 Coluna [stage]
SELECT stage, TRIM(stage) FROM Demissoes WHERE stage != TRIM(stage);

SELECT DISTINCT(stage)
FROM Demissoes 
WHERE stage NOT REGEXP "^[a-zA-Z0-9]+$"
ORDER BY 1;


-- 04.8 Coluna [country]
SELECT country, TRIM(country) FROM Demissoes WHERE country != TRIM(country);

SELECT DISTINCT(country)
FROM Demissoes 
WHERE country NOT REGEXP "^[a-zA-Z0-9 ]+$"
ORDER BY 1;

UPDATE Demissoes SET country = "United States" WHERE country = "United States.";

-- 04.9 Coluna [funds_raised_millions]
SELECT funds_raised_millions, TRIM(funds_raised_millions) FROM Demissoes WHERE funds_raised_millions != TRIM(funds_raised_millions);

SELECT DISTINCT(funds_raised_millions)
FROM Demissoes 
WHERE funds_raised_millions REGEXP "^[0-9]+$"
ORDER BY 1 ASC;

-- 04.9.1 Conferindo se há informação sobre o campo poder ser nulo e se haveria possibilidade de ajustar esse dado
SELECT * FROM Demissoes WHERE funds_raised_millions = 0;
SELECT * FROM Demissoes WHERE company = "BitMEX";
SELECT * FROM Demissoes WHERE company = "Chessable";
SELECT * FROM Demissoes WHERE company = "SuperLearn";
SELECT * FROM Demissoes WHERE company = "divvyDOSE";
SELECT * FROM Demissoes WHERE company = "Drip";
SELECT * FROM Demissoes WHERE company = "Tuft & Needle";


-- 05 Valores nulos e vazios
SELECT * FROM Demissoes WHERE company IS NULL;
SELECT * FROM Demissoes WHERE company = "";

SELECT * FROM Demissoes WHERE location IS NULL;
SELECT * FROM Demissoes WHERE location = "";

SELECT * FROM Demissoes WHERE industry IS NULL;
-- 05.1 Verificando "Bally's Interactive"
SELECT * FROM Demissoes WHERE company = "Bally's Interactive";
-- Aparentemente se trata de uma empresa de jogos de azar, baseado em pesquisa online
-- Conferindo as opções de industrias na base de dados para preencher o valor da melhor forma possível
SELECT distinct(industry) FROM Demissoes ORDER BY 1;
-- Observado aparente incoerência em 'Crypto"...
SELECT * FROM Demissoes WHERE industry LIKE "Crypto%";
-- Padronizando "CryptoCurrency", "Crypto Currency" para "Crypto", por ser a grande maioria da base de dados
UPDATE Demissoes SET industry = "Crypto" WHERE industry = "CryptoCurrency" OR industry = "Crypto Currency";

SELECT * FROM Demissoes WHERE industry = "";
-- 05.2 Verificando Airbnb em SF Bay Area, Juul em SF Bay Area e Carvana em Phoenix
SELECT * FROM Demissoes WHERE company = "Airbnb";
UPDATE Demissoes SET industry = "Travel" WHERE company = "Airbnb" AND industry = "";
SELECT * FROM Demissoes WHERE company = "Juul";
UPDATE Demissoes SET industry = "Consumer" WHERE company = "Juul" AND industry = "";
SELECT * FROM Demissoes WHERE company = "Carvana";
UPDATE Demissoes SET industry = "Transportation" WHERE company = "Carvana" AND industry = "";

-- OBSERVAÇÂO: indeterminado saber possível valor correto para "total_laid_off", "percentage_laid_off" e "funds_raised_millions",
-- salvo se registros forem duplicados (etapa ainda a ser realizada)

SELECT * FROM Demissoes WHERE data_demissao IS NULL;
-- Conferindo "Blackbaud"
SELECT * FROM Demissoes WHERE company = "Blackbaud";


SELECT * FROM Demissoes WHERE stage IS NULL OR stage = "";
-- Conferir:
-- Verily de SF Bay Area
SELECT * FROM Demissoes WHERE company = "Verily" AND location = "SF Bay Area";
-- Relevel de Bengaluru
SELECT * FROM Demissoes WHERE company = "Relevel" AND location = "Bengaluru";
-- Advata de Seattle
SELECT * FROM Demissoes WHERE company = "Advata" AND location = "Seattle";
-- Spreetail de Austin
SELECT * FROM Demissoes WHERE company = "Spreetail" AND location = "Austin";
-- Gatherly de Atlanta
SELECT * FROM Demissoes WHERE company = "Gatherly" AND location = "Atlanta";
-- Zapp de Londres
SELECT * FROM Demissoes WHERE company = "Zapp" AND location = "London";

SELECT * FROM Demissoes WHERE country IS NULL OR country = "";

-- 06 Conferir valores duplicados
/* Para conferir e remover valores duplicados será criada uma nova coluna com o número da linha, servindo de ID.
Em seguida, uma CTE contendo outro campo com quantidade de registros iguais para então avaliar duplicadas
e remover registros baseados no ID criado (número da linha.

Após remover os registros duplcados, será removida a coluna ID para voltar ao padrão da tabela original
*/

SELECT count(*) FROM Demissoes;
-- 06.1 Novo campo de ID
ALTER TABLE Demissoes ADD COLUMN id SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY;


-- 06.1 Adicionadno coluna extra com o total de registros e número de linha utilizando função de janela e CTE
WITH demissoes_extentida AS (
    SELECT *, 
            COUNT(*) OVER(PARTITION BY company, location, industry, data_demissao) AS qtd_registros
    FROM Demissoes
    ORDER BY company
)
SELECT * FROM demissoes_extentida WHERE qtd_registros > 1 ORDER BY qtd_registros DESC;

-- Observada aparente erro de país na empresa Oda
SELECT * FROM Demissoes WHERE company = "Oda";
-- Corrigindo o nome do páis
UPDATE Demissoes SET country = "Norway" WHERE company = "Oda" AND country = "Sweden";

-- 06.2 Conferindo novamente o SELECT anterior de registros duplicados 
WITH demissoes_extentida AS (
    SELECT *, 
            COUNT(*) OVER(PARTITION BY company, location, industry, data_demissao) AS qtd_registros
    FROM Demissoes
    ORDER BY company
)
SELECT * FROM demissoes_extentida WHERE qtd_registros > 1 ORDER BY qtd_registros DESC;

/* ODA em OSLO possuem 2 linhas com números iguais em total_laid_off e percentage_laid_off, 
porém com funds_raised_millions diferentes, logo, é indeterminado qual é a informação correta dos dois registros.
O terceiro registro possui número diferente no percentual o que pode implicar em demissão no mesmo dia, mas em duas partes,
ou seja, outro registro válido (não duplicado). Não removido por falta de informação adicional.

BUSTLE DIGITAL GROUP em NEW YORK CITY possui números de demissões diferentes. Permanecido ambos registros.

BYBIT em SINGAPORE possui registro com valores nulos. 
Remover a linha nula pois pode ser dupicada e/ou servir para análise por falta de informação (id 1490).

CASPER em NEW YORK CITY possui valores nulos e funds_raised_millions iguais. Remover um dos registros (id 2141).

CAZZO em LONDON, HIBOB em TEL AVIV, Wildlife Studios em Sao Paulo 
e YAHOO em SF Bay Area com registros duplos. Remover ids 1364, 2247, 2144 e 162

*/

-- Remover registros duplicados (IDs 1490, 2141, 1364, 2247, 2144 e 162)
DELETE FROM Demissoes 
WHERE id = 1490
    OR id = 2141
    OR id = 1364
    OR id = 2247
    OR id = 2144
    OR id = 162
;

-- Corrigindo terminus em Atlanta na area de Markting sem 'stage' em um registro
UPDATE Demissoes SET stage = "Series C" 
WHERE company = "Terminus" AND location = "Atlanta" 
    AND industry = "Marketing" AND stage = "Unknown";

-- Removendo a coluna de id criada para voltar ao padrão da tabela original
ALTER TABLE Demissoes DROP id;

-- Conferindo amostar dos dados do resultado
SELECT * FROM Demissoes ORDER BY company LIMIT 30;

-- 07 Pre Analises
-- 07.1 Conferindo e avaliando registros com campos numéris completamentos nulos
SELECT total_laid_off, percentage_laid_off, funds_raised_millions, COUNT(*) 
FROM Demissoes 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL AND funds_raised_millions IS NULL
GROUP BY total_laid_off, percentage_laid_off, funds_raised_millions;

-- 07.2 Considerando que esses registros não possuem nenhum dado numérico, 
-- esses 44 registros serão descartados por considerar-los não confiáveis para análises
DELETE FROM Demissoes 
WHERE total_laid_off IS NULL 
        AND percentage_laid_off IS NULL 
        AND funds_raised_millions IS NULL;

-- 08 Análises
-- 08.1 Paises e o percentual de demissões em relação ao total
WITH demissoes_para_percentual AS (
    SELECT country, 
            SUM(total_laid_off) AS "Qtd_Demissoes"
    FROM Demissoes
    GROUP BY country
    HAVING SUM(total_laid_off) IS NOT NULL
    ORDER BY SUM(total_laid_off) DESC
),
demissoes_percentuaLl AS (
    SELECT country, 
            Qtd_Demissoes,
            100 * Qtd_Demissoes / (SELECT SUM(Qtd_Demissoes) FROM demissoes_para_percentual) AS "% em relação ao total de demissões"
    FROM demissoes_para_percentual
)
SELECT * FROM demissoes_percentuaLl
UNION
SELECT CONCAT("Qtd Paises: ", 
                (SELECT COUNT(country) FROM demissoes_percentuaLl)
        ),
        CONCAT("Total Demissoes: ", 
                (SELECT SUM(Qtd_Demissoes) FROM demissoes_percentuaLl)
        ),
        CONCAT("Total: ", 
                (SELECT SUM(`% em relação ao total de demissões`) FROM demissoes_percentuaLl)
        )
FROM demissoes_percentuaLl;

-- 08.2 Empresas com maiores números de demissões

WITH empresa_demissoes AS 
(
    SELECT company, SUM(total_laid_off) AS total_demissoes
    FROM Demissoes
    GROUP BY company
    HAVING total_demissoes IS NOT NULL
    ORDER BY total_demissoes DESC
),
empresa_demissoes_cumulativo AS (
    SELECT DENSE_RANK() OVER(ORDER BY total_demissoes DESC) AS "#Pos",
        company,
        total_demissoes,
        SUM(total_demissoes) OVER(ORDER BY total_demissoes DESC) AS "Acumulativo"
    FROM empresa_demissoes
)
SELECT * FROM empresa_demissoes_cumulativo;

    
-- 08.3 Número de demissões ao longo do tempo
SELECT 
    DATE_FORMAT(data_demissao, "%Y-%m") AS Ano_Mes, 
    SUM(total_laid_off) AS Total_Demissoes,
    DENSE_RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS "# Rank Demissões no Mês"
FROM Demissoes
GROUP BY DATE_FORMAT(data_demissao, "%Y-%m")
HAVING Ano_Mes IS NOT NULL AND Total_Demissoes IS NOT NULL
ORDER BY Ano_Mes ASC;


