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

### Prerequisites
- Julia 1.9+ 
- Jupyter Notebook or JupyterLab

### Running the Experiments
1. Run model_1d_burgers.ipynb to generate Burgers' equation simulation data
2. Run training_burgers1d.ipynb to train and save the neural network surrogate model 
3. Run the correction experiments with the generated trained_model.bson
