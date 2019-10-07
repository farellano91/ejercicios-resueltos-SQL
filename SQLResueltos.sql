USE GD2019

/* EJERCICIO 1 */

SELECT clie_codigo, clie_razon_social
FROM Cliente
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo

/* EJERCICIO 2 */

SELECT prod_codigo AS 'Codigo', prod_detalle AS 'Producto'
FROM Factura, Item_Factura, Producto
WHERE fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo AND YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) DESC

/* EJERCICIO 3 */

SELECT prod_codigo AS 'Codigo', prod_detalle AS 'Producto', SUM(stoc_cantidad) AS 'Cant. Stock'
FROM Producto, STOCK
WHERE prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle

/* EJERCICIO 4 */

SELECT prod_codigo AS 'Codigo', prod_detalle AS 'Producto', COUNT(DISTINCT comp_componente) AS 'Cant. Componentes'
FROM Producto LEFT JOIN Composicion ON prod_codigo = comp_producto JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING AVG(stoc_cantidad) > 100

/* EJERCICIO 5 */

SELECT p.prod_codigo AS 'Codigo', p.prod_detalle AS 'Producto', SUM(i.item_cantidad) AS 'Egresos'
FROM Factura f, Item_Factura i, Producto p
WHERE f.fact_numero = i.item_numero AND f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND i.item_producto = p.prod_codigo AND YEAR(f.fact_fecha) = 2012
GROUP BY p.prod_codigo, p.prod_detalle
HAVING SUM(i.item_cantidad) > (SELECT SUM(item_cantidad)
                             FROM Factura, Item_Factura, Producto
							 WHERE fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo AND YEAR(fact_fecha) = 2011 AND prod_codigo = p.prod_codigo
							 )

/* EJERCICIO 6 */

SELECT rubr_id AS 'Codigo', rubr_detalle AS 'Rubro', COUNT(DISTINCT prod_codigo) AS 'Cant. articulos', SUM(stoc_cantidad) AS 'Cant. stock'
FROM Rubro LEFT JOIN Producto ON rubr_id = prod_rubro JOIN STOCK ON prod_codigo = stoc_producto
WHERE  ((SELECT SUM(stoc_cantidad) FROM STOCK WHERE stoc_producto = prod_codigo) >
       (SELECT stoc_cantidad FROM STOCK WHERE stoc_producto = '00000000' AND stoc_deposito = '00'))
GROUP BY rubr_id, rubr_detalle

/* EJERCICIO 7 */

SELECT prod_codigo 'Codigo', prod_detalle 'Producto', MAX(item_precio) 'Precio maximo', MIN(item_precio) 'Precio minimo', CAST(((MAX(item_precio) - MIN(item_precio)) / MIN(item_precio)) * 100 AS DECIMAL(10,2)) 'Dif. Porcentual'
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING SUM(stoc_cantidad) > 0
