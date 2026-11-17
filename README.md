# Statistical asymmetry

Code and data accompanying:

“Statistical asymmetry: an entropic measure of symmetry”<br>
Roberto C. Alamino, *Journal of Physics: Complexity* **6**, 045001 (2025)<br>
[doi.org/10.1088/2632-072X/ae0972](https://doi.org/10.1088/2632-072X/ae0972)

[Computational methods and reproducibility](docs/computational-methods.md)

## Getting started

Use Python 3.15 for the notebooks. From the repository root, create a
virtual environment and install the pinned dependencies. On Windows
with Git Bash, run:

```bash
py -3.15 -m venv .venv
source .venv/Scripts/activate
python -m pip install -r requirements.txt
```

Open a notebook in VS Code, select the `.venv` Python interpreter as its
kernel, and run all cells from top to bottom.

## Reproducibility Status

The following notebooks
have been checked against the paper or archived reference data.

| Result | Notebook | Verification |
| --- | --- | --- |
| Figure 1 · Hamming and Euclidean image distances | [Figure 1 notebook](notebooks/figure01_colour_distances.ipynb) | Regenerates all four panels and matches the published numerical values. The Hamming labels identify the comparison as a count of symbolic colour-class mismatches. |
| Figure 2 · Initial state for the cellular automata | [Figure 2 notebook](notebooks/figure02_initial_state.ipynb) | Regenerates all 100 states shown in the paper using NumPy’s `RandomState(55)`. |
| Figures 3 and 4 · Elementary cellular automata | [Figures 3 and 4 notebook](notebooks/figures03_04_cellular_automata.ipynb) | Regenerates the space–time diagrams and asymmetry curves for six rules over the final 200 states. All panels agree visually with the published figures. |
| Figure 5 · Rule 26 cellular automaton | [Rule 26 simulation](notebooks/figure05_rule26.ipynb) | Reruns the simulation from the seeded initial configuration. The state diagram and asymmetry curves agree visually with the published figure. |
| Figure 6 · Greenberg–Hastings spiral | [Spiral simulation](notebooks/figure06_ghm_spiral.ipynb) | Reruns the deterministic simulation. State counts at steps 0, 50, and 100 match the original code, and the plots agree visually with the published figure. |
| Figure 7 · Greenberg–Hastings ensemble | [Figure 7 notebook](notebooks/figure07_greenberg_hastings_ensemble.ipynb) and [Julia simulation](scripts/random_evolution_simulate.jl) | The mean curves and one-standard-deviation bands from 3000 realizations agree visually with the published figure. The notebook shows a representative trajectory at generations 0, 50, and 100 using NumPy seed `55`. Generate the aggregates with `julia --startup-file=no scripts/random_evolution_simulate.jl full ghm`. |
| Figure 8 · Ternary random evolution | [Figure 8 notebook](notebooks/figure08_ternary_random_evolution.ipynb) and [Julia simulation](scripts/random_evolution_simulate.jl) | A full rerun used 3000 realizations on a 100 × 100 grid with 100 recorded time points. The regenerated mean curves and one-standard-deviation bands agree visually with the published panels. The notebook draws representative snapshots at steps 0, 50, and 100 using NumPy seed `55`. Generate the aggregates with `julia --startup-file=no scripts/random_evolution_simulate.jl full ternary`. |
| Figure 9 · Conway’s Game of Life | [Figure 9 notebook](notebooks/figure09_game_of_life.ipynb) and [Julia simulation](scripts/random_evolution_simulate.jl) | A full rerun of 3000 realizations on a 100 × 100 grid with periodic boundaries produced mean curves and one-standard-deviation bands that agree visually with the published figure. The notebook shows a representative trajectory at generations 0, 50, and 100 using NumPy seed `55`. Generate the aggregates with `julia --startup-file=no scripts/random_evolution_simulate.jl full life`. |
| Figure 10 · Binary random evolution | [Figure 10 notebook](notebooks/figure10_binary_random_evolution.ipynb), [Julia simulation](scripts/random_evolution_simulate.jl), and [Python comparison](scripts/figure10_compare.py) | The notebook renders all six panels. It reconstructs the left-hand curves and bands from the [archived Julia aggregates](reference/figure10/) and generates representative snapshots at steps 0, 50, and 100 using seed `55`. The original snapshot grids and seed remain unrecovered. A full rerun closely reproduced the archived mean curves. The rotation band's average half-width was 0.017033 in the archive and 0.017003 in the rerun, with larger pointwise differences than for translations or reflections. |
| Table 1 · Prototypical binary sequences | [Table 1 notebook](notebooks/table01_prototypical_sequences.ipynb) | Renders the complete table with black-and-white sequence strips. It recomputes the four fixed rows, displays the published random row, and reports the exact random-case expectations from all 256 binary sequences of length eight. |
| Table 2 · Elementary cellular automata classification | [Table 2 notebook](notebooks/table02_cellular_automata_classification.ipynb) | Generates the complete classification table for all 88 rules from the Figure 2 initial state. The results agree with 85 published classifications, including Rules 54 and 73 after full-cycle checks. The three revised classifications appear under Errata. |
| Table 3 · Prototypical 4 × 4 binary matrices | [Table 3 notebook](notebooks/table03_binary_matrices.ipynb) | Renders the eight published matrices alongside all 40 recomputed asymmetry values at the published precision.|
| Table A1 · Comparison with LMC statistical complexity | [Table A1 notebook](notebooks/table_a1_lmc_comparison.ipynb) | Renders all five rows at the published precision. The three deterministic rows match the paper, and the two stochastic rows report recomputed means from 20000 runs each. |

## Computational Companion

The computational guide explains the transformations, Hamming
distances, and entropy calculation used to measure statistical
asymmetry. It also documents the simulation settings and how the
notebooks turn simulation outputs and archived data into figures and
tables.

## Errata

- **Figure 1 panel labels.** “Hamming (RGB)” should read “Hamming
  (colour classes)”. The reported values count symbolic colour-class
  mismatches, as described in the main text.
- **Figure 4 caption.** Panel (b) shows Rule 3, as stated in the panel
  title and supported by Table 2. The caption says Rule 2.
- **Figure 5 caption.** The plotted time window is 19000–20000,
  corresponding to the final 1000 states. The caption says 2000.
- **Figure 6 caption.** The two lines of excited and refractory cells
  extend from the centre to the **right**, as shown in the `t = 0`
  snapshot. The caption says “to the left”.
- **Figure 6 caption.** The rotation calculation uses successive
  quarter-turns ($\pi/2$). The caption gives $\pi/4$.
- **Table 2 classifications.** For the initial state shown in Figure 2,
  Rule 25 changes from `(C, PF)` to `(P2, PF)`, Rule 58 from `(C, C)`
  to `(C, PF)`, and Rule 62 from `(P2, PF)` to `(PF, PF)`. The [Table 2 notebook](notebooks/table02_cellular_automata_classification.ipynb) describes the classification procedure and generates the revised table.