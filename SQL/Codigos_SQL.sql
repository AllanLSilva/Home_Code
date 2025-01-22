CREATE TABLE Fornecedores (
	Id INT PRIMARY KEY,
  	Nome VARCHAR(50),
  	Email VARCHAR(30),
  	ContratoAtivo INT,
  	Endereço VARCHAR(100)

)

-- Criando a tabela 


BEGIN TRANSACTION;

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(1, 'Fornecedor A', 'fornecedora@email.com', 1);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(2, 'Fornecedor B', 'fornecedorb@email.com', 0);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(3, 'Fornecedor C', 'fornecedorc@email.com', 1);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(4, 'Fornecedor D', 'fornecedord@email.com', 0);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(5, 'Fornecedor E', 'fornecedore@email.com', 1);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(6, 'Fornecedor F', 'fornecedorf@email.com', 1);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(7, 'Fornecedor G', 'fornecedorg@email.com', 0);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(8, 'Fornecedor H', 'fornecedorh@email.com', 1);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(9, 'Fornecedor I', 'fornecedori@email.com', 0);

INSERT INTO Fornecedores (Id, Nome, Email, ContratoAtivo) VALUES
(10, 'Fornecedor J', 'fornecedorj@email.com', 1);

COMMIT;



-- Iniciando uma inserção de dados no SQLite na tabela de fornecedores

CREATE TABLE Clientes (

    Id INT PRIMARY KEY, 
    Nome VARCHAR(30),
    Email VARCHAR(30),
    Endereço VARCHAR(100),
    DataCompra DATE

)

-- Criando a Tabela de Clientes

BEGIN TRANSACTION;

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(1, 'Ana Silva', 'ana.silva@email.com', 'Rua das Flores, 123, São Paulo, SP', '2023-12-01');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(2, 'Carlos Oliveira', 'carlos.oliveira@email.com', 'Av. Paulista, 456, São Paulo, SP', '2023-12-02');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(3, 'Mariana Souza', 'mariana.souza@email.com', 'Rua das Palmeiras, 789, Rio de Janeiro, RJ', '2023-11-25');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(4, 'João Mendes', 'joao.mendes@email.com', 'Rua 7 de Setembro, 101, Salvador, BA', '2023-11-28');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(5, 'Fernanda Costa', 'fernanda.costa@email.com', 'Rua das Acácias, 1020, Belo Horizonte, MG', '2023-12-05');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(6, 'Pedro Henrique', 'pedro.henrique@email.com', 'Av. Brasil, 345, Porto Alegre, RS', '2023-12-03');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(7, 'Luciana Almeida', 'luciana.almeida@email.com', 'Rua dos Cravos, 12, Curitiba, PR', '2023-11-29');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(8, 'Rafael Lima', 'rafael.lima@email.com', 'Rua Marechal, 88, Fortaleza, CE', '2023-12-04');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(9, 'Camila Rocha', 'camila.rocha@email.com', 'Av. Santos Dumont, 250, Recife, PE', '2023-11-30');

INSERT INTO Clientes (Id, Nome, Email, Endereço, DataCompra) VALUES
(10, 'Gabriel Duarte', 'gabriel.duarte@email.com', 'Rua do Sol, 505, Brasília, DF', '2023-12-06');

COMMIT;

-- Inserindo dados na tabela de Clientes

CREATE TABLE Produtos (
    Id INT PRIMARY KEY,
    Descricao VARCHAR(100),
    ValorCompra DECIMAL(10, 2),
    ValorVenda DECIMAL(10, 2)
);

-- Tabela de Produtos

BEGIN TRANSACTION;

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(1, 'Notebook Dell Inspiron', 2500.00, 3200.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(2, 'Monitor Samsung 27"', 800.00, 1100.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(3, 'Teclado Mecânico Logitech', 200.00, 350.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(4, 'Mouse Gamer Razer', 150.00, 250.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(5, 'Smartphone Samsung Galaxy S21', 3000.00, 4000.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(6, 'Smart TV LG OLED 55"', 4000.00, 6000.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(7, 'Fone de Ouvido JBL', 100.00, 180.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(8, 'Impressora Multifuncional HP', 500.00, 750.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(9, 'Tablet Apple iPad Air', 3500.00, 4500.00);

INSERT INTO Produtos (Id, Descricao, ValorCompra, ValorVenda) VALUES
(10, 'Cadeira Gamer DXRacer', 800.00, 1200.00);

COMMIT;

-- Inserindo dados na tabela de Produtos

CREATE TABLE Vendas (
    IdVenda INT PRIMARY KEY,
    IdCliente INT,
    IdProduto INT,
    Qtd DECIMAL(10,2),
    IdFornecedor INT


)

-- Inserindo os dados de venda com Ids aleatórios que fazem referência a outras tabelas

BEGIN TRANSACTION;

INSERT INTO Vendas (IdVenda, IdCliente, IdProduto, Qtd, IdFornecedor) VALUES
(1, 3, 5, 300.00, 4),
(2, 1, 10, 10.00, 2),
(3, 6, 4, 20.00, 5),
(4, 5, 6, 250.00, 9),
(5, 2, 7, 100.00, 8),
(6, 9, 9, 80.00, 1),
(7, 10, 1, 180.00, 3),
(8, 8, 2, 20.00, 7),
(9, 7, 3, 15.00, 10)
(10, 4, 4, 300.00, 6)

COMMIT;

-- Consulta:

SELECT 

V.IdVenda as 'Id da Venda',
V.IdCliente AS 'Id do Cliente',
C.Nome AS 'Cliente',
SUBSTR(C.Endereço, LENGTH(C.Endereço) - 1, 2) AS UF,
strftime('%d/%m/%Y', C.DataCompra) AS 'Data da Venda',
V.IdProduto AS 'Id do Produto',
P.descricao AS 'Produto',
V.Qtd as 'Qtd.',
P.valorvenda as 'Valor',
CASE
    WHEN qtd IS NOT NULL THEN printf('%.2f', valorcompra * qtd)
    ELSE '-'
END AS 'Total',
V.IdFornecedor as 'Id do Fornecedor',
F.Nome as 'Fornecedor'

FROM Vendas V

	INNER JOIN
		Clientes C on V.IdCliente = C.Id 
	INNER JOIN
		Produtos P on V.IdProduto = P.id
    INNER JOIN
    	Fornecedores F ON V.IdFornecedor = F.Id
 

-- Foi elevado o nível da consulta da tabela de vendas nessa query

-- que acabou por virar um arquivo CSV e sendo tratado em pandas a partir de um data frame