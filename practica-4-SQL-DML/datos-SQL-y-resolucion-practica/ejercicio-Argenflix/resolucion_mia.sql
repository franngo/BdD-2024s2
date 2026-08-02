CREATE TABLE usuario (
    nombre_usuario VARCHAR(35),
    nombre_y_apellido VARCHAR(60),
    contrasenha VARCHAR(16),
    CONSTRAINT usuario_pk PRIMARY KEY (nombre_usuario)
);

CREATE TABLE pelicula (
    id_pelicula INT,
    nombre_pelicula VARCHAR(40),
    genero VARCHAR(20),
    duracion INT,
    calificacion INT,
    nombre_actor VARCHAR(50),
    nombre_director VARCHAR(50),
    CONSTRAINT pelicula_pk PRIMARY KEY (id_pelicula),
    CONSTRAINT pelicula_actor_fk FOREIGN KEY (nombre_actor) REFERENCES actor(nombre),
    CONSTRAINT pelicula_director_fk FOREIGN KEY (nombre_director) REFERENCES director(nombre_director)
);

CREATE TABLE serie (
    nombre_serie VARCHAR(50),
    anho_serie INT,
    genero VARCHAR(20),
    temporadas INT,
    calificacion INT,
    nombre_actor VARCHAR(50),
    nombre_director VARCHAR(50),
    CONSTRAINT serie_pk PRIMARY KEY (nombre_serie, anho_serie),
    CONSTRAINT serie_actor_fk FOREIGN KEY (nombre_actor) REFERENCES actor(nombre),
    CONSTRAINT serie_director_fk FOREIGN KEY (nombre_director) REFERENCES director(nombre_director)
);

CREATE TABLE actor (
    nombre VARCHAR(50),
    edad INT,
    anhos_activo INT,
    CONSTRAINT actor_pk PRIMARY KEY (nombre)
);

CREATE TABLE director (
    nombre_director VARCHAR(50),
    edad INT,
    nacionalidad VARCHAR(20),
    --actor_fetiche VARCHAR(50),
    CONSTRAINT director_pk PRIMARY KEY (nombre_director)
);

CREATE TABLE vio_pelicula (
    nombre_usuario VARCHAR(35),
    id_pelicula INT,
    CONSTRAINT vio_pelicula_pk PRIMARY KEY (nombre_usuario, id_pelicula),
    CONSTRAINT vio_pelicula_usuario_fk FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    CONSTRAINT vio_pelicula_pelicula_fk FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula)
);

CREATE TABLE vio_serie (
    nombre_usuario VARCHAR(35),
    nombre_serie VARCHAR(50),
    anho_serie INT,
    CONSTRAINT vio_serie_pk PRIMARY KEY (nombre_usuario, nombre_serie, anho_serie),
    CONSTRAINT vio_serie_usuario_fk FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    CONSTRAINT vio_serie_serie_fk FOREIGN KEY (nombre_serie, anho_serie) REFERENCES serie(nombre_serie, anho_serie)
);

--1. DDL:
--a) Crear todas las relaciones del ejercicio considerando los tipos de datos de cada atributo, las claves prima-
--rias y las claves foráneas entre las diferentes relaciones.

--b) Una vez creada la base de datos, el analista detecta que necesitamos modelar el concepto de actor fetiche.
--Se asume que cada director tiene sólo un actor fetiche y que dicho actor se encuentra registrado en el
--sistema. Escriba el código SQL que lleve adelante dicha modificación y ejecútelo.

ALTER TABLE director
ADD COLUMN actor_fetiche VARCHAR(50),
ADD CONSTRAINT director_actor_fk FOREIGN KEY (actor_fetiche) REFERENCES actor(nombre);

--2. DML:
--a) Actualizar todas las películas que hayan sido protagonizadas por Steve Guttenberg o Ian Ziering asígnan-
--dole una calificación de 10, que la máxima calificacion.
UPDATE pelicula
SET calificacion = 10
WHERE nombre_actor ILIKE '%Steve Guttenberg%';

UPDATE pelicula
SET calificacion = 10
WHERE nombre_actor ILIKE '%Ian Ziering%';

--b) Actualizar todas las películas que hayan sido dirigidas por directores argentinos asígnandole una califica-
--ción de 10.
UPDATE pelicula
SET calificacion = 10
WHERE nombre_director IN (SELECT nombre_director
                          FROM director
                          WHERE nacionalidad = 'Argentino');

--c) Eliminar todas las series con menos de 3 temporadas.
DELETE
FROM vio_serie
WHERE (nombre_serie, anho_serie) IN (SELECT nombre_serie, anho_serie
                                     FROM serie
                                     WHERE temporadas < 3);

