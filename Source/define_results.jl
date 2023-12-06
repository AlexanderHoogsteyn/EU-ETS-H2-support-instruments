function define_results!(data::Dict,results::Dict,ADMM::Dict,agents::Dict,ETS::Dict,EOM::Dict,REC::Dict,H2::Dict,H2CN_prod::Dict,H2CN_cap::Dict,NG::Dict) 
    results["e"] = Dict()
    results["g"] = Dict()
    results["r_y"] = Dict()
    results["r_m"] = Dict()
    results["r_d"] = Dict()
    results["r_h"] = Dict()
    results["b"] = Dict()
    results["h2_y"] = Dict()
    results["h2_d"] = Dict()
    results["h2_m"] = Dict()
    results["h2_h"] = Dict()
    results["h2_cap"] = Dict()
    results["support"] = Dict()
    results["h2cn_prod"] = Dict()
    results["h2cn_cap"] = Dict()
    results["dual_max_support_duration"] = Dict()

    for m in agents[:ets]
        results["b"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
        push!(results["b"][m],zeros(data["nyears"]))
        results["e"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
        push!(results["e"][m],zeros(data["nyears"]))
    end
    for m in agents[:rec]
        results["r_y"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
        push!(results["r_y"][m],zeros(data["nyears"]))
        results["r_m"][m] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
        push!(results["r_m"][m],zeros(12,data["nyears"]))
        results["r_d"][m] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
        push!(results["r_d"][m],zeros(data["nReprDays"],data["nyears"]))
        results["r_h"][m] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])  
        push!(results["r_h"][m],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    end
    for m in agents[:eom]
        results["g"][m] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"]) 
        push!(results["g"][m],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    end
    for m in agents[:h2]
        results["h2_y"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
        push!(results["h2_y"][m],zeros(data["nyears"]))
        results["h2_m"][m] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"]) 
        push!(results["h2_m"][m],zeros(data["nMonths"],data["nyears"]))
        results["h2_d"][m] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"]) 
        push!(results["h2_d"][m],zeros(data["nReprDays"],data["nyears"]))
        results["h2_h"][m] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"]) 
        push!(results["h2_h"][m],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
        results["h2_cap"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
        push!(results["h2_cap"][m],zeros(data["nyears"]))
    end
    for m in agents[:h2cn_prod]
        results["h2cn_prod"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
        push!(results["h2cn_prod"][m],zeros(data["nyears"]))
    end
    for m in agents[:h2cn_cap]
        results["h2cn_cap"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
        push!(results["h2cn_cap"][m],zeros(data["nyears"]))
    end
    for m in agents[:supported]
        results["support"][m] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
        push!(results["support"][m],zeros(data["nyears"]))
        results["dual_max_support_duration"][m] = CircularBuffer{Float64}(data["CircularBufferSize"])
        push!(results["dual_max_support_duration"][m],0)
    end

    results["s"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["s"],zeros(data["nyears"]))

    results["λ"] = Dict()
    results["λ"]["EUA"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"]) 
    push!(results["λ"]["EUA"],zeros(data["nyears"]))
    results["λ"]["REC"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["REC"],zeros(data["nyears"]))
    results["λ"]["EOM"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"]) 
    push!(results["λ"]["EOM"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    results["λ"]["REC_y"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["REC_y"],zeros(data["nyears"]))
    results["λ"]["REC_m"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
    push!(results["λ"]["REC_m"],zeros(12,data["nyears"]))
    results["λ"]["REC_d"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
    push!(results["λ"]["REC_d"],zeros(data["nReprDays"],data["nyears"]))
    results["λ"]["REC_h"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])  
    push!(results["λ"]["REC_h"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    results["λ"]["H2_h"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2_h"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    results["λ"]["H2_d"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2_d"],zeros(data["nReprDays"],data["nyears"]))
    results["λ"]["H2_m"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2_m"],zeros(data["nMonths"],data["nyears"]))
    results["λ"]["H2_y"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2_y"],zeros(data["nyears"]))

    results["λ"]["H2CN_prod"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2CN_prod"],zeros(data["nyears"]))
    results["λ"]["H2CN_cap"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2CN_cap"],zeros(data["nyears"]))
    results["λ"]["H2FP"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2FP"],zeros(data["nyears"]))
    results["λ"]["H2CfD"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2CfD"],zeros(data["nyears"]))
    results["λ"]["H2CfD_ref"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2CfD_ref"],zeros(data["nyears"]))
    results["λ"]["H2CG"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2CG"],zeros(data["nyears"]))
    results["λ"]["H2TD"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["H2TD"],zeros(data["nyears"]))
    results["λ"]["NG"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(results["λ"]["NG"],zeros(data["nyears"]))

    ADMM["Imbalances"] = Dict()
    ADMM["Imbalances"]["ETS"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])  
    push!(ADMM["Imbalances"]["ETS"],zeros(data["nyears"]))
    ADMM["Imbalances"]["MSR"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["MSR"],zeros(data["nyears"]))
    ADMM["Imbalances"]["EOM"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["EOM"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    ADMM["Imbalances"]["REC_y"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["REC_y"],zeros(data["nyears"]))
    ADMM["Imbalances"]["REC_m"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["REC_m"],zeros(12,data["nyears"]))
    ADMM["Imbalances"]["REC_d"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["REC_d"],zeros(data["nReprDays"],data["nyears"]))
    ADMM["Imbalances"]["REC_h"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["REC_h"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    ADMM["Imbalances"]["H2_h"] = CircularBuffer{Array{Float64,3}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2_h"],zeros(data["nTimesteps"],data["nReprDays"],data["nyears"]))
    ADMM["Imbalances"]["H2_d"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2_d"],zeros(data["nReprDays"],data["nyears"]))
    ADMM["Imbalances"]["H2_m"] = CircularBuffer{Array{Float64,2}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2_m"],zeros(data["nMonths"],data["nyears"]))
    ADMM["Imbalances"]["H2_y"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2_y"],zeros(data["nyears"]))
    ADMM["Imbalances"]["H2CN_prod"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2CN_prod"],zeros(data["nyears"]))
    ADMM["Imbalances"]["H2CN_cap"] = CircularBuffer{Array{Float64,1}}(data["CircularBufferSize"])
    push!(ADMM["Imbalances"]["H2CN_cap"],zeros(data["nyears"]))

    ADMM["Residuals"] = Dict()
    ADMM["Residuals"]["Primal"] = Dict()
    ADMM["Residuals"]["Primal"]["ETS"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["ETS"],0)
    ADMM["Residuals"]["Primal"]["MSR"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["MSR"],0)
    ADMM["Residuals"]["Primal"]["REC_y"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["REC_y"],0)
    ADMM["Residuals"]["Primal"]["REC_m"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["REC_m"],0)
    ADMM["Residuals"]["Primal"]["REC_d"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["REC_d"],0)
    ADMM["Residuals"]["Primal"]["REC_h"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["REC_h"],0)
    ADMM["Residuals"]["Primal"]["EOM"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["EOM"],0)
    ADMM["Residuals"]["Primal"]["H2_h"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2_h"],0)
    ADMM["Residuals"]["Primal"]["H2_d"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2_d"],0)
    ADMM["Residuals"]["Primal"]["H2_m"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2_m"],0)
    ADMM["Residuals"]["Primal"]["H2_y"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2_y"],0)
    ADMM["Residuals"]["Primal"]["H2CN_prod"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2CN_prod"],0)
    ADMM["Residuals"]["Primal"]["H2CN_cap"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Primal"]["H2CN_cap"],0)


    ADMM["Residuals"]["Dual"] = Dict()
    ADMM["Residuals"]["Dual"]["ETS"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["ETS"],0)
    ADMM["Residuals"]["Dual"]["REC_y"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["REC_y"],0)
    ADMM["Residuals"]["Dual"]["REC_m"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["REC_m"],0)
    ADMM["Residuals"]["Dual"]["REC_d"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["REC_d"],0)
    ADMM["Residuals"]["Dual"]["REC_h"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["REC_h"],0)
    ADMM["Residuals"]["Dual"]["EOM"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["EOM"],0)
    ADMM["Residuals"]["Dual"]["H2_h"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2_h"],0)
    ADMM["Residuals"]["Dual"]["H2_d"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2_d"],0)
    ADMM["Residuals"]["Dual"]["H2_m"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2_m"],0)
    ADMM["Residuals"]["Dual"]["H2_y"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2_y"],0)
    ADMM["Residuals"]["Dual"]["H2CN_prod"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2CN_prod"],0)
    ADMM["Residuals"]["Dual"]["H2CN_cap"] = CircularBuffer{Float64}(data["CircularBufferSize"])
    push!(ADMM["Residuals"]["Dual"]["H2CN_cap"],0)


    ADMM["Tolerance"] = Dict()
    ADMM["Tolerance"]["ETS"] = data["epsilon"]/100*maximum(ETS["CAP"])*sqrt(data["nyears"])
    ADMM["Tolerance"]["EOM"] = data["epsilon"]/100*maximum(EOM["D"])*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])
    ADMM["Tolerance"]["REC_y"] = data["epsilon"]/100*maximum(REC["RT"].*EOM["D_cum"])*sqrt(data["nyears"])  
    ADMM["Tolerance"]["REC_m"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/12*sqrt(data["nyears"]*12)  # unknown what maximum monthly REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["REC_d"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/365*sqrt(data["nyears"]*data["nReprDays"])   # unknown what maximum daily REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["REC_h"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/8760*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])   # unknown what maximum hourly REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["H2_h"] = data["epsilon"]/100*maximum(H2["D_h"])*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])
    ADMM["Tolerance"]["H2_d"] = data["epsilon"]/100*maximum(H2["D_d"])*sqrt(data["nyears"]*data["nReprDays"])
    ADMM["Tolerance"]["H2_m"] = data["epsilon"]/100*maximum(H2["D_m"])*sqrt(data["nyears"]*data["nMonths"])
    ADMM["Tolerance"]["H2_y"] = data["epsilon"]/100*maximum(H2["D_y"])*sqrt(data["nyears"])
    ADMM["Tolerance"]["H2CN_prod"] = data["epsilon"]/100*max(maximum(H2CN_prod["H2CN_PRODT"])*sqrt(data["nyears"]),1e-3)
    ADMM["Tolerance"]["H2CN_cap"] = data["epsilon"]/100*max(maximum(H2CN_cap["H2CN_CAPT"])*sqrt(data["nyears"]),1e-3)
    # TO DO add polict target one

    ADMM["ρ"] = Dict()
    ADMM["ρ"]["EUA"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["EUA"],data["rho_EUA"])
    ADMM["ρ"]["EOM"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["EOM"],data["rho_EOM"])
    ADMM["ρ"]["REC_y"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_y"],data["rho_REC"])    
    ADMM["ρ"]["REC_y_pre2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_y_pre2030"],data["rho_REC_y_pre2030"])    
    ADMM["ρ"]["REC_m_pre2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_m_pre2030"],data["rho_REC_m_pre2030"])
    ADMM["ρ"]["REC_d_pre2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_d_pre2030"],data["rho_REC_d_pre2030"])
    ADMM["ρ"]["REC_h_pre2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_h_pre2030"],data["rho_REC_h_pre2030"])
    ADMM["ρ"]["REC_y_post2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_y_post2030"],data["rho_REC_y_post2030"])    
    ADMM["ρ"]["REC_m_post2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_m_post2030"],data["rho_REC_m_post2030"])
    ADMM["ρ"]["REC_d_post2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_d_post2030"],data["rho_REC_d_post2030"])
    ADMM["ρ"]["REC_h_post2030"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["REC_h_post2030"],data["rho_REC_h_post2030"])
    ADMM["ρ"]["H2_h"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2_h"],data["rho_H2_h"])
    ADMM["ρ"]["H2_d"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2_d"],data["rho_H2_d"])
    ADMM["ρ"]["H2_m"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2_m"],data["rho_H2_m"])
    ADMM["ρ"]["H2_y"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2_y"],data["rho_H2_y"])
    ADMM["ρ"]["H2CN_prod"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2CN_prod"],data["rho_H2CN_prod"])
    ADMM["ρ"]["H2CN_cap"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2CN_cap"],data["rho_H2CN_cap"])
    ADMM["ρ"]["H2FP"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2FP"],data["rho_H2FP"])
    ADMM["ρ"]["H2CfD"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2CfD"],data["rho_H2CfD"])
    ADMM["ρ"]["H2CG"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2CG"],data["rho_H2CG"])
    ADMM["ρ"]["H2TD"] = CircularBuffer{Float64}(data["CircularBufferSize"]) 
    push!(ADMM["ρ"]["H2TD"],data["rho_H2TD"])

    ADMM["n_iter"] = 1 
    ADMM["walltime"] = 0
    
    if data["CNH2_demand_2030"] > 0 && data["CNH2_cap_target_2024"] == 0
        ADMM["imbalance_mode"] = "QUANTITY"
    elseif data["CNH2_cap_target_2024"] > 0 && data["CNH2_demand_2030"] == 0
        ADMM["imbalance_mode"] = "CAPACITY"
    else 
         # TO DO add policy budget case ADMM["Imbalances"]["H2CN_cap"]
         ADMM["imbalance_mode"] = "NO TARGET"
    end

    return results, ADMM
end

function define_results_hot_start!(data::Dict,results::Dict,ADMM::Dict,agents::Dict,ETS::Dict,EOM::Dict,REC::Dict,H2::Dict,H2CN_prod::Dict,H2CN_cap::Dict,NG::Dict)
    # Convert Arrays to circular buffers
    for (r,arr) in results
        if r!= "s"
            for (m,arr2) in arr
                cb = CircularBuffer(data["CircularBufferSize"])
                append!(cb,arr2)
                results[r][m] = cb
            end
        elseif r == "s"
            cb = CircularBuffer(data["CircularBufferSize"])
            append!(cb,arr)
            results[r] = cb
        end
    end
    for (r,arr) in ADMM["ρ"]
        cb = CircularBuffer(data["CircularBufferSize"])
        append!(cb, arr)
        ADMM["ρ"][r] = cb
    end
    for (r,arr) in ADMM["Residuals"]["Primal"]
        cb = CircularBuffer(data["CircularBufferSize"])
        append!(cb, arr)
        ADMM["Residuals"]["Primal"][r] = cb
    end
    for (r,arr) in ADMM["Residuals"]["Dual"]
        cb = CircularBuffer(data["CircularBufferSize"])
        append!(cb, arr)
        ADMM["Residuals"]["Dual"][r] = cb
    end
    for (r,arr) in ADMM["Imbalances"]
        cb = CircularBuffer(data["CircularBufferSize"])
        append!(cb, arr)
        ADMM["Imbalances"][r] = cb
    end

    # Some ADMM adjestmets to ρ to help convergence
    #ADMM["ρ"]["H2CN_prod"][1] = 1000
    #ADMM["ρ"]["H2CN_cap"][1] = 1000

    ADMM["Tolerance"] = Dict()
    ADMM["Tolerance"]["ETS"] = data["epsilon"]/100*maximum(ETS["CAP"])*sqrt(data["nyears"])
    ADMM["Tolerance"]["EOM"] = data["epsilon"]/100*maximum(EOM["D"])*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])
    ADMM["Tolerance"]["REC_y"] = data["epsilon"]/100*maximum(REC["RT"].*EOM["D_cum"])*sqrt(data["nyears"])  
    ADMM["Tolerance"]["REC_m"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/12*sqrt(data["nyears"]*12)  # unknown what maximum monthly REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["REC_d"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/365*sqrt(data["nyears"]*data["nReprDays"])   # unknown what maximum daily REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["REC_h"] = data["epsilon"]/100*maximum(H2CN_prod["H2CN_PRODT"])/8760*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])   # unknown what maximum hourly REC requirement will be, assume equal distribtuion over year
    ADMM["Tolerance"]["H2_h"] = data["epsilon"]/100*maximum(H2["D_h"])*sqrt(data["nyears"]*data["nTimesteps"]*data["nReprDays"])
    ADMM["Tolerance"]["H2_d"] = data["epsilon"]/100*maximum(H2["D_d"])*sqrt(data["nyears"]*data["nReprDays"])
    ADMM["Tolerance"]["H2_m"] = data["epsilon"]/100*maximum(H2["D_m"])*sqrt(data["nyears"]*data["nMonths"])
    ADMM["Tolerance"]["H2_y"] = data["epsilon"]/100*maximum(H2["D_y"])*sqrt(data["nyears"])
    ADMM["Tolerance"]["H2CN_prod"] = data["epsilon"]/100*max(maximum(H2CN_prod["H2CN_PRODT"])*sqrt(data["nyears"]),1e-3)
    ADMM["Tolerance"]["H2CN_cap"] = data["epsilon"]/100*max(maximum(H2CN_cap["H2CN_CAPT"])*sqrt(data["nyears"]),1e-3)

    ADMM["n_iter"] = 1 
    ADMM["walltime"] = 0

    if data["scenario"]["CNH2_demand_2030"] > 0 && data["scenario"]["CNH2_cap_target_2024"] == 0
        ADMM["imbalance_mode"] = "QUANTITY"
    elseif data["scenario"]["CNH2_cap_target_2024"] > 0 && data["scenario"]["CNH2_demand_2030"] == 0
        ADMM["imbalance_mode"] = "CAPACITY"
    else 
         # TO DO add policy budget case ADMM["Imbalances"]["H2CN_cap"]
    end

    return results, ADMM
end