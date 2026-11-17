# Computational methods and reproducibility

This document accompanies *Statistical asymmetry: an entropic measure
of symmetry*. It describes how the repository computes statistical
asymmetry, how to regenerate the figures and tables, and how the
regenerated results were checked against the published paper.

[Published paper](https://doi.org/10.1088/2632-072X/ae0972)

## Statistical asymmetry

For a configuration $x$, apply each transformation $g$ in the
chosen set $G$ and compute the Hamming distance
$d_g = \sum_i \mathbf{1}[x_i \ne (gx)_i]$. Let $p_d$ be the fraction of
transformations giving distance $d$. The implementation computes

$
B_G(x) =
\frac{-\sum_{d:p_d>0} p_d \log p_d}{\log |G|}
\frac{\max_{g \in G} d_g}{|x|},
$

where $|x|$ is the number of cells and $|G|$ is the number of
transformations used in that calculation. The identity contributes
a distance of zero. The entropy term measures the spread of the
distance distribution, while the second factor scales it by the
largest observed mismatch.

For the even-length sequences and even-sided grids used here, the
translation calculations include shifts from zero through half the
length along the relevant axis. A positive shift and the corresponding
negative shift give equal Hamming distances under periodic boundaries.
The reflection component uses the identity and one reflection. The
rotation component uses the identity and the three nontrivial
quarter-turns.

The two-dimensional calculations use five components. Table 3 lists
vertical translations, horizontal translations, reflection across the
horizontal centreline, reflection across the vertical centreline, and
quarter-turn rotations. The Julia ensemble files use the same
reflection and rotation order and list horizontal translations before
vertical translations.

## Image distances and fixed examples

[Figure 1](../notebooks/figure01_colour_distances.ipynb) compares each
variant of a 20 × 20 reference image with the original. Hamming distance
counts changes in symbolic colour class. The Euclidean measure averages
the Euclidean distance between corresponding RGB vectors across all
400 pixels. The two palette shifts preserve the symbolic classes,
whereas the cyclic reassignment changes every class. All six reported
distances match the published figure at its displayed precision.

[Table 1](../notebooks/table01_prototypical_sequences.ipynb) reproduces
the four fixed binary examples at the published precision. It also
enumerates all 256 binary sequences of length eight to compute exact
expectations for the random case. The notebook displays those
expectations alongside the published estimates.

[Table 3](../notebooks/table03_binary_matrices.ipynb) encodes the eight
published 4 × 4 matrices in reading order and computes all five
asymmetry components for each matrix. All 40 entries match at the
published precision.

## Elementary cellular automata

[Figure 2](../notebooks/figure02_initial_state.ipynb) recovers the
published initial configuration using
`np.random.RandomState(55).randint(0, 2, 100)`. The sequence matches all
100 positions in the paper, with `0` representing −1 and `1`
representing +1.

Each elementary rule updates a periodic ring of 100 cells
synchronously. The next state of a cell is determined by its left
neighbour, its own state, and its right neighbour, using the lookup
table encoded by the rule number. Each run records 20,000 states,
including the initial configuration at index 0.

- [Figures 3 and 4](../notebooks/figures03_04_cellular_automata.ipynb)
  plot the last 200 recorded states and their translation and reflection
  scores. The diagrams and curves agree visually with the published
  panels. Figure 4(b) uses Rule 3, as shown in the published panel.
- [Figure 5](../notebooks/figure05_rule26.ipynb) uses Rule 26 and
  displays the final 1,000 states, following the published plot's
  axis window.

### Table 2 classification audit

The [Table 2 notebook](../notebooks/table02_cellular_automata_classification.ipynb)
audits the 88 rules listed in the paper. It examines the final 2,000
asymmetry scores for each component, using an absolute tolerance of
$10^{-12}$. A zero series is labelled `T`, a nonzero constant series
`C`, a period-two series `P2`, and a series with a longer detected
period `PF`. The initial search requires at least three cycles in the
window and tests periods through 666. In this finite-window check,
`PI` records the absence of a detected period within that limit.

The initial audit matched 83 of 88 classifications. For Rules 54 and
73, the follow-up located the first exact recurrence of the full
100-cell configuration and then measured the smallest period of each
score over the complete cycle.

| Rule | Cycle starts at state index | Configuration period | Translation period | Reflection period |
| --- | ---: | ---: | ---: | ---: |
| 54 | 2,744 | 6,300 | 126 | 3,150 |
| 73 | 27 | 2,856 | 2,856 | 2,856 |

The follow-up confirmed the published `(PF, PF)` label for both rules,
bringing agreement to 85 of 88. For the Figure 2 initial state, the
remaining revisions are Rule 25 to `(P2, PF)`, Rule 58 to `(C, PF)`,
and Rule 62 to `(PF, PF)`. Pairs are in translation, reflection order.

## Two-dimensional simulations

[Figure 6](../notebooks/figure06_ghm_spiral.ipynb) starts the
Greenberg–Hastings model from a prescribed spiral seed on a 100 × 100
grid. The two initial lines extend to the right in the published
snapshot and in the notebook. The state counts at steps 0, 50, and 100
match the original implementation, and the curves and snapshots agree
visually with the published panels.

The ensemble figures use periodic 100 × 100 grids and 3,000
realizations per model. The Julia simulator records 100 observations
per realization, starting with the initial grid at index 0.

| Figure | Model | Update |
| --- | --- | --- |
| 7 | Greenberg–Hastings | A quiescent cell becomes excited when at least one of its four orthogonal neighbours is excited. Excited cells become refractory, and refractory cells become quiescent. |
| 8 | Ternary random evolution | Each update independently redraws every cell from three equally probable states. |
| 9 | Conway’s Game of Life | A dead cell is born with three live neighbours. A live cell survives with two or three of its eight neighbours alive. |
| 10 | Binary random evolution | Each update independently redraws every cell from two equally probable states. |

All cellular automaton updates are synchronous. Initial cells are
sampled independently and uniformly over the states for each model.
The companion Julia runs use seed `55`.

Run the following commands from the repository root with Julia
available on your `PATH`. In the repository-local Windows setup,
substitute `./.julia/julia-1.14.0-alpha1/bin/julia.exe` for `julia`.

```bash
julia --startup-file=no scripts/random_evolution_simulate.jl full ghm
julia --startup-file=no scripts/random_evolution_simulate.jl full ternary
julia --startup-file=no scripts/random_evolution_simulate.jl full life
julia --startup-file=no scripts/random_evolution_simulate.jl full binary
```

The simulator writes `Bdata.txt` and `VBdata.txt` under the
corresponding `outputs/figureNN_full/` directory. Each file has five
rows and 100 columns. A pair of entries stores $\sum_r B_r$ and
$\sum_r B_r^2$ for one component and observation. The plot uses

$
\bar B = \frac{\sum_r B_r}{M}, \qquad
\sigma = \sqrt{\frac{\sum_r B_r^2}{M} - \bar B^2}, \qquad M=3000.
$

Te shaded bands show $\bar B \pm \sigma$, the spread across
realizations. Monte Carlo standard errors of the mean would instead
scale that spread by $1/\sqrt{M}$.

The notebooks for [Figure 7](../notebooks/figure07_greenberg_hastings_ensemble.ipynb),
[Figure 8](../notebooks/figure08_ternary_random_evolution.ipynb), and
[Figure 9](../notebooks/figure09_game_of_life.ipynb) read the regenerated
aggregates. Their curves and bands agree visually with the published
figures. The right-hand panels show representative snapshots at
steps 0, 50, and 100, generated separately with NumPy seed `55`.
The original snapshot seeds and grids have not been recovered.

The [Figure 10 notebook](../notebooks/figure10_binary_random_evolution.ipynb)
plots the [archived aggregates](../reference/figure10/) and generates
representative snapshots using the same NumPy seed. To compare the
full Julia rerun with the archive, run the following command from
the repository root with the Python environment active.

```bash
python scripts/figure10_compare.py
```

The full rerun closely reproduced the archived mean curves. The average
rotation-band half-width was 0.017033 in the archive and 0.017003 in the
rerun, with more pointwise variation than in the translation and
reflection bands.

## Table A1 and LMC complexity

The [Table A1 notebook](../notebooks/table_a1_lmc_comparison.ipynb)
computes $C=HD$, where $H=-\sum_{i:p_i>0}p_i\log p_i$ and
$D=\sum_i(p_i-1/4)^2$. The four probabilities are the frequencies of
`00`, `01`, `10`, and `11` among the 100 overlapping circular bigrams.
The last and first symbols form one of those bigrams.

The three deterministic rows match at the published precision. The
companion uses NumPy seed `55` and 20,000 samples for each stochastic
row. The defect model flips five distinct positions sampled uniformly
from the alternating sequence. The random model draws each bit
independently with probability 0.5. The notebook displays the
published values, the regenerated estimates, and the Monte Carlo
standard errors for each stochastic mean.