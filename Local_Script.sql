USE master
GO

CREATE DATABASE BookListDistribuida
GO

USE BookListDistribuida
GO

-----> Criação do Linked Server para o Servidor Remoto;
EXEC sp_addlinkedserver 'ServidorRemoto', 'SQLServer OLEDB Provider', 'SQLOLEDB', '192.168.XXX.XXX'
-----> Criação do Processo de Autenticação para o Acesso ao Servidor Remoto;
EXEC sp_addlinkedsrvlogin
	@rmtsrvname = 'ServidorRemoto',
	@rmtuser = 'sa',
	@rmtpassword = '123456'

CREATE TABLE AutorAN(
ID_Autor INTEGER NOT NULL,
Nome VARCHAR(60) NOT NULL, 
Pseudonimo VARCHAR(60),
Biografia VARCHAR(1000), 
PRIMARY KEY(ID_Autor, Nome),
CHECK (Nome like '%AN%') --Pessoas que tenham AN no nome em qualquer posiçao
)

CREATE TABLE AdministradorAF(
ID_Administrador INTEGER NOT NULL,
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(100) NOT NULL, 
Email VARCHAR(255) NOT NULL,
CHECK(Email like '_%@_%._%'),
PRIMARY KEY(ID_Administrador, Username),
CHECK (Username <= 'F')   -- Admins com nomes de A a F
)

CREATE TABLE UtilizadorGmail(
ID_Utilizador INTEGER NOT NULL, 
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(20) NOT NULL, 
Nome VARCHAR(60) NOT NULL, 
Estado INTEGER NOT NULL, 
Data_Nascimento DATE NOT NULL, 
Email VARCHAR(255) NOT NULL,
MoradaLocalidade VARCHAR(500), 
PRIMARY KEY(ID_Utilizador, Email),
CHECK (Email like '%@gmail.com') --Emails pertencentes à Google
)

CREATE TABLE Categoria(
ID_Categoria INTEGER IDENTITY(1,1) NOT NULL,
Nome VARCHAR(60) NOT NULL, 
PRIMARY KEY(ID_Categoria)
)

CREATE TABLE Loja(
ID_Loja INTEGER IDENTITY(1,1) NOT NULL,
Nome VARCHAR(60) NOT NULL, 
PRIMARY KEY(ID_Loja)
)

CREATE TABLE Livro(
ID_Livro INTEGER IDENTITY(1,1) NOT NULL, 
ISBN VARCHAR(30) UNIQUE NOT NULL, 
Titulo VARCHAR(50) NOT NULL, 
Editora VARCHAR(50) NOT NULL,
Sinopse VARCHAR(MAX) NOT NULL, 
EdicaoData DATE NOT NULL,
Estado BIT NOT NULL DEFAULT 1,
PRIMARY KEY(ID_Livro)
)

CREATE TABLE Leu(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Comentario DATE, 
Comentario VARCHAR(500),
Estado BIT NOT NULL DEFAULT 1,
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro,ID_Utilizador)
)

CREATE TABLE Pede(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Criacao DATE NOT NULL, 
Estado_Pedido INTEGER NOT NULL,
CHECK(Estado_Pedido between 0 and 2),
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Utilizador,Data_Criacao)
)

CREATE TABLE Bloqueia(
ID_Administrador INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Bloqueio DATE NOT NULL, 
Data_Desbloqueio DATE, 
Motivo VARCHAR(200),
CHECK(Data_Desbloqueio>Data_Bloqueio),
PRIMARY KEY(ID_Administrador, ID_Utilizador)
)

CREATE TABLE Possui(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Visibilidade BIT NOT NULL,
Estado BIT NOT NULL DEFAULT 1,
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Utilizador)
)

CREATE TABLE Empresta(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador_pediu INTEGER NOT NULL, 
ID_Utilizador_recebeu integer not null,
Data_Emprestimo DATE NOT NULL, 
Data_Devolucao DATE, 
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Utilizador_pediu, ID_Utilizador_recebeu, Data_Emprestimo)
)

-----> Criação das "Views" para união das Tabelas Divididas e Acesso a Tabelas Remotas;
USE BookListDistribuida
GO

