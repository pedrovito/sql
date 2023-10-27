USE exercicios_trigger;


CREATE TRIGGER inserir_cliente_auditoria AFTER INSERT ON <link>Clientes</link>
FOR EACH ROW
BEGIN
    INSERT INTO <link>Auditoria</link> (mensagem, data_hora)
    VALUES ('Novo cliente inserido: ' + NEW.nome, NOW());
END;


CREATE TRIGGER excluir_cliente_auditoria BEFORE DELETE ON <link>Clientes</link>
FOR EACH ROW
BEGIN
    INSERT INTO <link>Auditoria</link> (mensagem, data_hora)
    VALUES ('Tentativa de exclusão do cliente: ' + OLD.nome, NOW());
END;


CREATE TRIGGER atualizar_nome_cliente_auditoria AFTER UPDATE ON <link>Clientes</link>
FOR EACH ROW
BEGIN
    IF NEW.nome <> OLD.nome THEN
        INSERT INTO <link>Auditoria</link> (mensagem, data_hora)
        VALUES ('Nome do cliente atualizado de ' + OLD.nome + ' para ' + NEW.nome, NOW());
    END IF;
END;


DELIMITER //
CREATE TRIGGER impedir_nome_vazio_null BEFORE UPDATE ON <link>Clientes</link>
FOR EACH ROW
BEGIN
    IF NEW.nome = '' OR NEW.nome IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O nome do cliente não pode ser vazio ou NULL.';
    END IF;
END //
DELIMITER ;

CREATE TRIGGER decrementar_estoque_auditoria AFTER INSERT ON <link>Pedidos</link>
FOR EACH ROW
BEGIN
    UPDATE <link>Produtos</link>
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
    
    IF (SELECT estoque FROM <link>Produtos</link> WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO <link>Auditoria</link> (mensagem, data_hora)
        VALUES ('Estoque baixo para o produto: ' + (SELECT nome FROM <link>Produtos</link> WHERE id = NEW.produto_id), NOW());
    END IF;
END;