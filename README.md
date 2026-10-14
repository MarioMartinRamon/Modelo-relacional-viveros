# Modelo-relacional-viveros

## Diagrama del Modelo Relacional en DBeaver

![](./imagen.png)

## Diagrama entidad-relación

![](./Diagrama%20sin%20título.drawio.png)

## Select de tablas

#### Ventas completas: Pedido + Cliente + Empleado + Contiene + Producto

```sql
SELECT 
    p.numero_pedido,
    p.fecha AS fecha_pedido,
    c.dni_cliente,
    c.nombre AS nombre_cliente,
    c.tajinaste_plus,
    c.bonificaciones,
    e.nombre AS empleado_responsable,
    pr.nombre AS producto,
    pr.tipo AS categoria_producto,
    co.cantidad,
    co.precio_unitario,
    (co.cantidad * co.precio_unitario) AS importe_linea
FROM pedido p
INNER JOIN cliente c ON p.dni_cliente = c.dni_cliente
INNER JOIN empleado e ON p.dni_empleado = e.dni_empleado
INNER JOIN contiene co ON p.numero_pedido = co.numero_pedido
INNER JOIN producto pr ON co.id_producto = pr.id_producto
ORDER BY p.numero_pedido;
```

```
 numero_pedido | fecha_pedido | dni_cliente |   nombre_cliente   | tajinaste_plus | bonificaciones | empleado_responsable |           producto            | categoria_producto | cantidad | precio_unitario | importe_linea 
---------------+--------------+-------------+--------------------+----------------+----------------+----------------------+-------------------------------+--------------------+----------+-----------------+---------------
             1 | 2026-09-10   | 12345678A   | Ana Belén Torres   | t              |          15.00 | Carlos Mendoza       | Tajinaste Rojo                | Plantas            |        2 |           18.50 |         37.00
             1 | 2026-09-10   | 12345678A   | Ana Belén Torres   | t              |          15.00 | Carlos Mendoza       | Sustrato Universal 50L        | Jardinería         |        1 |           12.00 |         12.00
             2 | 2026-09-12   | 23456789B   | Jorge Luis Borges  | t              |           7.50 | Laura Rodríguez      | Monstera Deliciosa            | Plantas            |        3 |           25.00 |         75.00
             3 | 2026-09-15   | 34567890C   | Elena Martín       | f              |           0.00 | Miguel Ángel Pérez   | Tijeras de Poda Profesionales | Jardinería         |        2 |           15.75 |         31.50
             4 | 2026-10-01   | 45678901D   | Roberto Carlos Gil | t              |          26.00 | Carlos Mendoza       | Maceta Cerámica Rústica       | Decoración         |        4 |           22.00 |         88.00
             5 | 2026-10-05   | 12345678A   | Ana Belén Torres   | t              |          15.00 | Sofía Hernández      | Tajinaste Rojo                | Plantas            |        5 |           18.50 |         92.50
(6 rows)
```

#### Histórico de empleados: Pertenece_historico + Empleado + Vivero + Zona + Tarea

```sql
SELECT 
    e.dni_empleado,
    e.nombre AS empleado,
    v.nombre AS vivero,
    z.nombre AS zona,
    t.nombre_tarea AS tarea_realizada,
    ph.fecha_inicio,
    COALESCE(ph.fecha_fin::TEXT, 'ACTIVO') AS fecha_fin
FROM pertenece_historico ph
INNER JOIN empleado e ON ph.dni_empleado = e.dni_empleado
INNER JOIN zona z ON ph.id_vivero = z.id_vivero AND ph.id_zona = z.id_zona
INNER JOIN vivero v ON z.id_vivero = v.id_vivero
INNER JOIN tarea t ON ph.id_tarea = t.id_tarea
ORDER BY e.nombre, ph.fecha_inicio;
```

```
 dni_empleado |      empleado      |      vivero       |           zona           |     tarea_realizada      | fecha_inicio | fecha_fin  
--------------+--------------------+-------------------+--------------------------+--------------------------+--------------+------------
 11111111A    | Carlos Mendoza     | Vivero La Laguna  | Zona Exterior            | Riego y Mantenimiento    | 2025-01-01   | 2025-06-30
 11111111A    | Carlos Mendoza     | Vivero La Orotava | Invernadero Subtropical  | Aclimatación Invernadero | 2025-07-01   | ACTIVO
 55555555E    | David González     | Vivero Santa Cruz | Almacén Logístico        | Control de Stock         | 2025-08-01   | ACTIVO
 22222222B    | Laura Rodríguez    | Vivero La Laguna  | Almacén Central          | Control de Stock         | 2025-03-01   | ACTIVO
 33333333C    | Miguel Ángel Pérez | Vivero La Orotava | Exposición Decoración    | Atención y Ventas        | 2025-02-15   | ACTIVO
 44444444D    | Sofía Hernández    | Vivero Adeje Sur  | Zona Cactus y Suculentas | Riego y Mantenimiento    | 2025-05-01   | ACTIVO
(6 rows)
```

