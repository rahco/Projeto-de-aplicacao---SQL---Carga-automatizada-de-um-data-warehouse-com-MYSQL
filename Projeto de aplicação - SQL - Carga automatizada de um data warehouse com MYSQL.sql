
-- Criar a tabela de parametros no BIGQUERY e copiar seu valor do MYSQL

DROP TABLE IF EXISTS `projeto-final-bq-ds-338821.BitbyteDW.parametro`;
CREATE TABLE `projeto-final-bq-ds-338821.BitbyteDW.parametro`
(PERIODO STRING);
INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.parametro`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT MAX(periodo_id) AS PERIODO FROM curso;");

-- Cargas das áreas de STAGE

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.curso`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.curso`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM curso WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.exercicio`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.exercicio`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM exercicio WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.matricula`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.matricula`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM matricula WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.nota`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.nota`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM nota WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.resposta`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.resposta`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM resposta WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.secao`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.secao`
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT * FROM secao WHERE periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.aluno` aluno
WHERE aluno.id IN (SELECT DISTINCT aluno_id FROM `projeto-final-bq-ds-338821.BitbyteDW.matricula`
WHERE periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`));

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.aluno` 
SELECT * FROM 
EXTERNAL_QUERY
("projects/projeto-final-bq-ds-338821/locations/southamerica-east1/connections/Banco-Bitbyte",
"SELECT DISTINCT aluno.* FROM aluno INNER JOIN matricula ON aluno.id = matricula.aluno_id WHERE matricula.periodo_id = (SELECT MAX(periodo_id) AS PERIODO FROM curso);");

-- Cargas do Data Warehouse

DELETE FROM `projeto-final-bq-ds-338821.BitbyteDW.bitbyte_dw` 
WHERE PERIODO = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`);

INSERT INTO `projeto-final-bq-ds-338821.BitbyteDW.bitbyte_dw`
SELECT 
aluno.nome AS NOME_ALUNO, curso.nome AS NOME_CURSO, matricula.tipo as TIPO_PAGAMENTO, 
curso.periodo_id AS PERIODO, curso.semestre AS SEMESTRE, curso.ano AS ANO, 
MAX(curso.preco) AS PRECO, COUNT(DISTINCT matricula.id) as NUMERO_MATRICULAS, 
ROUND((SUM(nota.nota)/SUM(1))*10) AS NOTA_FINAL
FROM `projeto-final-bq-ds-338821.BitbyteDW.aluno` aluno
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.resposta` resposta
ON aluno.id = resposta.aluno_id
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.nota` nota
ON resposta.id = nota.resposta_id AND resposta.periodo_id = nota.periodo_id
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.exercicio` exercicio 
ON exercicio.id = resposta.exercicio_id AND exercicio.periodo_id = resposta.periodo_id
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.secao` secao
ON secao.id = exercicio.secao_id AND secao.periodo_id = exercicio.periodo_id
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.curso` curso 
ON curso.id = secao.curso_id AND curso.periodo_id = secao.periodo_id
INNER JOIN `projeto-final-bq-ds-338821.BitbyteDW.matricula` matricula 
ON curso.id = matricula.curso_id and curso.periodo_id = matricula.periodo_id
AND aluno.id = matricula.aluno_id
WHERE resposta.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`) 
AND nota.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`)
AND exercicio.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`) 
AND secao.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`)
AND curso.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`) 
AND matricula.periodo_id = (SELECT PERIODO FROM `projeto-final-bq-ds-338821.BitbyteDW.parametro`)
GROUP BY 
aluno.nome, curso.nome, matricula.tipo , 
curso.periodo_id , curso.semestre, curso.ano;

-- SELECT * FROM `projeto-final-bq-ds-338821.BitbyteDW.bitbyte_dw` WHERE PERIODO ='2012.1';
























