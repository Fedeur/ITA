-- Creo la BBDD
CREATE DATABASE sprint04;
USE sprint04;

-- -----------------------------------------------| Creo las tablas |

CREATE TABLE users (
    id VARCHAR(250) NOT NULL,
    name VARCHAR(250),
    surname VARCHAR(250),
    phone VARCHAR(250),
    email VARCHAR(250),
    birth_date VARCHAR(250),
    country VARCHAR(250),
    city VARCHAR(250),
    postal_code VARCHAR(250),
    address VARCHAR(250),
    PRIMARY KEY (id)
);

CREATE TABLE companies (
    company_id VARCHAR(250) NOT NULL,
    company_name VARCHAR(250),
    phone VARCHAR(250),
    email VARCHAR(250),
    country VARCHAR(250),
    website VARCHAR(250),
    PRIMARY KEY (company_id)
);

CREATE TABLE credit_cards (
    id VARCHAR(250) NOT NULL,
    user_id VARCHAR(250),
    iban VARCHAR(250),
    pan VARCHAR(250),
    pin VARCHAR(250),
    cvv VARCHAR(250),
    track1 VARCHAR(250),
    track2 VARCHAR(250),
    expiring_date VARCHAR(250),
    PRIMARY KEY (id)
);

CREATE TABLE products (
    id VARCHAR(250) NOT NULL,
    product_name VARCHAR(250),
    price VARCHAR(250),
    colour VARCHAR(250),
    weight VARCHAR(250),
    warehouse_id VARCHAR(250),
    PRIMARY KEY (id)
);

CREATE TABLE transactions (
    id VARCHAR(250) NOT NULL,
    card_id VARCHAR(250),
    business_id VARCHAR(250),
    timestamp VARCHAR(250),
    amount VARCHAR(250),
    declined VARCHAR(250),
    product_ids VARCHAR(250),
    user_id VARCHAR(250),
    lat VARCHAR(250),
    longitude VARCHAR(250),
    PRIMARY KEY (id)
);
-- -----------------------------------------------| Verif (en el MAC estaba OFF y no hubo forma de importar|
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile'; -- ON pero no dejó importar desde ubicacion seleccionada
SHOW VARIABLES LIKE 'secure_file_priv'; -- pongo los archivos en la carpeta que indica

-- -----------------------------------------------| Importo datos de los CSV |

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/companies 2.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(company_id, company_name, phone, email, country, website);

SELECT count(1) FROM companies; -- Verifico si están los 5000 registros del CSV

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

SELECT	COUNT(1) FROM users; -- Verifico si están los 1010 usuarios Americanos

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

SELECT COUNT(1) FROM users; -- 5000 usarios es la suma de los 1010 Americanos + 3990 de Europeos 

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(1) FROM credit_cards;

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) AS Prod FROM products;

LOAD DATA LOCAL INFILE '/Users/fedeur/IT Academy/SQL/4 Sprint/BBDD/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
  
SELECT COUNT(*) AS TOTAL_TRANSACTIONS
FROM transactions;

ALTER TABLE credit_cards
  ADD CONSTRAINT fk_credit_cards_users
  FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE transactions
  ADD CONSTRAINT fk_transactions_users
  FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT fk_transactions_cards
  FOREIGN KEY (card_id) REFERENCES credit_cards(id),
  ADD CONSTRAINT fk_transactions_companies
  FOREIGN KEY (business_id) REFERENCES companies(company_id);


-- -----------------------------------------------| Ejercicio 1.1

SELECT *
FROM users
WHERE id IN (
			SELECT user_id
			FROM transactions
			GROUP BY user_id
			HAVING COUNT(*) > 80
			);
            
-- -----------------------------------------------| Ejercicio 1.2

SELECT cc.iban, 
	   ROUND(AVG(t.amount),2) AS media_amount
FROM transactions t
JOIN credit_cards cc
  ON t.card_id = cc.id
JOIN companies co
  ON t.business_id = co.company_id
WHERE co.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- -----------------------------------------------| Ejercicio 2.1


SHOW FULL TABLES;

CREATE TABLE credit_card_status AS
WITH ranked_transactions AS (
							  SELECT
									id,
									card_id,
									declined,
									timestamp,
									ROW_NUMBER() OVER (
														PARTITION BY card_id
														ORDER BY timestamp DESC
									                  ) AS row_num
							    FROM transactions
)
SELECT
		id,
		card_id,
		declined,
		timestamp,
		row_num
FROM ranked_transactions
WHERE row_num IN (1, 2, 3);

ALTER TABLE credit_card_status
  ADD CONSTRAINT fk_CCStatus_credit_cards
  FOREIGN KEY (card_id)
  REFERENCES credit_cards(id);

-- Compruebo los datos de la tabla credit_card_status
  SELECT * 
    FROM credit_card_status;


-- -------------------------| ¿Cuántas tarjetas están activas?
SELECT COUNT(card_id) AS 'Núm. tarjetas activas'
FROM (
		SELECT card_id
		FROM credit_card_status
		GROUP BY card_id
		HAVING SUM(declined) < 3
     ) AS credit_card_active;

-- -------------------------------------------------------| Ejercicio 3.1
SHOW FULL TABLES;
-- --------------------------------Creación de a tabla
CREATE TABLE transaction_products (
  transaction_id VARCHAR(250) NOT NULL,
  product_id VARCHAR(250) NOT NULL,
  PRIMARY KEY (transaction_id, product_id)
);

ALTER TABLE transaction_products
  ADD CONSTRAINT fk_tp_transactions
  FOREIGN KEY (transaction_id) REFERENCES transactions(id);

ALTER TABLE transaction_products
  ADD CONSTRAINT fk_tp_products
  FOREIGN KEY (product_id) REFERENCES products(id);
  
INSERT INTO transaction_products (transaction_id, product_id)
SELECT
       t.id,
	   jt.product_id
FROM transactions t
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),
  '$[*]' COLUMNS (product_id VARCHAR(250) PATH '$')
) jt
JOIN products p
  ON p.id = jt.product_id
WHERE t.product_ids IS NOT NULL
  AND t.product_ids <> '';  
-- ---------------------------------------| Respuesta de cant Vendidos  
SELECT
  product_id AS producto,
  COUNT(*) AS veces_vendido
FROM transaction_products
GROUP BY product_id;
  
