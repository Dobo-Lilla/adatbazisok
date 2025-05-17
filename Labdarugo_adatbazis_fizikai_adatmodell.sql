CREATE TABLE [Bajnoksag] (
  [bajnoksag_id] int PRIMARY KEY,
  [nev] nvarchar(255),
  [ev] int,
  [szezon] nvarchar(255),
  [osztaly] nvarchar(255)
)

CREATE TABLE [Jatekosok] (
  [jatekos_id] int PRIMARY KEY,
  [csapat_id] int,
  [nev] nvarchar(255),
  [szuletesi_datum] datetime,
  [poszt] nvarchar(255),
  [mezszam] tinyint,
  [allampolgarsag] nvarchar(255)
)

CREATE TABLE [Csapatok] (
  [csapat_id] int PRIMARY KEY,
  [nev] nvarchar(255),
  [varos] nvarchar(255),
  [edzo] nvarchar(255)
)

CREATE TABLE [Merkozesek] (
  [meccs_id] int PRIMARY KEY,
  [bajnoksag_id] int,
  [hazaicsapat_id] int NOT NULL,
  [vendegcsapat_id] int NOT NULL,
  [stadion_id] int,
  [idopont] datetime,
  [nezoszam] int,
  [jatekvezeto_id] int
)

CREATE TABLE [Stadionok] (
  [stadion_id] int PRIMARY KEY,
  [nev] nvarchar(255),
  [hely] nvarchar(255),
  [befogadokepesseg] int,
  [varos] nvarchar(255)
)

CREATE TABLE [Atigazolasok] (
  [atigazolas_id] int PRIMARY KEY,
  [jatekos_id] int,
  [regi_csapat_id] int,
  [uj_csapat_id] int,
  [atigazolas_datum] datetime,
  [atigazolasi_dij] int
)

CREATE TABLE [Golok] (
  [gol_id] int PRIMARY KEY,
  [jatekos_id] int,
  [meccs_id] int,
  [perc] int,
  [ongol] bit NOT NULL DEFAULT 0,
  tipus nvarchar(50),
  CHECK (tipus IN ('büntető', 'fejes', 'távoli','ziccer'))
)

CREATE TABLE [Lapok] (
  [lap_id] int PRIMARY KEY,
  [meccs_id] int,
  [jatekos_id] int,
  [perc] int,
  tipus nvarchar(50),
  CHECK (tipus IN ('sárga', 'piros'))
)

CREATE TABLE [Jatekvezetok] (
  [jatekvezeto_id] int PRIMARY KEY,
  [nev] nvarchar(255),
  [nemzetiseg] nvarchar(255),
  [szuletesi_datum] datetime,
  [tapasztalat] smallint
)


--Kulcsok
ALTER TABLE [Merkozesek] ADD FOREIGN KEY ([bajnoksag_id]) REFERENCES [Bajnoksag] ([bajnoksag_id])

ALTER TABLE [Merkozesek] ADD FOREIGN KEY ([hazaicsapat_id]) REFERENCES [Csapatok] ([csapat_id])

ALTER TABLE [Atigazolasok] ADD FOREIGN KEY ([jatekos_id]) REFERENCES [Jatekosok] ([jatekos_id])

ALTER TABLE [Merkozesek] ADD FOREIGN KEY ([stadion_id]) REFERENCES [Stadionok] ([stadion_id])

ALTER TABLE [Merkozesek] ADD FOREIGN KEY ([vendegcsapat_id]) REFERENCES [Csapatok] ([csapat_id])

ALTER TABLE [Atigazolasok] ADD FOREIGN KEY ([regi_csapat_id]) REFERENCES [Csapatok] ([csapat_id])

ALTER TABLE [Atigazolasok] ADD FOREIGN KEY ([uj_csapat_id]) REFERENCES [Csapatok] ([csapat_id])

ALTER TABLE [Merkozesek] ADD FOREIGN KEY ([jatekvezeto_id]) REFERENCES [Jatekvezetok] ([jatekvezeto_id])

ALTER TABLE [Lapok] ADD FOREIGN KEY ([jatekos_id]) REFERENCES [Jatekosok] ([jatekos_id])

ALTER TABLE [Golok] ADD FOREIGN KEY ([jatekos_id]) REFERENCES [Jatekosok] ([jatekos_id]);

ALTER TABLE [Golok] ADD FOREIGN KEY ([meccs_id]) REFERENCES [Merkozesek] ([meccs_id]);

ALTER TABLE [Lapok] ADD FOREIGN KEY ([meccs_id]) REFERENCES [Merkozesek] ([meccs_id]);
ALTER TABLE [Jatekosok] ADD FOREIGN KEY ([csapat_id]) REFERENCES [Csapatok]([csapat_id]);




--Kényszerek
ALTER TABLE Jatekosok
ADD CONSTRAINT C_Jatekosok_Mezszam CHECK (mezszam BETWEEN 1 AND 99);

