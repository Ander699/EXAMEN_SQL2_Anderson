USE eventos_premier;

SELECT 
    c.nombre_completo AS cliente,
    s.nombre_salon    AS salon,
    p.monto_pagado    AS total_pagado
FROM pagos p
JOIN reservas r ON p.id_reserva = r.id_reserva
JOIN clientes c ON r.id_cliente = c.id_cliente
JOIN salones  s ON r.id_salon   = s.id_salon
WHERE p.metodo_pago = 'Transferencia'
ORDER BY p.monto_pagado DESC;

