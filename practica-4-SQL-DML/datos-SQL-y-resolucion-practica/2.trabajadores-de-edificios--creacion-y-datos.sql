CREATE TABLE trabajador
(legajo int primary key,
	nombre varchar(12),
	tarifa int,
	oficio varchar(12)
);


alter table trabajador
add legajo_supv INT NULL REFERENCES trabajador;


INSERT INTO trabajador
(legajo, nombre, tarifa, oficio, legajo_supv)
VALUES
(1235, 'M. Fernandez', 12.5, 'electricista', 1311),
(1311, 'C. Garcia', 15.5, 'electricista', 1311),
(1412, 'C. Gonzalez', 13.75, 'plomero', 1520),
(1520, 'H. Caballero', 11.75, 'plomero', 1520),
(2920, 'R. Perez', 10.0, 'albanhil', 2920),
(3001, 'J. Gutierrez', 8.2, 'carpintero', 3231),
(3231, 'P. Alvarez', 17.4, 'carpintero', 3231)
;

CREATE TABLE edificio
(id_e int primary key,
	dir varchar(20),
	tipo varchar(10),
	nivel_calidad int,
	categoria int)
	;

	INSERT INTO edificio
	(id_e, dir, tipo, nivel_calidad, categoria)
	VALUES
	(111, 'Av. Paseo Colon 1213', 'oficina', 4, 1),
	(210, 'Rivadavia 1011', 'oficina', 3, 1),
	(312, 'Tucuman 123', 'oficina', 2, 2),
	(435, 'Cabildo 456', 'comercio', 1, 1),
	(460, 'Santa Fe 1415', 'almacen', 3, 3),
	(515, 'Chile 789', 'residencia', 3, 2)
	;

	CREATE TABLE asignacion
	(legajo int,
		id_e int,
		fecha_inicio timestamp,
		num_dias int,
		constraint fk_legajo foreign key (legajo)
		references trabajador(legajo),
		constraint fk_id_e foreign key (id_e)
		references edificio(id_e)
	)
	;

	INSERT INTO asignacion
	(legajo, id_e, fecha_inicio, num_dias)
	VALUES
	(1235, 312, '2014-10-10 00:00:00', 5),
	(1235, 515, '2014-10-17 00:00:00', 22),
	(1311, 435, '2014-10-08 00:00:00', 12),
	(1311, 460, '2014-10-23 00:00:00', 24),
	(1412, 111, '2014-12-01 00:00:00', 4),
	(1412, 210, '2014-11-15 00:00:00', 12),
	(1412, 312, '2014-10-01 00:00:00', 10),
	(1412, 435, '2014-10-15 00:00:00', 15),
	(1412, 460, '2014-10-08 00:00:00', 18),
	(1412, 515, '2014-11-05 00:00:00', 8),
	(1520, 312, '2014-10-30 00:00:00', 17),
	(1520, 515, '2014-10-09 00:00:00', 14),
	(2920, 210, '2014-11-10 00:00:00', 15),
	(2920, 460, '2014-05-20 00:00:00', 18),
	(3001, 111, '2014-10-08 00:00:00', 14),
	(3001, 210, '2014-10-27 00:00:00', 14),
	(3231, 111, '2014-10-10 00:00:00', 8),
	(3231, 312, '2014-10-24 00:00:00', 20)
	;

--1) DDL/DML
--a) Modifique la relación trabajador agregando la edad del mismo.
ALTER TABLE trabajador
ADD COLUMN edad INT;

--b) Modifique la relación edificio agregando un atributo que permita guardar la ciudad del edificio.
ALTER TABLE edificio
ADD COLUMN ciudad VARCHAR(100);

--c) Actualice la relación asignaciones incrementando en 4 los números de días en las asignaciones.
UPDATE asignacion
SET num_dias = num_dias + 4;

--d) Actualice el nivel de calidad de los edificios que son oficinas cambiando 4 por 5 y la categoría de 1 por 4.
UPDATE edificio
SET nivel_calidad = 5, categoria = 4
WHERE tipo = 'oficina';

--e) Elimine todos los plomeros.
DELETE
FROM asignacion
WHERE legajo IN (SELECT legajo
				 FROM trabajador
				 WHERE oficio = 'plomero');

DELETE
FROM trabajador
WHERE oficio = 'plomero';			 

--f) Elimine los edificios que son residencias.

DELETE
FROM asignacion 
WHERE id_e IN (SELECT id_e
			   FROM edificio
			   WHERE tipo = 'residencia');

DELETE
FROM edificio
WHERE tipo = 'residencia';

--2) DML: Resolver las siguientes consultas usando SQL
--a) Nombre de los trabajadores cuya tarifa está entre 10 y 12 pesos.
SELECT nombre
FROM trabajador
WHERE tarifa BETWEEN 10 AND 12;

--b) Cuáles son los oficios de los trabajadores asignados al edificio 435?
SELECT oficio
FROM asignacion AS a
JOIN trabajador AS t
ON a.legajo = t.legajo
WHERE id_e = 435;

--c) Indicar el nombre del trabajador y el de su supervisor.
--relación recursiva (ambas tablas comparten todos los atributos)
SELECT trab.nombre, supv.nombre
FROM trabajador as trab
JOIN trabajador as supv
ON trab.legajo_supv = supv.legajo;

--d) Nombre de los trabajadores asignados a oficinas.
SELECT DISTINCT nombre --distinct porque hay varios que tienen más de un trabajo en oficinas y no queremos sus nombres repetidos.
FROM asignacion as a
JOIN trabajador as t
ON a.legajo = t.legajo
JOIN edificio as e
ON a.id_e = e.id_e
WHERE tipo = 'oficina';

