CREATE TABLE libro (
	isbn SERIAL PRIMARY KEY,
	titulo VARCHAR(32)
);

INSERT INTO libro (isbn, titulo)
VALUES (33058621, 'Inferno'),
			 (35494238, 'Cien Anios de Soledad'),
			 (58764384, 'Venas abiertas de America Latina'),
			 (38784929, 'Aeropuerto');

CREATE TABLE ejemplar (
	cod_ejemplar SERIAL PRIMARY KEY,
	isbn_libro INT,
	edicion INT,
	CONSTRAINT fk_ejemplar FOREIGN KEY (isbn_libro)
	REFERENCES libro(isbn)
);

INSERT INTO ejemplar (cod_ejemplar, isbn_libro, edicion)
VALUES (503, 33058621, 2),
			 (785, 33058621, 4),
			 (065, 35494238, 1),
			 (098, 38784929, 3),
			 (223, 58764384, 3),
			 (101, 58764384, 1);

CREATE TABLE nacionalidad (
	nombre_pais VARCHAR(9) PRIMARY KEY,
	nacionalidad VARCHAR(9)
);

INSERT INTO nacionalidad (nombre_pais, nacionalidad)
VALUES ('Argentina', 'Argentina'),
			 ('Brasil', 'Brasilera'),
			 ('Peru', 'Peruana'),
			 ('Mexico', 'Mexicana');

CREATE TABLE socio (
	cod_socio SERIAL PRIMARY KEY,
	nombre_y_apellido VARCHAR(17),
	fecha_ingreso timestamp,
	monto_cuota INT,
	matricula INT,
	pais VARCHAR(9),
	CONSTRAINT fk_nombrepais FOREIGN KEY(pais) REFERENCES nacionalidad(nombre_pais)
);

INSERT INTO socio (cod_socio, nombre_y_apellido, fecha_ingreso, monto_cuota, matricula, pais)
VALUES (78, 'Sheldon Cooper', '2011-05-03 00:00:00', 12, 4, 'Brasil'),
			 (54, 'Howard Wolowitz', '2011-01-21 00:00:00', 16, 0, 'Argentina'),
			 (03, 'Amy Farrah Fowler', '2011-02-17 00:00:00', 5, 10, 'Argentina');

CREATE TABLE prestamo (
	cod_ejemplar INT,
	cod_socio INT,
	fecha_prestamo TIMESTAMP,
	fecha_devolucion TIMESTAMP,
	PRIMARY KEY(cod_ejemplar,cod_socio),
	CONSTRAINT fk_cod_ejemplar FOREIGN KEY (cod_ejemplar)
	REFERENCES ejemplar(cod_ejemplar),
	CONSTRAINT fk_cod_socio FOREIGN KEY (cod_socio)
	REFERENCES socio(cod_socio)
);

INSERT INTO prestamo (cod_ejemplar, cod_socio, fecha_prestamo, fecha_devolucion)
VALUES (503, 78, '2012-05-03 00:00:00', '2012/05/08'),
			 (223, 54, '2013-01-21 00:00:00', '2013/03/01'),
			 (785, 78, '2013-02-20 00:00:00', NULL),
			 (101, 03, '2013-11-17 00:00:00', '2013/11/18');

--1 (DML/DLL)

--b
ALTER TABLE ejemplar
ADD COLUMN anho_edicion INT;

--c
ALTER TABLE socio
ADD COLUMN domicilio_socio VARCHAR(100);

--d
UPDATE socio
SET monto_cuota = monto_cuota + 10 --si es para todos, no ponés un where

--e
ALTER TABLE nacionalidad
ALTER COLUMN nacionalidad TYPE varchar(100);

/* NO PORQUE EL ATRIBUTO PAÍS NO REQUIERE 9 CON "colombia"
ALTER TABLE socio  
ALTER COLUMN pais TYPE varchar(9);
*/ 

INSERT 
INTO nacionalidad 
VALUES ('Colombia', 'Colombiana');

UPDATE socio
SET pais = 'Mexico'
WHERE nombre_y_apellido = 'Amy Farrah Fowler'; --ojo. acá es mejor usar la PK (si hay 2 amy, actualizaría a las 2)

UPDATE socio
SET pais = 'Colombia'
WHERE nombre_y_apellido = 'Howard Wolowitz';

--f
--si hubiese habido alguien de la tabla socio con nacionalidad 'Peruana', habría que haberles eliminado ese dato para mantener la
--integridad referencial (capaz update a null)

/*
UPDATE socio
SET pais = NULL
WHERE pais = 'Perú';
*/