CREATE VIEW Utilizador
AS
	SELECT * FROM UtilizadorGmail
	UNION ALL
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.UtilizadorNGM
GO

CREATE VIEW Autor
AS
	SELECT * FROM AutorAN
	UNION ALL
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.AutorNAN
GO

CREATE VIEW Administrador
AS
	SELECT * FROM AdministradorAF
	UNION ALL
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.AdministradorGZ
GO

CREATE VIEW Escreve
AS
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.Escreve
GO

CREATE VIEW Pertence
AS
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.Pertence
GO

CREATE VIEW Disponivel
AS
	SELECT * FROM ServidorRemoto.BookListDistribuidaRemota.dbo.Disponivel
GO

use BookList
go

------------------------------
--       Criar Logins       --
------------------------------

CREATE LOGIN UtilizadorLog    WITH PASSWORD = 'Utilizador'
CREATE LOGIN AdministradorLog WITH PASSWORD = 'Administrador'
CREATE LOGIN VisitanteLog     WITH PASSWORD = 'Visitante'

------------------------------
--       Criar Users        --
------------------------------

CREATE USER Utilizador_TABD    FOR LOGIN UtilizadorLog
CREATE USER Administrador_TABD FOR LOGIN AdministradorLog
CREATE USER Visitante_TABD     FOR LOGIN VisitanteLog

------------------------------
--       Criar Roles        --
------------------------------

CREATE ROLE roleAdministrador
EXEC sp_addrolemember 'roleAdministrador', 'Administrador_TABD'

CREATE ROLE roleUtilizador
EXEC sp_addrolemember 'roleUtilizador', 'Utilizador_TABD'

CREATE ROLE roleVisitante
EXEC sp_addrolemember 'roleVisitante', 'Visitante_TABD'

------------------------------
--     Criar Permissões     --
------------------------------

-----> Visitante:
GRANT SELECT ON Livro		    TO roleVisitante
GRANT SELECT ON Escreve		    TO roleVisitante
GRANT SELECT ON Autor		    TO roleVisitante
GRANT SELECT ON AutorAN		    TO roleVisitante
GRANT SELECT ON Pertence	    TO roleVisitante
GRANT SELECT ON Categoria	    TO roleVisitante
GRANT SELECT ON Bloqueia	    TO roleVIsitante
GRANT SELECT ON Administrador   TO roleVisitante
GRANT SELECT ON AdministradorAF TO roleVisitante
GRANT INSERT ON Utilizador	    TO roleVisitante
GRANT SELECT ON UtilizadorGmail TO roleVisitante

-----> Utilizador:
GRANT SELECT				 ON Autor			TO roleUtilizador
GRANT SELECT				 ON AutorAN			TO roleUtilizador
GRANT SELECT				 ON Escreve			TO roleUtilizador
GRANT SELECT				 ON Livro			TO roleUtilizador
GRANT SELECT				 ON Pertence		TO roleUtilizador
GRANT SELECT				 ON Categoria		TO roleUtilizador
GRANT SELECT                 ON Disponivel		TO roleUtilizador
GRANT SELECT                 ON Loja			TO roleUtilizador
GRANT SELECT, update         ON Utilizador		TO roleUtilizador
GRANT SELECT, update         ON UtilizadorGmail TO roleUtilizador
GRANT SELECT, INSERT, update ON Possui			TO roleUtilizador
GRANT SELECT, INSERT, update ON Pede			TO roleUtilizador
GRANT SELECT, INSERT, update ON Empresta		TO roleUtilizador
GRANT SELECT, INSERT, update ON Leu				TO roleUtilizador


