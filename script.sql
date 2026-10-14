CREATE DATABASE viveros;

DROP TABLE IF EXISTS contiene CASCADE;
DROP TABLE IF EXISTS pedido CASCADE;
DROP TABLE IF EXISTS pertenece_historico CASCADE;
DROP TABLE IF EXISTS dispone CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS tarea CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS zona CASCADE;
DROP TABLE IF EXISTS vivero CASCADE;

CREATE TABLE vivero (
    id_vivero SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    latitud NUMERIC(8, 6) NOT NULL,
    longitud NUMERIC(9, 6) NOT NULL,
    CONSTRAINT chk_vivero_latitud CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT chk_vivero_longitud CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT uq_vivero_coordenadas UNIQUE (latitud, longitud)
);

CREATE TABLE zona (
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(8, 6) NOT NULL,
    longitud NUMERIC(9, 6) NOT NULL,
    PRIMARY KEY (id_vivero, id_zona),
    CONSTRAINT fk_zona_vivero FOREIGN KEY (id_vivero)
        REFERENCES vivero (id_vivero)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_zona_latitud CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT chk_zona_longitud CHECK (longitud BETWEEN -180 AND 180)
);

CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    precio NUMERIC(8, 2) NOT NULL,
    CONSTRAINT chk_producto_tipo CHECK (tipo IN ('Plantas', 'Jardinería', 'Decoración')),
    CONSTRAINT chk_producto_precio CHECK (precio > 0)
);