--e) ¿Qué trabajadores reciben una tarifa por hora mayor que la de su supervisor?
SELECT trab.nombre
FROM trabajador as trab
JOIN trabajador as supv
ON trab.legajo_supv = supv.legajo
WHERE trab.tarifa > supv.tarifa;

--f) ¿Cuál es el número total de días que se han dedicado a plomería en el edificio 312?
SELECT sum(num_dias) as dias_plomeria_en_312
FROM asignacion as a
JOIN trabajador as t
ON a.legajo = t.legajo
WHERE oficio = 'plomero'
GROUP BY id_e
HAVING id_e = 312;

--g) ¿Cuántos tipos de oficios diferentes hay?
SELECT oficio
FROM trabajador
GROUP BY oficio; --esto me da los distintos oficios que hay

SELECT count(*)
FROM (SELECT oficio
	  FROM trabajador
	  GROUP BY oficio) AS o; --una subquery en un FROM debe tener un alias


--h) Para cada supervisor, ¿cuál es la tarifa por hora más alta que se paga a un trabajador que informa a ese supervisor?
SELECT legajo_supv, max(tarifa) as tarifa_mas_alta_de_un_supervisado
FROM trabajador
GROUP BY legajo_supv; --acá, si hiciera join, podría agrupar por legajo_supv y nombre del supv, así lo muestro (total cada legajo va
					  --a ir siempre con el mismo nombre, así que es lo mismo que agrupar solo por legajo)

--si quisiera también dar el nombre del supervisor en cuestión:
--esta no funciona porque estoy referenciando tablas renombradas que solo se conocen dentro de la subquery pero no fuera de ella!
SELECT trab.legajo_supv, supv.nombre as nombre_supv, max(trab.tarifa) as tarifa_mas_alta_de_un_supervisado
FROM (SELECT *
	  FROM trabajador AS trab
	  JOIN trabajador AS supv
	  ON trab.legajo_supv = supv.legajo) AS tys
GROUP BY trab.legajo_supv, supv.nombre; 

--esta sí
SELECT supv_y_tar_superv.legajo_supv, supv.nombre as nombre_supv, tarifa_mas_alta_de_un_supervisado
FROM (SELECT legajo_supv, max(tarifa) as tarifa_mas_alta_de_un_supervisado
	  FROM trabajador
	  GROUP BY legajo_supv) AS supv_y_tar_superv
JOIN trabajador AS supv
ON supv_y_tar_superv.legajo_supv = supv.legajo;

--i) Para cada supervisor que supervisa a más de un trabajador, ¿cuál es la tarifa más alta que se
--paga a un trabajador que informa a ese supervisor?
SELECT legajo_supv, max(tarifa) as tarifa_mas_alta_de_un_supervisado
FROM trabajador
GROUP BY legajo_supv
HAVING count(*) > 1;

--j) Para cada tipo de edificio, ¿cuál es el nivel de calidad medio de los edificios con categoría 1?
--Considérense sólo aquellos tipos de edificios que tienen un nivel de calidad máximo nomayor que 3.
SELECT tipo, avg(nivel_calidad) as nivel_calidad_medio
FROM edificio
WHERE categoria = 1
GROUP BY tipo
HAVING max(nivel_calidad) <= 3;

--k) ¿Qué trabajadores reciben una tarifa por hora menor que la del promedio?
SELECT legajo, nombre, tarifa
FROM trabajador
WHERE tarifa < (SELECT avg(tarifa)
				FROM trabajador); --tarifa promedio

--l) ¿Qué trabajadores reciben una tarifa por hora menor que la del promedio de los trabajadores que tienen su mismo oficio?
SELECT legajo, nombre, tarifa, oficio
FROM trabajador AS t1
WHERE tarifa < (SELECT avg(tarifa)
				FROM trabajador AS t2
				WHERE t1.oficio = t2.oficio); --acá, cada tupla de g1 se compara con todas las de t2. luego avg y se revisa si tarifa < avg

--m) ¿Qué trabajadores reciben una tarifa por hora menor que la del promedio de los trabajadores
--que dependen del mismo supervisor que él?
SELECT legajo, nombre, tarifa, legajo_supv
FROM trabajador AS t1
WHERE tarifa < (SELECT avg(tarifa)
				FROM trabajador AS t2
				WHERE t1.legajo_supv = t2.legajo_supv);

--n) Seleccione el nombre de los electricistas asignados al edificio 435 y la fecha en la que empezaron a trabajar en él.
SELECT nombre, fecha_inicio
FROM asignacion AS a
JOIN trabajador AS t
ON a.legajo = t.legajo
WHERE oficio = 'electricista' AND id_e = 435;

--o) ¿Qué supervisores tienen trabajadores que tienen una tarifa por hora por encima de los 12 euros?
--1ra forma: (supongo que esta es mejor)
SELECT legajo_supv
FROM trabajador
GROUP BY legajo_supv
HAVING max(tarifa) > 12;

--y con el nombre

SELECT trab.legajo_supv, supv.nombre --acá no podría ser supv.legajo y supv.nombre porque supv.legajo no está en el group by (si cambio eso, entonces sí)
FROM trabajador AS trab
JOIN trabajador AS supv 
ON trab.legajo_supv = supv.legajo
GROUP BY trab.legajo_supv, supv.nombre --o supv.legajo y supv.nombre (es lo mismo)
HAVING max(trab.tarifa) > 12;

--2ra forma:
SELECT DISTINCT legajo_supv
FROM trabajador
WHERE tarifa > 12;

--y con el nombre

SELECT DISTINCT trab.legajo_supv, supv.nombre --o supv.legajo y supv.nombre (es lo mismo)
FROM trabajador AS trab
JOIN trabajador AS supv
ON trab.legajo_supv = supv.legajo
WHERE trab.tarifa > 12;