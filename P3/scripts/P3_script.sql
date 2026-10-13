-- ============================================================================
-- SCRIPT DE CREACIÓN E INSERCIÓN PARA LA BASE DE DATOS "VIVEROS"
-- Asignatura: Administración y Diseño de Bases de Datos
-- Titulación: Grado en Ingeniería Informática (ULL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CREACIÓN DE LA BASE DE DATOS Y LIMPIEZA PREVIA
-- ----------------------------------------------------------------------------
-- (Ejecutar por separado si se está en un cliente SQL):
-- CREATE DATABASE viveros;
-- \c viveros;

DROP TABLE IF EXISTS CONTIENE CASCADE;
DROP TABLE IF EXISTS PEDIDO CASCADE;
DROP TABLE IF EXISTS CLIENTE_PLUS CASCADE;
DROP TABLE IF EXISTS ASIGNACION CASCADE;
DROP TABLE IF EXISTS EMPLEADO CASCADE;
DROP TABLE IF EXISTS TIENE CASCADE;
DROP TABLE IF EXISTS PRODUCTO CASCADE;
DROP TABLE IF EXISTS ZONA CASCADE;
DROP TABLE IF EXISTS VIVERO CASCADE;

-- ----------------------------------------------------------------------------
-- 2. CREACIÓN DE TABLAS Y RESTRICCIONES (CHECK, FOREIGN KEYS, CASCADE/SET NULL)
-- ----------------------------------------------------------------------------

-- Tabla VIVERO
CREATE TABLE VIVERO (
    id_vivero SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(8,6) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
    longitud NUMERIC(9,6) NOT NULL CHECK (longitud BETWEEN -180 AND 180)
);

-- Tabla ZONA (Relación 1:N con Vivero, clave primaria compuesta)
CREATE TABLE ZONA (
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(8,6) CHECK (latitud BETWEEN -90 AND 90),
    longitud NUMERIC(9,6) CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT pk_zona PRIMARY KEY (id_vivero, id_zona),
    CONSTRAINT fk_zona_vivero FOREIGN KEY (id_vivero) 
        REFERENCES VIVERO(id_vivero) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla PRODUCTO
CREATE TABLE PRODUCTO (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0)
);

-- Tabla TIENE (Relación N:M entre Zona y Producto)
CREATE TABLE TIENE (
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    id_producto INT NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT pk_tiene PRIMARY KEY (id_vivero, id_zona, id_producto),
    CONSTRAINT fk_tiene_zona FOREIGN KEY (id_vivero, id_zona) 
        REFERENCES ZONA(id_vivero, id_zona) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tiene_producto FOREIGN KEY (id_producto) 
        REFERENCES PRODUCTO(id_producto) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla EMPLEADO
CREATE TABLE EMPLEADO (
    id_empleado SERIAL PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL CHECK (dni ~ '^[0-9]{8}[A-Z]$'),
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL
);

-- Tabla ASIGNACION (Relación N:M entre Zona y Empleado con histórico de fechas)
CREATE TABLE ASIGNACION (
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_inicial DATE NOT NULL,
    fecha_final DATE,
    productividad NUMERIC(5,2) CHECK (productividad BETWEEN 0 AND 100),
    CONSTRAINT pk_asignacion PRIMARY KEY (id_vivero, id_zona, id_empleado, fecha_inicial),
    CONSTRAINT chk_fechas CHECK (fecha_final IS NULL OR fecha_final >= fecha_inicial),
    CONSTRAINT fk_asig_zona FOREIGN KEY (id_vivero, id_zona) 
        REFERENCES ZONA(id_vivero, id_zona) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_asig_empleado FOREIGN KEY (id_empleado) 
        REFERENCES EMPLEADO(id_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla CLIENTE_PLUS
CREATE TABLE CLIENTE_PLUS (
    id_cliente SERIAL PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL CHECK (dni ~ '^[0-9]{8}[A-Z]$'),
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabla PEDIDO (Relación 1:N con Empleado y Cliente_Plus)
CREATE TABLE PEDIDO (
    id_pedido SERIAL PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto_total NUMERIC(10,2) DEFAULT 0.00 CHECK (monto_total >= 0),
    id_empleado INT,
    id_cliente INT NOT NULL,
    CONSTRAINT fk_pedido_empleado FOREIGN KEY (id_empleado) 
        REFERENCES EMPLEADO(id_empleado) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) 
        REFERENCES CLIENTE_PLUS(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabla CONTIENE (Detalle de líneas del Pedido con Producto)
CREATE TABLE CONTIENE (
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    CONSTRAINT pk_contiene PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT fk_contiene_pedido FOREIGN KEY (id_pedido) 
        REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contiene_producto FOREIGN KEY (id_producto) 
        REFERENCES PRODUCTO(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 3. TRATAMIENTO DE ATRIBUTOS DERIVADOS (VISTA CLIENTE_PLUS)
-- ----------------------------------------------------------------------------
-- En el Modelo E/R existen los atributos derivados "volumen_compras_mensual" y
-- "bonificaciones" en CLIENTE_PLUS. Los implementamos mediante una VISTA.

CREATE OR REPLACE VIEW VISTA_CLIENTE_PLUS_METRICAS AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.apellidos,
    c.email,
    COALESCE(SUM(p.monto_total), 0) AS volumen_compras_mensual,
    CASE 
        WHEN COALESCE(SUM(p.monto_total), 0) >= 500 THEN '20% Descuento + Envío Gratis'
        WHEN COALESCE(SUM(p.monto_total), 0) >= 200 THEN '10% Descuento'
        WHEN COALESCE(SUM(p.monto_total), 0) >= 50  THEN '5% Descuento'
        ELSE 'Sin bonificación'
    END AS bonificaciones
FROM CLIENTE_PLUS c
LEFT JOIN PEDIDO p ON c.id_cliente = p.id_cliente 
    AND p.fecha >= (CURRENT_DATE - INTERVAL '30 days')
GROUP BY c.id_cliente, c.nombre, c.apellidos, c.email;

-- ----------------------------------------------------------------------------
-- 4. INSERCIÓN DE DATOS (MÍNIMO 5 FILAS POR TABLA)
-- ----------------------------------------------------------------------------

-- Inserciones en VIVERO
INSERT INTO VIVERO (nombre, latitud, longitud) VALUES
('Vivero La Laguna', 28.487100, -16.315900),
('Vivero Anaga', 28.530000, -16.180000),
('Vivero Teide', 28.272000, -16.642000),
('Vivero Sur Granadilla', 28.118000, -16.578000),
('Vivero Orotava', 28.390000, -16.520000);

-- Inserciones en ZONA
INSERT INTO ZONA (id_vivero, id_zona, nombre, latitud, longitud) VALUES
(1, 1, 'Zona Exterior Plantas Tropicales', 28.487110, -16.315910),
(1, 2, 'Invernadero Cactáceas', 28.487120, -16.315920),
(2, 1, 'Zona Flora Autóctona', 28.530010, -16.180010),
(3, 1, 'Zona Semillas y Herramientas', 28.272010, -16.642010),
(4, 1, 'Invernadero Flores Frutales', 28.118010, -16.578010);

-- Inserciones en PRODUCTO
INSERT INTO PRODUCTO (nombre, tipo, precio) VALUES
('Palmera Canaria', 'Planta', 45.50),
('Cactus Asiento de Suegra', 'Planta', 12.00),
('Sustrato Universal 20L', 'Tierra/Abono', 8.50),
('Regadera Plástico 5L', 'Herramienta', 6.00),
('Rosal Rojo', 'Planta', 15.99);

-- Inserciones en TIENE
INSERT INTO TIENE (id_vivero, id_zona, id_producto, stock) VALUES
(1, 1, 1, 30),
(1, 2, 2, 100),
(3, 1, 3, 50),
(3, 1, 4, 15),
(4, 1, 5, 40);

-- Inserciones en EMPLEADO
INSERT INTO EMPLEADO (dni, nombre, apellidos, telefono) VALUES
('12345678A', 'Juan', 'Pérez Gómez', '600111222'),
('23456789B', 'María', 'López García', '600333444'),
('34567890C', 'Carlos', 'Rodríguez Hernández', '600555666'),
('45678901D', 'Ana', 'Martínez Ruiz', '600777888'),
('56789012E', 'Pedro', 'Sánchez Díaz', '600999000');

-- Inserciones en ASIGNACION
INSERT INTO ASIGNACION (id_vivero, id_zona, id_empleado, fecha_inicial, fecha_final, productividad) VALUES
(1, 1, 1, '2025-01-01', '2025-06-30', 88.50),
(1, 2, 2, '2025-01-01', NULL, 92.00),
(2, 1, 3, '2025-02-15', NULL, 75.00),
(3, 1, 4, '2025-03-01', '2025-08-31', 95.50),
(4, 1, 5, '2025-05-01', NULL, 81.00);

-- Inserciones en CLIENTE_PLUS
INSERT INTO CLIENTE_PLUS (dni, nombre, apellidos, email, fecha_ingreso) VALUES
('11111111H', 'Laura', 'García Fernández', 'laura.garcia@email.com', '2024-01-10'),
('22222222J', 'David', 'Torres Morales', 'david.torres@email.com', '2024-03-15'),
('33333333K', 'Elena', 'Navarro Castro', 'elena.navarro@email.com', '2024-05-20'),
('44444444L', 'Javier', 'Romero Gil', 'javier.romero@email.com', '2024-07-01'),
('55555555M', 'Carmen', 'Vázquez Ortiz', 'carmen.vazquez@email.com', '2024-09-12');

-- Inserciones en PEDIDO
INSERT INTO PEDIDO (fecha, monto_total, id_empleado, id_cliente) VALUES
('2026-10-01 10:30:00', 91.00, 1, 1),
('2026-10-05 11:15:00', 24.00, 2, 2),
('2026-10-08 16:45:00', 25.50, 3, 3),
('2026-10-10 09:20:00', 60.00, 1, 4),
('2026-10-12 18:00:00', 31.98, 4, 5);

-- Inserciones en CONTIENE
INSERT INTO CONTIENE (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 45.50), -- 2 Palmeras Canarias (91.00)
(2, 2, 2, 12.00), -- 2 Cactus (24.00)
(3, 3, 3, 8.50),  -- 3 Sustratos (25.50)
(4, 4, 10, 6.00), -- 10 Regaderas (60.00)
(5, 5, 2, 15.99); -- 2 Rosales (31.98)

-- ----------------------------------------------------------------------------
-- 5. CASOS PRÁCTICOS DE OPERACIONES DELETE (DEMOSTRACIÓN DE RESTRICCIONES)
-- ----------------------------------------------------------------------------

-- Ejemplo 1: DELETE CASCADE en ZONA / TIENE / ASIGNACION al borrar un VIVERO.
-- Al eliminar el Vivero 5, se borran automáticamente sus zonas asociadas.
DELETE FROM VIVERO WHERE id_vivero = 5;

-- Ejemplo 2: DELETE SET NULL en PEDIDO al borrar un EMPLEADO.
-- Al borrar al empleado 5, sus pedidos gestionados mantendrán el registro pero con id_empleado = NULL.
DELETE FROM EMPLEADO WHERE id_empleado = 5;

-- Ejemplo 3: DELETE CASCADE en CONTIENE al borrar un PEDIDO.
-- Eliminar el pedido 5 borra automáticamente sus líneas asociadas en CONTIENE.
DELETE FROM PEDIDO WHERE id_pedido = 5;

-- Ejemplo 4: DELETE RESTRICT al intentar borrar un CLIENTE_PLUS con pedidos.
-- La siguiente consulta fallará intencionadamente si el cliente tiene pedidos activos, protegiendo la integridad:
-- DELETE FROM CLIENTE_PLUS WHERE id_cliente = 1;

-- ----------------------------------------------------------------------------
-- 6. CONSULTAS SELECT PARA VERIFICACIÓN
-- ----------------------------------------------------------------------------
SELECT * FROM VIVERO;
SELECT * FROM ZONA;
SELECT * FROM PRODUCTO;
SELECT * FROM TIENE;
SELECT * FROM EMPLEADO;
SELECT * FROM ASIGNACION;
SELECT * FROM CLIENTE_PLUS;
SELECT * FROM PEDIDO;
SELECT * FROM CONTIENE;
SELECT * FROM VISTA_CLIENTE_PLUS_METRICAS;
