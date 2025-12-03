# AI-Based Bias Correction for Surrogate Storm Surge Models

This repository contains the code and results from Sara Velez's MSc internship at **Deltares** (HAF Department), developing **two-stage AI correction methods** for systematic wind stress bias in surrogate models. Two test cases validate the approach:

- **Model 1**: Burgers' equation (20% input bias) - controlled validation
- **Model 2**: 1D shallow-water equations with wind forcing (21% wind stress bias) - realistic storm surge physics

### Repository Structure
- `Model-1/`:  Burgers' equation validation
- `Model-2/`:  Storm surge (shallow-water) application
- `Project.toml`:  Julia dependencies
- `Manifest.toml`:  Reproducible package versions

### Prerequisites

- Julia 1.9
- JupyterLab (for `.ipynb` notebooks)
- Install dependencies: `julia --project=. -e 'using Pkg; Pkg.instantiate()'`

### Quick Start

1. Model 1 (Burgers): See `Model-1/README.md`
2. Model 2 (Storm Surge): See `Model-2/README.md`
3. Full Report: [`Internship_Report_SaraVelez.pdf`](Internship_Report_SaraVelez.pdf)

### Contact 
Please feel free to email me at saravlezfue@gmail.com if you have any questions or need additional information.