-----> Administrador:
GRANT SELECT                         ON Administrador	TO roleAdministrador
GRANT SELECT                         ON AdministradorAF TO roleAdministrador
GRANT SELECT                         ON Possui			TO roleAdministrador
GRANT SELECT                         ON Pede			TO roleAdministrador
GRANT SELECT                         ON Empresta		TO roleAdministrador
GRANT SELECT                         ON Leu				TO roleAdministrador
GRANT SELECT, update (estado)		 ON Utilizador		TO roleAdministrador
GRANT SELECT, update (estado)		 ON UtilizadorGmail TO roleAdministrador
GRANT SELECT, INSERT, update         ON Bloqueia		TO roleAdministrador
GRANT SELECT, INSERT, update		 ON Livro			TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Escreve			TO roleAdministrador
GRANT SELECT, INSERT, update		 ON Autor			TO roleAdministrador
GRANT SELECT, INSERT, update		 ON AutorAN			TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Pertence		TO roleAdministrador
GRANT SELECT, INSERT, update		 ON Categoria		TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Disponivel		TO roleAdministrador
GRANT SELECT, INSERT, update		 ON Loja			TO roleAdministrador

------------------------------
--Permissões para Procedures--
------------------------------
-----> Visitante:
GRANT EXECUTE ON RegistarUtilizador TO roleVisitante

-----> Utilizador:
GRANT EXECUTE ON CriarLeu		  TO roleUtilizador
GRANT EXECUTE ON CriarPossui	  TO roleUtilizador
GRANT EXECUTE ON CriarPedido	  TO roleUtilizador
GRANT EXECUTE ON ApagarLeu		  TO roleUtilizador
GRANT EXECUTE ON ApagarPossui	  TO roleUtilizador
GRANT EXECUTE ON EditarLeu		  TO roleUtilizador
GRANT EXECUTE ON EditarPossui     TO roleUtilizador
GRANT EXECUTE ON EditarPedido     TO roleUtilizador
GRANT EXECUTE ON CriarEmprestimo  TO roleUtilizador
GRANT EXECUTE ON DevolverLivro	  TO roleUtilizador
GRANT EXECUTE ON EditarUtilizador TO roleUtilizador

-----> Administrador:
GRANT EXECUTE ON CriarAutor			   TO roleAdministrador
GRANT EXECUTE ON CriarCategoria		   TO roleAdministrado
GRANT EXECUTE ON CriarLoja			   TO roleAdministrador
GRANT EXECUTE ON EditarAutor		   TO roleAdministrador
GRANT EXECUTE ON EditarCategoria	   TO roleAdministrador
GRANT EXECUTE ON EditarLoja			   TO roleAdministrador
GRANT EXECUTE ON CriarLivroCategoria   TO roleAdministrador
GRANT EXECUTE ON CriarLivroAutor	   TO roleAdministrador
GRANT EXECUTE ON CriarLivroLoja		   TO roleAdministrador
GRANT EXECUTE ON ApagarLivroCategoria  TO roleAdministrador
GRANT EXECUTE ON ApagarLivroAutor	   TO roleAdministrador
GRANT EXECUTE ON ApagarLivroLoja	   TO roleAdministrador
GRANT EXECUTE ON EditarDisponivel	   TO roleAdministrador
GRANT EXECUTE ON CriarLivro			   TO roleAdministrador
GRANT EXECUTE ON EditarLivro		   TO roleAdministrador
GRANT EXECUTE ON OcultarLivro		   TO roleAdministrador
GRANT EXECUTE ON BloquearUtilizador    TO roleAdministrador
GRANT EXECUTE ON DesbloquearUtilizador TO roleAdministrador
GRANT EXECUTE ON AtivarUtilizador	   TO roleAdministrador
GRANT EXECUTE ON EditarAdmin		   TO roleAdministrador


------------------------------
--   Standard Procedures    --
------------------------------


USE BookListDistribuida
GO

SET XACT_ABORT ON
GO

----> Criar Autor <----
CREATE PROCEDURE CriarAutor
@Nome VARCHAR(60), 
@Pseudonimo VARCHAR(60), 
@Biografia VARCHAR(1000)
AS
SET TRANSACTION ISOLATION LEVEL Serializable
	BEGIN DISTRIBUTED TRANSACTION

	DECLARE @AUXID Integer
	SELECT @AuxID = MAX(ID_Autor) FROM Autor

	INSERT INTO Autor(ID_Autor, Nome, Pseudonimo, Biografia) VALUES (@AUXID + 1, @Nome, @Pseudonimo, @Biografia)

	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Criar Categoria <----
CREATE PROCEDURE CriarCategoria
@Nome VARCHAR(60)
AS
SET TRANSACTION ISOLATION LEVEL Serializable
	BEGIN TRANSACTION
	
	INSERT INTO Categoria(Nome) VALUES (@Nome)
		
	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Criar Loja <----
