USE master
GO

CREATE DATABASE BookListDistribuidaRemota
GO

USE BookListDistribuidaRemota
GO

-----> Distribuição da Base de Dados Remota;
CREATE TABLE AutorNAN(
ID_Autor INTEGER NOT NULL,
Nome VARCHAR(60) NOT NULL, 
Pseudonimo VARCHAR(60),
Biografia VARCHAR(1000), 
PRIMARY KEY(ID_Autor, Nome),
CHECK (Nome not like '%AN%') -- Pessoas que não tenham AN no nome em qualquer posiçao
)

CREATE TABLE AdministradorGZ(
ID_Administrador INTEGER NOT NULL,
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(100) NOT NULL, 
Email VARCHAR(255) NOT NULL,
CHECK(Email like '_%@_%._%'),
PRIMARY KEY(ID_Administrador, Username),
CHECK (Username > 'F')   -- Admins com nomes de G a Z
)

CREATE TABLE UtilizadorNGM(
ID_Utilizador INTEGER NOT NULL, 
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(20) NOT NULL, 
Nome VARCHAR(60) NOT NULL, 
Estado INTEGER NOT NULL, 
Data_Nascimento DATE NOT NULL, 
Email VARCHAR(255) NOT NULL,
MoradaLocalidade VARCHAR(500), 
PRIMARY KEY(ID_Utilizador, Email),
CHECK (Email not like '%@gmail.com') --Emails nao pertencentes à Google
)

CREATE TABLE Escreve(
ID_Autor INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL,
PRIMARY KEY(ID_Livro, ID_Autor)
)

CREATE TABLE  Pertence(
ID_Categoria INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL,
PRIMARY KEY(ID_Livro, ID_Categoria)
)

CREATE TABLE  Disponivel(
ID_Loja INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL, 
Link VARCHAR(300) NOT NULL,
PRIMARY KEY(ID_Livro, ID_Loja)
)

use BookListDistribuidaRemota
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
GRANT SELECT ON AutorAN		    TO roleVisitante
GRANT SELECT ON AdministradorAF TO roleVisitante
GRANT SELECT ON UtilizadorGmail TO roleVisitante
GRANT SELECT ON Escreve		    TO roleVisitante
GRANT SELECT ON Pertence	    TO roleVisitante

-----> Utilizador:
GRANT SELECT		  ON AutorAN		 TO roleUtilizador
GRANT SELECT, update  ON UtilizadorGmail TO roleUtilizador
GRANT SELECT		  ON Escreve		 TO roleUtilizador
GRANT SELECT		  ON Pertence		 TO roleUtilizador
GRANT SELECT          ON Disponivel		 TO roleUtilizador

-----> Administrador:
GRANT SELECT						 ON AdministradorAF TO roleAdministrador
GRANT SELECT, update (estado)		 ON UtilizadorGmail TO roleAdministrador
GRANT SELECT, INSERT, update		 ON AutorAN		    TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Escreve			TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Pertence		TO roleAdministrador
GRANT SELECT, INSERT, update, delete ON Disponivel		TO roleAdministrador

