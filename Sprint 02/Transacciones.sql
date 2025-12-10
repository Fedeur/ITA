
# P2P Realizado por María Zaitseva
# Mostrar características de la BBDD:
-- Diagrama conceptual:
-- company 1 ───< transaction

-- Tabla company:
-- id (PK), company_name, phone, email, country, website

-- id (PK), credit_card_id, company_id (FK), user_id,
-- lat, longitude, timestamp, amount, declined
USE transactions;
-- -------------------------------------------------------------| N1 |
-- a)  Mostrar los |países| que están realizando |compras|.

SELECT distinct company.country AS PAIS
  FROM company
  JOIN transaction
	on company.id = transaction.company_id;

-- b) cuantos países son?
SELECT count(distinct company.country) AS CANTIDAD_PAISES
 FROM transaction
 JOIN company
   ON transaction.company_id = company.id;
   
 -- c) Companía con mayor media de ventas
 
 WITH Promedios AS (                                  -- ------------------ Necesito el promedio de ventas para poder calcular el MAX creo una Tabla temporal
					SELECT 
						company_id,
						AVG(amount) AS Avg
					FROM transaction
					GROUP BY company_id
				  ),
	MaxPromedio AS (								  -- ------------------ Saco el MAX de la tabla anterior y tamb se convierte en Tabla utilizable
		SELECT MAX(Avg) AS MAX_MEDIA
		FROM Promedios
				   )
SELECT 												  -- ----------------- Trabajo con las dos tablas anteriores	
    Promedios.company_id AS EMPRESA,
    MaxPromedio.MAX_MEDIA
FROM Promedios 
JOIN MaxPromedio
      ON Promedios.Avg = MaxPromedio.MAX_MEDIA;

-- 3.a) Mostrar todas las |transacciones| realizadas por |empresas| de |Alemania|.
-- ---------------------------------------------- 2º
SELECT *
FROM transaction
WHERE transaction.company_id IN (
-- ---------------------------------------------- 1º Identificar empresas de Alemania
								  SELECT id
									FROM company 
								   WHERE country = 'Germany'
								);
	

-- 3.b) Mostrar las |empresas| que realizaron |transacciones| con amount |mayor| que la |media de todas| las |transacciones|.
## poner alias a las tablas y acompañar a las columnas (buenas practicas)
-- ------------------------------------------------------------------ 3º Nombre de las Empresas (son 100 que en total hacen 13291 registros con todas sus transacc)
SELECT company_name AS EMPRESA                         -- -----------3º Recupero sólo los nombres de empresas donde su Id = a la lista q consegui antes
  FROM company
 WHERE exists (
-- ------------------------------------------------------------------ 2º Obtengo la lista de Company_id's c/amount mayor a la media
							SELECT company_id
							FROM transaction 
-- -------------------------------------------------------------------1º Media global de todas las transacciones
							WHERE amount > (   
											 SELECT AVG(T2.amount)  # 259.01
											   FROM transaction T2
										   )
						GROUP BY company_id							
			 );
             
             
-- Mostrar las |empresas| que NO tienen |transacciones| registradas.
 
SELECT company_name
FROM company
WHERE NOT EXISTS (								
				   SELECT id								
					 FROM transaction
				 );





-- ---------------------------------------------------------------------------------| NIVEL 2 |

#Identifica los 5 días con mayor ingreso x venta. Mostrar la fecha junto al total de las ventas

SELECT DATE(timestamp) AS FECHA,  -- DATE() Deja solo el día sin las horas
       SUM(amount) AS TOTAL_INGRESOS
FROM transaction
GROUP BY FECHA
ORDER BY TOTAL_INGRESOS DESC
LIMIT 5;

# Cual es la media de ventas por país? Presentar los resultados ordenados de mayor a menor

SELECT country AS PAIS,
       round(AVG(amount), 2) AS MEDIA_VENTAS
FROM transaction
JOIN company
      ON transaction.company_id = company.id
GROUP BY PAIS
ORDER BY MEDIA_VENTAS DESC;

-- Mostrar todas las |transacciones| realizadas por |empresas| que estan en el mismo |país| que la compañia 'Non Institute'.
-- ------------------------------------------ | ejercicio realizado usando Join |
SELECT  *
FROM transaction 
JOIN company
      ON transaction.company_id = company.id
WHERE company.country = (                                           -- 1º País de Non Institute ('United Kingdom')
						SELECT country
						FROM company
						WHERE company_name = 'Non Institute'
					   );
-- ------------------------------------------ | ejercicio realizado usando Subconsultas |
SELECT 
       id         AS ID_TRANSACCION,
       company_id AS ID_EMPRESA,
   date(timestamp)AS FECHA,
       amount     AS IMPORTE
 FROM transaction
WHERE company_id IN (					       -- 1) Empresas del país de Non Institute
					 SELECT company.id
					   FROM company
					  WHERE country = (		   -- 2) Cual es el País de Non Institute?
										SELECT country
										  FROM company
										 WHERE company_name = 'Non Institute'
									  )
					);

-- ---------------------------------------------------------------------------------| NIVEL 3 |
# 1) Mostrar el |nombre|, |teléfono|, |país|, |fecha| y |amount| de las empresas que realizaron |transacciones| con |amount| entre 350 y 400 € y en las fechas: . 
# Ordenar de mayor a menor importe.
SELECT
       C.company_name    AS NOMBRE_EMPRESA,
       C.phone           AS TELEFONO,
       C.country         AS PAIS,
       date(T.timestamp) AS FECHA,
	   T.amount          AS IMPORTE
FROM company C
JOIN transaction T
      ON T.company_id = C.id
WHERE T.amount BETWEEN 350 AND 400
  AND DATE(T.timestamp) IN ('2015-04-29',
                            '2018-07-20',
                            '2024-03-13')
ORDER BY IMPORTE DESC;

# 2) Mostrar las |empresas| indicando si tienen |más de 400 transacciones| o |menos o igual a 400|.

SELECT
       company.id            AS ID_EMPRESA,
       company.company_name  AS NOMBRE_EMPRESA,
       COUNT(transaction.id) AS TOTAL_TRANSACCIONES,
       CASE 
            WHEN COUNT(transaction.id) > 400 
                  THEN 'MAS_DE_400'
            ELSE '400_O_MENOS'
       END AS CLASIFICACION
FROM company
LEFT JOIN transaction
       ON transaction.company_id = company.id
GROUP BY
       company.id,
       company.company_name;

