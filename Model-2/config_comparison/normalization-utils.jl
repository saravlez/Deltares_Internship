using Statistics, Plots


function normalize_with_forcing_check(X_train, X_val, norm_cols, mask_cols, tau_col_idx)
    # Normalization that handles constant or zero wind forcing + Check if τ has near-zero variance
    # - If yes: skip normalization for τ, normalize everything else
    # - If no: normalize all features including τ

    X_train_n = copy(X_train)
    X_val_n = copy(X_val)
    
    # Check if tau is constant
    tau_train = X_train[:, tau_col_idx]
    tau_std = std(tau_train)
    tau_mean = mean(tau_train)
        
    if tau_std < 1e-10
        # Tau is constant (including zero case)
        @info """
        Wind forcing is constant (mean=$tau_mean, σ=$tau_std).
        Skipping normalization for τ column. To prevent division by zero.
        """
        
        # Remove tau_col_idx from normalization columns
        norm_cols_without_tau = [c for c in norm_cols if c != tau_col_idx]
        
        # Also ensure mask_cols are excluded from normalization
        actual_norm_cols = setdiff(norm_cols_without_tau, mask_cols)
        
        if !isempty(actual_norm_cols)
            mu = mean(X_train[:, actual_norm_cols], dims=1)
            sigma = std(X_train[:, actual_norm_cols], dims=1) .+ 1e-8
            
            X_train_n[:, actual_norm_cols] = (X_train[:, actual_norm_cols] .- mu) ./ sigma
            X_val_n[:, actual_norm_cols] = (X_val[:, actual_norm_cols] .- mu) ./ sigma
        else
            mu = zeros(1, 0)
            sigma = ones(1, 0)
        end
        
        # For consistency with full normalization, create full mu/sigma arrays
        mu_full = zeros(1, length(norm_cols))
        sigma_full = ones(1, length(norm_cols))
        
        # Fill in computed values for non-tau columns
        for (i, col) in enumerate(norm_cols)
            if col != tau_col_idx && !(col in mask_cols)
                idx_in_subset = findfirst(==(col), actual_norm_cols)
                if !isnothing(idx_in_subset)
                    mu_full[i] = mu[idx_in_subset]
                    sigma_full[i] = sigma[idx_in_subset]
                end
            else
                # For tau column and mask columns, use identity transformation
                mu_full[i] = 0.0
                sigma_full[i] = 1.0
            end
        end
        
        return X_train_n, X_val_n, mu_full, sigma_full
    else
        # Normal case: normalize all including tau, but exclude mask_cols
        @info """
        Wind forcing is varying (mean=$tau_mean, σ=$tau_std).
        Using standard normalization for all features.
        """
        
        # Ensure mask_cols are excluded from normalization
        actual_norm_cols = setdiff(norm_cols, mask_cols)
        X_train_n, X_val_n, mu, sigma = robust_normalization(X_train, X_val, actual_norm_cols, mask_cols)
        
        # Create full mu/sigma arrays for all norm_cols
        mu_full = zeros(1, length(norm_cols))
        sigma_full = ones(1, length(norm_cols))
        
        for (i, col) in enumerate(norm_cols)
            if !(col in mask_cols)
                idx_in_subset = findfirst(==(col), actual_norm_cols)
                if !isnothing(idx_in_subset)
                    mu_full[i] = mu[idx_in_subset]
                    sigma_full[i] = sigma[idx_in_subset]
                end
            end
        end
        
        return X_train_n, X_val_n, mu_full, sigma_full
    end
end

function robust_normalization(X_train, X_val, norm_cols, mask_cols)
    # Standard normalization 
    # 1. Handles near-constant features (adds eps to prevent division by ~0)
    # 2. Preserves mask columns (binary values) AND amplitude scaling factor A
    # 3. Checks for NaN/Inf in statistics
    # 4. Verifies mask columns and A unchanged after normalization

    X_train_n = copy(X_train)
    X_val_n = copy(X_val)
    
    # Filter norm_cols to exclude mask_cols (in case they were accidentally included)
    actual_norm_cols = setdiff(norm_cols, mask_cols)
    
    # Compute statistics only on columns to actually normalize
    mu = mean(X_train[:, actual_norm_cols], dims=1)
    sigma = std(X_train[:, actual_norm_cols], dims=1)
    
    # Handle near-constant features (avoid division by ~0)
    eps = 1e-8
    sigma = max.(sigma, eps)
    
    # Check for problematic values in statistics
    if any(isnan.(mu))
        error("NaN detected in mean statistics! Check input data.")
    end
    if any(isnan.(sigma))
        error("NaN detected in std statistics! Check input data.")
    end
    if any(isinf.(mu))
        error("Inf detected in mean statistics! Check input data.")
    end
    if any(isinf.(sigma))
        error("Inf detected in std statistics! Check input data.")
    end
    
    # Normalize only the actual_norm_cols
    X_train_n[:, actual_norm_cols] = (X_train[:, actual_norm_cols] .- mu) ./ sigma
    X_val_n[:, actual_norm_cols] = (X_val[:, actual_norm_cols] .- mu) ./ sigma
    
    # Verify mask and A preservation (critical check)
    if !all(X_train_n[:, mask_cols] .== X_train[:, mask_cols])
        println("Mask columns in training data:")
        println("Original: ", unique(X_train[:, mask_cols]))
        println("Normalized: ", unique(X_train_n[:, mask_cols]))
        error("Mask or A columns were altered during normalization! Check mask_cols definition.")
    end
    if !all(X_val_n[:, mask_cols] .== X_val[:, mask_cols])
        error("Validation mask or A columns were altered! Check mask_cols definition.")
    end
    
    # Check for NaN in normalized data
    if any(isnan.(X_train_n))
        @warn "NaN detected in normalized training data!"
        println("NaN locations in training data:")
        for i in 1:size(X_train_n, 1)
            for j in 1:size(X_train_n, 2)
                if isnan(X_train_n[i, j])
                    println("  Row $i, Column $j")
                end
            end
        end
    end
    if any(isnan.(X_val_n))
        @warn "NaN detected in normalized validation data!"
    end
    
    return X_train_n, X_val_n, mu, sigma
end

# ============================================================================

function denormalize_output(Y_norm, mu_Y, sigma_Y, norm_cols_Y)
    # Convert normalized outputs back to original scale
    Y = copy(Y_norm)
    Y[:, norm_cols_Y] = Y_norm[:, norm_cols_Y] .* sigma_Y .+ mu_Y
    return Y
end

function normalize_input(X, mu_X, sigma_X, norm_cols_X, mask_cols_X)
    # Normalize new input data using pre-computed statistics
    X_norm = copy(X)
    X_norm[:, norm_cols_X] = (X[:, norm_cols_X] .- mu_X) ./ sigma_X
    
    # Verify mask unchanged
    @assert all(X_norm[:, mask_cols_X] .== X[:, mask_cols_X]) "Mask altered!"
    
    return X_norm
end

function visualize_normalization(X_before, X_after, col_idx; name="Feature")
    # Plot feature distribution before and after normalization
    p1 = histogram(X_before[:, col_idx], bins=30, xlabel="Value", ylabel="Count", title="Before Normalization", legend=false)
    p2 = histogram(X_after[:, col_idx], bins=30, xlabel="Value", ylabel="Count", title="After Normalization", legend=false)
    p = plot(p1, p2, layout=(1, 2), size=(800, 300), plot_title="$name (Column $col_idx)")
    return p
end

