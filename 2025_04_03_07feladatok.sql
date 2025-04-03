/*1. Készítsünk nézetet VSZOBA néven, amely megjeleníti a szobák adatai mellett a megfelelő szálláshely nevét, helyét és a csillagok számát is!

Az oszlopoknak nem szükséges külön nevet adni!
Teszteljük is a nézetet, pl: SELECT * FROM VSZOBA*/

CREATE VIEW VSZOBA AS
SELECT sz.*, szh.SZALLAS_NEV, szh.CSILLAGOK_SZAMA
FROm Szoba sz JOIn Szallashely szh ON sz.SZALLAS_FK=szh.SZALLAS_ID

ALTER VIEW VSZOBA AS
SELECT sz.*,
		szh.SZALLAS_NEV AS 'NÉV', 
        szh.HELY,
        szh.CSILLAGOK_SZAMA
FROm Szoba sz JOIn Szallashely szh ON sz.SZALLAS_FK=szh.SZALLAS_ID

SELECT * FROM VSZOBA

/*2 Készítsen tárolt eljárást SPUgyfelFoglalasok, amely a paraméterként megkapott ügyfél azonosítóhoz tartozó foglalások adatait listázza!
Teszteljük a tárolt eljárás működését, pl: EXEC SPUgyfelFoglalasok 'laszlo2'
*/
CREATE OR ALTER PROCEDURE SPUgyfelFoglalasok
--paraméterek
@ugyfelazon nvarchar(40)
AS 
BEGIN
SELECT  *
FROM Foglalas
WHERE ugyfel_fk  = @ugyfelazon
END

EXEC SPUgyfelFoglalasok 'laszlo2'
/*
3. Készítsen skalár értékű függvényt UDFFerohely néven, amely visszaadja, hogy a paraméterként megkapott foglalás azonosítóhoz hány férőhelyes szoba tartozik!
a. Teszteljük a függvény működését!
*/
CREATE OR ALTER FUNCTION UDFFerohely
(
@fazon int
)
RETURNS int AS
BEGIN
DECLARe @ferohely int
SELECT @ferohely= sz.FEROHELY
FROM Foglalas f JOIN Szoba sz ON f.SZOBA_FK= sz.SZOBA_ID
WHERE foglalas_pk= @fazon
RETURN @ferohely
END
SELECT dbo.UDFFerohely(650)

--ez a szép megoldás

/*
CREATE OR ALTER FUNCTION UDFFerohely
(
@fazon int
)
RETURNS int AS
BEGIN
RETURN 
(SELECT @ferohely= sz.FEROHELY
FROM Foglalas f JOIN Szoba sz ON f.SZOBA_FK= sz.SZOBA_ID
WHERE foglalas_pk= @fazon)
END
SELECT dbo.UDFFerohely(650)
*/

/*
4. Készítsünk tárolt eljárást SPRangsor néven, amely rangsorolja a szálláshelyeket a foglalások száma alapján (a legtöbb foglalás legyen a rangsorban az első). A listában a szállás azonosítója, neve és a rangsor szerinti helyezés jelenjen meg - holtverseny esetén ugrással (ne sűrűn)! 
a. Teszteljük a tárolt eljárást, pl: EXEC SPRangsor
*/

/*
5. Készítsünk nézetet VFoglalasreszletek néven, amely a következő adatokat jeleníti meg: foglalás azonosítója, az ügyfél neve, a szálláshely neve és helye, a foglalás kezdete és vége, és a szoba száma. 

a. Az oszlopokat nevezzük el értelemszerűen! 
b. Teszteljük a nézet működését, pl: SELECT * FROM VFoglalasreszletek
*/

/*
6.
Készítsen tábla értékű függvényt NEPTUNKÓD_UDFFoglalasnelkuliek néven, amely azon ügyfelek adatait listázza, akik még nem foglaltak egyszer sem az adott évben adott hónapjában! A függvény paraméterként kapja meg a foglalás évét és hónapját! (Itt is a METTOL dátummal dolgozzunk) 
a. Teszteljük is a függvény működését, pl: SELECT * FROM dbo.UJAENB_UDFFoglalasnelkuliek(2016, 10)
*/




