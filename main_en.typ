#import "@preview/wired-ieee:1.0.1": ieee
#import "figs.typ": *

#show: ieee.with(
  title: [Rolling Min Tree: Max or Pass],
  abstract: [
    Many applications only need the $K$ largest elements of a vector of $N$
    values. Sorting the vector and keeping the first $K$ costs $O(N log N)$
    time and $O(N)$ extra memory. This work analyzes the _Rolling Min Tree_
    (RMinT), a fixed-capacity min-heap of size $K$ that discards its root when a
    larger element arrives, and compares it with complete sorting. RMinT
    costs $O(N log K)$ in the worst case, $O(N + K log K log(N slash K))$ on
    average for random input, and uses $O(K)$ memory. Time is measured on a
    single core of FinisTerrae III (CESGA) with $N$ from $10^4$ to $10^9$ and $K$
    from $1$ to $10^6$. With random input and $N = 10^9$, RMinT is $259 times$
    faster than sorting for $K <= 10^4$ and $79 times$ faster for $K = 10^6$.
    The advantage grows with $N$.
  ],
  index-terms: ("Top-K", "heap", "selection", "sorting", "HPC"),
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
  lang: "en",
)

= Introduction
Finding the $K$ largest values of a set (_top-K_) is a common step in
statistics and machine learning. After any transformation of the data, many
tasks need only those $K$ values. Sorting the whole vector does far more work
than necessary. The _Rolling Min Tree_ (RMinT) performs this selection using a
binary min-heap @williams1964 of fixed capacity $K$.

= The Rolling Min Tree <sec-rmint>
RMinT stores up to $K$ real values in a min-heap: the children of node $i$ are
at $2i + 1$ and $2i + 2$, and its parent at $floor((i - 1) slash 2)$. The root
is the minimum of the stored values. Each insertion has two cases:

+ *Tree not full.* The element is placed at the end and moves up while it is
  smaller than its parent.
+ *Tree full.* If the element is less than or equal to the root, it is discarded
  with a single comparison. Otherwise it replaces the root and sifts down: one
  sift-down per insertion.

After processing the first $i$ elements, the tree holds the $min(i, K)$ largest
of them, and the root is the $K$-th largest seen so far: nothing below it can
enter the result. At the end, the tree holds the $K$ largest elements, unsorted.

= Cost analysis <sec-analisis>
*Memory.* RMinT uses $K$ values, $O(K)$. Complete sorting processes all $N$
elements and, if the original vector is preserved, requires additional space
proportional to $N$.

*Worst case.* Each element causes at most one sift-down or one sift-up in a heap
of height $floor(log_2 K)$: $O(N log K)$. It happens with ascending input, where
every element is larger than all stored ones and always enters. It is measured
only as a reference.

*Random case.* The $i$-th element ($i > K$) is among the $K$ largest of the
first $i$ with probability $K slash i$, so the expected number of insertions is
$ K + sum_(i = K + 1)^N K / i approx K (1 + ln(N slash K)), $ and the expected
cost is $O(N + K log K dot log(N slash K))$. With $K << N$, $N$ dominates: almost
every element is discarded with one comparison against the root, in a sequential
scan.

*Sorting.* Complete sorting performs $Theta(N log N)$ comparisons @knuth1998,
regardless of $K$.

= Methodology <sec-metodo>
RMinT is compared with complete sorting in descending order.

- *Data.* Uniform values in $[0, 1)$ with a fixed seed; ascending input $i slash N$
  is also tested (worst case, only as a reference).
- *Sizes.* $N in {10^4, ..., 10^9}$ and $K in {1, 10, ..., 10^6}$ with $K < N$.
- *Time.* Median of 5 repetitions (3 for $N = 10^9$).
- *Correctness.* After each run, the $K$ tree elements, sorted, match the first
  $K$ of the sorted vector. All checks passed.