DELETE
FROM nacionalidad
WHERE nacionalidad = 'Peruana'; --o nombre_pais = 'Peru' (sería mejor porque es la PK) (mejor usar campos restrictivos que campos abiertos)

--g
DELETE 
FROM prestamo 
WHERE (cod_ejemplar IN (SELECT cod_ejemplar
					    FROM ejemplar
						WHERE edicion = 3));
--necesario por la integridad referencial, ya que si borro tuplas de acá con edición = 3 y justo sus cod_ejemplar aparecen como valor
--en el atributo clave foránea cod_ejemplar de la relación prestamo, ahí se rompería la integridad referencial.
--(ya que podrías tener tuplas donde su valor para el atributo que es clave foránea no provienen de la tabla de la que deberían provenir)

DELETE 
FROM ejemplar 
WHERE edicion = 3;

--2 (DML)

/*
a) Proyección
i) Indicar cuál es el resultado de las siguientes consultas y analizar que
representa cada una.
(1)SELECT cod_socio FROM prestamo TE DEVUELVE EL CÓDIGO DE TODOS LOS SOCIOS QUE TOMARON PRESTADO UN LIBRO
(2)SELECT cod_ejemplar FROM prestamo EL CÓDIGO DE TODOS LOS EJEMPLARES QUE FUERON PRESTADOS
(3)SELECT cod_ejemplar,cod_socio FROM prestamo EL CÓDIGO DE TANTO SOCIO COMO EJEMPLAR DE TODOS LOS PRESTAMOS DADOS

ii) ¿El resultado de <SELECT cod_socio FROM prestamo> es el mismo que el de
π<cod_socio> (prestamo). ¿Por qué?
NO es igual, ya que el select te puede devolver valores repetidos, mientras que la proyección NO (te devuelve un conjunto)
Si fuera SELECT DISTINCT cod_socio FROM prestamo; ahí SÍ serían iguales

iii)Sea R =<r1, . . . rn>. ¿Cómo es el esquema de las siguientes operaciones?
(1)SELECT r1 FROM R (va a tener solo el atributo r1)
(2)SELECT r1, r2 FROM R (va a tener solo los atributos r1 y r2)
(3) SELECT * FROM R (va a tener el mismo esquema que R)
*/
--iv)Calcular el nombre y apellido de todos los socios.
SELECT nombre_y_apellido
FROM socio;

/*
b) Atributos calculados
Resolver las siguientes consultas:
*/
--(1) Obtener la duración (en cantidad de días) de cada préstamo.
SELECT *, ((COALESCE (fecha_devolucion, CURRENT_DATE)) - fecha_prestamo) as durabilidad 
FROM prestamo;
--con esto creamos una columna para el select
--el coalesce lo usamos por si hay un null en fecha_devolucion (si fecha_devolucion es null, te devuelve lo siguiente, o sea, current_date)

--(2) Calcular cuánto paga cada socio por año, sabiendo que la matrícula
--se paga una vez al año y la cuota es mensual.
select cod_socio, nombre_y_apellido, (matricula + monto_cuota * 12) as pago_anual
from socio;

/*
c) Selección
i) Indicar cuál es el resultado de las siguientes consultas y analizar que
representa cada una.
(1) SELECT cod_socio
    FROM prestamo
    WHERE fecha_prestamo > '2012/01/31';
	Los códigos de todos los socios que tomaron préstamos después del 31/01/2012
(2)
SELECT cod_ejemplar
FROM prestamo
WHERE fecha_prestamo > '2012/01/31';
Te quedás con todos los códigos de ejemplares tomados prestados después del 31/01/2013
¿Cómo son estos resultados con respecto a los del ejercicio de la Proyección?
*/
--iii)Obtener el ISBN de los ejemplares de la segunda o tercera edición.
select isbn_libro
from ejemplar
where edicion = 2 OR edicion = 3; --o edicion IN (2, 3)

