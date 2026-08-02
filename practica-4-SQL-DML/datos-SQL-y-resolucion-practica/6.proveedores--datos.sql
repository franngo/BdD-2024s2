#PARA ESTE EJERCICIO NO SE PROVEEN LAS CREACIONES DE LAS TABLAS.

CREATE TABLE proveedores (
	id_prov CHAR(2),
	prov_nombre VARCHAR(100),
	categoria INT,
	ciudad VARCHAR(100),
	CONSTRAINT proveedores_pk PRIMARY KEY (id_prov)
);

CREATE TABLE articulos (
	id_art CHAR(2),
	art_nombre VARCHAR(100),
	ciudad VARCHAR(100),
	CONSTRAINT articulos_pk PRIMARY KEY (id_art)
);

CREATE TABLE componentes (
	id_comp CHAR(2),
	comp_nombre CHAR(3),
	color VARCHAR(100),
	peso INT,
	ciudad VARCHAR(100),
	CONSTRAINT componentes_pk PRIMARY KEY (id_comp)
);

CREATE TABLE envios (
	id_prov CHAR(2),
	id_comp CHAR(2),
	id_art CHAR(2),
	cantidad INT,
	CONSTRAINT envios_pk PRIMARY KEY (id_prov, id_comp, id_art, cantidad),
	CONSTRAINT envios_proveedores_fk FOREIGN KEY (id_prov) REFERENCES proveedores(id_prov),
	CONSTRAINT envios_componentes_fk FOREIGN KEY (id_comp) REFERENCES componentes(id_comp),
	CONSTRAINT envios_articulos_fk FOREIGN KEY (id_art) REFERENCES articulos(id_art)
);

INSERT INTO proveedores
	(id_prov, prov_nombre, categoria, ciudad)
VALUES
	('P1', 'Carlos', 20, 'La Plata'),
	('P2', 'Juan', 10, 'Cap. Fed.'),
	('P3', 'Jose', 30, 'La Plata'),
	('P4', 'Dora', 20, 'La Plata'),
	('P5', 'Eva', 30, 'Bernal')
;

INSERT INTO componentes
	(id_comp, comp_nombre, color, peso, ciudad)
VALUES
	('C1', 'X3A', 'Rojo', 12, 'La Plata'),
	('C2', 'B85', 'Verde', 17, 'Cap. Fed.'),
	('C3', 'C4B', 'Azul', 17, 'Quilmes'),
	('C4', 'C4B', 'Rojo', 14, 'La Plata'),
	('C5', 'VT8', 'Azul', 12, 'Cap. Fed.'),
	('C6', 'C30', 'Rojo', 19, 'La Plata')
;

INSERT INTO articulos
	(id_art, art_nombre, ciudad)
VALUES
	('T1', 'Clasificadora', 'Cap. Fed.'),
	('T2', 'Perforadora', 'Quilmes'),
	('T3', 'Lectora', 'Bernal'),
	('T4', 'Consola', 'Bernal'),
	('T5', 'Mezcladora', 'La Plata'),
	('T6', 'Terminal', 'Berazategui'),
	('T7', 'Cinta', 'La Plata')
;

INSERT INTO envios
	(id_prov, id_comp, id_art, cantidad)
VALUES
	('P1', 'C1', 'T1', 200),
	('P1', 'C1', 'T4', 700),
	('P2', 'C3', 'T1', 400),
	('P2', 'C3', 'T2', 200),
	('P2', 'C3', 'T3', 200),
	('P2', 'C3', 'T4', 500),
	('P2', 'C3', 'T5', 600),
	('P2', 'C3', 'T6', 400),
	('P2', 'C3', 'T7', 800),
	('P2', 'C5', 'T2', 100),
	('P3', 'C3', 'T1', 200),
	('P3', 'C4', 'T2', 100),
	('P4', 'C6', 'T3', 300),
	('P4', 'C6', 'T7', 300),
	('P5', 'C2', 'T2', 200),
	('P5', 'C2', 'T4', 100),
	('P5', 'C5', 'T4', 500),
	('P5', 'C5', 'T7', 100),
	('P5', 'C6', 'T2', 200),
	('P5', 'C1', 'T4', 100),
	('P5', 'C3', 'T4', 200),
	('P5', 'C4', 'T4', 800),
	('P5', 'C5', 'T5', 400),
	('P5', 'C6', 'T4', 500)
;