ALTER TABLE Jatekosok
ADD CONSTRAINT C_Jatekosok_Poszt CHECK (poszt IN ('Kapus', 'Védő', 'Középpályás', 'Csatár'));

ALTER TABLE Jatekosok
ADD CONSTRAINT C_Jatekosok_SzuletesiDatum CHECK (szuletesi_datum <= CAST(GETDATE() AS DATE));

ALTER TABLE Golok
ADD CONSTRAINT C_Golok_Tipus CHECK (tipus IN ('büntető', 'fejes', 'távoli', 'ziccer'));

ALTER TABLE Golok
ADD CONSTRAINT C_Golok_Perc CHECK (perc BETWEEN 1 AND 120);

ALTER TABLE Lapok
ADD CONSTRAINT C_Lapok_Tipus CHECK (tipus IN ('sárga', 'piros'));

ALTER TABLE Lapok
ADD CONSTRAINT C_Lapok_Perc CHECK (perc BETWEEN 1 AND 120);

ALTER TABLE Jatekvezetok
ADD CONSTRAINT C_Tapasztalat CHECK (tapasztalat BETWEEN 0 AND 50);

ALTER TABLE Jatekvezetok
ADD CONSTRAINT C_Jatekvezeto_SzulDatum CHECK (szuletesi_datum <= CAST(GETDATE() AS DATE));

ALTER TABLE Stadionok
ADD CONSTRAINT C_Befogado CHECK (befogadokepesseg > 0);

ALTER TABLE Atigazolasok
ADD CONSTRAINT C_Atigazolas_Dij CHECK (atigazolasi_dij >= 0);

ALTER TABLE Atigazolasok
ADD CONSTRAINT C_Atigazolas_Datum CHECK (atigazolas_datum <= CAST(GETDATE() AS DATE));

ALTER TABLE Merkozesek
ADD CONSTRAINT C_Nezoszam CHECK (nezoszam >= 0);

ALTER TABLE Merkozesek
ADD CONSTRAINT C_Merkozes_Idopont CHECK (idopont <= CAST(GETDATE() AS DATE));

--Userek
CREATE USER statisztikus WITHOUT LOGIN;
CREATE USER adatfelvivo WITHOUT LOGIN;
CREATE USER technikai_vezeto WITHOUT LOGIN;
CREATE USER riport_olvaso WITHOUT LOGIN;


--Jogosultságok
GRANT SELECT ON dbo.Merkozesek TO statisztikus;
GRANT SELECT ON dbo.Golok TO statisztikus;

GRANT INSERT ON dbo.Golok TO adatfelvivo;
GRANT INSERT ON dbo.Lapok TO adatfelvivo;
GRANT INSERT ON dbo.Merkozesek TO adatfelvivo;

GRANT INSERT, UPDATE ON dbo.Atigazolasok TO technikai_vezeto;
GRANT UPDATE ON dbo.Jatekosok TO technikai_vezeto;

GRANT SELECT ON dbo.Jatekosok TO riport_olvaso;
GRANT SELECT ON dbo.Merkozesek TO riport_olvaso;

--Domain-nek
CREATE TYPE NevTipus FROM NVARCHAR(255) NOT NULL;

CREATE TYPE MezszamTipus FROM TINYINT NOT NULL;

CREATE TYPE AllampolgarsagTipus FROM NVARCHAR(50) NOT NULL;

CREATE TYPE TapasztalatTipus FROM SMALLINT NOT NULL;

CREATE TYPE SzamTipus FROM INT NOT NULL;

CREATE TYPE DatumTipus FROM DATE NOT NULL;

--Indexek
CREATE INDEX I_Merkozesek_Csapatok 
ON Merkozesek(hazaicsapat_id, vendegcsapat_id);

CREATE INDEX I_Atigazolasok_Jatekos 
ON Atigazolasok(jatekos_id);

CREATE INDEX I_Jatekosok_Csapat 
ON Jatekosok(csapat_id);

--Triggerek
GO
CREATE TRIGGER t_Check_Nezoszam_Stadion
ON Merkozesek
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN Stadionok s ON i.stadion_id = s.stadion_id
    WHERE i.nezoszam IS NOT NULL AND i.nezoszam > s.befogadokepesseg
    )
    BEGIN
      RAISERROR('A megadott nézőszám meghaladja a stadion befogadóképességét!', 16, 1);
      ROLLBACK TRANSACTION;
    END
END;

GO
CREATE TRIGGER t_Update_Jatekos_Csapat
ON Atigazolasok
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Jatekosok
  SET csapat_id = i.uj_csapat_id
  FROM Jatekosok j
  JOIN inserted i ON j.jatekos_id = i.jatekos_id;
END;


--Tárolt eljárások

--Függvények
GO
CREATE FUNCTION dbo.GetGolokSzama 
  (
    @jatekos_id INT
  )
 RETURNS INT
 AS
 BEGIN
    DECLARE @golok_szama INT;
    SELECT @golok_szama = COUNT(*)
    FROM Golok
    WHERE jatekos_id = @jatekos_id;

     RETURN @golok_szama;
END;