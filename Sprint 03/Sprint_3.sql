USE transactions;


CREATE TABLE Credit_card (
						  id             VARCHAR(15) PRIMARY KEY,
						  iban           VARCHAR(50),
						  pan            VARCHAR(50),
						  pin            VARCHAR(4),
						  cvv            INT,
						  expiring_date  VARCHAR(20),
						  fecha_actual   VARCHAR(20)
                     

                         );
SELECT DISTINCT credit_card_id
FROM transaction
WHERE credit_card_id IS NOT NULL
AND credit_card_id NOT IN (
							SELECT id 
							FROM credit_card
						  );

ALTER TABLE  transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);



SELECT IBAN
  FROM credit_card
 WHERE id = 'CcU-2938';
 
UPDATE credit_card
   SET iban = 'TR323456312213576817699999'
 WHERE id = 'CcU-2938';
 
 SELECT IBAN
  FROM credit_card
 WHERE id = 'CcU-2938';
-- -----------------------------------------------| Si quiero incertar un registro en transaction, tiene q tener relación con otro en Company y Credit_card
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

SELECT IBAN
  FROM credit_card
 WHERE id = 'CcU-2938';
 -- -----------------------------------------------| Inserto los datos en transaction
INSERT INTO transaction (
							id,
							credit_card_id,
							company_id,
							user_id,
							lat,
							longitude,
							amount,
							declined
						)
				 VALUES (
							'108B1D1D-5B23-A76C-55EF-C568E49A99DD',
							'CcU-9999',
							'b-9999',
							9999,
							829.999,
							-117.999,
							111.11,
							0
						);

 -- -----------------------------------------------| Verifico q el nuevo registro es OK
SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
-- ------------------------------------------------| 1.4 
 DESCRIBE credit_card;  # Verifico los campos de la tabla
 
ALTER TABLE credit_card -- ------------------------| Modificación Solicitada
DROP COLUMN pan;

DESCRIBE credit_card; # Verifico eliminación de `pan`

SELECT *  			 # Verifico q el registro existe
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transaction -- ------------------------| Ejecuto la Eliminación del registro 
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *  			 # Verifico q el registro NO existe
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- --------------------------------------------------------| Crear Vista
CREATE VIEW VistaMarketing AS
SELECT
       Company.company_name AS NombreEmpresa,
		      Company.phone AS Telefono,
		    Company.country AS Pais,
    AVG(Transaction.amount) AS PromCompras
FROM transaction AS Transaction
JOIN company AS Company
    ON Transaction.company_id = Company.id
GROUP BY
    NombreEmpresa,
    Telefono,
    Pais;

SELECT *
FROM VistaMarketing
ORDER BY PromCompras DESC;

SELECT *
FROM VistaMarketing
WHERE pais = 'Germany'
ORDER BY PromCompras DESC;



CREATE TABLE IF NOT EXISTS data_user (
										id CHAR(10) PRIMARY KEY,
										name VARCHAR(100),
										surname VARCHAR(100),
										phone VARCHAR(150),
										email VARCHAR(150),
										birth_date VARCHAR(100),
										country VARCHAR(150),
										city VARCHAR(150),
										postal_code VARCHAR(100),
										address VARCHAR(255)    
									);
                                    
SELECT  count(id)
  FROM data_user;
  
ALTER TABLE  transaction
ADD CONSTRAINT fk_data_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);
-- -------------------------------------------------| Verifico cambios a realizar en Tabla Company
DESCRIBE company;
ALTER TABLE company DROP website;
DESCRIBE company;
-- -------------------------------------------------| Verifico cambios a realizar en Tabla data user
DESCRIBE data_user;
ALTER TABLE data_user RENAME COLUMN email TO personal_email;
ALTER TABLE data_user MODIFY COLUMN id int;
DESCRIBE data_user;
-- -------------------------------------------------| Verifico cambios a realizar en Tabla Credit_card
DESCRIBE Credit_card;

ALTER TABLE credit_card MODIFY COLUMN fecha_actual DATE;
ALTER TABLE credit_card MODIFY COLUMN id VARCHAR (20);
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR (4) ;
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR (10);

DESCRIBE Credit_card; -- ---------------------------| Verifico cambios realizados en Tabla Credit_card



-- -------------------------------------------------| Crear Nueva vista InformeTecnico

CREATE VIEW InformeTecnico AS
SELECT
	   t.id 			AS ID,
       d.name			AS NOMBRE,
       d.surname		AS APELLIDO,
       c.iban			AS IBAN,
	  Co.company_name	AS EMPRESA
FROM transaction t
JOIN data_user d
  ON t.user_id = d.id
JOIN Credit_card c
  ON t.credit_card_id = c.id
JOIN company Co
  ON t.company_id = Co.id;
  
  
SELECT *
FROM InformeTecnico
ORDER BY t.id DESC;



