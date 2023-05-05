function update_rho!(ADMM::Dict, iter::Int64)
    if mod(iter,1) == 0
        # ρ-updates following Boyd et al.  
        if ADMM["Residuals"]["Primal"]["ETS"][end]+ADMM["Residuals"]["Primal"]["MSR"][end]> 2*ADMM["Residuals"]["Dual"]["ETS"][end]
            push!(ADMM["ρ"]["EUA"], minimum([1000,1.1*ADMM["ρ"]["EUA"][end]]))
        elseif ADMM["Residuals"]["Dual"]["ETS"][end]+ADMM["Residuals"]["Primal"]["MSR"][end] > 2*ADMM["Residuals"]["Primal"]["ETS"][end]
            push!(ADMM["ρ"]["EUA"], 1/1.1*ADMM["ρ"]["EUA"][end])
        end

        if ADMM["Residuals"]["Primal"]["EOM"][end] > 2*ADMM["Residuals"]["Dual"]["EOM"][end]
            push!(ADMM["ρ"]["EOM"], minimum([1000,1.1*ADMM["ρ"]["EOM"][end]]))
        elseif ADMM["Residuals"]["Dual"]["EOM"][end] > 2*ADMM["Residuals"]["Primal"]["EOM"][end]
            push!(ADMM["ρ"]["EOM"], 1/1.1*ADMM["ρ"]["EOM"][end])
        end

        if ADMM["Residuals"]["Primal"]["REC_y"][end] > 2*ADMM["Residuals"]["Dual"]["REC_y"][end]
            push!(ADMM["ρ"]["REC_y"], minimum([1000,1.1*ADMM["ρ"]["REC_y"][end]]))
            push!(ADMM["ρ"]["REC_y_pre2030"], minimum([1000,1.1*ADMM["ρ"]["REC_y_pre2030"][end]]))
            push!(ADMM["ρ"]["REC_y_post2030"], minimum([1000,1.1*ADMM["ρ"]["REC_y_post2030"][end]]))
        elseif ADMM["Residuals"]["Dual"]["REC_y"][end] > 2*ADMM["Residuals"]["Primal"]["REC_y"][end]
            push!(ADMM["ρ"]["REC_y"], 1/1.1*ADMM["ρ"]["REC_y"][end])
            push!(ADMM["ρ"]["REC_y_pre2030"], 1/1.1*ADMM["ρ"]["REC_y_pre2030"][end])
            push!(ADMM["ρ"]["REC_y_post2030"], 1/1.1*ADMM["ρ"]["REC_y_post2030"][end])
        end

        if ADMM["Residuals"]["Primal"]["REC_m"][end] > 2*ADMM["Residuals"]["Dual"]["REC_m"][end]
            push!(ADMM["ρ"]["REC_m_pre2030"], minimum([1000,1.1*ADMM["ρ"]["REC_m_pre2030"][end]]))
            push!(ADMM["ρ"]["REC_m_post2030"], minimum([1000,1.1*ADMM["ρ"]["REC_m_post2030"][end]]))
        elseif ADMM["Residuals"]["Dual"]["REC_m"][end] > 2*ADMM["Residuals"]["Primal"]["REC_m"][end]
            push!(ADMM["ρ"]["REC_m_pre2030"], 1/1.1*ADMM["ρ"]["REC_m_pre2030"][end])
            push!(ADMM["ρ"]["REC_m_post2030"], 1/1.1*ADMM["ρ"]["REC_m_post2030"][end])
        end

        if ADMM["Residuals"]["Primal"]["REC_d"][end] > 2*ADMM["Residuals"]["Dual"]["REC_d"][end]
            push!(ADMM["ρ"]["REC_d_pre2030"], minimum([1000,1.1*ADMM["ρ"]["REC_d_pre2030"][end]]))
            push!(ADMM["ρ"]["REC_d_post2030"], minimum([1000,1.1*ADMM["ρ"]["REC_d_post2030"][end]]))
        elseif ADMM["Residuals"]["Dual"]["REC_d"][end] > 2*ADMM["Residuals"]["Primal"]["REC_d"][end]
            push!(ADMM["ρ"]["REC_d_pre2030"], 1/1.1*ADMM["ρ"]["REC_d_pre2030"][end])
            push!(ADMM["ρ"]["REC_d_post2030"], 1/1.1*ADMM["ρ"]["REC_d_post2030"][end])
        end

        if ADMM["Residuals"]["Primal"]["REC_h"][end] > 2*ADMM["Residuals"]["Dual"]["REC_h"][end]
            push!(ADMM["ρ"]["REC_h_pre2030"], minimum([1000,1.1*ADMM["ρ"]["REC_h_pre2030"][end]]))
            push!(ADMM["ρ"]["REC_h_post2030"], minimum([1000,1.1*ADMM["ρ"]["REC_h_post2030"][end]]))
        elseif ADMM["Residuals"]["Dual"]["REC_h"][end] > 2*ADMM["Residuals"]["Primal"]["REC_h"][end]
            push!(ADMM["ρ"]["REC_h_pre2030"], 1/1.1*ADMM["ρ"]["REC_h_pre2030"][end])
            push!(ADMM["ρ"]["REC_h_pre2030"], 1/1.1*ADMM["ρ"]["REC_h_post2030"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2_h"][end] > 2*ADMM["Residuals"]["Dual"]["H2_h"][end]
            push!(ADMM["ρ"]["H2_h"], minimum([1000,1.1*ADMM["ρ"]["H2_h"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2_h"][end] > 2*ADMM["Residuals"]["Primal"]["H2_h"][end]
            push!(ADMM["ρ"]["H2_h"], 1/1.1*ADMM["ρ"]["H2_h"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2_d"][end] > 2*ADMM["Residuals"]["Dual"]["H2_d"][end]
            push!(ADMM["ρ"]["H2_d"], minimum([1000,1.1*ADMM["ρ"]["H2_d"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2_d"][end] > 2*ADMM["Residuals"]["Primal"]["H2_d"][end]
            push!(ADMM["ρ"]["H2_d"], 1/1.1*ADMM["ρ"]["H2_d"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2_m"][end] > 2*ADMM["Residuals"]["Dual"]["H2_m"][end]
            push!(ADMM["ρ"]["H2_m"], minimum([1000,1.1*ADMM["ρ"]["H2_m"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2_m"][end] > 2*ADMM["Residuals"]["Primal"]["H2_m"][end]
            push!(ADMM["ρ"]["H2_m"], 1/1.1*ADMM["ρ"]["H2_m"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2_y"][end] > 2*ADMM["Residuals"]["Dual"]["H2_y"][end]
            push!(ADMM["ρ"]["H2_y"], minimum([1000,1.1*ADMM["ρ"]["H2_y"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2_y"][end] > 2*ADMM["Residuals"]["Primal"]["H2_y"][end]
            push!(ADMM["ρ"]["H2_y"], 1/1.1*ADMM["ρ"]["H2_y"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2CN_prod"][end] > 2*ADMM["Residuals"]["Dual"]["H2CN_prod"][end]
            push!(ADMM["ρ"]["H2CN_prod"], minimum([1000,1.1*ADMM["ρ"]["H2CN_prod"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2CN_prod"][end] > 2*ADMM["Residuals"]["Primal"]["H2CN_prod"][end]
            push!(ADMM["ρ"]["H2CN_prod"], 1/1.1*ADMM["ρ"]["H2CN_prod"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2CN_cap"][end] > 2*ADMM["Residuals"]["Dual"]["H2CN_cap"][end]
            push!(ADMM["ρ"]["H2CN_cap"], minimum([1000,1.1*ADMM["ρ"]["H2CN_cap"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2CN_cap"][end] > 2*ADMM["Residuals"]["Primal"]["H2CN_cap"][end]
            push!(ADMM["ρ"]["H2CN_cap"], 1/1.1*ADMM["ρ"]["H2CN_cap"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2FP"][end] > 2*ADMM["Residuals"]["Dual"]["H2FP"][end]
            push!(ADMM["ρ"]["H2FP"], minimum([1000,1.1*ADMM["ρ"]["H2FP"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2FP"][end] > 2*ADMM["Residuals"]["Primal"]["H2FP"][end]
            push!(ADMM["ρ"]["H2FP"], 1/1.1*ADMM["ρ"]["H2FP"][end])
        end

        if ADMM["Residuals"]["Primal"]["H2CfD"][end] > 2*ADMM["Residuals"]["Dual"]["H2CfD"][end]
            push!(ADMM["ρ"]["H2CfD"], minimum([1000,1.1*ADMM["ρ"]["H2CfD"][end]]))
        elseif ADMM["Residuals"]["Dual"]["H2CfD"][end] > 2*ADMM["Residuals"]["Primal"]["H2CfD"][end]
            push!(ADMM["ρ"]["H2CfD"], 1/1.1*ADMM["ρ"]["H2CfD"][end])
        end
    end
end