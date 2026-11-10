#import "@preview/lilaq:0.5.0" as lq

// Datos: mediana de las repeticiones de cada (dist, N, K, método).
#let rows = csv("data/results.csv", row-type: dictionary)
#let median(xs) = {
  let s = xs.sorted()
  let n = s.len()
  if calc.odd(n) { s.at(calc.div-euclid(n, 2)) } else { (s.at(n.bit-rshift(1) - 1) + s.at(n.bit-rshift(1))) / 2 }
}
#let med(dist, n, k, method) = median(
  rows
    .filter(r => r.dist == dist and int(r.N) == n and int(r.K) == k and r.method == method)
    .map(r => float(r.ms)),
)
#let has(dist, n, k, method) = rows.any(r => r.dist == dist and int(r.N) == n and int(r.K) == k and r.method == method)

#let ns = (10000, 100000, 1000000, 10000000, 100000000, 1000000000)
#let ks = (1, 10, 100, 1000, 10000, 100000, 1000000)
#let nmax = ns.last()

// K == N es degenerado (el árbol nunca se llena): solo K < N.
#let ok(dist, n, k) = k < n and has(dist, n, k, "rmint")

// Viridis truncado (sin el amarillo final, ilegible sobre blanco): perceptualmente
// uniforme, apto para daltónicos y legible en escala de grises.
#let kcolors = (
  rgb("#440154"), rgb("#46327e"), rgb("#365c8d"), rgb("#277f8e"), rgb("#1fa187"), rgb("#4ac16d"), rgb("#a0da39"),
)
#let sort-color = rgb("#d62839")
#let tr = (
  es: (time: [tiempo (ms)], rand: [aleatoria], asc: [ascendente], sort: [ordenación]),
  en: (time: [time (ms)], rand: [random], asc: [ascending], sort: [sorting]),
)
#let kname(k) = if k > 1 { $10^#(str(k).len() - 1)$ } else { $1$ }

#let fig-time(lang: "es", dist: "rand", width: 5.4cm, height: 5.2cm) = lq.diagram(
  width: width, height: height,
  xscale: "log", yscale: "log",
  xlabel: [$N$], ylabel: tr.at(lang).time,
  legend: (position: left + horizon, dx: 100% + 4pt),
  lq.plot(ns, ns.map(n => med(dist, n, 0, "sort")), mark: "s", color: sort-color, label: tr.at(lang).sort),
  ..ks.enumerate().map(((i, k)) => {
    let nn = ns.filter(n => ok(dist, n, k))
    lq.plot(nn, nn.map(n => med(dist, n, k, "rmint")), mark: "o", color: kcolors.at(i), label: [$K = #kname(k)$])
  }),
)

#let fig-speedup(lang: "es", width: 5.4cm, height: 5.2cm) = lq.diagram(
  width: width, height: height,
  xscale: "log", yscale: "log",
  xlabel: [$N$], ylabel: [$t_"sort" slash t_"RMinT"$],
  legend: (position: left + horizon, dx: 100% + 4pt),
  lq.hlines(1, stroke: (dash: "dashed", paint: luma(120), thickness: 0.6pt)),
  ..ks.enumerate().map(((i, k)) => {
    let nn = ns.filter(n => ok("rand", n, k))
    lq.plot(
      nn,
      nn.map(n => med("rand", n, 0, "sort") / med("rand", n, k, "rmint")),
      mark: "o",
      color: kcolors.at(i),
      label: [$K = #kname(k)$],
    )
  }),
)

#let fig-k(lang: "es", width: 100%, height: 4.2cm) = {
  let panel(dist, title, ylabel: none) = {
    let kk = ks.filter(k => ok(dist, nmax, k))
    lq.diagram(
      width: width, height: height,
      xscale: "log", yscale: "log",
      xlabel: [$K$], ylabel: ylabel, title: title,
      legend: (position: left + top),
      lq.hlines(med(dist, nmax, 0, "sort"), stroke: sort-color, label: tr.at(lang).sort),
      lq.plot(kk, kk.map(k => med(dist, nmax, k, "rmint")), mark: "o", color: kcolors.at(3), label: [RMinT]),
    )
  }
  grid(
    columns: (1fr, 1fr), column-gutter: 4pt,
    panel("rand", tr.at(lang).rand, ylabel: tr.at(lang).time), panel("asc", tr.at(lang).asc),
  )
}

// Celda de tabla: milisegundos con separador de miles (espacio fino).
#let ms(x) = {
  let s = str(calc.round(x))
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "\u{202F}" }
    out += c
  }
  out
}
