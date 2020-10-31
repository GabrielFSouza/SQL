SELECT    pe.codigo,
    pe.nome,
    pe.natureza,
    RPAD(pe.cnpj_cpf, 14 , '0') AS cnpj_cpf,
    solv.titulo,
    cli.data_cadastro AS data_cadastro_cliente,
    cli.data_aprovacao AS data_aprovacao_cliente,
    cli.data_bloqueio AS data_bloqueio_cliente,
    cli.vencimento_credito as vencimento_credito,
    (CASE WHEN cli.situacao_credito = 1 THEN 'PENDENTE AGUARDANDO APROVAÇÃO'
	WHEN cli.situacao_credito = 2 THEN 'LIBERADO' 
	WHEN cli.situacao_credito = 3 THEN 'BLOQUEADO'
	WHEN cli.situacao_credito = 4 THEN 'RESTRIÇÃO'
	END) AS situacao_credito
FROM pessoa pe 
    INNER JOIN cliente cli ON (cli.id_cliente = pe.id_pessoa)
    INNER JOIN sis_opcao_lista_valor solv ON (solv.id = cli.situacao AND solv.id_lista_valor = 'CED4819EB98547978B2DDD63C4F1CC19')
WHERE cli.situacao IN (:SituacaoClienteMultSlc)
and vencimento_credito between (:DataInicialVencimento) and (:DataFinalVencimento)
and cli.situacao_credito in (:SituacaoCredito)
ORDER BY pe.nome

--Gabriel Ferreira de Souza