- *Platform.* One core of a shared FinisTerrae III node @ft3guide, with an Intel
  Xeon Platinum 8352Y at 2.2 GHz.

= Results <sec-resultados>
@fig-time shows time versus $N$ with random input. With $K <= 10^3$, RMinT takes
0.84 ns per element, almost constant: the cost of reading the element and
comparing it with the root. The cost of complete sorting rises from 105 ns ($N = 10^4$)
to 222 ns ($N = 10^9$), as expected from a $log N$ factor.

#figure(
  fig-time(lang: "en", height: 3.6cm),
  caption: [Time (median) versus $N$ with random input, log-log scale.],
) <fig-time>

@fig-speedup shows the speedup $t_"sort" slash t_"RMinT"$. It is above 1 in all
cases (minimum $3.3 times$, with $K = 10^6$ and $N = 10^7$) and grows with $N$:
with $N = 10^9$ it reaches $259 times$ for $K <= 10^4$ and drops to $79 times$
with $K = 10^6$, where about $K (1 + ln(N slash K)) approx 7.9 dot 10^6$
insertions are expected, under 1 % of the elements.

#figure(
  fig-speedup(lang: "en", height: 3.6cm),
  caption: [Speedup of RMinT over complete sorting with random input. The dashed line
    marks equality.],
) <fig-speedup>

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header([Method], [Random (ms)], [Ascending (ms)]),
    table.hline(stroke: 0.5pt),
    [Sorting], [#ms(med("rand", nmax, 0, "sort"))], [#ms(med("asc", nmax, 0, "sort"))],
    ..(1, 100, 10000, 1000000).map(k => (
      [RMinT, $K = #kname(k)$],
      [#ms(med("rand", nmax, k, "rmint"))],
      [#ms(med("asc", nmax, k, "rmint"))],
    )).flatten(),
    table.hline(),
  ),
  caption: [Median time with $N = 10^9$.],
) <tab-nmax>

With $N = 10^9$ and random input (@tab-nmax, @fig-k), time is flat up to
$K = 10^4$ and triples at $K = 10^6$. With ascending input every element enters
the tree and the cost becomes $O(N log K)$: for $K >= 10^3$ RMinT is slower than
complete sorting, which is also $4.0 times$ faster than on random data. This case is not
the intended use.

#figure(
  fig-k(lang: "en", height: 3.0cm),
  caption: [Time versus $K$ with $N = 10^9$. The horizontal line is complete sorting,
    which does not depend on $K$.],
) <fig-k>

The spread between repetitions is 0.9 % in median and at most 4 % for
$N >= 10^8$.

= Algorithmic properties and extensions
*Selection invariant.* After reading any input prefix, the tree contains
exactly the $min(i, K)$ largest values in that prefix, including duplicates.
The property is preserved because, when the tree is full, its root is the
smallest current candidate: a value that does not exceed it cannot belong to the
largest $K$, while a larger value replaces a candidate that may leave the set.
The subsequent sift-down restores the heap property without changing the
selected set.

The result is unsorted, which is useful when only the threshold or the $K$
values themselves are needed. If sorted output is required, repeatedly
extracting the root costs $O(K log K)$, independently of $N$. In a distributed
execution, each process can retain its local $K$ largest values: an element
discarded locally cannot be among the global $K$ largest. Combining those
candidates with another RMinT or a balanced reduction therefore produces the
global result without gathering all $N$ values.

= Conclusions
RMinT solves the selection of the $K$ largest elements with $O(K)$ memory and,
for random data, a cost that is practically linear in $N$. With $N = 10^9$ it
takes 0.84 s versus 222 s for complete sorting, and its advantage grows with $N$.
Against Hoare's expected-$O(N)$ quickselect @hoare1961, RMinT preserves input
and uses $O(K)$ state, avoiding full-array reordering. If $N$ exceeds RAM,
quickselect cannot partition directly; RMinT streams chunks, retaining $K$ values
with sequential I/O, and can remain performant. This case is unmeasured.
