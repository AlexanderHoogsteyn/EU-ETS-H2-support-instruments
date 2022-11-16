function solve_ps_agent!(mod::Model)
    # Extract sets
    JH = mod.ext[:sets][:JH]
    JD = mod.ext[:sets][:JD]
    JY = mod.ext[:sets][:JY]
   
    # Extract parameters
    W = mod.ext[:parameters][:W] # weight of the representative days
    if mod.ext[:parameters][:NG] == 1
        VC  = mod.ext[:parameters][:VC] = mod.ext[:parameters][:λ_NG]/mod.ext[:parameters][:η]
    else 
        VC  = mod.ext[:parameters][:VC]  
    end
    IC = mod.ext[:parameters][:IC] # overnight investment costs
    A = mod.ext[:parameters][:A] # discount factors
    CAP_SV = mod.ext[:parameters][:CAP_SV] # salvage value of new capacity
    DELTA_CAP_MAX = mod.ext[:parameters][:DELTA_CAP_MAX] # max YoY change in new capacity
    λ_EUA = mod.ext[:parameters][:λ_EUA] # EUA prices
    b_bar = mod.ext[:parameters][:b_bar] # element in ADMM penalty term related to EUA auctions
    ρ_EUA = mod.ext[:parameters][:ρ_EUA] # rho-value in ADMM related to EUA auctions
    λ_EOM = mod.ext[:parameters][:λ_EOM] # EOM prices
    g_bar = mod.ext[:parameters][:g_bar] # element in ADMM penalty term related to EOM
    ρ_EOM = mod.ext[:parameters][:ρ_EOM] # rho-value in ADMM related to EUA auctions
    λ_y_REC = mod.ext[:parameters][:λ_y_REC] # REC prices
    r_y_bar = mod.ext[:parameters][:r_y_bar] # element in ADMM penalty term related to REC auctions
    ρ_y_REC = mod.ext[:parameters][:ρ_y_REC] # rho-value in ADMM related to REC auctions
    λ_d_REC = mod.ext[:parameters][:λ_d_REC] # REC prices
    r_d_bar = mod.ext[:parameters][:r_d_bar] # element in ADMM penalty term related to REC auctions
    ρ_d_REC = mod.ext[:parameters][:ρ_d_REC] # rho-value in ADMM related to REC auctions
    λ_h_REC = mod.ext[:parameters][:λ_h_REC] # REC prices
    r_h_bar = mod.ext[:parameters][:r_h_bar] # element in ADMM penalty term related to REC auctions
    ρ_h_REC = mod.ext[:parameters][:ρ_h_REC] # rho-value in ADMM related to REC auctions
    
    # Extract variables and expressions
    cap = mod.ext[:variables][:cap]  
    g = mod.ext[:variables][:g]  
    b = mod.ext[:variables][:b]  
    r_y = mod.ext[:variables][:r_y]
    r_d = mod.ext[:variables][:r_d]
    r_h = mod.ext[:variables][:r_h]

    # Update objective
    if  mod.ext[:parameters][:REC] == 1 && mod.ext[:parameters][:ETS] == 0
        if DELTA_CAP_MAX > 0 
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*cap[jy] for jy in JY)
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY)
            - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY)
            + sum(ρ_d_REC/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY)
            + sum(ρ_h_REC/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        else
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY)
            - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY)
            + sum(ρ_d_REC/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY)
            + sum(ρ_h_REC/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        end
    elseif mod.ext[:parameters][:REC] == 0 && mod.ext[:parameters][:ETS] == 1
        if DELTA_CAP_MAX > 0 
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*cap[jy] for jy in JY)
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY)
            + sum(ρ_EUA/2*(b[jy] - b_bar[jy])^2 for jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        else
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY)
            + sum(ρ_EUA/2*(b[jy] - b_bar[jy])^2 for jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        end
    elseif mod.ext[:parameters][:REC] == 0 && mod.ext[:parameters][:ETS] == 0
        if DELTA_CAP_MAX > 0 
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*cap[jy] for jy in JY)
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        else
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        end
    else
        if DELTA_CAP_MAX > 0 
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*cap[jy] for jy in JY)
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY)
            - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY)
            + sum(ρ_EUA/2*(b[jy] - b_bar[jy])^2 for jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY)
            + sum(ρ_d_REC/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY)
            + sum(ρ_h_REC/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        else
            mod.ext[:objective] = @objective(mod, Min,
            + sum(A[jy]*W[jd]*VC[jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_EOM[jh,jd,jy]*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY)
            - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY)
            - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY)
            + sum(ρ_EUA/2*(b[jy] - b_bar[jy])^2 for jy in JY)
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY)
            + sum(ρ_d_REC/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY)
            + sum(ρ_h_REC/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY)
            )
        end
    end

    optimize!(mod);

    return mod
end