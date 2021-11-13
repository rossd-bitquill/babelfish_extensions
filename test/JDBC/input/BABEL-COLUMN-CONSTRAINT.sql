USE master;
GO

CREATE SCHEMA [Babelfish_COLCONST];
GO

create table [Babelfish_COLCONST].[a] (
  id int identity primary key,
  texto varchar(50) NOT NULL
);
GO

create table [Babelfish_COLCONST].[b] (
  id int identity primary key,
  foreign_id int not null references [Babelfish_COLCONST].[a],
  texto varchar(50) NOT NULL
);
GO

create table [Babelfish_COLCONST].[c] (
    id int identity primary key,
    foreign_id int not null,
    foreign key(foreign_id) references [Babelfish_COLCONST].[a](id),
    texto varchar(50) NOT NULL
);
GO

SET IDENTITY_INSERT [Babelfish_COLCONST].[a] ON;
insert into [Babelfish_COLCONST].[a](id,texto) values(1, 'some text');
SET IDENTITY_INSERT [Babelfish_COLCONST].[a] OFF;
GO

insert into [Babelfish_COLCONST].[b](foreign_id, texto) values(1,'insert text');
GO

insert into [Babelfish_COLCONST].[c](foreign_id, texto) values(1,'insert text');
GO

DROP TABLE [Babelfish_COLCONST].[c];
DROP TABLE [Babelfish_COLCONST].[b];
DROP TABLE [Babelfish_COLCONST].[a];
DROP SCHEMA [Babelfish_COLCONST];
GO