CREATE PROCEDURE CriarLoja
@Nome VARCHAR(60)
AS
SET TRANSACTION ISOLATION LEVEL Serializable
	BEGIN TRANSACTION
	
	INSERT INTO Loja(Nome) VALUES (@Nome) 

	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Editar Autor <----
CREATE PROCEDURE EditarAutor
@ID_Autor INT,
@Nome VARCHAR(60),
@Pseudonimo VARCHAR(60),
@Biografia VARCHAR(1000)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN DISTRIBUTED TRANSACTION

	UPDATE Autor
	SET Nome = @Nome, Pseudonimo = @Pseudonimo, Biografia = @Biografia
	WHERE ID_Autor = @ID_Autor

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Editar Categoria <----
CREATE PROCEDURE EditarCategoria
@ID_Categoria INT,
@Nome VARCHAR(60)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	UPDATE Categoria
	SET Nome = @Nome
	WHERE ID_Categoria = @ID_Categoria

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Editar Loja <----
CREATE PROCEDURE EditarLoja
@ID_Loja INT,
@Nome VARCHAR(60)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	UPDATE Loja
	SET Nome = @Nome
	WHERE ID_Loja = @ID_Loja

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Criar Relaçao Livro-Categoria <----
CREATE PROCEDURE CriarLivroCategoria
@ID_Categoria INTEGER, 
@ID_Livro INTEGER
AS
SET TRANSACTION ISOLATION LEVEL Serializable

	BEGIN TRANSACTION
	
	INSERT INTO Pertence(ID_Categoria, ID_Livro) VALUES (@ID_Categoria, @ID_Livro)

	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Criar Relaçao Livro-Autor <----
CREATE PROCEDURE CriarLivroAutor
@ID_Autor INTEGER, 
@ID_Livro INTEGER
AS
SET TRANSACTION ISOLATION LEVEL Serializable

	BEGIN TRANSACTION
	
	IF NOT EXISTS(SELECT ID_Autor
	FROM Autor 
	WHERE ID_Autor = @ID_Autor) 
	begin
		rollback
		RETURN -1
	end

	INSERT INTO Escreve(ID_Autor, ID_Livro) VALUES (@ID_Autor, @ID_Livro)

	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Criar Relaçao Livro-Loja <----
CREATE PROCEDURE CriarLivroLoja
@ID_Loja INTEGER, 
@ID_Livro INTEGER,
@Link VARCHAR(300)
AS
SET TRANSACTION ISOLATION LEVEL Serializable

	BEGIN TRANSACTION
	
	INSERT INTO Disponivel(ID_Loja, ID_Livro, Link) VALUES (@ID_Loja, @ID_Livro, @Link)

	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Apagar relaçao Livro-Categoria <----
CREATE PROCEDURE ApagarLivroCategoria
@ID_Categoria INTEGER, 
@ID_Livro INTEGER
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

	Delete from Pertence 
	where ID_Categoria = @ID_Categoria and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Apagar relaçao Livro-Autor <----
CREATE PROCEDURE ApagarLivroAutor
@ID_Autor INTEGER, 
@ID_Livro INTEGER
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
c
BEGIN TRANSACTION

	Delete from Escreve 
	where ID_Autor = @ID_Autor and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Apagar relaçao Livro-Loja <----
CREATE PROCEDURE ApagarLivroLoja
@ID_Loja INTEGER, 
@ID_Livro INTEGER
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

	Delete from Disponivel
	where ID_Loja = @ID_Loja and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Editar Disponivel <----
CREATE PROCEDURE EditarDisponivel
@ID_Loja INTEGER, 
@ID_Livro INTEGER,
@Link VARCHAR(300)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	Update Disponivel
	Set Link = @Link
	Where ID_Loja = @ID_Loja and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end
	
	COMMIT
	RETURN 1
GO

