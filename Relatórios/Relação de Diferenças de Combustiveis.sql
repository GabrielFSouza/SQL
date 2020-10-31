--QUERY CUSTOMIZADA

WITH mov_estoque AS (
	SELECT	id_empresa,
		data_movimento,
		id_local_estoque,
		id_item,
		SUM(quantidade) AS valor
	FROM	movimento_estoque
	WHERE	data_movimento BETWEEN :DataInicial AND :DataFinal
	AND	id_empresa =  :IdEmpresaObrigatorio
	AND	id_tipo_movimento_estoque = 3
	GROUP BY 1,2,3,4 ),

volume AS (
	SELECT	mlmcx.id_movimento_lmc,
		nfex.entrada,
		lex.numero_tanque,
		SUM(infex.quantidade_convertida) AS volume_recebido
	FROM	movimento_lmc AS mlmcx
		INNER JOIN lmc AS lmcx ON (lmcx.id_lmc = mlmcx.id_lmc)
		INNER JOIN local_estoque AS lex ON (lex.id_item_tanque = lmcx.id_combustivel AND lex.id_empresa = lmcx.id_empresa)
		INNER JOIN item_nfe AS infex ON (infex.id_item = lex.id_item_tanque AND infex.id_local_estoque = lex.id_local_estoque)
		INNER JOIN nota_fiscal_entrada AS nfex ON (nfex.id_nota_fiscal_entrada = infex.id_nota_fiscal_entrada)
		--INNER JOIN medicao
	WHERE	mlmcx.data_movimento BETWEEN :DataInicial AND :DataFinal
	AND	nfex.id_empresa = :IdEmpresaObrigatorio
	AND	lmcx.id_empresa = :IdEmpresaObrigatorio
	AND	lex.id_empresa = :IdEmpresaObrigatorio
	GROUP BY 1,2,3 ),
	--Parametros Configurados ate aqui

resul AS (
	SELECT	se.id_empresa,
		se.nome AS nome_empresa,
		mt.id_tanque,
		le.denominacao AS denominacao_tanque,
		mt.estoque_abertura,
		lmc.id_combustivel,
		it.denominacao AS denominacao_item,
		mt.venda_dia,
		COALESCE((	SELECT valor FROM mov_estoque WHERE id_local_estoque = mt.id_tanque AND mov_estoque.data_movimento = mlmc.data_movimento), 0) AS valor_estoque,
		mlmc.data_movimento,
		mt.estoque_escritural,
		mt.estoque_fisico_fechamento, 
		mt.sobra,
		mt.perda,
		(mt.sobra - mt.perda) AS total_perdas_sobras,
		(SELECT volume_recebido FROM volume WHERE id_movimento_lmc = mlmc.id_movimento_lmc AND entrada = data_movimento AND numero_tanque = le.numero_tanque) AS volume_recebido
	FROM	lmc
		INNER JOIN movimento_lmc AS mlmc ON (mlmc.id_lmc = lmc.id_lmc)
		INNER JOIN medicao_tanque_lmc AS mt ON (mt.id_movimento_lmc = mlmc.id_movimento_lmc)
		INNER JOIN local_estoque AS le ON (le.id_local_estoque = mt.id_tanque)
		INNER JOIN item AS it ON (lmc.id_combustivel = it.id_item)
		INNER JOIN sis_empresa AS se ON (se.id_empresa = lmc.id_empresa)
	WHERE	mlmc.data_movimento BETWEEN :DataInicial AND :DataFinal
	AND	le.id_empresa = :IdEmpresaObrigatorio
	AND	(:IdTanque = -1 OR le.id_local_estoque = :IdTanque)
	AND	NOT (mt.estoque_escritural = 0 AND mt.estoque_fisico_fechamento = 0) )

SELECT	r.nome_empresa,
	r.denominacao_tanque,
	--r.denominacao_item,
	r.data_movimento,
	r.estoque_abertura,
	r.volume_recebido,
	r.estoque_escritural,
	(r.venda_dia - r.valor_estoque) AS saida,
	--r.sobra,
	(r.estoque_escritural - r.estoque_fisico_fechamento) as diferenca,
	r.estoque_fisico_fechamento as estoque_final
	--r.total_perdas_sobras,
	--ROUND(((r.total_perdas_sobras / ((r.venda_dia - r.valor_estoque) + 0.0001)) * 100), 3) AS perc_perdas_sobras,
	
FROM	resul AS r
ORDER BY r.nome_empresa,
	r.denominacao_tanque,
	--r.denominacao_item
	r.data_movimento

	--Gabriel Ferreira de Souza 