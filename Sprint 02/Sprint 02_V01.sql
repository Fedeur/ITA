
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
 
 SELECT Co.company_name AS EMPRESA,
 ROUND(AVG(T.amount),2) AS MEDIA_VENTAS
FROM transaction T
JOIN company Co
  ON T.company_id = Co.id
GROUP BY Co.company_name
ORDER BY MEDIA_VENTAS DESC
LIMIT 1;



-- 3.a) Mostrar todas las |transacciones| realizadas por |empresas| de |Alemania|.
-- ---------------------------------------------- 2º
SELECT *
FROM transaction 
WHERE company_id IN (
-- ---------------------------------------------- 1º Identificar empresas de Alemania
						SELECT id
						  FROM company 
						 WHERE country = 'Germany'
					  );
	

-- 3.b) Mostrar las |empresas| que realizaron |transacciones| con amount |mayor| que la |media de todas| las |transacciones|.
## poner alias a las tablas y acompañar a las columnas (buenas practicas)
-- ----------------------------------------------------------- 3º Nombre de las Empresas (son 100 que en total hacen 13291 registros con todas sus transacc)
SELECT Co.company_name AS EMPRESA   -- -----------3º Recupero sólo los nombres de empresas donde su Id = a la lista q consegui antes
FROM company Co
WHERE EXISTS (
				SELECT T.company_id-- ----------------------------------------------- 2º Obtengo la lista de Company_id's c/amount mayor a la media
				  FROM transaction T   
				 WHERE T.company_id = Co.id -- -------------------------------------- y los id coincidan en las 2 tablas
				   AND T.amount > (
									SELECT AVG(T2.amount)-- -------------------------1º Media global de todas las transacciones
									  FROM transaction T2
								  )
			 );
       
             
-- Mostrar las |empresas| que NO tienen |transacciones| registradas.
 
SELECT Co.company_name AS EMPRESA
FROM company Co
WHERE NOT EXISTS (
					SELECT T.company_id
					FROM transaction T
					WHERE T.company_id = Co.id
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

SELECT            Co.country AS PAIS,
       ROUND(AVG(T.amount), 2) AS MEDIA_VENTAS
FROM transaction T
JOIN company Co
      ON T.company_id = Co.id
GROUP BY PAIS
ORDER BY MEDIA_VENTAS DESC;

-- Mostrar todas las |transacciones| realizadas por |empresas| que estan en el mismo |país| que la compañia 'Non Institute'.
-- ------------------------------------------ | ejercicio realizado usando Join |
SELECT T.*, 
       Co.company_name AS EMPRESA_COMPETIDORA
  FROM transaction T
  JOIN company Co
      ON T.company_id = Co.id
 WHERE Co.country = ( -- ------------------------------- 1 Pais de Non Institute (United Kindom)
						SELECT country
						FROM company
						WHERE company_name = 'Non Institute'
					);

-- ------------------------------------------ | ejercicio realizado usando Subconsultas |
SELECT
    T.*,                                                                        			-- Transacciones de empresas en UK
    (SELECT Co.company_name FROM company Co WHERE Co.id = T.company_id) AS EMPRESA
       FROM transaction T
      WHERE T.company_id IN (																-- Compañias en UK
							 SELECT id
							   FROM company
							  WHERE country = (                                             -- UK
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
    C.id AS ID_EMPRESA,
    C.company_name AS NOMBRE_EMPRESA,
    COUNT(T.id) AS TOTAL_TRANSACCIONES,
    CASE
        WHEN COUNT(T.id) > 400 THEN 'MAS_DE_400'
        ELSE '400_O_MENOS'
    END AS CLASIFICACION
FROM company C
JOIN transaction T
    ON T.company_id = C.id
GROUP BY C.id;


