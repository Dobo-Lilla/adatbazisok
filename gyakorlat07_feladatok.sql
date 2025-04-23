/*1. Készítsünk nézetet VSZOBA néven, amely megjeleníti a szobák adatai mellett a megfelelő szálláshely nevét, helyét és a csillagok számát is!

Az oszlopoknak nem szükséges külön nevet adni!
Teszteljük is a nézetet, pl: SELECT * FROM VSZOBA*/

CREATE VIEW VSZOBA 
AS
SELECT sz.*, szh.SZALLAS_NEV, szh.HELY, szh.CSILLAGOK_SZAMA
FROM Szallashely szh JOIN Szoba sz ON szh.SZALLAS_ID = sz.SZALLAS_FK

SElect * FROM VSZOBA


/*2 Készítsen tárolt eljárást SPUgyfelFoglalasok, amely a paraméterként megkapott ügyfél azonosítóhoz tartozó foglalások adatait listázza!
Teszteljük a tárolt eljárás működését, pl: EXEC SPUgyfelFoglalasok 'laszlo2'
*/

CREATE PROCEDURE SPUgyfelFoglalasok
@ugyfel_azon nvarchar(100)
AS
BEGIN
SELECT *
FROM Foglalas 
WHERE usernev = @ugyfel_azon
END

EXEC SPUgyfelFoglalasok 'laszlo2'


/*
3. Készítsen skalár értékű függvényt UDFFerohely néven, amely visszaadja,
hogy a paraméterként megkapott foglalás azonosítóhoz hány férőhelyes szoba tartozik!
a. Teszteljük a függvény működését!
*/

CREATE FUNCTION UDFFerohely
(@foglalas_azon int)
RETURNS INT
AS
BEGIN
DECLARE @db INT
SELECT @db= sz.FEROHELY
FROM Foglalas f JOIN Szoba sz ON f.SZOBA_FK = sz.SZOBA_ID
WHERE f.FOGLALAS_PK = @foglalas_azon
RETURN @db
END

SELECT dbo.UDFFerohely(561)


/*
4. Készítsünk tárolt eljárást SPRangsor néven, amely rangsorolja a szálláshelyeket a foglalások száma alapján (a legtöbb foglalás legyen a rangsorban az első). 
A listában a szállás azonosítója, neve és a rangsor szerinti helyezés jelenjen meg - holtverseny esetén ugrással (ne sűrűn)! 
a. Teszteljük a tárolt eljárást, pl: EXEC SPRangsor
*/

CREATE PROCEDURE SPRangsor
AS 
BEGIN
SELECT szh.SZALLAS_ID,
		szh.SZALLAS_NEV
        ,RANK() OVER( ORDER BY COUNT(*) DESC)
FROM Foglalas f JOIN Szoba sz ON f.SZOBA_FK =sz.SZOBA_ID
	JOIN Szallashely szh ON sz.SZALLAS_FK = szh.SZALLAS_ID
GROUP BY szh.SZALLAS_ID, szh.SZALLAS_NEV
END

EXEC SPRangsor

/*
5. Készítsünk nézetet VFoglalasreszletek néven, amely a következő adatokat jeleníti meg: 
foglalás azonosítója, az ügyfél neve, a szálláshely neve és helye, a foglalás kezdete és vége, és a szoba száma. 

a. Az oszlopokat nevezzük el értelemszerűen! 
b. Teszteljük a nézet működését, pl: SELECT * FROM VFoglalasreszletek
*/
CREATE VIEW VFoglalasreszletek
(['Foglalás Azonosító'],['Ügyfél neve'],['Szállás neve'],['Szalláshely'],['Tartózkodás kezdete'],['Tartózkodás vége'],['Szoba száma'])
AS
SELECT f.FOGLALAS_PK, 
		v.USERNEV, 
        szh.SZALLAS_NEV,
        szh.HELY,
        f.METTOL,
        f.MEDDIG,
        sz.SZOBA_SZAMA AS 
FROM Foglalas f JOIN Vendeg v on f.UGYFEL_FK = v.USERNEV
	JOIN Szoba sz ON f.SZOBA_FK= sz.SZOBA_ID
    JOIN Szallashely szh ON sz.SZALLAS_FK = szh.SZALLAS_ID
    
SELECT * FROM VFoglalasreszletek

/*
6.
Készítsen tábla értékű függvényt NEPTUNKÓD_UDFFoglalasnelkuliek néven, amely azon ügyfelek adatait listázza, 
akik még nem foglaltak egyszer sem az adott évben adott hónapjában! A függvény paraméterként kapja meg a foglalás évét és hónapját! (Itt is a METTOL dátummal dolgozzunk) 
a. Teszteljük is a függvény működését, pl: SELECT * FROM dbo.UJAENB_UDFFoglalasnelkuliek(2016, 10)
*/

CREATE FUNCTION NEPTUNKÓD_UDFFoglalasnelkuliek
(@ev INT,
@ho INT)
RETURNS TABLE
AS
RETURN
SELECT *
FROM Vendeg
WHERE usernev NOT IN
(
  SELECT ugyfel_fk
  FROM Foglalas
  WHERE YEAR(mettol) = @ev AND MONTH(mettol)= @ho
)

SELECT * FROM dbo.NEPTUNKÓD_UDFFoglalasnelkuliek(2016, 10)

