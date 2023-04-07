function build_h2s_agent!(mod::Model)
    # Extract sets
    JH = mod.ext[:sets][:JH]
    JD = mod.ext[:sets][:JD]
    JM = mod.ext[:sets][:JM]
    JY = mod.ext[:sets][:JY]
    JY_pre2030 = mod.ext[:sets][:JY_pre2030]
    JY_post2030 = mod.ext[:sets][:JY_post2030]
       
    # Extract parameters
    W = mod.ext[:parameters][:W] # weight of the representative days
    Wm = mod.ext[:parameters][:Wm] # weight of the representative days
    IC = mod.ext[:parameters][:IC] # overnight investment costs
    CI = mod.ext[:parameters][:CI] # carbon intensity
    LEG_CAP = mod.ext[:parameters][:LEG_CAP] # legacy capacity
    CAP_LT = mod.ext[:parameters][:CAP_LT] # lead time on new capacity
    CAP_SV = mod.ext[:parameters][:CAP_SV] # salvage value of new capacity
    DELTA_CAP_MAX = mod.ext[:parameters][:DELTA_CAP_MAX] # max YoY change in new capacity
    A = mod.ext[:parameters][:A] # discount factors
    η_E_H2 = mod.ext[:parameters][:η_E_H2] # efficiency E->H2
    η_NG_H2 = mod.ext[:parameters][:η_NG_H2] # efficiency NG->H2
    λ_NG = mod.ext[:parameters][:λ_NG] # natural gas price
    λ_EOM = mod.ext[:parameters][:λ_EOM] # EOM prices
    λ_EUA = mod.ext[:parameters][:λ_EUA] # ETS prices

    λ_h_H2 = mod.ext[:parameters][:λ_h_H2] # H2 prices
    λ_d_H2 = mod.ext[:parameters][:λ_d_H2] # H2 prices
    λ_m_H2 = mod.ext[:parameters][:λ_m_H2] # H2 prices
    λ_y_H2 = mod.ext[:parameters][:λ_y_H2] # H2 prices

    λ_h_REC = mod.ext[:parameters][:λ_h_REC] # REC prices
    λ_d_REC = mod.ext[:parameters][:λ_d_REC] # REC prices
    λ_m_REC = mod.ext[:parameters][:λ_m_REC] # REC prices
    λ_y_REC = mod.ext[:parameters][:λ_y_REC] # REC prices

    λ_H2CN_prod = mod.ext[:parameters][:λ_H2CN_prod] # Carbon neutral H2 generation subsidy
    λ_H2CN_cap = mod.ext[:parameters][:λ_H2CN_cap] # Carbon neutral H2 capacity subsidy



    # Extract H2 policy parameters
    max_support_duration = mod.ext[:parameters][:max_support_duration]
    H2FP_PREM = mod.ext[:parameters][:H2FP_PREM]
    λ_HPA = mod.ext[:parameters][:λ_HPA]
    is_HPA_covered = mod.ext[:parameters][:is_HPA_covered]
    H2_CAPG = mod.ext[:parameters][:H2CAP_PREM]


    # ADMM algorithm parameters
    ρ_y_REC_pre2030 = mod.ext[:parameters][:ρ_y_REC_pre2030] # rho-value in ADMM related to REC auctions
    ρ_y_REC_post2030 = mod.ext[:parameters][:ρ_y_REC_post2030] # rho-value in ADMM related to REC auctions
    ρ_m_REC_pre2030 = mod.ext[:parameters][:ρ_m_REC_pre2030] # rho-value in ADMM related to REC auctions
    ρ_m_REC_post2030 = mod.ext[:parameters][:ρ_m_REC_post2030] # rho-value in ADMM related to REC auctions
    ρ_d_REC_pre2030 = mod.ext[:parameters][:ρ_d_REC_pre2030] # rho-value in ADMM related to REC auctions
    ρ_d_REC_post2030 = mod.ext[:parameters][:ρ_d_REC_post2030] # rho-value in ADMM related to REC auctions
    ρ_h_REC_pre2030 = mod.ext[:parameters][:ρ_h_REC_pre2030] # rho-value in ADMM related to REC auctions
    ρ_h_REC_post2030 = mod.ext[:parameters][:ρ_h_REC_post2030] # rho-value in ADMM related to REC auctions
    ADD_SF = mod.ext[:parameters][:ADD_SF] 

    # Decision variables
    capH = mod.ext[:variables][:capH] = @variable(mod, [jy=JY], lower_bound=0, base_name="capacity")
    capHCN = mod.ext[:variables][:capHCN] = @variable(mod, [jy=JY], lower_bound=0, base_name="green_capacity")
    gH = mod.ext[:variables][:gH] = @variable(mod, [jh=JH,jd=JD,jy=JY], lower_bound=0, base_name="generation_hydrogen")
    gHCN = mod.ext[:variables][:gHCN] = @variable(mod, [jy=JY], lower_bound=0, base_name="generation_carbon_neutral_hydrogen")
    g = mod.ext[:variables][:g] = @variable(mod, [jh=JH,jd=JD,jy=JY], upper_bound=0, base_name="demand_electricity_hydrogen") # note this is defined as a negative number, consumption
    dNG = mod.ext[:variables][:dNG] = @variable(mod, [jy=JY], lower_bound=0, base_name="demand_natural_gas_hydrogen")
    b = mod.ext[:variables][:b] = @variable(mod, [jy=JY], lower_bound=0, base_name="EUA") 
    r_y = mod.ext[:variables][:r_y] = @variable(mod, [jy=JY], upper_bound=0, base_name="REC_y") 
    r_m = mod.ext[:variables][:r_m] = @variable(mod, [jd=JM,jy=JY], upper_bound=0, base_name="REC_m") 
    r_d = mod.ext[:variables][:r_d] = @variable(mod, [jd=JD,jy=JY], upper_bound=0, base_name="REC_d") 
    r_h = mod.ext[:variables][:r_h] = @variable(mod, [jh=JH,jd=JD,jy=JY], upper_bound=0, base_name="REC_h") 
    gH_m = mod.ext[:variables][:gH_m] = @variable(mod, [jm=JM,jy=JY],lower_bound=0, base_name="generation_hydrogen_monthly") # needs to be variable to get feasible solution with representative days (combination of days may not allow exact match of montly demand, may be infeasible)

    # Create affine expressions  
    mod.ext[:expressions][:e] = @expression(mod, [jy=JY],
        CI*dNG[jy]
    )
    mod.ext[:expressions][:gw] = @expression(mod, [jh=JH,jd=JD,jy=JY],
        W[jd]*g[jh,jd,jy]
    )
    gH_y = mod.ext[:expressions][:gH_y] = @expression(mod, [jy=JY],
        sum(W[jd]*gH[jh,jd,jy] for jh in JH, jd in JD)
    )
    gH_d = mod.ext[:expressions][:gH_d] = @expression(mod, [jd=JD,jy=JY],
        sum(gH[jh,jd,jy] for jh in JH)
    )
    mod.ext[:expressions][:gH_h_w] = @expression(mod, [jh=JH,jd=JD,jy=JY],
        W[jd]*gH[jh,jd,jy] 
    )
    mod.ext[:expressions][:gH_d_w] = @expression(mod, [jd=JD,jy=JY],
        W[jd]*sum(gH[jh,jd,jy] for jh in JH)
    )
    # Used to calculate total system cost, hence does not consider exogenous costs of the modelled comodities
    mod.ext[:expressions][:tot_cost] = @expression(mod, 
        + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*capH[jy] for jy in JY)
        + sum(A[jy]*λ_NG[jy]*dNG[jy] for jy in JY) 
    )
    # Agent revenue before  do consider all cost of an agent, including exogenous costs of the modelled comodities 
    mod.ext[:expressions][:agent_revenue_before_support] = @expression(mod, 
        - sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*capH[jy] for jy in JY)
        - sum(A[jy]*λ_NG[jy]*dNG[jy] for jy in JY)
        + sum(A[jy]*W[jd]*(λ_EOM[jh,jd,jy])*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY) # [MEUR]
        + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY)  
        + sum(A[jy]*W[jd]*λ_h_H2[jh,jd,jy]*gH[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*W[jd]*λ_d_H2[jd,jy]*gH_d[jd,jy] for jd in JD, jy in JY)
        + sum(A[jy]*λ_m_H2[jm,jy]*gH_m[jm,jy] for jm in JM, jy in JY)
        + sum(A[jy]*λ_y_H2[jy]*gH_y[jy] for jy in JY)
    )

    # Hydrogen policy costs 
    mod.ext[:expressions][:hpa_cost] = @expression(mod, 
        sum(A[jy]*is_HPA_covered[jy]*(λ_HPA[jy]
            -λ_y_H2[jy]
            -sum(λ_m_H2[jm,jy] for jm in JM)
            -sum(W[jd]*λ_d_H2[jd,jy] for jd in JD)
            -sum(W[jd]*λ_h_H2[jh,jd,jy]*gH[jh,jd,jy] for jh in JH, jd in JD))  for jy in JY)
    )
    mod.ext[:expressions][:h2f_cost] = @expression(mod, 
        sum(A[jy]*W[jd]*H2FP_PREM[jy]*gH[jh,jd,jy] for jh in JH, jd in JD, jy in JY) 
    )
    mod.ext[:expressions][:h2_cap_grant_cost] = @expression(mod, 
        sum(A[jy]*H2_CAPG[jy]*capH[jy] for jy in JY)
    )

    # Agent revenue do consider all cost of an agent, including exogenous costs of the modelled comodities
    mod.ext[:expressions][:agent_revenue_after_support] = @expression(mod, 
        mod.ext[:expressions][:agent_revenue_before_support]
        + mod.ext[:expressions][:hpa_cost]
        + mod.ext[:expressions][:h2f_cost]
        + mod.ext[:expressions][:h2_cap_grant_cost]
        + sum(A[jy]*ADD_SF[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY)
        + sum(A[jy]*λ_m_REC[jm,jy]*r_m[jm,jy] for jm in JM, jy in JY)
        + sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY)
        + sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
        + sum(A[jy]*λ_H2CN_prod[jy]*gHCN[jy] for jy in JY) 
        + sum(A[jy]*(1-CAP_SV[jy])*λ_H2CN_cap[jy]*capHCN[jy] for jy in JY)
)

    # Definition of the objective function - will be updated 
    mod.ext[:objective] = @objective(mod, Min,0)
    
    # Constraints
    mod.ext[:constraints][:gen_limit_capacity] = @constraint(mod, [jh=JH,jd=JD,jy=JY],
        gH[jh,jd,jy] <=  (sum(CAP_LT[y2,jy]*capH[y2] for y2=1:jy) + LEG_CAP[jy])/1000 # [TWh]        
    )

    # montlhly limit
    mod.ext[:constraints][:monthly_gen] = @constraint(mod, [jm=JM,jy=JY],
        gH_m[jm,jy] <= sum(Wm[jd,jm]*gH[jh,jd,jy] for jh in JH,jd in JD)
    ) 

    # Investment limits: YoY investment is limited
    mod.ext[:constraints][:cap_limit] = @constraint(mod,
        capH[1] <= DELTA_CAP_MAX*LEG_CAP[1] # [GW]
    )
    mod.ext[:constraints][:cap_limit] = @constraint(mod, [jy=2:JY[end]],
        capH[jy] <= DELTA_CAP_MAX*(sum(CAP_LT[y2,jy]*capH[y2] for y2=1:jy-1) + LEG_CAP[jy-1]) # [GW]
    )

    # Electricity consumption
    mod.ext[:constraints][:elec_consumption] = @constraint(mod, [jh=JH,jd=JD,jy=JY],
        -η_E_H2*g[jh,jd,jy] <= (sum(CAP_LT[y2,jy]*capH[y2] for y2=1:jy) + LEG_CAP[jy])/1000  # [TWh]
    )    

    # Total H2 production
    if mod.ext[:parameters][:EOM] == 1 
        mod.ext[:constraints][:gen_limit_energy_sources] = @constraint(mod, [jh=JH,jd=JD,jy=JY],
            gH[jh,jd,jy] <= -η_E_H2*g[jh,jd,jy]  # [TWh]
        )
    end

    if mod.ext[:parameters][:NG] == 1 
        mod.ext[:constraints][:gen_limit_energy_sources] = @constraint(mod, [jy=JY],
            sum(W[jd]*gH[jh,jd,jy] for jh in JH, jd in JD) <= η_NG_H2*dNG[jy] # [TWh]
        )
    end
    
    if mod.ext[:parameters][:H2CN_prod] == 1
        mod.ext[:constraints][:gen_limit_carbon_neutral] = @constraint(mod, [jy=JY],
            gHCN[jy] <=  sum(W[jd]*gH[jh,jd,jy] for jh in JH, jd in JD) # [TWh]
        )
        mod.ext[:constraints][:max_support_duration] = @constraint(mod, [jy=JY], 
            gHCN[jy] <= max_support_duration * (sum(CAP_LT[y2,jy]*capH[y2] for y2=1:jy) + LEG_CAP[jy])/1000 # [TWh]
        )
    else
        mod.ext[:constraints][:gen_limit_carbon_neutral] = @constraint(mod, [jy=JY],
            gHCN[jy] == 0 # [TWh]
        )
    end

    if mod.ext[:parameters][:H2CN_cap] == 1
        mod.ext[:constraints][:cap_limit_carbon_neutral]  = @constraint(mod, [jy=JY], 
            capHCN[jy] <= sum(CAP_LT[y2,jy]*capH[y2] for y2=1:jy) + LEG_CAP[jy] # [GW] - cap are capacity additions per year, whereas capHCN needs to be the avaiable capacity
        )
    else
        mod.ext[:constraints][:cap_limit_carbon_neutral]  = @constraint(mod, [jy=JY], 
            capHCN[jy] == 0 # [GW]
        )
    end

    if CI == 0 # Mton CO2/TWh 
        mod.ext[:constraints][:EUA_balance]  = @constraint(mod, [jy=JY], 
            b[jy] == 0 # [MtonCO2]
        )
    else
        mod.ext[:constraints][:EUA_balance]  = @constraint(mod, [jy=JY], 
            sum(b[y2] for y2=1:jy) >=  sum(CI*dNG[y2] for y2=1:jy) # [MtonCO2]
        )
    end

    # recall that g and r are negative numbers (demand for electricity or renewable electricity)
    # ρ_m_REC, ρ_d_REC, ρ_h_REC are only non-zero if additionality is enforced on those time scales
    if mod.ext[:parameters][:REC] == 1 
        if  ρ_y_REC_pre2030 > 0 
            mod.ext[:constraints][:REC_balance_yearly] = @constraint(mod, [jy=JY_pre2030],
                r_y[jy] <= -gHCN[jy]/η_E_H2 + ADD_SF[jy]*(sum(W[jd]*g[jh,jd,jy] for jh in JH, jd in JD) + gHCN[jy]/η_E_H2)
            )           
        else
            # contribution to the general RES target:
            mod.ext[:constraints][:REC_balance_yearly] = @constraint(mod, [jy=JY_pre2030],
                r_y[jy] <= ADD_SF[jy]*(sum(W[jd]*g[jh,jd,jy] for jh in JH, jd in JD) - (sum(r_m[jm,jy] for jm in JM) + sum(W[jd]*r_d[jd,jy] for jd in JD) + sum(W[jd]*r_h[jh,jd,jy] for jh in JH, jd in JD)))
            )     
        end

        if  ρ_y_REC_post2030 > 0 
            mod.ext[:constraints][:REC_balance_yearly] = @constraint(mod, [jy=JY_post2030],
               r_y[jy] <= -gHCN[jy]/η_E_H2 + ADD_SF[jy]*(sum(W[jd]*g[jh,jd,jy] for jh in JH, jd in JD) + gHCN[jy]/η_E_H2)
            )
        else
            # contribution to the general RES target:
            mod.ext[:constraints][:REC_balance_yearly] = @constraint(mod, [jy=JY_post2030],
                r_y[jy] <= ADD_SF[jy]*(sum(W[jd]*g[jh,jd,jy] for jh in JH, jd in JD) - (sum(r_m[jm,jy] for jm in JM) + sum(W[jd]*r_d[jd,jy] for jd in JD) + sum(W[jd]*r_h[jh,jd,jy] for jh in JH, jd in JD)))
            )     
        end

        mod.ext[:constraints][:REC_balance_yearly_2] = @constraint(mod, [jy=JY],
            r_y[jy] >= sum(W[jd]*g[jh,jd,jy] for jh in JH, jd in JD)
        ) 

        if  ρ_m_REC_pre2030 > 0 
            mod.ext[:constraints][:REC_balance_monthly] = @constraint(mod, [jy=JY_pre2030],
                -η_E_H2*sum(r_m[jm,jy] for jm in JM) >= gHCN[jy] 
            )
            mod.ext[:constraints][:REC_balance_monthly_2] = @constraint(mod, [jm=JM,jy=JY_pre2030],
                r_m[jm,jy] >= sum(Wm[jd,jm]*g[jh,jd,jy] for jh in JH,jd in JD)
            )
        else
            mod.ext[:constraints][:REC_balance_monthly] = @constraint(mod, [jm=JM,jy=JY_pre2030],
                r_m[jm,jy] == 0
            )   
        end

        if  ρ_m_REC_post2030 > 0 
            mod.ext[:constraints][:REC_balance_monthly] = @constraint(mod, [jy=JY_post2030],
                -η_E_H2*sum(r_m[jm,jy] for jm in JM) >= gHCN[jy] 
            )
            mod.ext[:constraints][:REC_balance_monthly_2] = @constraint(mod, [jm=JM,jy=JY_post2030],
                r_m[jm,jy] >= sum(Wm[jd,jm]*g[jh,jd,jy] for jh in JH,jd in JD)
            )
        else
            mod.ext[:constraints][:REC_balance_monthly] = @constraint(mod, [jm=JM,jy=JY_post2030],
                r_m[jm,jy] == 0
            )   
        end

        
        if  ρ_d_REC_pre2030 > 0 
            mod.ext[:constraints][:REC_balance_daily] = @constraint(mod, [jy=JY_pre2030],
                -η_E_H2*sum(W[jd]*r_d[jd,jy] for jd in JD)  >= gHCN[jy] 
            )
            mod.ext[:constraints][:REC_balance_daily_2] = @constraint(mod, [jd=JD,jy=JY_pre2030],
                r_d[jd,jy] >= sum(g[jh,jd,jy] for jh in JH)
            )
        else
            mod.ext[:constraints][:REC_balance_daily] = @constraint(mod, [jd=JD,jy=JY_pre2030],
                r_d[jd,jy] == 0 
            )
        end

        if  ρ_d_REC_post2030 > 0 
            mod.ext[:constraints][:REC_balance_daily] = @constraint(mod, [jy=JY_post2030],
                -η_E_H2*sum(W[jd]*r_d[jd,jy] for jd in JD)  >= gHCN[jy] 
            )
            mod.ext[:constraints][:REC_balance_daily_2] = @constraint(mod, [jd=JD,jy=JY_post2030],
                r_d[jd,jy] >= sum(g[jh,jd,jy] for jh in JH)
            )
        else
            mod.ext[:constraints][:REC_balance_daily] = @constraint(mod, [jd=JD,jy=JY_post2030],
                r_d[jd,jy] == 0 
            )
        end

        if  ρ_h_REC_pre2030 > 0 
            mod.ext[:constraints][:REC_balance_hourly] = @constraint(mod, [jy=JY_pre2030],
                -η_E_H2*sum(W[jd]*r_h[jh,jd,jy] for jh in JH, jd in JD) >= gHCN[jy]   
            )
            mod.ext[:constraints][:REC_balance_hourly_2] = @constraint(mod, [jh=JH,jd=JD,jy=JY_pre2030],
                r_h[jh,jd,jy] >= g[jh,jd,jy] 
            )
        else
            mod.ext[:constraints][:REC_balance_hourly] = @constraint(mod, [jh=JH,jd=JD,jy=JY_pre2030],
                r_h[jh,jd,jy] == 0 
            )
        end

        if  ρ_h_REC_post2030 > 0 
            mod.ext[:constraints][:REC_balance_hourly] = @constraint(mod, [jy=JY_post2030],
                -η_E_H2*sum(W[jd]*r_h[jh,jd,jy] for jh in JH, jd in JD) >= gHCN[jy]   
            )
            mod.ext[:constraints][:REC_balance_hourly_2] = @constraint(mod, [jh=JH,jd=JD,jy=JY_post2030],
                r_h[jh,jd,jy] >= g[jh,jd,jy] 
            )
        else
            mod.ext[:constraints][:REC_balance_hourly] = @constraint(mod, [jh=JH,jd=JD,jy=JY_post2030],
                r_h[jh,jd,jy] == 0 
            )
        end
       
    else
        mod.ext[:constraints][:REC_balance_yearly] = @constraint(mod, [jy=JY],
            r_y[jy] == 0
        )
        mod.ext[:constraints][:REC_balance_monthly] = @constraint(mod, [jm=JM,jy=JY],
            r_m[jm,jy] == 0
        )
        mod.ext[:constraints][:REC_balance_daily] = @constraint(mod, [jd=JD,jy=JY],
            r_d[jd,jy] == 0 
        )
        mod.ext[:constraints][:REC_balance_hourly] = @constraint(mod, [jh=JH,jd=JD,jy=JY],
            r_h[jh,jd,jy] == 0 
        )
    end

    return mod

end