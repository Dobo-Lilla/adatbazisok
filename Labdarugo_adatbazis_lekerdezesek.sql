--1.lekérdezés
SELECT TOP 10 j.nev As 'Játékos neve',
		cs.nev AS 'Csapat neve', 
		COUNT(g.gol_id) AS 'Gólok száma',
        RANK() OVER (ORDER BY COUNT(g.gol_id) DESC) as 'Gól lövőlista helyezés'
FROM Golok g JOIN Jatekosok j ON g.jatekos_id = j.jatekos_id
JOIN Csapatok cs ON j.csapat_id = cs.csapat_id
GROUP By j.jatekos_id,j.nev,cs.nev
ORDER BY 3 DESC;


--2.lekérdezés
SELECT Top 1
    j.nev AS 'Játékos neve',
    COUNT(g.gol_id) AS 'Összes lőtt gól'
FROM Golok g JOIN Jatekosok j ON g.jatekos_id = j.jatekos_id
GROUP BY j.jatekos_id, j.nev
ORDER BY 2 DESC;

--3.lekérdezés
SELECT
    m.meccs_id,
    hcs.nev AS 'Hazai Csapat',
    vcs.nev AS 'Vendég Csapat',
    CAST(m.idopont as date) As 'Időpont' ,
    m.nezoszam as 'Nézőszám',
CASE
	WHEN m.nezoszam < 5000 THEN 'Kis Stadion'
	WHEN m.nezoszam > 15000 Then 'Nagy Stadion'
	ElSE 'Közepes Stadion'
END AS 'Stadion Méret'
FROM
    Merkozesek AS m
JOIN
    Csapatok AS hcs ON m.hazaicsapat_id = hcs.csapat_id 
JOIN
    Csapatok AS vcs ON m.vendegcsapat_id = vcs.csapat_id 
JOIN
    Bajnoksag AS b ON m.bajnoksag_id = b.bajnoksag_id 
ORDER By m.nezoszam ASC;

--4.lekérdezése
SELECT
    b.szezon AS Szezon,
    cs.nev AS 'Csapat neve',
    COUNT(l.lap_id) AS 'Sárga lapok száma'
FROM Lapok l 
JOIN Merkozesek m ON l.meccs_id = m.meccs_id
JOIN Bajnoksag b ON m.bajnoksag_id = b.bajnoksag_id
JOIN Jatekosok j ON l.jatekos_id = j.jatekos_id
JOIN Csapatok cs ON j.csapat_id = cs.csapat_id
WHERE l.tipus = 'sárga' 
GROUP BY b.szezon, cs.nev 
ORDER BY b.szezon, 3 DESC;


--5.lekérdezés
SELECT
    s.nev AS Stadion,
    ROUND(AVG(CAST(m.nezoszam AS FLOAT) / s.befogadokepesseg) * 100,2) AS 'Stadionok átlagos kihasználtsága'
FROM Merkozesek m
JOIN Stadionok s ON m.stadion_id = s.stadion_id
GROUP BY s.stadion_id, s.nev
ORDER BY 2 DESC;



--6.lekérdezés
SELECT 
    jv.nev AS 'Játékvezető',
    COUNT(m.meccs_id) AS 'Vezetett meccsek',
    CAST(COUNT(m.meccs_id) * 100.0 / (SELECT COUNT(*) FROM Merkozesek) AS DECIMAL(5,2)) AS 'Százalékos Részesedés'
FROM Merkozesek m
JOIN Jatekvezetok jv ON m.jatekvezeto_id = jv.jatekvezeto_id
GROUP BY jv.nev
ORDER BY 2 DESC;

--7.lekérdezés
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) < 20 THEN '20 év alatt'
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) BETWEEN 20 AND 25 THEN '20-30 év'
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) BETWEEN 26 AND 31 THEN '31-40 év'
        ELSE '32+ év'
    END AS Korosztaly,
    COUNT(*) AS JatekosokSzama
FROM Jatekosok
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) < 20 THEN '20 év alatt'
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) BETWEEN 20 AND 25 THEN '20-30 év'
        WHEN DATEDIFF(YEAR, szuletesi_datum, GETDATE()) BETWEEN 26 AND 31 THEN '31-40 év'
        ELSE '32+ év'
    END;

--8.lekérdezés
SELECT 
    CASE 
        WHEN GROUPING(StadionMeret) = 1 THEN 'Összesen'
        ELSE StadionMeret 
    END AS StadionMeret,
    COUNT(*) AS MerkozesekSzama
FROM (
    SELECT 
        CASE
            WHEN nezoszam < 5000 THEN 'Kis Stadion'
            WHEN nezoszam > 15000 THEN 'Nagy Stadion'
            ELSE 'Közepes Stadion'
        END AS StadionMeret
    FROM Merkozesek
    WHERE nezoszam IS NOT NULL
) AS stadiontipusok
GROUP BY ROLLUP(StadionMeret)
ORDER BY 
    CASE 
        WHEN StadionMeret = 'Kis Stadion' THEN 1
        WHEN StadionMeret = 'Közepes Stadion' THEN 2
        WHEN StadionMeret = 'Nagy Stadion' THEN 3
        ELSE 4
    END;

-- 9.lekérdezés
SELECT
    Szezon,
    Csapatnév,
    Gólok_összesen,
    Átlagos_gólok_szezononként
FROM (
    SELECT
        b.szezon AS Szezon,
        cs.nev AS Csapatnév,
        COUNT(g.gol_id) AS 'Gólok_összesen',
        AVG(CAST(COUNT(g.gol_id) AS FLOAT)) OVER
 (PARTITION BY b.szezon) AS 'Átlagos_gólok_szezononként'
    FROM Golok g
    JOIN Merkozesek m ON g.meccs_id = m.meccs_id
    JOIN Bajnoksag b ON m.bajnoksag_id = b.bajnoksag_id
    JOIN Jatekosok j ON g.jatekos_id = j.jatekos_id
    JOIN Csapatok cs ON j.csapat_id = cs.csapat_id
    GROUP BY b.szezon, cs.csapat_id, cs.nev ) AS belso
ORDER BY Szezon, 2 DESC;