#### Stock de productos: Dispone + Producto + Vivero + Zona

```sql
SELECT 
    v.nombre AS vivero,
    z.nombre AS zona,
    z.latitud,
    z.longitud,
    pr.nombre AS producto,
    pr.tipo,
    pr.precio,
    d.stock AS unidades_disponibles
FROM dispone d
INNER JOIN zona z ON d.id_vivero = z.id_vivero AND d.id_zona = z.id_zona
INNER JOIN vivero v ON z.id_vivero = v.id_vivero
INNER JOIN producto pr ON d.id_producto = pr.id_producto
ORDER BY v.nombre, z.nombre;
```

```
      vivero       |           zona           |  latitud  |  longitud  |           producto            |    tipo    | precio | unidades_disponibles 
-------------------+--------------------------+-----------+------------+-------------------------------+------------+--------+----------------------
 Vivero Adeje Sur  | Zona Cactus y Suculentas | 28.122800 | -16.726100 | Tajinaste Rojo                | Plantas    |  18.50 |                   25
 Vivero La Laguna  | Almacén Central          | 28.487300 | -16.317000 | Sustrato Universal 50L        | Jardinería |  12.00 |                  120
 Vivero La Laguna  | Zona Exterior            | 28.487200 | -16.316900 | Tajinaste Rojo                | Plantas    |  18.50 |                   40
 Vivero La Orotava | Exposición Decoración    | 28.390700 | -16.523200 | Maceta Cerámica Rústica       | Decoración |  22.00 |                   50
 Vivero La Orotava | Invernadero Subtropical  | 28.390600 | -16.523100 | Monstera Deliciosa            | Plantas    |  25.00 |                   35
 Vivero Santa Cruz | Almacén Logístico        | 28.463700 | -16.251900 | Tijeras de Poda Profesionales | Jardinería |  15.75 |                   80
(6 rows)

```


#### Vivero

```
 id_vivero |      nombre       |  latitud  |  longitud  
-----------+-------------------+-----------+------------
         1 | Vivero La Laguna  | 28.487100 | -16.316800
         2 | Vivero La Orotava | 28.390500 | -16.523000
         3 | Vivero Adeje Sur  | 28.122700 | -16.726000
         4 | Vivero Santa Cruz | 28.463600 | -16.251800
         5 | Vivero Tegueste   | 28.516700 | -16.333300
(5 rows)
```
#### Zona

```
 id_vivero | id_zona |          nombre          |  latitud  |  longitud  
-----------+---------+--------------------------+-----------+------------
         1 |       1 | Zona Exterior            | 28.487200 | -16.316900
         1 |       2 | Almacén Central          | 28.487300 | -16.317000
         2 |       1 | Invernadero Subtropical  | 28.390600 | -16.523100
         2 |       2 | Exposición Decoración    | 28.390700 | -16.523200
         3 |       1 | Zona Cactus y Suculentas | 28.122800 | -16.726100
         4 |       1 | Almacén Logístico        | 28.463700 | -16.251900
(6 rows)
```

#### Producto

```

 id_producto |            nombre             |    tipo    | precio 
-------------+-------------------------------+------------+--------
           1 | Tajinaste Rojo                | Plantas    |  18.50
           2 | Monstera Deliciosa            | Plantas    |  25.00
           3 | Sustrato Universal 50L        | Jardinería |  12.00
           4 | Tijeras de Poda Profesionales | Jardinería |  15.75
           5 | Maceta Cerámica Rústica       | Decoración |  22.00
(5 rows)
```

#### Tarea

```

 id_tarea |       nombre_tarea       |                  descripcion                   
----------+--------------------------+------------------------------------------------
        1 | Riego y Mantenimiento    | Cuidado diario, riego y poda de plantas vivas
        2 | Control de Stock         | Recepción de mercancía e inventario en almacén
        3 | Atención y Ventas        | Asesoramiento a clientes y gestión de pedidos
        4 | Aclimatación Invernadero | Control de humedad y temperatura de especies
        5 | Decoración deExpositores | Montaje visual de artículos de decoración
(5 rows)
```

#### Empleado

```

 dni_empleado |       nombre       |        email        
--------------+--------------------+---------------------
 11111111A    | Carlos Mendoza     | carlos@tajinaste.es
 22222222B    | Laura Rodríguez    | laura@tajinaste.es
 33333333C    | Miguel Ángel Pérez | miguel@tajinaste.es
 44444444D    | Sofía Hernández    | sofia@tajinaste.es
 55555555E    | David González     | david@tajinaste.es
(5 rows)
```

#### Cliente

```

 dni_cliente |       nombre       | tajinaste_plus | fecha_ingreso_plus | volumen_compras_mensual | bonificaciones 
-------------+--------------------+----------------+--------------------+-------------------------+----------------
 12345678A   | Ana Belén Torres   | t              | 2025-01-15         |                  300.00 |          15.00
 23456789B   | Jorge Luis Borges  | t              | 2025-06-01         |                  150.00 |           7.50
 34567890C   | Elena Martín       | f              |                    |                   80.00 |           0.00
 45678901D   | Roberto Carlos Gil | t              | 2026-02-10         |                  520.00 |          26.00
 56789012E   | Lucía Méndez       | f              |                    |                   45.00 |           0.00
(5 rows)
```

