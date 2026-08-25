-- =====================================================================
-- Proyecto : Eventos Premier S.A.S.
-- Script   : 04_views_and_queries.sql
-- Descripción: Vistas (CREATE VIEW) y consultas SQL requeridas
-- =====================================================================

USE eventos_premier;

-- =====================================================================
-- VISTA: vista_resumen_reservas
-- Nombre del cliente, nombre del salón, fecha de inicio, fecha fin,
-- total y estado de cada reserva.
-- =====================================================================
DROP VIEW IF EXISTS vista_resumen_reservas;

CREATE VIEW vista_resumen_reservas AS
SELECT
    r.id_reserva,
    c.nombre_completo   AS cliente,
    s.nombre_salon       AS salon,
    r.fecha_inicio,
    r.fecha_fin,
    r.valor_total        AS total,
    r.estado
FROM reservas r
JOIN clientes c ON c.id_cliente = r.id_cliente
JOIN salones  s ON s.id_salon   = r.id_salon;


-- =====================================================================
-- CONSULTAS SQL REQUERIDAS
-- =====================================================================

-- 1) Reservas realizadas en un rango de fechas (BETWEEN)
SELECT
    id_reserva,
    id_cliente,
    id_salon,
    fecha_inicio,
    fecha_fin,
    valor_total
FROM reservas
WHERE fecha_inicio BETWEEN '2026-03-01' AND '2026-04-30';

-- 2) Salones con capacidad mayor a X personas y estado = 'Disponible'
--    (reemplazar 50 por el valor de X deseado)
SELECT
    id_salon,
    nombre_salon,
    capacidad,
    precio_hora,
    estado
FROM salones
WHERE capacidad > 50
  AND estado = 'Disponible';

-- 3) Clientes corporativos con más de 3 reservas (subconsulta + COUNT)
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.tipo_cliente,
    conteo.total_reservas
FROM clientes c
JOIN (
    SELECT id_cliente, COUNT(*) AS total_reservas
    FROM reservas
    GROUP BY id_cliente
    HAVING COUNT(*) > 3
) AS conteo ON conteo.id_cliente = c.id_cliente
WHERE c.tipo_cliente = 'Corporativo';

-- 4) Consulta de la vista vista_resumen_reservas
SELECT * FROM vista_resumen_reservas
ORDER BY fecha_inicio;

-- =====================================================================
-- Consultas adicionales de apoyo (opcional, para reportes)
-- =====================================================================

-- Ingresos totales recaudados por salón
SELECT
    s.nombre_salon,
    IFNULL(SUM(p.monto_pagado), 0) AS total_recaudado
FROM salones s
LEFT JOIN reservas r ON r.id_salon = s.id_salon
LEFT JOIN pagos p    ON p.id_reserva = r.id_reserva
GROUP BY s.id_salon, s.nombre_salon
ORDER BY total_recaudado DESC;

-- Reservas sin pago registrado (control de cartera)
SELECT
    r.id_reserva,
    c.nombre_completo,
    r.valor_total,
    r.estado
FROM reservas r
JOIN clientes c ON c.id_cliente = r.id_cliente
LEFT JOIN pagos p ON p.id_reserva = r.id_reserva
WHERE p.id_pago IS NULL
  AND r.estado = 'Confirmada';
