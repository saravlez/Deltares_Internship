# Model 1: Burgers' Equation with AI-Based Bias Correction

This repository contains the implementation of AI-based bias correction methods for surrogate models, applied to the 1D Burgers' equation. 

## Directory Structure
├── Project.toml # Julia package dependencies
├── Manifest.toml # Exact package versions 
├── burgers1d_periodic.jld2 # Burgers' equation simulation data
├── trained_model.bson # Pre-trained surrogate model
├── model_1d_burgers.ipynb # Main surrogate model notebook
├── training_burgers1d.ipynb # Data generation and training
├── additive_correction/ # Additive correction method
│ ├── additive_correction_final.ipynb
│ ├── additive_correction.bson
│ └── img/ # Generated plots
├── input_correction/ # Input correction method
│ ├── input_correction_final.ipynb
│ ├── input_correction.bson
│ └── img/ # Generated plots
└── combined_correction/ # Combined method structure

### Prerequisites
- Julia 1.9+ 
- Jupyter Notebook or JupyterLab

### Running the Experiments
1. Run model_1d_burgers.ipynb to generate Burgers' equation simulation data
2. Run training_burgers1d.ipynb to train and save the neural network surrogate model 
3. Run the correction experiments with the generated trained_model.bson
     1. Additive correction
     2. Input correction
     3. Combined Structure (for additive correction for example)


Train the neural network surrogate model

Save the model as trained_model.bson
