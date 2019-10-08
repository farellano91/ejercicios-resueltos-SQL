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

SELECT 
	prod_codigo 'Codigo', 
	prod_detalle 'Producto', 
	MAX(item_precio) 'Precio maximo', 
	MIN(item_precio) 'Precio minimo', 
	CAST(((MAX(item_precio) - MIN(item_precio)) / MIN(item_precio)) * 100 AS DECIMAL(10,2)) 'Dif. Porcentual'
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING SUM(stoc_cantidad) > 0

/* EJERCICIO 8 */

SELECT prod_detalle 'Producto', MAX(stoc_cantidad) 'Max Stock'
FROM Producto JOIN STOCK ON prod_codigo = stoc_producto
WHERE stoc_cantidad > 0
GROUP BY prod_detalle
HAVING COUNT (DISTINCT stoc_deposito) = (SELECT COUNT(*) FROM DEPOSITO)

/* EJERCICIO 9 */

SELECT 
    j.empl_codigo 'Jefe', 
	e.empl_codigo 'Cod. Empleado', 
	e.empl_nombre 'Nombre Empleado', 
	e.empl_apellido 'Apellido Empleado', 
	(SELECT COUNT(*) FROM DEPOSITO WHERE depo_encargado = j.empl_codigo) 'Cant. Depositos Jefe',
	(SELECT COUNT(*) FROM DEPOSITO WHERE depo_encargado = e.empl_codigo) 'Cant. Depositos Empleado'
FROM Empleado j JOIN Empleado e ON j.empl_codigo = e.empl_jefe

/* EJERCICIO 10 */

SELECT p.prod_codigo 'Cod. Producto', p.prod_detalle 'Producto', (SELECT TOP 1 fact_cliente
																  FROM Factura, Item_Factura
																  WHERE fact_tipo = item_tipo AND 
																        fact_numero = item_numero AND 
																        fact_sucursal = item_sucursal AND 
																		p.prod_codigo = item_producto
                                                                  GROUP BY fact_cliente
																  ORDER BY SUM(item_cantidad) DESC) 'Cod. Cliente que mas compro'
FROM Producto p
WHERE p.prod_codigo IN ((SELECT TOP 10 prod_codigo
					  FROM Producto JOIN Item_Factura ON prod_codigo = item_producto
					  GROUP BY prod_codigo
					  ORDER BY SUM(item_cantidad) DESC)
				  UNION (SELECT TOP 10 prod_codigo
						FROM Producto JOIN Item_Factura ON prod_codigo = item_producto
						GROUP BY prod_codigo
						ORDER BY SUM(item_cantidad) ASC))

/* EJERCICIO 11 */

SELECT fami_detalle 'Familia', COUNT(DISTINCT item_producto) 'Cant. productos distintos' , SUM(item_cantidad * item_precio) 'Monto Total Venta'
FROM Producto, Familia, Factura, Item_Factura
WHERE prod_familia = fami_id AND fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo
GROUP BY fami_detalle
HAVING fami_detalle IN (SELECT fami_detalle
						FROM Producto, Familia, Factura, Item_Factura
						WHERE prod_familia = fami_id AND fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND 
						item_producto = prod_codigo AND YEAR(fact_fecha) = 2012
						GROUP BY fami_detalle
						HAVING SUM(item_cantidad * item_precio) > 20000
						)
ORDER BY COUNT(DISTINCT item_producto) DESC

/* EJERCICIO 12 */

SELECT prod_detalle 'Producto', 
		COUNT(DISTINCT fact_cliente) 'Cant. Clientes que compraron', 
		AVG(item_cantidad * item_precio) 'Importe Promedio', 
		COUNT(DISTINCT stoc_deposito) 'Cant, Depositos con Stock', 
		SUM(stoc_cantidad) 'Stock Total'
FROM Producto, Factura, Item_Factura, STOCK
WHERE fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo AND prod_codigo = stoc_producto AND stoc_cantidad > 0
GROUP BY prod_detalle
HAVING prod_detalle IN (SELECT DISTINCT prod_detalle 
						FROM Producto, Factura, Item_Factura
						WHERE fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND item_producto = prod_codigo AND YEAR(fact_fecha) = 2012
						)
ORDER BY SUM(item_cantidad * item_precio) DESC

/* EJERCICIO 13 */

SELECT producto.prod_detalle 'Producto', producto.prod_precio 'Precio', SUM(componente.prod_precio * comp_cantidad) 'Precio total de los componentes'
FROM Producto producto JOIN Composicion ON producto.prod_codigo = comp_producto JOIN Producto componente ON componente.prod_codigo = comp_componente 
GROUP BY producto.prod_detalle, producto.prod_precio
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC

/* EJERCICIO 14 */

SELECT clie_codigo 'Cliente', 
	   COUNT(*) 'Cant. Compras ultimo año', 
	   AVG(fact_total) 'Promedio gastado en compras', 
	   COUNT(DISTINCT item_producto) 'Cant. productos dif. comprados', 
	   MAX(fact_total) 'Monto mayor compra'
FROM Cliente LEFT JOIN Factura ON clie_codigo = fact_cliente JOIN Item_Factura ON fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal
WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
GROUP BY clie_codigo
ORDER BY COUNT(*) DESC