----> Criar Livro <----
CREATE PROCEDURE CriarLivro
@ISBN VARCHAR(30), 
@Titulo VARCHAR(50), 
@Editora VARCHAR(50),
@Sinopse VARCHAR(MAX), 
@EdicaoData DATE,
@ID_Categoria INTEGER,
@ID_Autor INTEGER,
@ID_Loja INTEGER,
@Link VARCHAR(300)
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

	DECLARE @res INT

	INSERT INTO Livro(ISBN, Titulo, Editora, Sinopse, EdicaoData, Estado) 
		VALUES (@ISBN, @Titulo, @Editora, @Sinopse, @EdicaoData, 1)
	
	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	EXEC @res = CriarLivroCategoria @ID_Categoria, @@IDENTITY
	IF (@res <> 1)
	begin
		rollback
		RETURN -2
	end
	EXEC @res = CriarLivroAutor @ID_Autor, @@IDENTITY
	IF (@res <> 1)
	begin
		rollback
		RETURN -3
	end

	EXEC @res = CriarLivroLoja @ID_Loja, @@IDENTITY, @Link
	IF (@res <> 1) 
	begin
		rollback
		RETURN -4
	end

	COMMIT
	RETURN 1
GO

----> Editar Livro <----
CREATE PROCEDURE EditarLivro
@ID_Livro INTEGER,
@ISBN VARCHAR(30), 
@Titulo VARCHAR(50), 
@Editora VARCHAR(50),
@Sinopse VARCHAR(MAX), 
@EdicaoData DATE
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

	Update Livro
	Set ISBN = @ISBN , Titulo = @Titulo, Editora = @Editora, Sinopse = @Sinopse, EdicaoData = @EdicaoData
	Where ID_Livro = @ID_Livro
	
	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Ocultar/Desocultar Livro <----   0-Oculto, 1-Visivel
CREATE PROCEDURE OcultarLivro
@ID_Livro INTEGER,
@Estado INTEGER
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION 

	Update Livro
	Set Estado = @Estado
	Where ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
go

----> Criar Leu <----
CREATE PROCEDURE CriarLeu
@ID_Livro INT,
@ID_Utilizador INT,
@Comentario VARCHAR(500)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
	
BEGIN  TRANSACTION

	IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador) 
		begin
		rollback
		RETURN -1
	end

	If(@Comentario <> null)
	begin
		INSERT INTO Leu(ID_Livro, ID_Utilizador, Data_Comentario, Comentario, Estado)
		VALUES (@ID_Utilizador, @ID_Livro, GETDATE(), @Comentario, 1)
	end
	Else
	begin
		INSERT INTO Leu(ID_Livro, ID_Utilizador, Data_Comentario, Comentario, Estado)
		VALUES (@ID_Utilizador, @ID_Livro, Null, Null, 1)
	end
	
	IF (@@ERROR <> 0) 
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Criar Possui <----
CREATE PROCEDURE CriarPossui
@ID_Utilizador INT,
@ID_Livro INT,
@Visibilidade BIT
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador) 
		begin
		rollback
		RETURN -1
	end

	INSERT INTO Possui(ID_Livro, ID_Utilizador, Visibilidade, Estado) 
	VALUES (@ID_Utilizador, @ID_Livro, @Visibilidade, 1)
	
	IF (@@ERROR <> 0) 
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Criar Pedido <----
CREATE PROCEDURE CriarPedido
@ID_Livro INTEGER,
@ID_Utilizador INTEGER
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION


	IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador) 
		begin
		rollback
		RETURN -1
	end

	INSERT INTO Pede(ID_Livro, ID_Utilizador,Data_Criacao, Estado_Pedido) 
	VALUES (@ID_Utilizador, @ID_Livro, GETDATE(), 0)
	
	IF (@@ERROR <> 0) 
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Apagar Leu <----
CREATE PROCEDURE ApagarLeu
@ID_Livro INT,
@ID_Utilizador INT
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
BEGIN TRANSACTION
	
	
	Delete from Leu
	where ID_Utilizador = @ID_Utilizador and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Apagar Possui <----
CREATE PROCEDURE ApagarPossui
@ID_Livro INT,
@ID_Utilizador INT
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
BEGIN TRANSACTION
	
	
	Delete from Possui
	where ID_Utilizador = @ID_Utilizador and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Editar Leu <----