CREATE TABLE tarea (
    id_tarea SERIAL PRIMARY KEY,
    nombre_tarea VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE empleado (
    dni_empleado VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE
);

CREATE TABLE cliente (
    dni_cliente VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tajinaste_plus BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_ingreso_plus DATE,
    volumen_compras_mensual NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    bonificaciones NUMERIC(10, 2) GENERATED ALWAYS AS (
        CASE 
            WHEN tajinaste_plus = TRUE THEN ROUND(volumen_compras_mensual * 0.05, 2)
            ELSE 0.00
        END
    ) STORED,
    CONSTRAINT chk_volumen_compras CHECK (volumen_compras_mensual >= 0),
    CONSTRAINT chk_coherencia_plus CHECK (
        (tajinaste_plus = TRUE AND fecha_ingreso_plus IS NOT NULL) OR
        (tajinaste_plus = FALSE AND fecha_ingreso_plus IS NULL)
    )
);

CREATE TABLE pedido (
    numero_pedido SERIAL PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    dni_cliente VARCHAR(9) NOT NULL,
    dni_empleado VARCHAR(9) NOT NULL,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (dni_cliente)
        REFERENCES cliente (dni_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_empleado FOREIGN KEY (dni_empleado)
        REFERENCES empleado (dni_empleado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE dispone (
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    id_producto INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_vivero, id_zona, id_producto),
    CONSTRAINT fk_dispone_zona FOREIGN KEY (id_vivero, id_zona)
        REFERENCES zona (id_vivero, id_zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_dispone_producto FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_dispone_stock CHECK (stock >= 0)
);

CREATE TABLE pertenece_historico (
    dni_empleado VARCHAR(9) NOT NULL,
    id_vivero INT NOT NULL,
    id_zona INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_tarea INT NOT NULL,
    PRIMARY KEY (dni_empleado, id_vivero, id_zona, fecha_inicio),
    CONSTRAINT fk_pertenece_empleado FOREIGN KEY (dni_empleado)
        REFERENCES empleado (dni_empleado)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pertenece_zona FOREIGN KEY (id_vivero, id_zona)
        REFERENCES zona (id_vivero, id_zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pertenece_tarea FOREIGN KEY (id_tarea)
        REFERENCES tarea (id_tarea)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_historico CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE TABLE contiene (
    numero_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(8, 2) NOT NULL,
    PRIMARY KEY (numero_pedido, id_producto),
    CONSTRAINT fk_contiene_pedido FOREIGN KEY (numero_pedido)
        REFERENCES pedido (numero_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_contiene_producto FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_contiene_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_contiene_precio CHECK (precio_unitario > 0)
);

INSERT INTO vivero (nombre, latitud, longitud) VALUES
('Vivero La Laguna', 28.487100, -16.316800),
('Vivero La Orotava', 28.390500, -16.523000),
('Vivero Adeje Sur', 28.122700, -16.726000),
('Vivero Santa Cruz', 28.463600, -16.251800),
('Vivero Tegueste', 28.516700, -16.333300);

INSERT INTO zona (id_vivero, id_zona, nombre, latitud, longitud) VALUES
(1, 1, 'Zona Exterior', 28.487200, -16.316900),
(1, 2, 'Almacén Central', 28.487300, -16.317000),
(2, 1, 'Invernadero Subtropical', 28.390600, -16.523100),
(2, 2, 'Exposición Decoración', 28.390700, -16.523200),
(3, 1, 'Zona Cactus y Suculentas', 28.122800, -16.726100),
(4, 1, 'Almacén Logístico', 28.463700, -16.251900);

INSERT INTO producto (nombre, tipo, precio) VALUES
('Tajinaste Rojo', 'Plantas', 18.50),
('Monstera Deliciosa', 'Plantas', 25.00),
('Sustrato Universal 50L', 'Jardinería', 12.00),
('Tijeras de Poda Profesionales', 'Jardinería', 15.75),
('Maceta Cerámica Rústica', 'Decoración', 22.00);

INSERT INTO tarea (nombre_tarea, descripcion) VALUES
('Riego y Mantenimiento', 'Cuidado diario, riego y poda de plantas vivas'),
('Control de Stock', 'Recepción de mercancía e inventario en almacén'),
('Atención y Ventas', 'Asesoramiento a clientes y gestión de pedidos'),
('Aclimatación Invernadero', 'Control de humedad y temperatura de especies'),
('Decoración deExpositores', 'Montaje visual de artículos de decoración');

INSERT INTO empleado (dni_empleado, nombre, email) VALUES
('11111111A', 'Carlos Mendoza', 'carlos@tajinaste.es'),
('22222222B', 'Laura Rodríguez', 'laura@tajinaste.es'),
('33333333C', 'Miguel Ángel Pérez', 'miguel@tajinaste.es'),
('44444444D', 'Sofía Hernández', 'sofia@tajinaste.es'),
('55555555E', 'David González', 'david@tajinaste.es');

INSERT INTO cliente (dni_cliente, nombre, tajinaste_plus, fecha_ingreso_plus, volumen_compras_mensual) VALUES
('12345678A', 'Ana Belén Torres', TRUE, '2025-01-15', 300.00),
('23456789B', 'Jorge Luis Borges', TRUE, '2025-06-01', 150.00),
('34567890C', 'Elena Martín', FALSE, NULL, 80.00),
('45678901D', 'Roberto Carlos Gil', TRUE, '2026-02-10', 520.00),
('56789012E', 'Lucía Méndez', FALSE, NULL, 45.00);

INSERT INTO dispone (id_vivero, id_zona, id_producto, stock) VALUES
(1, 1, 1, 40),
(1, 2, 3, 120),
(2, 1, 2, 35),
(2, 2, 5, 50),
(3, 1, 1, 25),
(4, 1, 4, 80);

INSERT INTO pertenece_historico (dni_empleado, id_vivero, id_zona, fecha_inicio, fecha_fin, id_tarea) VALUES
('11111111A', 1, 1, '2025-01-01', '2025-06-30', 1), -- Destino pasado de Carlos
('11111111A', 2, 1, '2025-07-01', NULL, 4),         -- Destino actual de Carlos
('22222222B', 1, 2, '2025-03-01', NULL, 2),         -- Destino actual de Laura
('33333333C', 2, 2, '2025-02-15', NULL, 3),         -- Destino actual de Miguel
('44444444D', 3, 1, '2025-05-01', NULL, 1),         -- Destino actual de Sofía
('55555555E', 4, 1, '2025-08-01', NULL, 2);         -- Destino actual de David

INSERT INTO pedido (fecha, dni_cliente, dni_empleado) VALUES
('2026-09-10', '12345678A', '11111111A'),
('2026-09-12', '23456789B', '22222222B'),
('2026-09-15', '34567890C', '33333333C'),
('2026-10-01', '45678901D', '11111111A'),
('2026-10-05', '12345678A', '44444444D');

INSERT INTO contiene (numero_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 18.50),
(1, 3, 1, 12.00),
(2, 2, 3, 25.00),
(3, 4, 2, 15.75),
(4, 5, 4, 22.00),
(5, 1, 5, 18.50);

DELETE FROM vivero WHERE id_vivero = 4;

DELETE FROM cliente WHERE dni_cliente = '34567890C';