DELETE
FROM serie
WHERE temporadas < 3;                                     


--3. Consultas:
--a) Obtener la cantidad de películas en las que haya actuado el actor Jim Carrey.
SELECT count(*) AS cant_peliculas
FROM pelicula
WHERE nombre_actor ILIKE '%Jim Carrey%';

--b) Obtener la cantidad películas por nacionalidad del director. El resultado debe tener sólo los campos <na-
--cionalidad, cantidad>.
SELECT nacionalidad, count(*) AS cant_peliculas
FROM pelicula AS p
JOIN director AS d ON p.nombre_director = d.nombre_director
GROUP BY nacionalidad;

--c) Listar el nombre y la cantidad de temporadas de las series que hayan sido dirigidas por directores que
--hayan dirigido por lo menos alguna película.
SELECT nombre_serie, temporadas
FROM serie
WHERE nombre_director IN (SELECT nombre_director
                          FROM pelicula);

--d) Obtener el nombre de los actores que actuaron en películas pero que no lo hicieron en series. Los resulta-
--dos no deben tener registros repetidos.
SELECT DISTINCT nombre_actor
FROM pelicula
WHERE nombre_actor NOT IN (SELECT nombre_actor
                           FROM serie);

--e) Obtener los nombres de las películas, actores y directores de las películas en las que un director dirigió a
--su actor fetiche.
SELECT nombre_pelicula, nombre_actor, p.nombre_director
FROM pelicula AS p
JOIN director AS d ON p.nombre_director = d.nombre_director
WHERE p.nombre_actor = d.actor_fetiche;

--f ) Obtener los nombres de la serie, el género y el nombre del usuario de las series que hayan sido vistas por
--los usuarios de nombre “RossGeller85” o “BreakingThrones”.
SELECT vs.nombre_serie, genero, nombre_usuario --entiendo que con nom del usuario se refiere al usuario de los 2 que la vio
FROM vio_serie AS vs
JOIN serie AS s ON vs.nombre_serie = s.nombre_serie AND vs.anho_serie = s.anho_serie
WHERE nombre_usuario IN ('RossGeller85', 'BreakingThrones');

--g) Obtener la tabla de usuarios ordenados de mayor a menor de acuerdo a la cantidad de películas que
--vieron. La tabla resultante debe tener 2 columnas: el nombre del usuario y la cantidad de películas vistas.
SELECT nombre_usuario, count(*) AS cant_peliculas
FROM vio_pelicula
GROUP BY nombre_usuario
ORDER BY cant_peliculas DESC;

--En caso de que me este pidiendo nombre y apellido real del usuario
SELECT nombre_y_apellido, count(*) AS cant_peliculas
FROM vio_pelicula AS vp
JOIN usuario AS u ON vp.nombre_usuario = u.nombre_usuario
GROUP BY vp.nombre_usuario, nombre_y_apellido
ORDER BY cant_peliculas DESC;

--h) Por cuestiones legales es necesario eliminar al usuario "DarthVader".
DELETE
FROM vio_pelicula
WHERE nombre_usuario = 'DarthVader';

DELETE
FROM vio_serie
WHERE nombre_usuario = 'DarthVader';

DELETE
FROM usuario
WHERE nombre_usuario = 'DarthVader';

--i) Es necesario identificar a los directores que no hayan dirigido ninguna película. Presente al menos dos
--consultas equivalentes.
SELECT nombre_director
FROM director
WHERE nombre_director NOT IN (SELECT nombre_director
                              FROM pelicula);

SELECT d.nombre_director
FROM director AS d
LEFT JOIN pelicula AS p ON d.nombre_director = p.nombre_director
WHERE p.nombre_director IS NULL;

--j) Crear una vista que muestre, de las 3 peliculas más vistas que no sean estadounidenses, cuál es su origen y
--la cantidad de veces que fue vista por los usuarios del sistema. La vista debe llamarse otras_mas_vistas,
--los campos resultantes deben denominarse origen_pelicula y veces_vista.
SELECT p.id_pelicula, nombre_pelicula, nacionalidad AS origen_pelicula, count(*) AS veces_vista
FROM vio_pelicula AS vp
JOIN pelicula AS p ON vp.id_pelicula = p.id_pelicula
JOIN director AS d ON p.nombre_director = d.nombre_director
WHERE nacionalidad <> 'Estadounidense'
GROUP BY p.id_pelicula, nombre_pelicula, nacionalidad
ORDER BY veces_vista DESC
LIMIT 3;

--para crear vista es: create view as (consulta)
