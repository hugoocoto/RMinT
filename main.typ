#import "@preview/wired-ieee:1.0.1": ieee
#import "figs.typ": *

#show: ieee.with(
  title: [Rolling Min Tree: Max or Pass],
  abstract: [
    Muchas aplicaciones solo necesitan los $K$ elementos mayores de un vector de
    $N$ valores. Ordenar el vector y quedarse con los $K$ primeros cuesta
    $O(N log N)$ en tiempo y $O(N)$ en memoria adicional. Este trabajo analiza
    el _Rolling Min Tree_ (RMinT), un montículo de mínimos de capacidad fija $K$
    que descarta la raíz cuando llega un elemento mayor, y lo compara con la
    ordenación completa.
    El RMinT cuesta $O(N log K)$ en el peor caso, $O(N + K log K log(N slash K))$
    en promedio para entradas aleatorias, y usa $O(K)$ de memoria. Se mide el
    tiempo en un único núcleo de FinisTerrae III (CESGA) con $N$ entre $10^4$ y
    $10^9$ y $K$ entre $1$ y $10^6$. Con entrada aleatoria y $N = 10^9$, el RMinT
    es $259 times$ más rápido que la ordenación para $K <= 10^4$ y $79 times$
    para $K = 10^6$. La ventaja crece con $N$.
  ],
  index-terms: ("Top-K", "montículo", "heap", "selección", "ordenación", "HPC"),
  authors: (
    (
      name: "Hugo Coto Flórez",
      department: [Independent researcher],
      location: [Santiago de Compostela],
      email: "hugo.coto@outlook.com",
    ),
    (
      name: "David Sanchez Miguez",
      department: [Hobbyist console hacker],
      location: [Area, Galicia],
      email: "david.sanchez.miguez@rai.usc.es",
    ),
  ),
  bibliography: bibliography("refs.bib"),
  lang: "es",
)

= Introducción
Obtener los $K$ valores mayores de un conjunto (_top-K_) es un paso habitual en
estadística y aprendizaje automático. Tras cualquier transformación de los
datos, muchas tareas solo necesitan esos $K$ valores. Ordenar todo el vector
hace mucho más trabajo del necesario. El _Rolling Min Tree_ (RMinT) resuelve
esta selección mediante un montículo binario de mínimos @williams1964 de
capacidad fija $K$.

= El Rolling Min Tree <sec-rmint>
El RMinT guarda hasta $K$ reales con la disposición de un montículo de mínimos:
los hijos del nodo $i$ están en $2i + 1$ y $2i + 2$, y su padre en
$floor((i - 1) slash 2)$. La raíz es el mínimo de los valores guardados. Cada
inserción tiene dos casos:

+ *Árbol no lleno.* El elemento se coloca al final y sube mientras sea menor que
  su padre.
+ *Árbol lleno.* Si el elemento es menor o igual que la raíz, se descarta con
  una sola comparación. Si es mayor, sustituye a la raíz y se reajusta el
  montículo hacia abajo: una sola bajada por inserción.

Tras procesar los $i$ primeros elementos, el árbol contiene los $min(i, K)$
mayores de ellos, y la raíz es el $K$-ésimo mayor visto: nada por debajo de ella
puede entrar en el resultado. Al terminar, el árbol contiene los $K$ mayores,
sin ordenar.

= Análisis de coste <sec-analisis>
*Memoria.* El RMinT ocupa $K$ valores, $O(K)$. La ordenación completa debe
procesar los $N$ elementos y, si se conserva el vector original, requiere
además espacio proporcional a $N$.

*Peor caso.* Cada elemento provoca como mucho una bajada o una subida en un
montículo de altura $floor(log_2 K)$: $O(N log K)$. Ocurre con entrada
ascendente, donde cada elemento es mayor que todos los guardados y siempre
entra. Se mide solo como referencia.

*Caso aleatorio.* El elemento $i$-ésimo ($i > K$) está entre los $K$ mayores de
los $i$ primeros con probabilidad $K slash i$, así que el número esperado de
inserciones es $ K + sum_(i = K + 1)^N K / i approx K (1 + ln(N slash K)), $ y el
coste esperado $O(N + K log K dot log(N slash K))$. Con $K << N$ domina $N$:
casi todos los elementos se descartan con una comparación contra la raíz, en un
recorrido secuencial.

*Ordenación.* La ordenación completa hace $Theta(N log N)$ comparaciones
@knuth1998, independientemente de $K$.

= Metodología <sec-metodo>
Se compara el RMinT con una ordenación completa de mayor a menor.

- *Datos.* Valores uniformes en $[0, 1)$ con semilla fija; también se prueba la
  entrada ascendente $i slash N$ (peor caso, solo como referencia).
