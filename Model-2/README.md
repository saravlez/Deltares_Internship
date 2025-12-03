# Model 2: 1D Shallow-Water Storm Surge with Wind Stress Bias Correction

Implements **two-stage AI bias correction** for **21% systematic wind stress underestimation** in surrogate models of 1D shallow-water equations. Features realistic physics: spatially-varying bathymetry, quadratic friction, CFL-stable numerics.

## Directory Structure
- `input_data.ipynb` # Parameter sweeps + visualization
- `wind_forcing_functions.jl` # Periodic/piecewise/AR/multi-freq wind
- `normalization-utils.jl` # Input/output normalization
- `surrogate_multi-data.ipynb` # Surrogate training (multi-scale wind)
- `surrogate_multi-data-init.ipynb` # Multi-IC variant (flat/bump/smallbump)
- `correction_multi-data.ipynb` # Per-station input correction training
- `utils/` 
    - `model_1d_surge_wave.jl` # Fast PDE solver
    - `wave1d_surge.jld2` # Reference simulation
    - `show_input.ipynb` # Input showcase for predefined configuration
    - `show_surrogate.ipynb` # Surrogate diagnostics and visualization
    - `show_correction.ipynb` # Correction results + RMSE analysis
- `surrogates/`: Trained surrogate models, data and visuals for short and long periods
- `config_comparison/`: 
    - `correction_multi-comparison.ipynb`: Configuration comparison loop over 6 different combinations
    - `Configuration_experiments`: Correction model data results from comparison
    - `img`: Visualization from show_correction
- `data/`: Diverse simulation and surrogate data
- `data_multiscale/`: Multi-scale wind training data
- `'Correction Comparisons of Report'/`: Report correction comparison results and figures
- `report_plots/`: Final report figures


## Running the Experiments
 1. Numerical Simulation + Data : first run `input_data.ipynb` to generate the different frameworks (all already in `data` folder)
 2. Train Surrogate : then define the framework at the top of `surrogate_multi-data-init.ipynb` and run complete notebook (until surrogate 5 it is done for flat IC and short and long time)
 3. Train Correction : Finally, run `correction_multi-data.ipynb` with a similar framework


## Large Files Notice

One surrogate model exceeds GitHub’s 100 MB limit. Because of this, the file is **not stored directly in the repository**, surrogate 3 in the code which was not included in the report. Note how 3.1 and 3.2 correspond to 5 short and 5 long.   
All other surrogate model files are saved normally on `data` and `surrogates`
