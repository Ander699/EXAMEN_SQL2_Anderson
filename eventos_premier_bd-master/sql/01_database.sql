-- =====================================================================
-- Proyecto : Eventos Premier S.A.S.
-- Script   : 01_database.sql
-- Autor    : [Tu nombre aquí]
-- Descripción: Creación de la base de datos, tablas, relaciones,
--              llaves foráneas y datos de ejemplo para el sistema
--              de gestión de reservas de salones.
-- =====================================================================

DROP DATABASE IF EXISTS eventos_premier;
CREATE DATABASE eventos_premier

USE eventos_premier;

-- ---------------------------------------------------------------------
-- Tabla: salones
-- ---------------------------------------------------------------------
CREATE TABLE salones (
    id_salon        INT AUTO_INCREMENT PRIMARY KEY,
    nombre_salon    VARCHAR(100)    NOT NULL,
    capacidad       INT             NOT NULL CHECK (capacidad > 0),
    precio_hora     DECIMAL(10,2)   NOT NULL CHECK (precio_hora >= 0),
    estado          ENUM('Disponible', 'Ocupado', 'En mantenimiento') NOT NULL DEFAULT 'Disponible',
    encargado       VARCHAR(100)    NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: clientes
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente          INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo     VARCHAR(150)    NOT NULL,
    identificacion      VARCHAR(30)     NOT NULL UNIQUE,
    telefono            VARCHAR(20),
    correo_electronico  VARCHAR(120),
    tipo_cliente        ENUM('Individual', 'Corporativo') NOT NULL DEFAULT 'Individual'
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: reservas
-- ---------------------------------------------------------------------
CREATE TABLE reservas (
    id_reserva      INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente      INT             NOT NULL, 
    id_salon        INT             NOT NULL,
    fecha_inicio    DATETIME        NOT NULL,
    fecha_fin       DATETIME        NOT NULL,
    total_horas     DECIMAL(6,2)    NOT NULL,
    valor_total     DECIMAL(12,2)   NOT NULL DEFAULT 0,
    estado          ENUM('Confirmada', 'Cancelada') NOT NULL DEFAULT 'Confirmada',
    CONSTRAINT fk_reservas_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reservas_salon
        FOREIGN KEY (id_salon) REFERENCES salones(id_salon)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_validas
        CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;    

-- ---------------------------------------------------------------------
-- Tabla: pagos
-- ---------------------------------------------------------------------
CREATE TABLE pagos (
    id_pago         INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva      INT             NOT NULL,
    fecha_pago      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto_pagado    DECIMAL(12,2)   NOT NULL CHECK (monto_pagado > 0),
    metodo_pago     ENUM('Efectivo', 'Tarjeta', 'Transferencia')  NOT NULL,
    CONSTRAINT fk_pagos_reserva
        FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Tabla: auditoria_precios
-- ---------------------------------------------------------------------
CREATE TABLE auditoria_precios (
    id_auditoria    INT AUTO_INCREMENT PRIMARY KEY,
    id_salon        INT             NOT NULL,
        usuario         VARCHAR(100)    NOT NULL,
        fecha_cambio    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
        precio_anterior DECIMAL(10,2)   NOT NULL,
    precio_nuevo    DECIMAL(10,2)   NOT NULL,
    CONSTRAINT fk_auditoria_salon
        FOREIGN KEY (id_salon) REFERENCES salones(id_salon)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Índices adicionales para optimizar consultas frecuentes
-- ---------------------------------------------------------------------    
CREATE INDEX idx_reservas_fechas ON reservas (fecha_inicio, fecha_fin);
CREATE INDEX idx_clientes_tipo ON clientes (tipo_cliente);
CREATE INDEX idx_salones_estado ON salones (estado);

-- =====================================================================
-- Datos de ejemplo
-- =====================================================================
INSERT INTO salones (nombre_salon, capacidad, precio_hora, estado, encargado) VALUES
('Salón Esmeralda',    80,  150000.00, 'Disponible', 'Diana Castro'),
('Salón Zafiro',       150, 220000.00, 'Disponible', 'Miguel Ángel Ruiz'),
('Salón Rubí',         40,  90000.00,  'Disponible', 'Laura Jiménez'),
('Salón Topacio',      200, 300000.00, 'En mantenimiento', 'Carlos Vargas');

INSERT INTO clientes (nombre_completo, identificacion, telefono, correo_electronico, tipo_cliente) VALUES
('Andrea Gómez',           '1091234567', '3001112233', 'andrea.gomez@mail.com',     'Individual'),
('Tech Solutions S.A.S.',  '900112233',  '6076543210', 'contacto@techsolutions.co', 'Corporativo'),
('Eventos Corporativos LTDA', '900998877', '6079988776', 'info@eventoscorp.co',    'Corporativo'),
('Julián Torres',          '1102233445', '3159876543', 'julian.torres@mail.com',    'Individual');

INSERT INTO reservas (id_cliente, id_salon, fecha_inicio, fecha_fin, total_horas, valor_total, estado) VALUES
(2, 1, '2026-03-10 08:00:00', '2026-03-10 12:00:00', 4,  4 * 150000 * 1.19, 'Confirmada'),
(2, 2, '2026-03-15 14:00:00', '2026-03-15 18:00:00', 4,  4 * 220000 * 1.19, 'Confirmada'),
(3, 1, '2026-04-02 09:00:00', '2026-04-02 13:00:00', 4,  4 * 150000 * 1.19, 'Confirmada'),
(3, 3, '2026-04-05 16:00:00', '2026-04-05 19:00:00', 3,  3 * 90000  * 1.19, 'Confirmada'),
(2, 3, '2026-05-01 10:00:00', '2026-05-01 14:00:00', 4,  4 * 90000  * 1.19, 'Confirmada');

INSERT INTO pagos (id_reserva, fecha_pago, monto_pagado, metodo_pago) VALUES
(1, '2026-03-09 10:00:00', 714000.00, 'Transferencia'),
(2, '2026-03-14 11:00:00', 1047200.00, 'Tarjeta'),
(3, '2026-04-01 09:30:00', 714000.00, 'Efectivo');