/*
d) Join Natural
i)Indicar cuál es el resultado de las siguientes consultas y analizar que representa cada una.
(1)SELECT * FROM prestamo NATURAL JOIN ejemplar TODOS LOS PRÉSTAMOS CON LA DESCRIPCIÓN DE LOS EJEMPLARES PRESTADOS
(2)SELECT * FROM prestamo NATURAL JOIN socio TODOS LOS PRÉSTAMOS CON LA DESCRIPCIÓN DE LOS SOCIOS QUE TOMARON PRESTADO
¿Tiene sentido calcular: SELECT * FROM ejemplar NATURAL JOIN socio? NO porque no comparten ningún atributo
Justificar

ii) ¿Qué condiciones deben cumplir R1 y R2 para que tenga sentido la consulta SELECT *
FROM R1 NATURAL JOIN R2? que tengan atributos en común R1 y R2
¿Cuál es el esquema resultante de esa consulta? atributos de R1 + atributos de R2 - atributos repetidos

iii) ¿Qué condiciones deben cumplir R1 y R2 para que tenga sentido la consulta SELECT *
FROM R1 NATURAL JOIN R2 WHERE B? Que R1 y R2 tengan atributos en común y que la condición B incluya un atributo de R1, de R2 o algo como 1=1
¿Cuál es el esquema resultante? los de R1 + los de R2

Resolver las siguientes consultas:
*/
--(1) Obtener el nombre de los libros que tienen ejemplares de la
--segunda o tercera edición.
select isbn, titulo
from ejemplar
join libro
ON ejemplar.isbn_libro = libro.isbn
WHERE edicion = 2 OR edicion = 3; --primero joineamos las tablas. DESPUÉS se hace el where sobre los resultados

--otra forma 

select isbn, titulo
from (SELECT * FROM ejemplar
WHERE edicion = 2 OR edicion = 3) as A
join libro as B
ON A.isbn_libro = B.isbn; --acá lo hago al revés para acotar el conjunto antes de joinear (creo que NO es recomendable)


--(2) Obtener cuántos préstamos tuvo cada socio el último verano (suponiendo que fue el del 2012)
select cod_socio, count(*) as cantidad_prestamos --acá solo pueden aparecer atributos ingresados en el group by. OTRA COSA ES QUE SE CUENTA EN BASE A LO QUE YO AGRUPO.
from prestamo
where fecha_prestamo between '2012-12-21' and '2013-03-20' --or fecha_devolucion between '2012-12-21' and '2013-03-20'
   or fecha_prestamo < '2012-12-21' and (fecha_devolucion is null or fecha_devolucion >= '2012-12-21')
group by cod_socio;

/*
e) Producto Cartesiano
i)Indicar cuál es el resultado de las siguientes consultas y analizar que
representa cada una.
(1)SELECT * FROM prestamo JOIN socio; //error porque no se indica una condición (si se quiere hacer producto cartesiano, sería con cross join)
(2)SELECT * FROM ejemplar JOIN socio; //error porque no se indica una condición (si se quiere hacer producto cartesiano, sería con cross join)

ii)¿Qué condiciones deben cumplir R1 y R2 para que tenga sentido las consultas:
(1) SELECT * FROM R1 JOIN R2? //para hacer cross join entre r1 y r2, no se debe cumplir ninguna condicion (en AR, sería que no hayan
							  //atributos en común)
(2) SELECT * FROM R1 JOIN R2 where B? //para esta operación (con cross join) lo único que se debe cumplir es que B incluya un atributo
									  //de la tabla resultante (o, de hecho, ni siquiera eso es necesario. puede ser 1=1)
¿Cuál es el esquema resultante de cada una? //atributos de R1 + atributos de R2

f) Join con condición
i)Indicar cuál es el resultado de las siguientes consultas y analizar qué
representa cada una.
(1) SELECT *
FROM prestamo
JOIN socio
ON fecha_ingreso < fecha_prestamo; //tampoco tiene sentido porque compara 2 atributos de la misma tablas (igual funciona)
//te termina devolviéndo todas las tuplas de préstamo en donde fecha_prestamo es menor a fecha_devolución (todas menos en la que
//fecha_devolucion=NULL) relacionadas con todas las tuplas de socio
//lo que tendría sentido es hacer un where con esa condición después del JOIN (y diría tmb relacionando por cod_socio las tuplas)
//algo con más sentido es esto
SELECT *
FROM prestamo
join socio
on prestamo.cod_socio = socio.cod_socio 
where fecha_prestamo < fecha_devolucion;
(2)
SELECT *
FROM ejemplar
JOIN socio
ON fecha_ingreso < '2008/02/01'; //no tiene sentido porque no estás comparando un atributo de una con la otra (igual funciona)
//te da vacío, porque hace producto cartesiano y, después, se queda con las tuplas de la tabla resultante donde fecha_ingreso < '2008/02/01',
//que en este caso no son ninguna (todos ingresaron en 2011)
//si fuera, x ej, fecha_ingreso < '2012/02/01', te daría una tabla con todas las tuplas de ejemplar relacionadas con todas las de socio.
//claramente tiene más sentido preguntar eso en un where posterior al join.
//algo así
SELECT *
FROM ejemplar
join socio
on ???
where fecha_prestamo < fecha_devolucion;
//de hecho, no tiene sentido porque ejemplar y socio no tienen ningún atributo utilizable para una comparación/ que comparta significados.
*/