CREATE PROCEDURE EditarLeu
@ID_Utilizador INTEGER,
@ID_Livro INTEGER,
@Comentario VARCHAR(500),
@Estado BIT
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	UPDATE Leu
	SET 	Comentario = @Comentario, Data_Comentario = GETDATE(), Estado = @Estado
	WHERE ID_Utilizador = @ID_Utilizador and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Editar Possui <----
CREATE PROCEDURE EditarPossui
@ID_Utilizador INT,
@ID_Livro INT,
@Visibilidade BIT,
@Estado BIT
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRANSACTION

	UPDATE Possui
	SET 	Visibilidade = @Visibilidade, Estado = @Estado
	WHERE ID_Utilizador = @ID_Utilizador and ID_Livro = @ID_Livro

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Editar Pedido <----  0-pendente 1-aceite 2-cancelado
CREATE PROCEDURE EditarPedido
@ID_Livro INTEGER,
@ID_Utilizador INTEGER,
@Data_Criacao DATE,
@Estado_Pedido INTEGER
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

BEGIN TRANSACTION

	Update Pede
	Set Estado_Pedido = @Estado_Pedido
	Where ID_Livro = @ID_Livro and ID_Utilizador = @ID_Utilizador and Data_Criacao = @Data_Criacao
	
	IF (@@ERROR <> 0 or @@ROWCOUNT = 0) 
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Criar Emprestimo (Aceitar Pedido)<----
CREATE PROCEDURE CriarEmprestimo
@ID_Livro INTEGER,
@ID_Utilizador_Pediu INTEGER, 
@ID_Utilizador_Emprestou INTEGER,
@Data_Criacao DATE
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

	IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador_Pediu) 
		begin
		rollback
		RETURN -1
	end

		IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador_Emprestou) 
		begin
		rollback
		RETURN -2
	end
	DECLARE @res INT

	INSERT INTO Empresta(ID_Livro, ID_Utilizador_pediu, ID_Utilizador_recebeu, Data_Emprestimo) 
		VALUES (@ID_Livro, @ID_Utilizador_Pediu, @ID_Utilizador_Emprestou, GETDATE())
	
	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -3
	end

	EXECUTE @res = EditarPossui @ID_Utilizador_Emprestou, @ID_Livro, 1, 0 --visibilidade 1 e Estado 0
	IF (@res <> 1)
	begin
		rollback
		RETURN -4
	end

	EXEC @res = EditarPedido @ID_Livro, @ID_Utilizador_Pediu, @Data_Criacao, 1 --estado 1, pedido aceite
	IF (@res <> 1)
	begin
		rollback
		RETURN -5
	end


	COMMIT
	RETURN 1
GO

----> Devolver Livro <----
CREATE PROCEDURE DevolverLivro
@ID_Livro INTEGER,
@ID_Utilizador_Pediu INTEGER, 
@ID_Utilizador_Emprestou INTEGER,
@Data_Empresta DATE,
@LeuLivro BIT,
@Comentario VARCHAR(500)
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION
	DECLARE @res INT
	UPDATE Empresta
	SET 	Data_Devolucao = GETDATE()
	WHERE ID_Utilizador_pediu = @ID_Utilizador_Pediu and ID_Livro = @ID_Livro and ID_Utilizador_recebeu = @ID_Utilizador_Emprestou and Data_Emprestimo = @Data_Empresta
	
	IF (@@ERROR <> 0)
	begin
		rollback
		RETURN -1
	end

	EXECUTE @res = EditarPossui @ID_Utilizador_Emprestou, @ID_Livro, 1, 1 --visibilidade 1 e Estado 1
	IF (@res <> 1)
	begin
		rollback
		RETURN -2
	end

	EXEC @res = EditarLeu @ID_Utilizador_Pediu, @ID_Livro, @Comentario, @LeuLivro --estado 1, pedido aceite
	IF (@res <> 1)
	begin
		rollback
		RETURN -3
	end


	COMMIT
	RETURN 1
GO

----> Registar Utilizador <----
CREATE PROCEDURE RegistarUtilizador 
@Username VARCHAR(20),
@Pass VARCHAR(20), 
@Nome VARCHAR(60),
@DataNasc DATE,
@EMail VARCHAR(255),
@Morada VARCHAR(500)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	DECLARE @AUXID Integer
	SELECT @AuxID = MAX(ID_Autor) FROM Autor

