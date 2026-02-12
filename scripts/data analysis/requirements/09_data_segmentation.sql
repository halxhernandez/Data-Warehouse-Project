/*
======================================================================================
Análisis De Segmentación De Datos
======================================================================================
Objetivo:
    - Agrupar datos en categorías significativas para obtener información específica.
    - Segmentar clientes y categorizar productos.

Funciones SQL utilizadas:
    - CASE
    - GROUP BY
======================================================================================
*/

/*
Segmentar los productos en rangos de precio y contar cuántos productos pertenecen
a cada segmento:

    - Si el costo es menor a 100 el rango es 'Below 100'
    - Si el costo se encuentra entre 100 y 500 el rango es '100-500'
    - Si el costo se encuentra entre 500 y 1000 el rango es '500-1000'
    - Si el costo es mayor a 1000 el rango es 'Above 1000'
*/

/*
Agrupar a los clientes en tres segmentos según su comportamiento de gasto:

    - VIP: Clientes con al menos 12 meses de historial y un gasto superior a 5000
    - Regular: Clientes con al menos 12 meses de historial, pero con un gasto de 500
      o menos
    - New: Clientes con una vida útil inferior a 12 meses

y calcular el número total de clientes de cada grupo
*/
