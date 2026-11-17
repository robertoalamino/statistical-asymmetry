from pathlib import Path

import numpy as np

RUNS = 3000

def load_stats(directory):
    path = Path(directory)
    totals = np.loadtxt(path / "Bdata.txt")
    squared_totals = np.loadtxt(path / "VBdata.txt")
    assert totals.shape == squared_totals.shape == (5, 100), directory
    assert np.isfinite(totals).all() and np.isfinite(squared_totals).all(), directory

    mean = totals / RUNS
    variance = squared_totals / RUNS - mean**2
    assert (variance >= -1e-12).all(), directory
    return mean, np.sqrt(np.maximum(variance, 0))

archived_mean, archived_sd = load_stats("reference/figure10")
new_mean, new_sd = load_stats("outputs/figure10_full")

mean_difference = new_mean - archived_mean
combined_se = np.sqrt((archived_sd**2 + new_sd**2) / RUNS)
standardized = mean_difference / combined_se

labels = ("H translation", "V translation", "H reflection",
          "V reflection", "Rotation")

print(f"{'Measurement':<16} {'Mean bias':>11} {'Mean RMSE':>11} "
      f"{'SD RMSE':>11} {'Max |z|':>9}")
for row, label in enumerate(labels):
    delta = mean_difference[row]
    sd_delta = new_sd[row] - archived_sd[row]
    print(f"{label:<16} {delta.mean():11.6f} "
          f"{np.sqrt(np.mean(delta**2)):11.6f} "
          f"{np.sqrt(np.mean(sd_delta**2)):11.6f} "
          f"{np.max(np.abs(standardized[row])):9.2f}")

print("\nRotation band diagnostics")
print(f"Archived mean SD: {archived_sd[4].mean():.6f}")
print(f"New mean SD:      {new_sd[4].mean():.6f}")
print(f"Signed SD bias:   {(new_sd[4] - archived_sd[4]).mean():+.6f}")