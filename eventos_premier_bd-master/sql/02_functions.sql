-- =====================================================================
-- Proyecto : Eventos Premier S.A.S.
-- Script   : 02_functions.sql
-- Descripción: Funciones personalizadas (CREATE FUNCTION)
-- =====================================================================

USE eventos_premier;


-- ---------------------------------------------------------------------
-- Función 1: calcular_total_reserva
-- Calcula el valor total de una reserva a partir del precio por hora
-- y el número de horas, incluyendo el 19% de IVA.
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS calcular_total_reserva;

CREATE FUNCTION calcular_total_reserva(
    p_precio_hora DECIMAL(10,2),
    p_horas       DECIMAL(6,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal DECIMAL(12,2);
    DECLARE v_total    DECIMAL(12,2);

    SET v_subtotal = p_precio_hora * p_horas;
    SET v_total    = v_subtotal * 1.19;

    RETURN v_total;
END;

-- ---------------------------------------------------------------------
-- Función 2: verificar_disponibilidad
-- Retorna 1 si el salón está disponible en el rango de fechas dado
-- (es decir, no tiene ninguna reserva confirmada que se cruce con
-- ese rango), o 0 si está ocupado.
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS verificar_disponibilidad;

CREATE FUNCTION verificar_disponibilidad(
    p_id_salon      INT,
    p_fecha_inicio  DATETIME,
    p_fecha_fin     DATETIME
)
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cruces INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cruces
    FROM reservas
    WHERE id_salon = p_id_salon
      AND estado = 'Confirmada'
      AND p_fecha_inicio < fecha_fin
      AND p_fecha_fin    > fecha_inicio;

    IF v_cruces > 0 THEN
        RETURN 0;  -- Ocupado
    ELSE
        RETURN 1;  -- Disponible
    END IF;
END;


-- ---------------------------------------------------------------------
-- Ejemplos de uso
-- ---------------------------------------------------------------------
 SELECT calcular_total_reserva(150000, 4);
-- -- Resultado esperado: 714000.00  (150000 * 4 * 1.19)

SELECT verificar_disponibilidad(1, '2026-03-10 09:00:00', '2026-03-10 11:00:00');
-- -- Resultado esperado: 0 (ya existe una reserva de 08:00 a 12:00 ese día)

SELECT verificar_disponibilidad(1, '2026-06-01 09:00:00', '2026-06-01 11:00:00');
-- -- Resultado esperado: 1 (no hay cruces de horario)