/* EJERCICIO 1 */

SELECT clie_codigo, clie_razon_social
FROM Cliente
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo

/* EJERCICIO 2 */

SELECT prod_codigo, prod_detalle
FROM Factura, Item_Factura, Producto
WHERE fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo AND YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) DESC

/* EJERCICIO 3 */

SELECT prod_codigo, prod_detalle, SUM(stoc_cantidad)
FROM Producto, STOCK
WHERE prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle

/* EJERCICIO 4 */

SELECT prod_codigo, prod_detalle, COUNT(DISTINCT comp_componente)
FROM Producto LEFT JOIN Composicion ON prod_codigo = comp_producto JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING AVG(stoc_cantidad) > 100