BEGIN DISTRIBUTED TRAN
	INSERT INTO Utilizador(ID_Utilizador ,Username, Pass, Nome, Estado, Data_Nascimento, Email, MoradaLocalidade)
	VALUES(@AuxID + 1, @Username, @Pass, @Nome, 0, @DataNasc, @EMail, @Morada) --Estado a 0, Pendente

	IF (@@ERROR <> 0) 
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Editar Utilizador <----
CREATE PROCEDURE EditarUtilizador 
@ID_Utilizador INTEGER,
@Username VARCHAR(50),
@Pass VARCHAR(16), 
@Nome VARCHAR(50),
@DataNasc VARCHAR(255),
@EMail VARCHAR(255),
@Morada VARCHAR(255)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN DISTRIBUTED TRAN
	
	UPDATE Utilizador
		SET Username = @Username, Pass = @Pass, Nome = @Nome, Data_Nascimento = @DataNasc, Email = @EMail, MoradaLocalidade = @Morada
		WHERE ID_Utilizador = @ID_Utilizador

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO

----> Bloquear Utilizador <----		  0-Pendente, 1-Ativo, 2-Bloquead0
CREATE PROCEDURE BloquearUtilizador
@ID_Admin INTEGER,
@ID_Utilizador INTEGER,
@Motivo VARCHAR(200)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	
BEGIN DISTRIBUTED TRANSACTION
	
	IF NOT EXISTS(SELECT ID_Utilizador
	FROM Utilizador 
	WHERE ID_Utilizador = @ID_Utilizador) 
		begin
		rollback
		RETURN -1
	end
	
	IF NOT EXISTS(SELECT ID_Administrador
	FROM Administrador 
	WHERE ID_Administrador = @ID_Admin) 
		begin
		rollback
		RETURN -1
	end
	INSERT INTO Bloqueia(ID_Administrador, ID_Utilizador, Data_Bloqueio, Motivo)
	VALUES (@ID_Admin, @ID_Utilizador, GETDATE(), @Motivo)
	IF (@@ERROR <> 0) 
	begin
		rollback
		RETURN -1
	end

	UPDATE Utilizador
	Set Estado = 2
	Where ID_Utilizador = @ID_Utilizador
	IF (@@ERROR <> 0 or @@ROWCOUNT = 0) 
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Desbloquear Utilizador <----
CREATE PROCEDURE DesbloquearUtilizador
@ID_Admin INTEGER,
@ID_Utilizador INTEGER
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
BEGIN DISTRIBUTED TRANSACTION
	
	UPDATE Bloqueia
	SET Data_Desbloqueio = GETDATE()
	WHERE ID_Administrador = @ID_Admin and ID_Utilizador = @ID_Utilizador

	IF (@@ERROR <> 0 or @@ROWCOUNT = 0) 
	begin
		rollback
		RETURN -1
	end

	UPDATE Utilizador
	Set Estado = 1
	Where ID_Utilizador = @ID_Utilizador
	IF (@@ERROR <> 0 or @@ROWCOUNT = 0) 
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Ativar Utilizador <----
CREATE PROCEDURE AtivarUtilizador
@ID_Utilizador INT
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
BEGIN DISTRIBUTED TRANSACTION
	
	UPDATE Utilizador
	Set Estado = 1
	Where ID_Utilizador = @ID_Utilizador

	IF (@@ERROR <> 0 or @@ROWCOUNT = 0) 
	begin
		rollback
		RETURN -2
	end

	COMMIT
	RETURN 1
GO

----> Editar Admin <----
CREATE PROCEDURE EditarAdmin 
@ID_Admin INTEGER,
@Pass VARCHAR(100),
@EMail VARCHAR(255)
AS

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN DISTRIBUTED TRAN
	
	UPDATE Administrador
		SET  Pass = @Pass, Email = @EMail
		WHERE ID_Administrador = @ID_Admin

	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
	begin
		rollback
		RETURN -1
	end

	COMMIT
	RETURN 1
GO