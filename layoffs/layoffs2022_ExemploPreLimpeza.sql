USE layoffs2022;

/* EXEMPLO DE ANTES DA LIMPEZA
caracteres indevidos,/nomes incorretos, país incosistente (nomes distintos) 
e industria inconsistentes (com e sem espaço no nome), além de campo vazio
*/

SELECT company, location, country, industry
FROM layoffs
WHERE company LIKE "Ual%" 
UNION
    SELECT company, location, country, industry
    FROM layoffs
    WHERE location NOT REGEXP "^[a-zA-Z0-9  \.]+$"
UNION
    SELECT company, location, country, industry
    FROM layoffs
    WHERE country NOT REGEXP "^[a-zA-Z0-9 ]+$"
UNION
    SELECT company, location, country, industry
    FROM layoffs
    WHERE industry LIKE "Crypto_%" OR industry = ""
UNION
    SELECT company, location, country, industry
    FROM layoffs
    WHERE company = "Oda"
    ORDER BY 4
;
