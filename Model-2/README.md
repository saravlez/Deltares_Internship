# Model 2: 1D Shallow-Water Storm Surge with Wind Stress Bias Correction

Implements **two-stage AI bias correction** for **21% systematic wind stress underestimation** in surrogate models of 1D shallow-water equations. Features realistic physics: spatially-varying bathymetry, quadratic friction, CFL-stable numerics.

## Directory Structure
- `input_data.ipynb` # Parameter sweeps + visualization
- `surrogate_multi-data.ipynb` # Surrogate training (multi-scale wind)
- `surrogate_multi-data-init.ipynb` # Multi-IC variant (flat/bump/smallbump)
- `correction_multi-data.ipynb` # Input correction training
- `wind_forcing_functions.jl` # Periodic/piecewise/AR/multi-freq wind stress functions
- `normalization-utils.jl` # Input/output normalization functions
- `utils/` 
    - `model_1d_surge_wave.jl` # Fast PDE solver
    - `wave1d_surge.jld2` # Reference simulation
    - `show_input.ipynb` # Input showcase
    - `show_surrogate.ipynb` # Surrogate diagnostics
    - `show_correction.ipynb` # Correction evaluation
- `surrogates/`: Trained surrogate models, data and visuals for short and long periods
- `config_comparison/`: 
    - `correction_multi-comparison.ipynb`: Configuration comparison loop over 6 different combinations
    - `Configuration_experiments`: Correction model data results from comparison
    - `img`: Visualization from show_correction
- `data/`: Diverse simulation and surrogate data
- `data_multiscale/`: Multi-scale wind training data
- `'Correction Comparisons of Report'/`: Report comparison results and figures
- `report_plots/`: Final report figures


### Quick Run Order
1. `input_data.ipynb` → Generates `data/*.jld2` (already done)
2. `surrogate_multi-data-init.ipynb` → Train surrogates (Surrogate_1-5, short/long)
3. `correction_multi-data.ipynb` → Train per-station corrections

**Key params at top of notebooks:**
- `wind_name`: `periodic` (default), `piecewise`, `multi-frequency`
- `TRAINSCALES`: `[0.9,1.0,1.2]` (multi-scale training)
- `global_scale=false` (per-station correction)
- `bias_factor=1.1` (true 21% wind stress bias)

### Expected Outputs
- Training loss curves + validation rollouts
- 3-station comparisons (left/middle/right)
- RMSE evolution (74-78% improvement)
- Correction factor evolution vs true bias
- Phase space plots + GIFs in `utils/`

### Large Files Notice
Surrogate_3 exceeds GitHub 100MB limit → Excluded from repo (not in report).  
Note that Surrogates 3.1/3.2 = Surrogate_5 (short/long versions).  
All other models/data available in `surrogates/` and `data/`.

