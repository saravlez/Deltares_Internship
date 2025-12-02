# Model 1: Burgers' Equation with AI-Based Bias Correction

This repository contains the implementation of AI-based bias correction methods for surrogate models, applied to the 1D Burgers' equation. 

## Directory Structure
- Project.toml : Julia package dependencies
- Manifest.toml # Exact package versions 
- burgers1d_periodic.jld2 : Burgers' equation simulation data
- trained_model.bson : Pre-trained surrogate model
- model_1d_burgers.ipynb : Main surrogate model notebook
- training_burgers1d.ipynb : Data generation and training
- additive_correction/additive_correction_final.ipynb : Additive correction method
- input_correction/input_correction_final.ipynb : Input correction method
- combined_correction/combined_model_final.ipynb : Combined method structure

## Running the Experiments
1. First run `model_1d_burgers.ipynb` to generate Burgers' equation simulation data (generates `burgers1d_periodic.jld2`)
2. Then run `training_burgers1d.ipynb` to train and save the neural network surrogate model (creates `trained_model.bson`)
3. Finally, run the correction notebooks from the pre-trained model

### Prerequisites
- Julia 1.9+ 
- Jupyter Notebook or JupyterLab

## Expected Outputs
- `img/` directories with plots in each correction folder
- Loss curves, RMSE plots, spatial snapshots, time series 
- GIF animations of the simulations
- Updated `.bson` files for correction models
