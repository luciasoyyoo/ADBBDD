# Práctica 1: Conceptos Fundamentales de PostgreSQL

Este repositorio contiene la solución completa para la **Práctica 1: Conceptos fundamentales de PostgreSQL**, incluyendo scripts de creación de base de datos, administración de usuarios y permisos, consultas SQL avanzadas, funciones, vistas y exportación/importación de datos.

## Índice

 1. [Creación de la Base de Datos](#1-creación-de-la-base-de-datos)

 2. [Creación de Usuarios y Permisos](#2-creación-de-usuarios-y-permisos)

 3. [Creación de Tablas](#3-creación-de-tablas)

 4. [Inserción de Datos](#4-inserción-de-datos)

 5. [Consultas Básicas](#5-consultas-básicas)

 6. [Consultas con Agregación](#6-consultas-con-agregación)

 7. [Modificación de Datos y Cascada](#7-modificación-de-datos-y-cascada)

 8. [Creación de Vistas y Permisos](#8-creación-de-vistas-y-permisos)

 9. [Funciones y Consultas Avanzadas](#9-funciones-y-consultas-avanzadas)

10. [Exportación e Importación de Datos](#10-exportación-e-importación-de-datos)

## 1. Creación de la Base de Datos

Creación de la base de datos `biblioteca` conectándose como el usuario administrador del sistema (`postgres`).

```
CREATE DATABASE biblioteca;
\c biblioteca

```

**Salida:**

```
CREATE DATABASE
You are now connected to database "biblioteca" as user "postgres".

```

## 2. Creación de Usuarios y Permisos

Creación de los usuarios `admin_biblio`, `usuario_biblio` y el rol `lectores`. Se aplican las restricciones para garantizar que `usuario_biblio` solo tenga acceso de lectura y no pueda eliminar ni modificar registros.

```
-- Creación de usuarios
CREATE USER admin_biblio WITH PASSWORD 'AdminPass123!';
CREATE USER usuario_biblio WITH PASSWORD 'UserPass123!';

-- Asignar permisos de administrador sobre la base de datos
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;

-- Crear el rol de solo lectura
CREATE ROLE lectores;
GRANT CONNECT ON DATABASE biblioteca TO lectores;
GRANT USAGE ON SCHEMA public TO lectores;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- Asegurar permisos de lectura en futuras tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO lectores;

-- Asignar el rol al usuario
GRANT lectores TO usuario_biblio;

-- Consultar los usuarios y roles creados
SELECT rolname, rolsuper, rolcreaterole, rolcanlogin 
FROM pg_roles 
WHERE rolname IN ('admin_biblio', 'usuario_biblio', 'lectores');

```

**Salida:**

| 

| **rolname** | **rolsuper** | **rolcreaterole** | **rolcanlogin** | 
| admin_biblio | f | f | t | 
| usuario_biblio | f | f | t | 
| lectores | f | f | f | 

```
-- Cambiar la contraseña del usuario usuario_biblio
ALTER USER usuario_biblio WITH PASSWORD 'NuevaPassword456!';

-- Garantizar que usuario_biblio no pueda eliminar o modificar datos
REVOKE DELETE, UPDATE, INSERT ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE DELETE, UPDATE, INSERT ON ALL TABLES IN SCHEMA public FROM usuario_biblio;

```

**Salida:**

```
ALTER ROLE
REVOKE
REVOKE

```

## 3. Creación de Tablas

Definición del esquema relacional con sus respectivas claves primarias y foráneas.

```
-- Tabla autores
CREATE TABLE autores (
    id_autor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50) NOT NULL
);

-- Tabla libros
CREATE TABLE libros (
    id_libro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    año_publicacion INT CHECK (año_publicacion > 0),
    id_autor INT NOT NULL,
    CONSTRAINT fk_autor FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE
);

-- Tabla prestamos
CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    id_libro INT NOT NULL,
    fecha_prestamo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion DATE,
    usuario_prestatario VARCHAR(100) NOT NULL,
    CONSTRAINT fk_libro FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE
);

```

**Salida:**

```
CREATE TABLE
CREATE TABLE
CREATE TABLE

```

## 4. Inserción de Datos

Inserción de datos iniciales en la base de datos (5 autores, 8 libros y 5 préstamos).

```
-- Autores
INSERT INTO autores (nombre, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombiana'),
('Isabel Allende', 'Chilena'),
('Jorge Luis Borges', 'Argentina'),
('Mario Vargas Llosa', 'Peruana'),
('Julio Cortázar', 'Argentina');

-- Libros
INSERT INTO libros (titulo, año_publicacion, id_autor) VALUES
('Cien años de soledad', 1967, 1),
('El amor en los tiempos del cólera', 1985, 1),
('La casa de los espíritus', 1982, 2),
('Ficciones', 1944, 3),
('El Aleph', 1949, 3),
('La ciudad y los perros', 1963, 4),
('Rayuela', 1963, 5),
('Bestiario', 1951, 5);

-- Préstamos
INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES
(1, '2026-01-10', '2026-01-20', 'Carlos Pérez'),
(1, '2026-02-01', NULL, 'Ana Gómez'),
(3, '2026-02-15', '2026-02-25', 'Carlos Pérez'),
(4, '2026-03-01', NULL, 'María López'),
(7, '2026-03-05', NULL, 'Ana Gómez');

```

**Salida:**

```
INSERT 0 5
INSERT 0 8
INSERT 0 5

```

## 5. Consultas Básicas

### 5.1. Listar todos los libros con su autor correspondiente

```
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor
FROM libros l
JOIN autores a ON l.id_autor = a.id_autor;

```

**Salida:**

| **id_libro** | **titulo** | **año_publicacion** | **autor** | 
| 1 | Cien años de soledad | 1967 | Gabriel García Márquez | 
| 2 | El amor en los tiempos del cólera | 1985 | Gabriel García Márquez | 
| 3 | La casa de los espíritus | 1982 | Isabel Allende | 
| 4 | Ficciones | 1944 | Jorge Luis Borges | 
| 5 | El Aleph | 1949 | Jorge Luis Borges | 
| 6 | La ciudad y los perros | 1963 | Mario Vargas Llosa | 
| 7 | Rayuela | 1963 | Julio Cortázar | 
| 8 | Bestiario | 1951 | Julio Cortázar | 

### 5.2. Mostrar préstamos sin fecha de devolución pendiente

```
SELECT id_prestamo, id_libro, fecha_prestamo, usuario_prestatario 
FROM prestamos 
WHERE fecha_devolucion IS NULL;

```

**Salida:**

| **id_prestamo** | **id_libro** | **fecha_prestamo** | **usuario_prestatario** | 
| 2 | 1 | 2026-02-01 | Ana Gómez | 
| 4 | 4 | 2026-03-01 | María López | 
| 5 | 7 | 2026-03-05 | Ana Gómez | 

### 5.3. Obtener autores con más de un libro registrado

```
SELECT a.nombre, COUNT(l.id_libro) AS total_libros
FROM autores a
JOIN libros l ON a.id_autor = l.id_autor
GROUP BY a.id_autor, a.nombre
HAVING COUNT(l.id_libro) > 1;

```

**Salida:**

| **nombre** | **total_libros** | 
| Gabriel García Márquez | 2 | 
| Jorge Luis Borges | 2 | 
| Julio Cortázar | 2 | 

## 6. Consultas con Agregación

### 6.1. Número total de préstamos realizados

```
SELECT COUNT(*) AS total_prestamos 
FROM prestamos;

```

**Salida:**

| **total_prestamos** | 
| 5 | 

### 6.2. Número de libros prestados por cada usuario

```
SELECT usuario_prestatario, COUNT(*) AS libros_prestados
FROM prestamos
GROUP BY usuario_prestatario;

```

**Salida:**

| **usuario_prestatario** | **libros_prestados** | 
| Carlos Pérez | 2 | 
| Ana Gómez | 2 | 
| María López | 1 | 

## 7. Modificación de Datos y Cascada

### 7.1. Actualizar fecha de devolución de un préstamo pendiente

```
UPDATE prestamos 
SET fecha_devolucion = '2026-03-10' 
WHERE id_prestamo = 2;

```

**Salida:**

```
UPDATE 1

```

### 7.2. Eliminar un libro y comprobar efecto en cascada

> **Justificación del comportamiento:** La restricción `FOREIGN KEY` en la tabla `prestamos` fue definida con la cláusula `ON DELETE CASCADE`. Esto significa que al eliminar un registro en la tabla padre (`libros`), PostgreSQL elimina automáticamente todos los registros asociados en la tabla hija (`prestamos`).

```
-- Eliminar el libro con id_libro = 1 (Cien años de soledad)
DELETE FROM libros WHERE id_libro = 1;

-- Comprobar eliminación en prestamos
SELECT * FROM prestamos WHERE id_libro = 1;

```

**Salida:**

```
DELETE 1

```

| **id_prestamo** | **id_libro** | **fecha_prestamo** | **fecha_devolucion** | **usuario_prestatario** | 
| *(0 filas)* |  |  |  |  | 

## 8. Creación de Vistas y Permisos

```
-- Crear vista de libros prestados
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo AS libro, a.nombre AS autor, p.usuario_prestatario AS prestatario
FROM prestamos p
JOIN libros l ON p.id_libro = l.id_libro
JOIN autores a ON l.id_autor = a.id_autor;

-- Otorgar permisos de consulta únicamente a usuario_biblio
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;

-- Consultar la vista
SELECT * FROM vista_libros_prestados;

```

**Salida:**

| **libro** | **autor** | **prestatario** | 
| La casa de los espíritus | Isabel Allende | Carlos Pérez | 
| Ficciones | Jorge Luis Borges | María López | 
| Rayuela | Julio Cortázar | Ana Gómez | 

## 9. Funciones y Consultas Avanzadas

### 9.1. Función para obtener libros por autor

```
CREATE OR REPLACE FUNCTION obtener_libros_autor(p_nombre_autor VARCHAR)
RETURNS TABLE(id_libro INT, titulo VARCHAR, año_publicacion INT) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_libro, l.titulo, l.año_publicacion
    FROM libros l
    JOIN autores a ON l.id_autor = a.id_autor
    WHERE a.nombre ILIKE '%' || p_nombre_autor || '%';
END;
$$ LANGUAGE plpgsql;

-- Ejecutar función
SELECT * FROM obtener_libros_autor('Jorge Luis Borges');

```

**Salida:**

| **id_libro** | **titulo** | **año_publicacion** | 
| 4 | Ficciones | 1944 | 
| 5 | El Aleph | 1949 | 

### 9.2. Consulta de los 3 libros más prestados

```
SELECT l.titulo, COUNT(p.id_prestamo) AS cantidad_prestamos
FROM libros l
LEFT JOIN prestamos p ON l.id_libro = p.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY cantidad_prestamos DESC, l.titulo ASC
LIMIT 3;

```

**Salida:**

| **titulo** | **cantidad_prestamos** | 
| Ficciones | 1 | 
| La casa de los espíritus | 1 | 
| Rayuela | 1 | 

## 10. Exportación e Importación de Datos

```
-- Exportar tabla libros a un archivo CSV
COPY libros TO '/tmp/libros_exportados.csv' WITH (FORMAT csv, HEADER, DELIMITER ',');

```

**Salida:**

```
COPY 7

```

```
-- Importar nuevos autores desde un archivo CSV
COPY autores(nombre, nacionalidad) 
FROM '/tmp/nuevos_autores.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',');

```

**Salida:**

```
COPY 2

```

## Estructura sugerida para el Repositorio de GitHub

```
.
├── README.md               # Documentación y ejecuciones completas (este archivo)
├── script.sql              # Script SQL ejecutable completo
└── data/
    ├── libros_exportados.csv # CSV exportado
    └── nuevos_autores.csv    # CSV para importación de prueba

```
