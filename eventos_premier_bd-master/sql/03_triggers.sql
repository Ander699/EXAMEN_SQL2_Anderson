-- =====================================================================
-- Proyecto : Eventos Premier S.A.S.
-- Script   : 03_triggers.sql
-- Descripción: Triggers de control de estado y auditoría (CREATE TRIGGER)
-- =====================================================================

USE eventos_premier;
-- ---------------------------------------------------------------------
-- Trigger 1: actualizar_estado_salon_trigger
-- Al registrar una nueva reserva confirmada, el salón cambia su
-- estado a 'Ocupado'.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS actualizar_estado_salon_trigger;

CREATE TRIGGER actualizar_estado_salon_trigger
AFTER INSERT ON reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Confirmada' THEN
        UPDATE salones
        SET estado = 'Ocupado'
        WHERE id_salon = NEW.id_salon
          AND estado = 'Disponible';
    END IF;
END;

-- ---------------------------------------------------------------------
-- Trigger 2: liberar_salon_trigger
-- Al eliminar una reserva, el salón vuelve a estado 'Disponible'
-- (siempre que no tenga otras reservas confirmadas activas).
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS liberar_salon_trigger;

CREATE TRIGGER liberar_salon_trigger
AFTER DELETE ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_reservas_activas INT DEFAULT 0;

    SELECT COUNT(*) INTO v_reservas_activas
    FROM reservas
    WHERE id_salon = OLD.id_salon
      AND estado = 'Confirmada';

    IF v_reservas_activas = 0 THEN
        UPDATE salones
        SET estado = 'Disponible'
        WHERE id_salon = OLD.id_salon
          AND estado = 'Ocupado';
    END IF;
END;

-- ---------------------------------------------------------------------
-- Trigger 3: auditoria_precios_trigger
-- Cuando se actualiza el precio_hora de un salón, registra el
-- cambio (usuario, fecha, precio anterior y nuevo) en la tabla
-- auditoria_precios.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS auditoria_precios_trigger;

CREATE TRIGGER auditoria_precios_trigger
AFTER UPDATE ON salones
FOR EACH ROW
BEGIN
    IF OLD.precio_hora <> NEW.precio_hora THEN
        INSERT INTO auditoria_precios (id_salon, usuario, fecha_cambio, precio_anterior, precio_nuevo)
        VALUES (OLD.id_salon, CURRENT_USER(), NOW(), OLD.precio_hora, NEW.precio_hora);
    END IF;
END;

-- =====================================================================
-- Pruebas sugeridas
-- =====================================================================

-- 1) Probar actualizar_estado_salon_trigger
INSERT INTO reservas (id_cliente, id_salon, fecha_inicio, fecha_fin, total_horas, valor_total, estado)
VALUES (1, 3, '2026-07-01 09:00:00', '2026-07-01 12:00:00', 3, calcular_total_reserva(90000, 3), 'Confirmada');
SELECT estado FROM salones WHERE id_salon = 3;   -- Debe mostrar 'Ocupado'

-- 2) Probar liberar_salon_trigger
DELETE FROM reservas WHERE id_salon = 3 AND fecha_inicio = '2026-07-01 09:00:00';
SELECT estado FROM salones WHERE id_salon = 3;   -- Debe volver a 'Disponible' si no hay otras reservas

-- 3) Probar auditoria_precios_trigger
UPDATE salones SET precio_hora = 160000.00 WHERE id_salon = 1;
SELECT * FROM auditoria_precios;
