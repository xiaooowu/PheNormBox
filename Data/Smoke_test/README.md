# Smoke-test data

This folder contains a reproducible synthetic cohort used to exercise the
generalizable PheNorm workflow without protected health information. The
simulation retains the simplest `nonrare_info` mechanism adapted from
`create_simulation_data()` in the
[PheNorm simulation code](https://github.com/Charl3456/PheNorm_public/blob/main/1_Helper_data_gen.R).

## Files

- `01_generate_smoke_data.R` regenerates and validates the synthetic cohort.
- `phenorm_smoke_test_nonrare_info.csv` is the CSV input used by
  `PheNorm_Analysis.Rmd`.
- `phenorm_smoke_test_nonrare_info.rds` stores the same data as an R object.

## Generation mechanism

The generator sets the random-number seed to `20261011` and creates `1,000`
independent observations:

1. Each observation receives a latent outcome probability drawn from a normal
   distribution with mean `0.4` and standard deviation `0.1`, truncated to the
   interval `[0, 1]`.
2. `gold_outcome` is sampled from a Bernoulli distribution using that
   observation-specific probability.
3. An ICD count is sampled from a Poisson distribution with mean `8` for cases
   and `2` for non-cases.
4. An NLP count is sampled independently from a Poisson distribution with mean
   `12` for cases and `3` for non-cases.
5. A simple random sample of `200` observations is selected without replacement
   for chart review. These rows receive `reviewed_col = 1`; all remaining rows
   receive `reviewed_col = 0`.
6. Utilization and sampling weights are set to `1` for every observation.
7. Three silver standards are constructed from the simulated counts: the ICD
   count, the NLP count, and their sum.
8. The seven predictor columns mirror the compact example in
   the root `README.md`: age is sampled uniformly from
   the integers `18` through `90`; sex is represented by a Bernoulli female
   indicator with probability `0.52`; and race is sampled as one mutually
   exclusive category (`asian`, `black`, or `white`) with probabilities `0.15`,
   `0.20`, and `0.65`.
9. The two CUI predictors are informative but noisy NLP mention counts.
   `C0000001` has Poisson mean `2.5` for cases and `0.5` for non-cases;
   `C0000002` has Poisson mean `1.5` for cases and `0.25` for non-cases.

The latent probability is deliberately excluded from the saved data so that it
cannot leak outcome information into the predictors.

## Output schema

| Variable | Description |
|---|---|
| `study_id` | Unique integer identifier from `1` through `1000`. |
| `reviewed_col` | Chart-review indicator: `0` = not reviewed, `1` = reviewed. |
| `gold_outcome` | Binary simulated outcome: `0` = not a case, `1` = case. |
| `utilization` | Constant nonnegative utilization value of `1`. |
| `sampling_weight` | Constant positive sampling weight of `1`. |
| `silver_total_icd_nlp` | Sum of the simulated ICD and NLP counts. |
| `silver_total_icd_mention` | Simulated ICD count. |
| `silver_total_nlp` | Simulated NLP count. |
| `age` | Integer age from `18` through `90`. |
| `sex_female` | Binary sex indicator: `1` = female, `0` = otherwise. |
| `race_asian` | Binary indicator for the mutually exclusive Asian race category. |
| `race_black` | Binary indicator for the mutually exclusive Black race category. |
| `race_white` | Binary indicator for the mutually exclusive White race category. |
| `C0000001` | Simulated outcome-informative CUI mention count. |
| `C0000002` | Simulated outcome-informative CUI mention count. |

All names are unique. Ordinary variable names are lowercase with underscores,
while CUI variables begin with uppercase `C`. Silver-standard names begin with
`silver_`. The script verifies the required binary values, both
outcome classes among reviewed observations, unique IDs, complete finite model
variables, nonnegative values, positive sampling weights, expected predictor
names, valid binary indicators, and mutually exclusive race indicators before
saving.

## Regenerating the files

Open `PheNorm_renv.Rproj`, ensure the project environment has been restored,
and run from the project root:

```r
source("Data/Smoke_test/01_generate_smoke_data.R")
```

Because the seed and mechanism are fixed, rerunning the script reproduces the
same CSV and RDS data. The smoke-test R Markdown file writes its rendered report
and analysis artifacts to a timestamped folder under `Result/`.
