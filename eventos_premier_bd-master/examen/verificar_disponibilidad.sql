USE eventos_premier;

DELIMITER //

DROP FUNCTION IF EXISTS verificar_disponibilidad //

CREATE FUNCTION verificar_disponibilidad(
    p_salon_id     INT,
    p_fecha_inicio DATETIME,
    p_fecha_fin    DATETIME
)
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    IF EXISTS (
        SELECT 1
        FROM reservas
        WHERE id_salon = p_salon_id
            AND estado = 'Confirmada'
            AND p_fecha_inicio < fecha_fin
            AND p_fecha_fin    > fecha_inicio
    ) THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END //
DELIMITER ;

SELECT verificar_disponibilidad(1, '2026-03-10 09:00:00', '2026-03-10 11:00:00') AS esta_disponible;
SELECT verificar_disponibilidad(1, '2026-06-01 09:00:00', '2026-06-01 11:00:00') AS esta_disponible;