- *Tamaños.* $N in {10^4, ..., 10^9}$ y $K in {1, 10, ..., 10^6}$ con $K < N$.
- *Tiempo.* Mediana de 5 repeticiones (3 para $N = 10^9$).
- *Corrección.* Tras cada ejecución, los $K$ elementos del árbol, ordenados,
  coinciden con los $K$ primeros del vector ordenado. Todas las comprobaciones
  pasaron.
- *Plataforma.* Un núcleo de un nodo compartido de FinisTerrae III @ft3guide,
  con Intel Xeon Platinum 8352Y a 2,2 GHz.

= Resultados <sec-resultados>
La @fig-time muestra el tiempo frente a $N$ con entrada aleatoria. Con
$K <= 10^3$, el RMinT tarda 0,84 ns por elemento, casi constante: es el coste de
leer el elemento y compararlo con la raíz. El de la ordenación sube de 105 ns
($N = 10^4$) a 222 ns ($N = 10^9$), como se espera de un factor $log N$.

#figure(
  fig-time(height: 3.6cm),
  caption: [Tiempo (mediana) frente a $N$ con entrada aleatoria, en escala
    log-log.],
) <fig-time>

La @fig-speedup muestra la aceleración $t_"sort" slash t_"RMinT"$. Es mayor que
1 en todos los casos (mínimo $"3,3" times$, con $K = 10^6$ y $N = 10^7$) y crece
con $N$: con $N = 10^9$ llega a $259 times$ para $K <= 10^4$ y baja a $79 times$
con $K = 10^6$, donde se esperan $K (1 + ln(N slash K)) approx "7,9" dot 10^6$
inserciones, menos del 1 % de los elementos.

#figure(
  fig-speedup(height: 3.6cm),
  caption: [Aceleración del RMinT respecto a la ordenación con entrada aleatoria. La
    línea discontinua marca la igualdad.],
) <fig-speedup>

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header([Método], [Aleatoria (ms)], [Ascendente (ms)]),
    table.hline(stroke: 0.5pt),
    [Ordenación], [#ms(med("rand", nmax, 0, "sort"))], [#ms(med("asc", nmax, 0, "sort"))],
    ..(1, 100, 10000, 1000000).map(k => (
      [RMinT, $K = #kname(k)$],
      [#ms(med("rand", nmax, k, "rmint"))],
      [#ms(med("asc", nmax, k, "rmint"))],
    )).flatten(),
    table.hline(),
  ),
  caption: [Tiempo mediano con $N = 10^9$.],
) <tab-nmax>

Con $N = 10^9$ y entrada aleatoria (@tab-nmax, @fig-k), el tiempo es plano hasta
$K = 10^4$ y se triplica con $K = 10^6$. Con entrada ascendente, cada elemento
entra en el árbol y el coste pasa a ser $O(N log K)$: para $K >= 10^3$ el RMinT
es más lento que la ordenación, que además es $"4,0" times$ más rápida que con datos
aleatorios. Este caso no corresponde al uso previsto.

#figure(
  fig-k(height: 3.0cm),
  caption: [Tiempo frente a $K$ con $N = 10^9$. La línea horizontal es la ordenación,
    que no depende de $K$.],
) <fig-k>

La dispersión entre repeticiones es del 0,9 % en mediana y como máximo del 4 %
para $N >= 10^8$.

= Propiedades y extensiones
*Invariante de selección.* Tras leer cualquier prefijo de la entrada, el árbol
contiene exactamente los $min(i, K)$ mayores elementos de ese prefijo, contando
repeticiones. La propiedad se conserva porque, si el árbol está lleno, la raíz
es el menor de los candidatos actuales: un valor que no la supera no puede
formar parte de los $K$ mayores, mientras que uno mayor reemplaza a un
candidato que sí puede quedar fuera. El reajuste posterior solo restaura la
propiedad de montículo y no cambia el conjunto seleccionado.

El resultado queda sin ordenar, una propiedad útil cuando solo interesa el
umbral o recorrer los $K$ valores. Si se necesita presentarlos ordenados, basta
con extraer repetidamente la raíz; ese paso cuesta $O(K log K)$ y es
independiente de $N$. En una ejecución distribuida, cada proceso puede conservar
sus $K$ mayores valores: ningún elemento descartado localmente puede estar entre
los $K$ mayores globales. Basta combinar esos candidatos, con otro RMinT o una
reducción equilibrada, para obtener el resultado global sin reunir los $N$
elementos.

= Conclusiones
El RMinT resuelve la selección de los $K$ mayores con memoria $O(K)$ y, para
datos aleatorios, coste prácticamente lineal en $N$. Con $N = 10^9$ tarda 0,84 s
frente a los 222 s de la ordenación completa, y su ventaja aumenta con $N$. Solo pierde
con entradas casi ordenadas y $K$ grande, fuera de su uso previsto. Como trabajo
futuro, compararlo con la selección rápida @hoare1961 y combinar los $K$ mayores
de distintos procesos con una reducción final.