-- -------------- 1. DDL/DML---------------------
--b) Modifique la relación componentes agregando como atributo la provincia de la ciudad de los
--Componentes.
ALTER TABLE componentes
ADD COLUMN provincia VARCHAR(100);

--c) Modifique la relación artículos agregando un atributo que permita guardar el número de
--serie de cada artículo.
ALTER TABLE articulos
ADD COLUMN nro_serie INT;

--d) Actualice la relación componentes cambiando los colores rojos por violeta y los azules por
--marrón.
UPDATE componentes
SET color = 'Violeta'
WHERE color = 'Rojo';

UPDATE componentes
SET color = 'Marrón'
WHERE color = 'Azul';

--otra forma usando CASE (es como la alternativa condicional)
UPDATE componentes
SET color =
	CASE
	WHEN color = 'Rojo' THEN 'Violeta'
	WHEN color = 'Azul' THEN 'Marrón'
	ELSE color
	END;

--e) Actualice la definición de componentes para que los colores posibles sean solamente {rojo,
--verde, azul, violeta o marrón}
ALTER TABLE componentes
ADD CONSTRAINT componentes_color_check CHECK (color IN ('Rojo','Verde','Azul','Violeta','Marrón'));

--f) Actualice la ciudad de los proveedores cuyos nombres son Carlos o Eva, y cambie su ciudad
--por Bahía Blanca.
UPDATE proveedores
SET ciudad = 'Bahía Blanca'
WHERE prov_nombre IN ('Carlos', 'Eva');

--g) Elimine todos los envios cuya cantidad esté entre 200 y 300.
DELETE
FROM envios
WHERE cantidad BETWEEN 200 AND 300;

--h) Elimine los artículos de La Plata.
DELETE
FROM envios
WHERE id_art IN (SELECT id_art
				 FROM articulos
				 WHERE ciudad = 'La Plata');

DELETE
FROM articulos 
WHERE ciudad = 'La Plata';				 


-- -------------- 2. DML: Consultas----------------------
--a) Obtener todos los detalles de todos los artículos de Bernal.
SELECT *
FROM articulos
WHERE ciudad = 'Bernal';

--b) Obtener todos los valores de id_prov para los proveedores que abastecen el artículo T1.
SELECT id_prov
FROM envios
WHERE id_art = 'T1';

--c) Obtener de la tabla de artículos los valores de id_art y ciudad donde el nombre de la ciudad
--acaba en D o contiene al menos una E.
SELECT id_art, ciudad
FROM articulos
WHERE ciudad ILIKE '%d' OR ciudad ILIKE '%e%';

--d) Obtener los valores de id_prov para los proveedores que suministran para el artículo T1 el
--componente C1.
SELECT id_prov
FROM envios
WHERE id_comp = 'C1' AND id_art = 'T1';

--e) Obtener los valores de art_nombre en orden alfabético para los artículos abastecidos por el
--proveedor P1.
SELECT art_nombre
FROM articulos AS a
JOIN envios AS e ON a.id_art = e.id_art
WHERE id_prov = 'P1'
ORDER BY art_nombre; --ASC (viene por default en el order by)

--f) Obtener los valores de id_comp para los componentes suministrados para cualquier artículo
--de Capital Federal.
SELECT DISTINCT id_comp
FROM envios AS e
JOIN articulos AS a ON e.id_art = a.id_art
WHERE ciudad = 'Cap. Fed.';

--g) Obtener el id_comp del (o los) componente(s) que tienen el menor peso.
SELECT id_comp
FROM componentes
WHERE peso = (SELECT min(peso)
			  FROM componentes);

--h) Obtener los valores de idprov para los proveedores que suministran para un artículo de La
--Plata o Capital Federal un componente Rojo.
SELECT id_prov
FROM envios AS e
JOIN articulos AS a ON e.id_art = a.id_art
JOIN componentes AS c ON e.id_comp = c.id_comp
WHERE a.ciudad IN ('La Plata', 'Cap. Fed.') AND color = 'Rojo';

--i) Seleccionar el id_prov de los proveedores que nunca suministraron un componente verde.
SELECT id_prov
FROM proveedores
WHERE id_prov NOT IN (SELECT id_prov
					  FROM envios AS e
					  JOIN componentes AS c ON e.id_comp = c.id_comp
					  WHERE color = 'Verde');

