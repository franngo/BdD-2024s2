--2.a
--Actualizar todas las películas que hayan sido protagonizadas por Steve Guttenberg o Ian Ziering asígnan-
--dole una calificación de 10, que la máxima calificacion.
update pelicula
set calificacion = 10
WHERE actor LIKE %'Steve Guttenberg'% OR
WHERE actor LIKE %'Ian Ziering'%;

--2.b
--Actualizar todas las películas que hayan sido dirigidas por directores argentinos asígnandole una califica-
--ción de 10.
UPDATE pelicula
SET calificacion = 10
WHERE nombre_director IN (SELECT nombre_director
                          FROM director
                          WHERE nacionalidad = 'Argentino');

--2.c
--Eliminar todas las series con menos de 3 temporadas.

--por integridad referencial hay que borrar en vio_serie
--vio_serie<nombre_usuario:VARCHAR(35) PK FK, nombre_serie:VARCHAR(50) PK FK,
--anho_serie: INT PK FK>
DELETE
FROM vio_serie
WHERE (nombre_serie, anho_serie) IN (SELECT nombre_serie, anho_serie
                                     FROM serie
                                     WHERE temporadas < 3)

DELETE 
FROM serie
WHERE temporadas < 3;

--aparte

--eliminar de vio_serie todos los registros de series que NO están en la tabla serie (no hay integridad referencial para nombre y anho)
DELETE
FROM vio_serie
WHERE (nombre_serie, anho_serie) NOT IN (SELECT nombre_serie, anho_serie
                                         FROM serie);

--o con left join
DELETE
FROM vio_serie as vs
LEFT JOIN serie as s
ON (vs.nombre_serie, vs.anho_serie) = (s.nombre_serie, s.anho_serie)
WHERE s.nombre_serie IS NULL

--3. Consultas:
--a) Obtener la cantidad de películas en las que haya actuado el actor Jim Carrey.
SELECT count(*) as cant_peliculas
FROM pelicula
WHERE nombre_actor = 'Jim Carrey'

--b) Obtener la cantidad películas por nacionalidad del director. El resultado debe tener sólo los campos <na-
--cionalidad, cantidad>.
SELECT nacionalidad, count(*) as cantidad
FROM pelicula AS p
JOIN director AS d
ON p.nombre_director = d.nombre_director
GROUP BY nacionalidad;

--c) Listar el nombre y la cantidad de temporadas de las series que hayan sido dirigidas por directores que
--hayan dirigido por lo menos alguna película.
SELECT nombre_serie, temporadas
FROM serie
WHERE nombre_director IN (SELECT DISTINCT nombre_director --no es necesario el distinct
                          FROM pelicula);

--otra opcion
SELECT nombre_serie, temporadas --distinct?
FROM serie AS s
JOIN pelicula AS p ON s.nombre_director = p.nombre_director; --con esto ya te asegurás que el director dirigió al menos una película

--d) Obtener el nombre de los actores que actuaron en películas pero que no lo hicieron en series. Los resulta-
--dos no deben tener registros repetidos.
--e) Obtener los nombres de las películas, actores y directores de las películas en las que un director dirigió a
--su actor fetiche.
--join comparando donde el nombre del actor es igual al nombre del actor fetiche
--f ) Obtener los nombres de la serie, el género y el nombre del usuario de las series que hayan sido vistas por
--los usuarios de nombre “RossGeller85” o “BreakingThrones”.
--lo mismo. join y filtrando

--g) Obtener la tabla de usuarios ordenados de mayor a menor de acuerdo a la cantidad de películas que
--vieron. La tabla resultante debe tener 2 columnas: el nombre del usuario y la cantidad de películas vistas.
SELECT vp.nombre_usuario, count(*) as cant_pelis_vistas
FROM vio_pelicula AS vp
JOIN usuario AS u
GROUP BY vp.nombre_usuario
ORDER BY cant_pelis_vistas DESC; --acá no hace falta poner count(*) porque ya se ejecutó el select y ya existe cant_pelis_vistas

--h) Por cuestiones legales es necesario eliminar al usuario "DarthVader".

--i) Es necesario identificar a los directores que no hayan dirigido ninguna película. Presente al menos dos
--consultas equivalentes.

--j) Crear una vista que muestre, de las 3 peliculas más vistas que no sean estadounidenses, cuál es su origen y
--la cantidad de veces que fue vista por los usuarios del sistema. La vista debe llamarse otras_mas_vistas,
--los campos resultantes deben denominarse origen_pelicula y veces_vista.
CREATE VIEW otras_mas_vistas AS
SELECT origen_pelicula, veces_vista --no podría simplemente poner la subconsulta directamente?
FROM (
      SELECT p.id_pelicula, d.nacionalidad as origen_pelicula, count(*) as veces_vista
      FROM pelicula AS p
      JOIN director AS d ON p.nombre_director = d.nombre_director --el resultado de este join, lo vamos a joinear con otra tabla
      JOIN vio_pelicula AS vp ON p.id_pelicula = vp.id_pelicula 
      WHERE d.nacionalidad <> 'Estadounidense'
      GROUP BY p.id_pelicula, d.nacionalidad
      ORDER BY veces_vista DESC
      LIMIT 3;
);

SELECT *
FROM otras_mas_vistas; --acá hacemos uso de la vista, la cual es una consulta guardada bajo un nombre que se ejecuta al ser referenciada
                       --siempre que se la referencie, se ejecutará y devolverá una tabla como resultado. es un rename para una consulta.