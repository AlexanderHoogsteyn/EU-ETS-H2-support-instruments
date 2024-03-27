function solve_h2s_agent!(mod::Model)
   # Extract sets
   JH = mod.ext[:sets][:JH]
   JD = mod.ext[:sets][:JD]
   JM = mod.ext[:sets][:JM]
   JY = mod.ext[:sets][:JY]
   JT= mod.ext[:sets][:JT]
   JY_pre2030 = mod.ext[:sets][:JY_pre2030]
   JY_post2030 = mod.ext[:sets][:JY_post2030]
   JY_post2040 = mod.ext[:sets][:JY_post2040]
   
   # Extract parameters 
   W = mod.ext[:parameters][:W] # weight of the representative days
   Wm = mod.ext[:parameters][:Wm] 
   IC = mod.ext[:parameters][:IC] # overnight investment costs
   CAP_SV = mod.ext[:parameters][:CAP_SV] # salvage value of new capacity
   A = mod.ext[:parameters][:A] # discount factors
   I = mod.ext[:parameters][:I] # discount factors
   
   # Extract variables and expressions
   capH = mod.ext[:variables][:capH] 
   capHCN = mod.ext[:variables][:capHCN]
   gHCN = mod.ext[:variables][:gHCN]

    
    # Expressions to compute objective
    if mod.ext[:parameters][:EOM] == 1
        λ_EOM = mod.ext[:parameters][:λ_EOM] # EOM prices
        g_bar = mod.ext[:parameters][:g_bar] # element in ADMM penalty term related to EOM
        ρ_EOM = mod.ext[:parameters][:ρ_EOM] # rho-value in ADMM related to EUA auctions
        g = mod.ext[:variables][:g] 

        EOM_obj = mod.ext[:expressions][:EOM_obj] = @expression(mod,
            - sum(A[jy]*W[jd]*(λ_EOM[jh,jd,jy])*g[jh,jd,jy] for jh in JH, jd in JD, jy in JY) # [MEUR]
            + sum(ρ_EOM/2*W[jd]*(g[jh,jd,jy] - g_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY) 
        )
    else 
        EOM_obj = mod.ext[:expressions][:EOM_obj] = @expression(mod,
            0
        )
    end

    if mod.ext[:parameters][:REC] == 1
        ADD_SF = mod.ext[:parameters][:ADD_SF] 
        λ_y_REC = mod.ext[:parameters][:λ_y_REC] # REC prices
        r_y_bar = mod.ext[:parameters][:r_y_bar] # element in ADMM penalty term related to REC auctions
        ρ_y_REC = mod.ext[:parameters][:ρ_y_REC] # rho-value in ADMM related to REC auctions
        ρ_h_REC_pre2030 = mod.ext[:parameters][:ρ_h_REC_pre2030] # rho-value in ADMM related to REC auctions
        ρ_d_REC_pre2030 = mod.ext[:parameters][:ρ_d_REC_pre2030] # rho-value in ADMM related to REC auctions
        ρ_m_REC_pre2030 = mod.ext[:parameters][:ρ_m_REC_pre2030] # rho-value in ADMM related to REC auctions
        ρ_h_REC_post2030 = mod.ext[:parameters][:ρ_h_REC_post2030] # rho-value in ADMM related to REC auctions
        ρ_d_REC_post2030 = mod.ext[:parameters][:ρ_d_REC_post2030] # rho-value in ADMM related to REC auctions
        ρ_m_REC_post2030 = mod.ext[:parameters][:ρ_m_REC_post2030] # rho-value in ADMM related to REC auctions
        r_y = mod.ext[:variables][:r_y] 

        if ρ_h_REC_pre2030 > 0 
            λ_h_REC = mod.ext[:parameters][:λ_h_REC] # REC prices
            r_h_bar = mod.ext[:parameters][:r_h_bar] # element in ADMM penalty term related to REC auctions
            r_h = mod.ext[:variables][:r_h] 

            REC_obj_pre2030 = mod.ext[:expressions][:REC_obj_pre2030] = @expression(mod,
                - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY_pre2030)
                + sum(ρ_h_REC_pre2030/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY_pre2030)
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_pre2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_pre2030)
            )
        elseif ρ_d_REC_pre2030 > 0 
            λ_d_REC = mod.ext[:parameters][:λ_d_REC] # REC prices
            r_d_bar = mod.ext[:parameters][:r_d_bar] # element in ADMM penalty term related to REC auctions
            r_d = mod.ext[:variables][:r_d]  

            REC_obj_pre2030 = mod.ext[:expressions][:REC_obj_pre2030] = @expression(mod,
                - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY_pre2030)
                + sum(ρ_d_REC_pre2030/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY_pre2030)
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_pre2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_pre2030)
            )
            
        elseif ρ_m_REC_pre2030 > 0 
            λ_m_REC = mod.ext[:parameters][:λ_m_REC] # REC prices
            r_m_bar = mod.ext[:parameters][:r_m_bar] # element in ADMM penalty term related to REC auctions
            r_m = mod.ext[:variables][:r_m] 

            REC_obj_pre2030 = mod.ext[:expressions][:REC_obj_pre2030] = @expression(mod,
                - sum(A[jy]*λ_m_REC[jm,jy]*r_m[jm,jy] for jm in JM, jy in JY_pre2030)
                + sum(ρ_m_REC_pre2030/2*(r_m[jm,jy] - r_m_bar[jm,jy])^2 for jm in JM, jy in JY_pre2030)
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_pre2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_pre2030)
            )
        else
            REC_obj_pre2030 = mod.ext[:expressions][:REC_obj_pre2030] = @expression(mod,
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_pre2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_pre2030)
            )
        end

        if ρ_h_REC_post2030 > 0 
            λ_h_REC = mod.ext[:parameters][:λ_h_REC] # REC prices
            r_h_bar = mod.ext[:parameters][:r_h_bar] # element in ADMM penalty term related to REC auctions
            r_h = mod.ext[:variables][:r_h] 

            REC_obj_post2030 = mod.ext[:expressions][:REC_obj_post2030] = @expression(mod,
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_post2030)
                - sum(A[jy]*W[jd]*λ_h_REC[jh,jd,jy]*r_h[jh,jd,jy] for jh in JH, jd in JD, jy in JY_post2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_post2030)
                + sum(ρ_h_REC_post2030/2*W[jd]*(r_h[jh,jd,jy] - r_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY_post2030)
            )
        elseif ρ_d_REC_post2030 > 0 
            λ_d_REC = mod.ext[:parameters][:λ_d_REC] # REC prices
            r_d_bar = mod.ext[:parameters][:r_d_bar] # element in ADMM penalty term related to REC auctions
            r_d = mod.ext[:variables][:r_d]  

            REC_obj_post2030 = mod.ext[:expressions][:REC_obj_post2030] = @expression(mod,
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_post2030)
                - sum(A[jy]*W[jd]*λ_d_REC[jd,jy]*r_d[jd,jy] for jd in JD, jy in JY_post2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_post2030)
                + sum(ρ_d_REC_post2030/2*W[jd]*(r_d[jd,jy] - r_d_bar[jd,jy])^2 for jd in JD, jy in JY_post2030)
            )
        elseif ρ_m_REC_post2030 > 0 
            λ_m_REC = mod.ext[:parameters][:λ_m_REC] # REC prices
            r_m_bar = mod.ext[:parameters][:r_m_bar] # element in ADMM penalty term related to REC auctions
            r_m = mod.ext[:variables][:r_m] 

            REC_obj_post2030 = mod.ext[:expressions][:REC_obj_post2030] = @expression(mod,
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_post2030)
                - sum(A[jy]*λ_m_REC[jm,jy]*r_m[jm,jy] for jm in JM, jy in JY_post2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_post2030)
                + sum(ρ_m_REC_post2030/2*(r_m[jm,jy] - r_m_bar[jm,jy])^2 for jm in JM, jy in JY_post2030)
            )
        else 
            REC_obj_post2030 = mod.ext[:expressions][:REC_obj_post2030] = @expression(mod,
                - sum(A[jy]*λ_y_REC[jy]*r_y[jy] for jy in JY_post2030)
                + sum(ρ_y_REC/2*(r_y[jy] - r_y_bar[jy])^2 for jy in JY_post2030)
            )
        end
    else
        REC_obj_pre2030 = mod.ext[:expressions][:REC_obj_pre2030] = @expression(mod,
            0
        )
        REC_obj_post2030 = mod.ext[:expressions][:REC_obj_post2030] = @expression(mod,
            0
        )
    end 

    ρ_h_H2 = mod.ext[:parameters][:ρ_h_H2] # rho-value in ADMM related to H2 market
    ρ_d_H2 = mod.ext[:parameters][:ρ_d_H2] # rho-value in ADMM related to H2 market
    ρ_m_H2 = mod.ext[:parameters][:ρ_m_H2] # rho-value in ADMM related to H2 market
    ρ_y_H2 = mod.ext[:parameters][:ρ_y_H2] # rho-value in ADMM related to H2 market

    if ρ_h_H2 > 0
        λ_h_H2 = mod.ext[:parameters][:λ_h_H2] # H2 prices
        gH_h_bar = mod.ext[:parameters][:gH_h_bar] # element in ADMM penalty term related to hydrogen market
        gH = mod.ext[:variables][:gH]
 
        λ_y_H2 = [ sum(λ_h_H2[jh,jd,jy]*W[jd] for jh in JH, jd in JD)/8760 for jy in JY ]

        H2_obj = mod.ext[:expressions][:H2_obj] = @expression(mod,
            - sum(A[jy]*W[jd]*λ_h_H2[jh,jd,jy]*gH[jh,jd,jy] for jh in JH, jd in JD, jy in JY)
            + sum(ρ_h_H2/2*W[jd]*(gH[jh,jd,jy] - gH_h_bar[jh,jd,jy])^2 for jh in JH, jd in JD, jy in JY) 
        )
    elseif ρ_d_H2 > 0 
        λ_d_H2 = mod.ext[:parameters][:λ_d_H2] # H2 prices
        gH_d_bar = mod.ext[:parameters][:gH_d_bar] # element in ADMM penalty term related to hydrogen market
        gH_d = mod.ext[:expressions][:gH_d]
        λ_y_H2 = [ sum(λ_d_H2[jd,jy]*W[jd] for jd in JD)/365 for jy in JY ]
        H2_obj = mod.ext[:expressions][:H2_obj] = @expression(mod,
            - sum(A[jy]*W[jd]*λ_d_H2[jd,jy]*gH_d[jd,jy] for jd in JD, jy in JY)
            + sum(ρ_d_H2/2*W[jd]*(gH_d[jd,jy] - gH_d_bar[jd,jy])^2 for jd in JD, jy in JY) 
        )
    elseif ρ_m_H2 > 0 
        λ_m_H2 = mod.ext[:parameters][:λ_m_H2] # H2 prices
        gH_m_bar = mod.ext[:parameters][:gH_m_bar] # element in ADMM penalty term related to hydrogen market
        gH_m = mod.ext[:variables][:gH_m]

        λ_y_H2 = [ sum(λ_m_H2[jm,jy]*Wm[jm] for jm in JM)/12 for jy in JY ]

        H2_obj = mod.ext[:expressions][:H2_obj] = @expression(mod,
            - sum(A[jy]*λ_m_H2[jm,jy]*gH_m[jm,jy] for jm in JM, jy in JY)
            + sum(ρ_m_H2/2*(gH_m[jm,jy] - gH_m_bar[jm,jy])^2 for jm in JM, jy in JY) 
        )
    elseif ρ_y_H2 > 0 
        λ_y_H2 = mod.ext[:parameters][:λ_y_H2] # H2 prices
        gH_y_bar = mod.ext[:parameters][:gH_y_bar] # element in ADMM penalty term related to hydrogen market
        gH_y = mod.ext[:expressions][:gH_y]

        H2_obj = mod.ext[:expressions][:H2_obj] = @expression(mod,
            - sum(A[jy]*λ_y_H2[jy]*gH_y[jy] for jy in JY)
            + sum(ρ_y_H2/2*(gH_y[jy] - gH_y_bar[jy])^2 for jy in JY) 
        )
    end

    if mod.ext[:parameters][:supported] == 1
        # Extract H2 policy parameters
        max_support_duration = mod.ext[:parameters][:max_support_duration]
        run_theoretical_min = mod.ext[:parameters][:run_theoretical_min]
        H2CfD_tender = mod.ext[:parameters][:H2CfD_tender]
        H2FP_tender = mod.ext[:parameters][:H2FP_tender]
        H2_cap_tax_reduct = mod.ext[:parameters][:H2_cap_tax_reduct]
        H2_cap_grant = mod.ext[:parameters][:H2_cap_grant]
        contract_duration = mod.ext[:parameters][:contract_duration]
        tender_year = mod.ext[:parameters][:tender_year]

        λ_H2CN_prod = mod.ext[:parameters][:λ_H2CN_prod] # Carbon neutral H2 generation subsidy
        λ_H2CN_cap = mod.ext[:parameters][:λ_H2CN_cap] # Carbon neutral H2 capacity subsidy
        λ_H2FP = mod.ext[:parameters][:λ_H2FP]
        λ_H2CfD = mod.ext[:parameters][:λ_H2CfD]
        λ_H2CG = mod.ext[:parameters][:λ_H2CG]
        λ_H2TD = mod.ext[:parameters][:λ_H2TD]

        ρ_H2CN_prod = mod.ext[:parameters][:ρ_H2CN_prod]
        ρ_H2CN_cap = mod.ext[:parameters][:ρ_H2CN_cap]
        gHCN_bar = mod.ext[:parameters][:gHCN_bar]
        capHCN_bar = mod.ext[:parameters][:capHCN_bar]

        gH_y = mod.ext[:expressions][:gH_y]
        gH = mod.ext[:variables][:gH]

        if ρ_h_H2 > 0
            λ_y_H2 = [ sum(λ_h_H2[jh,jd,jy]*W[jd] for jh in JH, jd in JD)/8760 for jy in JY ]
        elseif ρ_d_H2 > 0
            λ_y_H2 = [ sum(λ_d_H2[jd,jy]*W[jd] for jd in JD)/365 for jy in JY ]
        elseif ρ_m_H2 > 0
            λ_y_H2 = [ sum(λ_m_H2[jm,jy]*Wm[jm] for jm in JM)/12 for jy in JY ]
        elseif ρ_y_H2 > 0
            λ_y_H2 = mod.ext[:parameters][:λ_y_H2] # H2 prices
        end

        if run_theoretical_min == "YES"
            H2CN_obj  = mod.ext[:expressions][:H2CN_obj] = @expression(mod, - sum(gHCN[jy]*λ_H2CN_prod[jy] + capHCN[jy]*λ_H2CN_cap[jy] for jy in JY)
                                                                        + sum(ρ_H2CN_prod/2*(gHCN[jy] - gHCN_bar[jy])^2 for jy in JY)
                                                                        + sum(ρ_H2CN_cap/2*(capHCN[jy] - capHCN_bar[jy])^2 for jy in JY)
                                                                        )
        elseif H2FP_tender == "YES"
            H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, -sum( A[jt]*gHCN[jt]*λ_H2FP[jt] for jt in JT) + sum(ρ_H2CN_prod/2*(gH_y[jt] - gHCN_bar[jt])^2 for jt in JT))
        elseif H2CfD_tender  == "YES"
            H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, -sum(A[jt]*gHCN[jt]*(λ_H2CfD[jt] - λ_y_H2[jt]) for jt in  JT) + sum(ρ_H2CN_prod/2*(gH_y[jt] - gHCN_bar[jt])^2 for jt in JT))
        elseif H2_cap_tax_reduct == "YES"
            H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, -A[tender_year]*capH[tender_year]*IC[tender_year]*λ_H2TD[tender_year] + sum(ρ_H2CN_prod/2*(gH_y[jt] - gHCN_bar[jt])^2 for jt in JT) + ρ_H2CN_prod/20*(capH[tender_year] - capHCN_bar[tender_year])^2)
        elseif H2_cap_grant == "YES"
            H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, -A[tender_year]*capH[tender_year]*λ_H2CG[tender_year] + sum(ρ_H2CN_prod/2*(gH_y[jt] - gHCN_bar[jt])^2 for jt in JT) + ρ_H2CN_prod/20*(capH[tender_year] - capHCN_bar[tender_year])^2)
        else 
            # if calibration run
            H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, 0)
        end
    else
        H2CN_obj = mod.ext[:expressions][:H2CN_obj] = @expression(mod, 0)
    end

    if mod.ext[:parameters][:ETS] == 1
        λ_EUA = mod.ext[:parameters][:λ_EUA] # EUA prices
        b_bar = mod.ext[:parameters][:b_bar] # element in ADMM penalty term related to EUA auctions
        ρ_EUA = mod.ext[:parameters][:ρ_EUA] # rho-value in ADMM related to EUA auctions
        b = mod.ext[:variables][:b]    

        ETS_obj = mod.ext[:expressions][:ETS_obj] = @expression(mod,
            + sum(A[jy]*λ_EUA[jy]*b[jy] for jy in JY) 
            + sum(ρ_EUA/2*(b[jy] - b_bar[jy])^2 for jy in JY)
        )
    else
        ETS_obj = mod.ext[:expressions][:ETS_obj] = @expression(mod,
            0
        )
    end

    if mod.ext[:parameters][:NG] == 1
        λ_NG = mod.ext[:parameters][:λ_NG] # Gas prices
        dNG = mod.ext[:variables][:dNG] 

        NG_obj = mod.ext[:expressions][:NG_obj] = @expression(mod,
            + sum(A[jy]*λ_NG[jy]*dNG[jy] for jy in JY) 
        )
    else
        NG_obj = mod.ext[:expressions][:NG_obj] = @expression(mod,
            0
        )
    end

    CAPEX_obj = mod.ext[:expressions][:CAPEX_obj] = @expression(mod,
        + sum(A[jy]*(1-CAP_SV[jy])*IC[jy]*capH[jy] for jy in JY) # [MEUR]
    )

    # Update objective 
    mod.ext[:objective] = @objective(mod, Min,
        + CAPEX_obj
        + EOM_obj
        + REC_obj_pre2030
        + REC_obj_post2030
        + ETS_obj
        + H2_obj
        + H2CN_obj
        + NG_obj
    )
    
    optimize!(mod);

    return mod

end