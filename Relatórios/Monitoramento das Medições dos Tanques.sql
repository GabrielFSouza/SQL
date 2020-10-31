-- Monitoramento das Medições dos Tanques
SELECT 	se.nome AS empresa,
	le.denominacao AS tanque,
	cmt.data_medicao,
	cmt.volume_medicao_1,
	cmt.hora_medicao_1,
	cmt.volume_medicao_2,
	cmt.hora_medicao_2,
	cmt.volume_medicao_3,
	cmt.hora_medicao_3,
	cmt.volume_medicao_4,
	cmt.hora_medicao_4,
	(cmt.volume_medicao_2 - cmt.volume_medicao_1) AS diferenca_medicao1,
	(cmt.volume_medicao_3 - cmt.volume_medicao_2) AS diferenca_medicao2,
	(cmt.volume_medicao_4 - cmt.volume_medicao_3) AS diferenca_medicao3

FROM    captura_medicao_tanque AS cmt
	INNER JOIN local_estoque AS le ON (le.id_local_estoque = cmt.id_tanque)
	INNER JOIN sis_empresa AS se ON (se.id_empresa = le.id_empresa)
WHERE   le.id_empresa IN (:IdEmpresaMultSlc)
AND	cmt.data_medicao BETWEEN :DataInicial AND :DataFinal
AND	cmt.tipo_medicao = f_obtem_parametro_inteiro('automacao.tipo_medicao_lmc_automatico', le.id_empresa, 0, 'N')
ORDER BY se.nome,
	cmt.data_medicao,
	le.denominacao

	--Gabriel Ferreira de Souza