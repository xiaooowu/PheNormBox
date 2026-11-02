# PheNorm Smoke-Test Modifications

This file records modifications made after running the original PheNorm scripts against the synthetic smoke-test data in `../Test`.

The original files are preserved unchanged. Modified copies use a `Modified_` filename prefix.

## Smoke-test environment

- Test date: 2026-10-11
- Data-generating mechanism: `create_simulation_data()` from `Charl3456/PheNorm_public/1_Helper_data_gen.R`
- Scenario: simplified/ideal, `nonrare_info`
- Total records: 1,000
- Training records: 800
- Chart-reviewed test records: 200
- Random seed: `20261011`

## Original-script results before modification

| Stage | Original file | Result |
|---|---|---|
| Data processing | `01_process_data.R` | Passed |
| PheNorm fitting | `02_run_phenorm.R` | Passed |
| Internal evaluation | `03_get_results.R` | Passed, with nonfatal plotting warnings about one missing/out-of-range ROC row |
| Full-cohort prediction | `04_get_predicted_probabilities.R` | Failed while creating the command-line parser |

## Modification 1: duplicated `--seed` option

### Original file

`04_get_predicted_probabilities.R`

### Modified copy

`Modified_04_get_predicted_probabilities.R`

### Observed error

```text
Error in validityMethod(object) : duplicate long flag: --seed
Calls: add_option ... isTRUE -> validityMethod -> option_conflict_error_stop
Execution halted
```

### Cause

The original script calls `add_option(parser, "--seed", ...)` twice: first with a default of `1234`, and later with a default of `4747`. `optparse` requires each long flag to be unique and stops before reading any analysis data.

### Change

The second, duplicated `add_option(parser, "--seed", ...)` call was removed from the modified copy. The first definition remains, and the smoke-test runner explicitly supplies `--seed 20261011`.

The modified location is marked inline with:

```r
# MODIFICATION 1 (2026-10-11):
```

### Scope

No other modeling behavior was changed in this modified copy. This portable `renv` project additionally anchors the copied entry scripts at `PheNorm_renv.Rproj` with `here::here()` and routes their default data/output directories beneath `Data/`. The original script's behavior of writing sequential row numbers under the configured study-ID column name remains unchanged and should not be interpreted as preserving source patient IDs.

### Verification after modification

The modified copy completed successfully with exit status zero. The full R Markdown smoke test then reran all four internal stages in separate R processes and completed successfully:

| Stage | Script used | Exit status |
|---|---|---:|
| Data processing | `01_process_data.R` | 0 |
| PheNorm fitting | `02_run_phenorm.R` | 0 |
| Internal evaluation | `03_get_results.R` | 0 |
| Full-cohort prediction | `Modified_04_get_predicted_probabilities.R` | 0 |

The rendered report is `../Test/PheNorm_Smoke_Test.html`. Prepared input is stored in `../Data/Smoke_test/`; each run's analysis objects, results, and console logs are stored in a timestamped `../Test/Smoke_test_result_YYYYMMDD_HHMMSS/` folder.

## Nonfatal observations not modified

1. `03_get_results.R` emitted four plotting warnings stating that one missing or out-of-range row was removed by `geom_line()`. The stage still completed and wrote all expected result files. These warnings occur at metric-curve boundary values and were not treated as a runtime failure.
2. `02_run_phenorm.R` refers to nonexistent `analysis_data$train` when calculating the inflated training size. For this 800-row training set, the intended `13 * 800 = 10,400` and the expression's effective fallback both resolve to the hard minimum of `100,000`, so the smoke-test result is unaffected. This was not modified because it did not cause this test to fail.
   1. change nrow(analysis_data$train) to length(analysis_data$train_ids).
3. The stage-4 output uses sequential row numbers under the study-ID heading rather than reading the original IDs. The simulated IDs are also sequential `1` through `1000`, so this specific smoke test cannot expose a mismatch. The behavior remains unchanged and should be corrected before using data with nonsequential identifiers.
