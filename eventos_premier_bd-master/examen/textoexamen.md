
# Examen 
Eres parte del equipo de desarrollo de Eventos Premier S.A.S., y te asignaron optimizar el control de reservas y pagos.

Debes implementar nuevas funciones y consultas que permitan verificar disponibilidad, generar reportes y mantener consistencia en la base de datos.

Tareas a desarrollar
1. Crear una función llamada verificar_disponibilidad

La función debe recibir como parámetros:
salon_id INT
fecha_inicio DATETIME
fecha_fin DATETIME
Debe retornar:
1 si el salón no tiene reservas en ese rango de fechas (disponible).
0 si el salón ya está reservado en ese rango
Pista: Usa una subconsulta o EXISTS para verificar si existe una reserva que se cruce en fechas.
2. Crear una consulta que muestre:
El nombre del cliente, el nombre del salón y el total pagado,
Solo de las reservas con pagos realizados mediante “Transferencia”,
Ordenadas de mayor a menor monto pagado.
3. Crear una vista llamada vista_resumen_pagos

Debe mostrar:
Nombre del cliente
Nombre del salón
Método de pago
Fecha del pago
Monto pagado
Debe construirse con JOIN entre las tablas pagos, reservas, clientes y salones.
4. Crear un trigger llamado auditoria_pagos_trigger

Debe activarse después de insertar un nuevo pago (AFTER INSERT en pagos).
Insertará un registro en una tabla llamada auditoria_pagos con:
ID del pago
Fecha actual
Usuario responsable (puedes usar un campo fijo, por ejemplo 'admin')
Valor pagado


Resultado esperado

Entregables:
Script SQL con la función verificar_disponibilidad.
Script SQL con la consulta de pagos por transferencia.
Script SQL para crear la vista vista_resumen_pagos.
Script SQL para crear el trigger auditoria_pagos_trigger.
README corto con instrucciones de prueba y ejemplos de ejecución.

## Guía Rápida de Ejecución y Pruebas SQL

Sistema de Gestión de Reservas

Este documento contiene las instrucciones y consultas de prueba para validar la función de disponibilidad, consultas con filtrado y ordenamiento, vistas agregadas y triggers de auditoría en la base de datos eventos_premier.

## 1. Requisitos y Orden de Ejecución

Ejecuta los scripts SQL en tu cliente de base de datos (MySQL CLI, VS Code o Workbench) siguiendo estrictamente este orden:

SOURCE sql/01_database.sql;

SOURCE sql/02_functions.sql;

SOURCE sql/03_triggers.sql;

SOURCE sql/04_views_and_queries.sql;

## 2. Prueba de la Función verificar_disponibilidad

Verifica si un salón está libre (devuelve 1) u ocupado (devuelve 0) en un rango de fechas determinado.


-- Probar con horario ocupado (esperado: 0)

SELECT verificar_disponibilidad(1, '2026-03-10 09:00:00', '2026-03-10 11:00:00') AS disponible;

-- Probar con horario disponible (esperado: 1)

SELECT verificar_disponibilidad(1, '2026-06-01 09:00:00', '2026-06-01 11:00:00') AS disponible;

## 3. Prueba de Consulta: Pagos por Transferencia

Obtiene el cliente, salón y total pagado para los pagos realizados mediante transferencia, ordenados de mayor a menor.

SELECT
    c.nombre_completo AS cliente,
    s.nombre_salon AS salon,
    p.monto_pagado AS total_pagado
FROM pagos p
JOIN reservas r ON p.id_reserva = r.id_reserva
JOIN clientes c ON r.id_cliente = c.id_cliente
JOIN salones s ON r.id_salon = s.id_salon
WHERE p.metodo_pago = 'Transferencia'
ORDER BY p.monto_pagado DESC;

## 4. Prueba de Vista vista_resumen_pagos

Consulta la vista con el resumen de las transacciones:

SELECT * FROM vista_resumen_pagos;


## 5. Prueba del Trigger auditoria_pagos_trigger

Valida la auditoría automática insertando un nuevo pago y consultando el registro generado.

1. Insertar un pago de prueba

- INSERT INTO pagos (id_reserva, fecha_pago, monto_pagado, metodo_pago)
VALUES (1, NOW(), 450000.00, 'Transferencia');

2. Verificar la auditoría registrada por el trigger

- SELECT *
FROM auditoria_pagos
ORDER BY id_auditoria DESC
LIMIT 1;
