USE eventos_premier;

DROP VIEW IF EXISTS vista_resumen_pagos;

CREATE VIEW vista_resumen_pagos AS
SELECT 
    c.nombre_completo AS cliente,
    s.nombre_salon    AS salon,
    p.metodo_pago,
    p.fecha_pago,
    p.monto_pagado
FROM pagos p
JOIN reservas r ON p.id_reserva = r.id_reserva
JOIN clientes c ON r.id_cliente = c.id_cliente
JOIN salones  s ON r.id_salon   = s.id_salon;

SELECT * FROM vista_resumen_pagos;