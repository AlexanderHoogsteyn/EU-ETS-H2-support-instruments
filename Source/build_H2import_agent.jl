function build_h2import_agent!(mod)
    # Extract sets
    JH = mod.ext[:sets][:JH]
    JD = mod.ext[:sets][:JD]
    JM = mod.ext[:sets][:JM]
    JY = mod.ext[:sets][:JY]
    
    # Extract parameters
    W = mod.ext[:parameters][:W] # weight of the representative days
    Wm = mod.ext[:parameters][:Wm] # weight of the representative days
    A = mod.ext[:parameters][:A]
    As = mod.ext[:parameters][:As]
    λ_h_H2 = mod.ext[:parameters][:λ_h_H2] # H2 prices
    gH_h_bar = mod.ext[:parameters][:gH_h_bar] # element in ADMM penalty term related to hydrogen market
    ρ_h_H2 = mod.ext[:parameters][:ρ_h_H2] # rho-value in ADMM related to H2 market
    λ_d_H2 = mod.ext[:parameters][:λ_d_H2] # H2 prices
    gH_d_bar = mod.ext[:parameters][:gH_d_bar] # element in ADMM penalty term related to hydrogen market
    ρ_d_H2 = mod.ext[:parameters][:ρ_d_H2] # rho-value in ADMM related to H2 market
    λ_m_H2 = mod.ext[:parameters][:λ_m_H2] # H2 prices
    gH_m_bar = mod.ext[:parameters][:gH_m_bar] # element in ADMM penalty term related to hydrogen market
    ρ_m_H2 = mod.ext[:parameters][:ρ_m_H2] # rho-value in ADMM related to H2 market
    λ_y_H2 = mod.ext[:parameters][:λ_y_H2] # H2 prices
    gH_y_bar = mod.ext[:parameters][:gH_y_bar] # element in ADMM penalty term related to hydrogen market
    ρ_y_H2 = mod.ext[:parameters][:ρ_y_H2] # rho-value in ADMM related to H2 market
    ADD_SF = mod.ext[:parameters][:ADD_SF] 
    SF = mod.ext[:parameters][:SF]
    α_1 = mod.ext[:parameters][:α_1]
    α_2 = mod.ext[:parameters][:α_2]
    LT = mod.ext[:parameters][:LT]

    # Decision variables
    gH = mod.ext[:variables][:gH] = @variable(mod, [jh=JH,jd=JD,jy=JY], lower_bound=0, base_name="generation_hydrogen") 
    
    # Create affine expressions 
    gH_y = mod.ext[:expressions][:gH_y] = @expression(mod, [jy=JY],
    sum(W[jd]*gH[jh,jd,jy] for jh in JH, jd in JD)
    )
    gH_d = mod.ext[:expressions][:gH_d] = @expression(mod, [jd=JD,jy=JY],
    sum(gH[jh,jd,jy] for jh in JH)
    )
    gH_h_w = mod.ext[:expressions][:gH_h_w] = @expression(mod, [jh=JH,jd=JD,jy=JY],
    W[jd]*gH[jh,jd,jy] 
    )
    gH_d_w = mod.ext[:expressions][:gH_d_w] = @expression(mod, [jd=JD,jy=JY],
    W[jd]*sum(gH[jh,jd,jy] for jh in JH)
    )
    gH_m = mod.ext[:variables][:gH_m] = @expression(mod, [jm=JM,jy=JY],
    sum(Wm[jd]*sum(gH[jh,jd,jy] for jh in JH) for jd in JD)
    )

    capH = mod.ext[:variables][:capH] = @expression(mod, [jy=JY], 0)

    mod.ext[:expressions][:tot_cost] = @expression(mod, 
    sum(A[jy]*SF[jy]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
    )


    if ρ_h_H2 > 0 
        mod.ext[:expressions][:agent_revenue_before_support] = @expression(mod,
        - sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*W[jd]*gH[jh,jd,jy]*λ_h_H2[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
        )

        # Objective
        @objective(mod, Min,
        + sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        - sum(A[jy]*W[jd]*gH[jh,jd,jy]*λ_h_H2[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
        + sum(ρ_h_H2/2*W[jd]*(gH[jh,jd,jy] - gH_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY) 
        )
    elseif ρ_d_H2 > 0
        mod.ext[:expressions][:agent_revenue_before_support] = @expression(mod,
        - sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*W[jd]*λ_d_H2[jd,jy]*gH_d[jd,jy] for jd in JD, jy in JY)
        )

        # Objective
        @objective(mod, Min,
        + sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        - sum(A[jy]*W[jd]*λ_d_H2[jd,jy]*gH_d[jd,jy] for jd in JD, jy in JY)
        + sum(ρ_d_H2/2*W[jd]*(gH_d[jd,jy] - gH_d_bar[jd,jy])^2 for jd in JD, jy in JY) 
        )
    elseif ρ_m_H2 > 0
        mod.ext[:expressions][:agent_revenue_before_support] = @expression(mod,
        - sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*λ_m_H2[jm,jy]*gH_m[jm,jy] for jm in JM, jy in JY)
        )

        # Objective
        @objective(mod, Min,
        + sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        - sum(A[jy]*λ_m_H2[jm,jy]*gH_m[jm,jy] for jm in JM, jy in JY)
        + sum(ρ_m_H2/2*(gH_m[jm,jy] - gH_m_bar[jm,jy])^2 for jm in JM, jy in JY) 
        )
    elseif ρ_y_H2 > 0
        mod.ext[:expressions][:agent_revenue_before_support] = @expression(mod,
        - sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*λ_y_H2[jy]*gH_y[jy] for jy in JY)
        )

        # Objective
        @objective(mod, Min,
        + sum(A[jy]*SF[jy]*W[jd]*(α_2*gH[jh,jd,jy]+ α_1)*gH[jh,jd,jy]  for jh in JH, jd in JD, jy in JY)
        - sum(A[jy]*λ_y_H2[jy]*gH_y[jy] for jy in JY)
        + sum(ρ_y_H2/2*(gH_y[jy] - gH_y_bar[jy])^2 for jy in JY) 
        )
    end

    mod.ext[:constraints][:leadtime] = @constraint(mod, [jh=JH,jd=JD,jy=1:LT],
        gH[jh,jd,jy] == 0
    )

    mod.ext[:constraints][:daily_dispatch] = @constraint(mod, [jh=JH,jd=JD,jy=JY],
    gH[1,jd,jy] == gH[jh,jd,jy]
    )

    mod.ext[:expressions][:agent_revenue_after_support] = @expression(mod,
    mod.ext[:expressions][:agent_revenue_before_support]
    + 0
    )
    
    optimize!(mod);
    
    return mod
    end
    