--j) Obtener, para los envíos del proveedor P2, el número de suministros realizados, el número de
--artículos distintos suministrados y la cantidad total.
SELECT count(*) AS num_suministros, count(DISTINCT id_art) AS num_articulos, sum(cantidad) AS total_suministrado
FROM envios 
WHERE id_prov = 'P2';
--como es un solo grupo el que nos interesa, nos basta con un where y no hace falta recurrir a group by

--k) Obtener la cantidad máxima suministrada en un mismo envío, para cada proveedor.
SELECT id_prov, max(cantidad) as mayor_suministro
FROM envios
GROUP BY id_prov;

--l) Para cada artículo y componente suministrado obtener los valores de id_comp, id_art y la
--cantidad total correspondiente.
SELECT id_art, id_comp, sum(cantidad) AS total_suministrado
FROM envios
GROUP BY id_art, id_comp;

--m) Seleccionar los nombres de los componentes que son suministrados en una cantidad total
--superior a 500.
SELECT e.id_comp, comp_nombre
FROM envios AS e
JOIN componentes AS c ON e.id_comp = c.id_comp
GROUP BY e.id_comp, comp_nombre
HAVING sum(cantidad) > 500;
--si se refiere a total entre todos los suministros de ese componente

SELECT e.id_comp, comp_nombre
FROM envios AS e
JOIN componentes AS c ON e.id_comp = c.id_comp 
WHERE cantidad > 500;
--si se refiere a en cada suministro específico

--n) Obtener los identificadores de artículos, id_art, para los que se ha suministrado algún
--componente del que se haya suministrado una media superior a 420 artículos.
SELECT DISTINCT id_art
FROM envios AS e
JOIN (SELECT id_comp, avg(cantidad) AS media
	  FROM envios
	  GROUP BY id_comp) AS m ON e.id_comp = m.id_comp
WHERE media > 420;	  

--alternativa 1:
SELECT DISTINCT id_art
FROM envios AS e
JOIN (SELECT id_comp
	  FROM envios
	  GROUP BY id_comp
	  HAVING avg(cantidad) > 420) AS m ON e.id_comp = m.id_comp;

--alternativa 2:
SELECT DISTINCT id_art
FROM envios 
WHERE id_comp IN (SELECT id_comp
				  FROM envios
				  GROUP BY id_comp
				  HAVING avg(cantidad) > 420);	  

--o) Seleccionar los identificadores de proveedores que hayan realizado algún envío con cantidad
--mayor que la media de los envíos realizados para el componente a que corresponda dicho
--envío.
SELECT DISTINCT id_prov
FROM envios AS e
JOIN (SELECT id_comp, avg(cantidad) AS media
	  FROM envios
	  GROUP BY id_comp) AS m ON e.id_comp = m.id_comp
WHERE cantidad > media;	  

--otra opción más disparatada que se me ocurrió. Lo que busco es que se fije para cada tupla si cantidad es mayor a la media en base a
--cantidad para el subconjunto de tuplas en el que quedó dicha tupla.
--NO FUNCIONARÍA! YA QUE NO SE PUEDE HACER UN WHERE POSTERIOR A UN GROUP BY!
/*
SELECT DISTINCT id_prov
FROM envios
GROUP BY id_comp
WHERE cantidad > avg(cantidad);
*/

--p) Seleccionar los identificadores de artículos para los cuales todos sus componentes se fabrican
--en una misma Ciudad.
SELECT id_art
FROM envios AS e
JOIN componentes AS c ON e.id_comp = c.id_comp
GROUP BY id_art
HAVING COUNT(DISTINCT ciudad) = 1;

--Otra forma que se me ocurrió a mí
SELECT id_art
FROM (SELECT DISTINCT id_art, ciudad --te queda cada artículo relacionado con las distinas ciudades de sus componentes
	  FROM envios AS e
	  JOIN componentes AS c ON e.id_comp = c.id_comp) AS ac
GROUP BY id_art
HAVING count(*) = 1;	  

--q) Seleccionar los identificadores de artículos para los que se provean envíos de todos los
--componentes existentes en la base de datos.
SELECT id_art
FROM envios
GROUP BY id_art
HAVING count(DISTINCT id_comp) = (SELECT count(*)
								  FROM componentes);

--Otra forma que se me ocurrió a mí
SELECT id_art
FROM (SELECT DISTINCT id_art, id_comp --te queda cada artículo relacionado con las distintas ciudades de sus componentes
	  FROM envios) AS ac
GROUP BY id_art
HAVING count(*) = (SELECT count(*)
				   FROM componentes);
