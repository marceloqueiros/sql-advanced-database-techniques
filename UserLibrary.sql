USE MASTER
GO

CREATE DATABASE BookList
GO

USE BookList
GO

CREATE TABLE Autor(
ID_Autor INTEGER IDENTITY(1,1) NOT NULL,
Nome VARCHAR(60) NOT NULL, 
Pseudonimo VARCHAR(60),
Biografia VARCHAR(1000), 
PRIMARY KEY(ID_Autor)
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

CREATE TABLE Administrador(
ID_Administrador INTEGER IDENTITY(1,1) NOT NULL,
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(100) NOT NULL, 
Email VARCHAR(255) NOT NULL,
CHECK(Email like '_%@_%._%'),
PRIMARY KEY(ID_Administrador)      
)

CREATE TABLE Utilizador(
ID_Utilizador INTEGER IDENTITY(1,1) NOT NULL, 
Username VARCHAR(20) NOT NULL, 
Pass VARCHAR(20) NOT NULL, 
Nome VARCHAR(60) NOT NULL, 
Estado INTEGER NOT NULL, 
Data_Nascimento DATE NOT NULL, 
Email VARCHAR(255) NOT NULL,
MoradaLocalidade VARCHAR(500), 
PRIMARY KEY(ID_Utilizador)
)

CREATE TABLE Escreve(
ID_Autor INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL,
FOREIGN KEY(ID_Autor) REFERENCES Autor(ID_Autor),
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Autor)
)

CREATE TABLE  Pertence(
ID_Categoria INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL,
FOREIGN KEY(ID_Categoria) REFERENCES Categoria(ID_Categoria),
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Categoria)
)

CREATE TABLE  Disponivel(
ID_Loja INTEGER NOT NULL, 
ID_Livro INTEGER NOT NULL, 
Link VARCHAR(300) NOT NULL,
FOREIGN KEY(ID_Loja) REFERENCES Loja(ID_Loja),
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
PRIMARY KEY(ID_Livro, ID_Loja)
)

CREATE TABLE Leu(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Comentario DATE, 
Comentario VARCHAR(500),
Estado BIT NOT NULL DEFAULT 1,
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador),
PRIMARY KEY(ID_Livro,ID_Utilizador)
)

CREATE TABLE Pede(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Criacao DATE NOT NULL, 
Estado_Pedido INTEGER NOT NULL,
CHECK(Estado_Pedido between 0 and 2),
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador),
PRIMARY KEY(ID_Livro, ID_Utilizador,Data_Criacao)
)

CREATE TABLE Bloqueia(
ID_Administrador INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Data_Bloqueio DATE NOT NULL, 
Data_Desbloqueio DATE, 
Motivo VARCHAR(200),
CHECK(Data_Desbloqueio>Data_Bloqueio),
FOREIGN KEY(ID_Administrador) REFERENCES Administrador(ID_Administrador),
FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador),
PRIMARY KEY(ID_Administrador, ID_Utilizador)
)

CREATE TABLE Possui(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador INTEGER NOT NULL, 
Visibilidade BIT NOT NULL,
Estado BIT NOT NULL DEFAULT 1,
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador),
PRIMARY KEY(ID_Livro, ID_Utilizador)
)

CREATE TABLE Empresta(
ID_Livro INTEGER NOT NULL, 
ID_Utilizador_pediu INTEGER NOT NULL, 
ID_Utilizador_recebeu integer not null,
Data_Emprestimo DATE NOT NULL, 
Data_Devolucao DATE, 
FOREIGN KEY(ID_Livro) REFERENCES Livro(ID_Livro),
FOREIGN KEY(ID_Utilizador_pediu) REFERENCES Utilizador(ID_Utilizador),
FOREIGN KEY(ID_Utilizador_recebeu) REFERENCES Utilizador(ID_Utilizador),
PRIMARY KEY(ID_Livro, ID_Utilizador_pediu, ID_Utilizador_recebeu, Data_Emprestimo)
)