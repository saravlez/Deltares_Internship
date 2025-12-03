using OrdinaryDiffEq, ComponentArrays, Plots, JLD2, Flux, Random, Statistics, ProgressMeter, StatsBase, ParameterSchedulers, Distributions
using ParameterSchedulers: Stateful

# ============================================================================

function make_tau_ou(; amplitude=1.0, theta=0.5, sigma=0.3, dt=60.0, seed=nothing)
    # Creates an Ornstein-Uhlenbeck wind stress forcing function
    # Stochastic differential equation: dτ = θ(μ - τ)dt + σ dW  where W is a Wiener process (Brownian motion)

    # - amplitude: Long-term mean wind stress (μ)
    # - theta: Mean reversion rate (higher = faster return to mean)
    # - sigma: Volatility (noise magnitude as fraction of amplitude)
    
    if !isnothing(seed)
        Random.seed!(seed)
    end
    
    # Initialize state using Refs for mutability in closure
    tau_current = Ref(amplitude)
    t_last = Ref(0.0)
    initialized = Ref(false)
    
    function tau_ou(t)
        # Initialize on first call
        if !initialized[]
            tau_current[] = amplitude
            t_last[] = 0.0
            initialized[] = true
        end
        
        # Handle backward time jumps (reset)
        if t < t_last[]
            tau_current[] = amplitude
            t_last[] = 0.0
        end
        
        # Simulate forward to requested time
        while t_last[] < t
            # Euler-Maruyama discretization of OU process
            drift = theta * (amplitude - tau_current[])
            diffusion = sigma * sqrt(dt) * randn()
            
            tau_current[] = tau_current[] + drift * dt + diffusion
            
            # Physical constraint: wind stress must be non-negative
            tau_current[] = max(0.0, tau_current[])
            t_last[] += dt
        end
        
        return tau_current[]
    end
    
    return tau_ou
end

# ============================================================================

function make_tau_multifreq(; amplitude=1.0, periods=[6*3600, 8*3600, 12*3600], weights=[0.4, 0.4, 0.2], phases=nothing, seed=nothing)
    # Wind stress as sum of multiple sinusoidal components with different periods,
    # Model: τ(t) = Σᵢ wᵢ × (amplitude × sin(2πt/Tᵢ + φᵢ))²

    # - amplitude:: Base amplitude for all components
    # - periods: Periods in seconds for each component
    # - weights: Relative weights for each component (normalized)
    # - phases: Phase offsets (randomized if nothing)

    # Generate random phases if not provided
    if !isnothing(seed) && isnothing(phases)
        Random.seed!(seed)
        phases = [2π * rand() for _ in 1:length(periods)]
    elseif isnothing(phases)
        phases = zeros(length(periods))
    end
    
    # Normalize weights to sum to 1
    weights = weights ./ sum(weights)
    
    return t -> begin
        tau = 0.0
        for (period, weight, phase) in zip(periods, weights, phases)
            tau += weight * (amplitude * sin(2π * t / period + phase))^2
        end
        return tau
    end
end

# ============================================================================

function make_tau_piecewise(; amplitude=1.0, avg_duration=3600.0, noise_level=0.3, seed=nothing)
    # Wind stress that stays constant for random durations then jumps to new value,
    # Model: τ(t) = constant value that changes at random intervals
    # New value = amplitude + noise_level × amplitude × N(0,1)

    # - amplitude: Base wind stress level
    # - avg_duration: Average duration between changes (seconds)
    # - noise_level: Relative noise level (0.3 = ±30%)

    if !isnothing(seed)
        Random.seed!(seed)
    end
    
    next_change_time = Ref(0.0)
    current_tau = Ref(amplitude)
    
    return t -> begin
        if t >= next_change_time[]
            # Duration until next change (uniform between 0.5x and 1.5x avg)
            duration = avg_duration * (0.5 + rand())
            next_change_time[] = t + duration
            
            # New wind stress value (random walk around amplitude)
            variation = noise_level * amplitude * randn()
            current_tau[] = max(0.0, amplitude + variation)
        end
        
        return current_tau[]
    end
end

# ============================================================================

function make_tau_ar(; amplitude=1.0, coeffs=[0.7, 0.2], sigma=0.2, dt=60.0, seed=nothing)
    # Autoregressive process for wind stress, Model: τₜ = Σᵢ φᵢ×τₜ₋ᵢ + εₜ  where εₜ ~ N(0, σ²)

    # - amplitude: Mean level (used for initialization)
    # - coeffs: AR coefficients [φ₁, φ₂, ..., φₚ]
    # - sigma: Noise standard deviation (as fraction of amplitude)

    if !isnothing(seed)
        Random.seed!(seed)
    end
    
    p = length(coeffs)
    history = fill(amplitude, p)
    t_last = Ref(-dt)
    
    return t -> begin
        # Time step forward if needed
        while t_last[] < t
            tau_new = sum(coeffs .* history) + sigma * amplitude * randn()
            tau_new = max(0.0, tau_new)
            
            # Update history 
            push!(history, tau_new)
            popfirst!(history)
            
            t_last[] += dt
        end
        
        return history[end]
    end
end

# ============================================================================

function make_tau_zero()
    # Zero wind forcing 
    return t -> 0.0
end

# ============================================================================

function make_tau_constant(; amplitude=1.0)
    # Constant wind stress
    return t -> amplitude
end

# ============================================================================

function make_tau_periodic(amplitude=1.0, period=8*3600.0)
    # Original periodic wind forcing (squared sine wave)
    return t -> (amplitude * sin(2π * t / period))^2
end

# ============================================================================

function visualize_forcing(tau, times; title="Wind Stress Forcing")
    # Plot wind stress forcing over time
    tau_values = [tau(t) for t in times]
    p = plot(times ./ 3600, tau_values, xlabel="Time (hours)", ylabel="Wind Stress τ", title=title, lw=2, legend=false)
    return p
end

function compare_forcings(forcing_dict, times)
    default_colors = Dict("Nominal" => cur_colors[4], "True, Bias 1.1" => cur_colors[1])
    
    # Compare multiple forcing types on same plot
    p = plot(xlabel="Time (hours)", ylabel="Wind Stress τ", title="Comparison of Forcing Types", legend=:topright)

    for (name, tau) in forcing_dict
        tau_values = [tau(t) for t in times]
        color = get(default_colors, name, nothing)  
        plot!(p, times ./ 3600, tau_values, label=name, lw=2, color=color)
    end
    return p
end
