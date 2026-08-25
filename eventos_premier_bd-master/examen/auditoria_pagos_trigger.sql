USE eventos_premier;

-- CREE TABLA PARA CREAR EL TRIGGER 
CREATE TABLE IF NOT EXISTS auditoria_pagos (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_pago      INT NOT NULL,
    fecha_actual DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario      VARCHAR(100) NOT NULL,
    monto_pagado DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_auditoria_pago
        FOREIGN KEY (id_pago) REFERENCES pagos(id_pago)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;


-- CREE EL TRIGGER
DROP TRIGGER IF EXISTS auditoria_pagos_trigger;

DELIMITER //

CREATE TRIGGER auditoria_pagos_trigger
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_pagos (id_pago, fecha_actual, usuario, monto_pagado)
    VALUES (NEW.id_pago, NOW(), 'admin', NEW.monto_pagado);
END //

DELIMITER ;

SELECT * FROM auditoria_pagos;

INSERT INTO pagos (id_reserva, fecha_pago, monto_pagado, metodo_pago)
VALUES (1, NOW(), 350000.00, 'Transferencia');

SELECT * FROM auditoria_pagos;

SHOW TRIGGERS WHERE `Table` = 'pagos';