#### Dispone

```

 id_vivero | id_zona | id_producto | stock 
-----------+---------+-------------+-------
         1 |       1 |           1 |    40
         1 |       2 |           3 |   120
         2 |       1 |           2 |    35
         2 |       2 |           5 |    50
         3 |       1 |           1 |    25
         4 |       1 |           4 |    80
(6 rows)
```

#### Pertenece_historico

```

 dni_empleado | id_vivero | id_zona | fecha_inicio | fecha_fin  | id_tarea 
--------------+-----------+---------+--------------+------------+----------
 11111111A    |         1 |       1 | 2025-01-01   | 2025-06-30 |        1
 11111111A    |         2 |       1 | 2025-07-01   |            |        4
 22222222B    |         1 |       2 | 2025-03-01   |            |        2
 33333333C    |         2 |       2 | 2025-02-15   |            |        3
 44444444D    |         3 |       1 | 2025-05-01   |            |        1
 55555555E    |         4 |       1 | 2025-08-01   |            |        2
(6 rows)
```

#### Pedido

```

 numero_pedido |   fecha    | dni_cliente | dni_empleado 
---------------+------------+-------------+--------------
             1 | 2026-09-10 | 12345678A   | 11111111A
             2 | 2026-09-12 | 23456789B   | 22222222B
             3 | 2026-09-15 | 34567890C   | 33333333C
             4 | 2026-10-01 | 45678901D   | 11111111A
             5 | 2026-10-05 | 12345678A   | 44444444D
(5 rows)
```

#### Contiene

```
 numero_pedido | id_producto | cantidad | precio_unitario 
---------------+-------------+----------+-----------------
             1 |           1 |        2 |           18.50
             1 |           3 |        1 |           12.00
             2 |           2 |        3 |           25.00
             3 |           4 |        2 |           15.75
             4 |           5 |        4 |           22.00
             5 |           1 |        5 |           18.50
(6 rows)
```

## Borrado en Cascada de una Entidad Fuerte hacia su Entidad Débil

Como **`zona`** es una entidad débil respecto a **`vivero`**, y tanto **`dispone`** como **`pertenece_historico`** dependen de zona, al eliminar el **Vivero Santa Cruz**, el sistema elimina en cascada:

1. El registro del vivero `4` en la tabla `vivero`.
2. Su zona asociada `(4, 1) - Almacén Logístico` en la tabla `zona`.
3. El stock alojado en esa zona `(4, 1, 4)` en la tabla `dispone`.
4. La asignación del empleado `55555555E` en esa zona dentro de `pertenece_historico`.

```sql
DELETE FROM vivero WHERE id_vivero = 4;
```

Comprobación en `zona` y `dispone` tras el borrado (la zona `4, 1` y su stock han desaparecido automáticamente):

```text
 id_vivero | id_zona |          nombre          |  latitud  |  longitud  
-----------+---------+--------------------------+-----------+------------
         1 |       1 | Zona Exterior            | 28.487200 | -16.316900
         1 |       2 | Almacén Central          | 28.487300 | -16.317000
         2 |       1 | Invernadero Subtropical  | 28.390600 | -16.523100
         2 |       2 | Exposición Decoración    | 28.390700 | -16.523200
         3 |       1 | Zona Cactus y Suculentas | 28.122800 | -16.726100
(5 rows)
```

## Resumen de la Estructura del Modelo Relacional

1. **Entidades Fuertes (`vivero`, `producto`, `tarea`, `empleado`, `cliente`, `pedido`):**

2. **Entidad Débil por Identificación (`zona`):**
   * La entidad `zona` no puede existir sin un `vivero` al que pertenezca, por lo que su clave primaria es compuesta por `id_vivero` y `id_zona`.

3. **Relaciones Muchos a Muchos (`N:M`) transformadas en tablas (`dispone`, `pertenece_historico`, `contiene`):**
   * La relación entre `zona` y `producto` se modela mediante la tabla `dispone`, que registra el stock disponible en cada zona.
   * La relación entre `empleado`, `zona` y `tarea` se modela mediante la tabla `pertenece_historico`, que controla las asignaciones de trabajadores a zonas y tareas a lo largo del tiempo.
   * La relación entre `pedido` y `producto` se modela mediante la tabla `contiene`, que registra los artículos incluidos en cada pedido.

4. **Atributos Derivados (Calculados):**
      * En la tabla **`cliente`**, el atributo **`bonificaciones`** se ha implementado como una columna generada automáticamente. Si el cliente pertenece al programa Tajinaste Plus, calcula automáticamente el **5%** de su `volumen_compras_mensual`; en caso contrario, asigna `0.00`.