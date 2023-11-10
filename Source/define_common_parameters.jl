function define_common_parameters!(m::String,mod::Model, data::Dict, ts::DataFrame, repr_days::DataFrame, agents::Dict)
    # Solver settings
    # Define dictonaries for sets, parameters, timeseries, variables, constraints & expressions
    mod.ext[:sets] = Dict()
    mod.ext[:parameters] = Dict()
    mod.ext[:timeseries] = Dict()
    mod.ext[:variables] = Dict()
    mod.ext[:constraints] = Dict()
    mod.ext[:expressions] = Dict()

    # Sets
    mod.ext[:sets][:JY] = 1:data["nyears"]    
    mod.ext[:sets][:JY_pre2030] = 1:10  
    mod.ext[:sets][:JY_post2030] = 11:data["nyears"]
    mod.ext[:sets][:JY_post2040] = 21:data["nyears"]
    mod.ext[:sets][:JT] = (data["tender_year"]+data["tender_lead_time"]-2020):(data["tender_year"]+data["tender_lead_time"]+data["contract_duration"]-2020)
    mod.ext[:sets][:JM] = 1:12
    mod.ext[:sets][:JD] = 1:data["nReprDays"]
    mod.ext[:sets][:JH] = 1:data["nTimesteps"]

    # Parameters
    months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    mod.ext[:parameters][:W] = [repr_days[!,:weights][jd] for jd in mod.ext[:sets][:JD]]                              # weights of each representative day
    mod.ext[:parameters][:Wm] = [repr_days[!,months[jm]][jd] for jd in mod.ext[:sets][:JD],jm in mod.ext[:sets][:JM]] # weights of each representative day => month
    mod.ext[:parameters][:A] = ones(data["nyears"],1)                                                                 # Discount rate, 2021 as base year due to calibration to 2019 data
    mod.ext[:parameters][:As] = ones(data["nyears"],1)                                                                 # Discount rate, 2021 as base year due to calibration to 2019 data
    for y in 4:data["nyears"]
        mod.ext[:parameters][:A][y] = 1/(1+data["discount_rate"])^(y-3)
    end
    mod.ext[:parameters][:I] = ones(data["nyears"],1)                                                                 # Discount rate, 2021 as base year due to calibration to 2019 data
    for y in 4:data["nyears"]
        mod.ext[:parameters][:I][y] = (1+data["inflation"])^(y-3)
    end
    for y in 4:data["nyears"]
        mod.ext[:parameters][:As][y] = (1+data["social_discount_rate"])^(y-3)
    end
    # Parameters related to the EUA auctions
    mod.ext[:parameters][:λ_EUA] = zeros(data["nyears"],1)       # Price structure
    mod.ext[:parameters][:b_bar] = zeros(data["nyears"],1)       # ADMM penalty term
    mod.ext[:parameters][:ρ_EUA] = data["rho_EUA"]               # ADMM rho value 

    # Parameters related to the EOM
    mod.ext[:parameters][:λ_EOM] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])   # Price structure
    mod.ext[:parameters][:g_bar] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])   # ADMM penalty term
    mod.ext[:parameters][:ρ_EOM] = data["rho_EOM"]                                              # ADMM rho value 

    # Parameters related to the REC
    mod.ext[:parameters][:λ_y_REC] = zeros(data["nyears"],1)                # Price structure
    mod.ext[:parameters][:r_y_bar] = zeros(data["nyears"],1)                # ADMM penalty term
    mod.ext[:parameters][:ρ_y_REC] = data["rho_REC_y"]                      # ADMM rho value 
    mod.ext[:parameters][:ρ_y_REC_pre2030] = data["rho_REC_y_pre2030"]      # ADMM rho value 
    mod.ext[:parameters][:ρ_y_REC_post2030] = data["rho_REC_y_post2030"]    # ADMM rho value 

    mod.ext[:parameters][:λ_m_REC] = zeros(12,data["nyears"])                     # Price structure
    mod.ext[:parameters][:r_m_bar] = zeros(12,data["nyears"])                     # ADMM penalty term
    mod.ext[:parameters][:ρ_m_REC_pre2030] = data["rho_REC_m_pre2030"]            # ADMM rho value 
    mod.ext[:parameters][:ρ_m_REC_post2030] = data["rho_REC_m_post2030"]          # ADMM rho value 
   
    mod.ext[:parameters][:λ_d_REC] = zeros(data["nReprDays"],data["nyears"])       # Price structure
    mod.ext[:parameters][:r_d_bar] = zeros(data["nReprDays"],data["nyears"])       # ADMM penalty term
    mod.ext[:parameters][:ρ_d_REC_pre2030] = data["rho_REC_d_pre2030"]             # ADMM rho value 
    mod.ext[:parameters][:ρ_d_REC_post2030] = data["rho_REC_d_post2030"]           # ADMM rho value 

    mod.ext[:parameters][:λ_h_REC] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])         # Price structure
    mod.ext[:parameters][:r_h_bar] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])         # ADMM penalty term
    mod.ext[:parameters][:ρ_h_REC_pre2030] = data["rho_REC_h_pre2030"]                                  # ADMM rho value 
    mod.ext[:parameters][:ρ_h_REC_post2030] = data["rho_REC_h_post2030"]                                # ADMM rho value 

    # Parameters related to the H2 market
    mod.ext[:parameters][:λ_h_H2] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])       # Price structure
    mod.ext[:parameters][:gH_h_bar] = zeros(data["nTimesteps"],data["nReprDays"],data["nyears"])     # ADMM penalty term
    mod.ext[:parameters][:ρ_h_H2] = data["rho_H2_h"]                                                 # ADMM rho value 

    mod.ext[:parameters][:λ_d_H2] = zeros(data["nReprDays"],data["nyears"])       # Price structure
    mod.ext[:parameters][:gH_d_bar] = zeros(data["nReprDays"],data["nyears"])     # ADMM penalty term
    mod.ext[:parameters][:ρ_d_H2] = data["rho_H2_d"]                              # ADMM rho value 

    mod.ext[:parameters][:λ_m_H2] = zeros(data["nMonths"],data["nyears"])       # Price structure
    mod.ext[:parameters][:gH_m_bar] = zeros(data["nMonths"],data["nyears"])     # ADMM penalty term
    mod.ext[:parameters][:ρ_m_H2] = data["rho_H2_m"]                            # ADMM rho value 

    mod.ext[:parameters][:λ_y_H2] = zeros(data["nyears"])       # Price structure
    mod.ext[:parameters][:gH_y_bar] = zeros(data["nyears"])     # ADMM penalty term
    mod.ext[:parameters][:ρ_y_H2] = data["rho_H2_y"]            # ADMM rho value 


    # Parameters related to the natural gas market
    mod.ext[:parameters][:λ_NG] = zeros(data["nyears"],1)               # Price structure

    # Parameters related to hydrogen support mechanisms
    mod.ext[:parameters][:λ_H2CN_prod] = zeros(data["nyears"],1) # Parameters related to the carbon-neutral H2 generation subsidy (theoretical reference)
    mod.ext[:parameters][:λ_H2CN_cap] = zeros(data["nyears"],1)  # Parameters related to the carbon-neutral H2 production capacity subsidy
    mod.ext[:parameters][:λ_H2FP] = zeros(data["nyears"],1)
    mod.ext[:parameters][:λ_H2CfD] = zeros(data["nyears"],1)
    mod.ext[:parameters][:λ_H2CG] = zeros(data["nyears"],1)
    mod.ext[:parameters][:λ_H2TD] = zeros(data["nyears"],1)
    mod.ext[:parameters][:support_bar] = zeros(data["nyears"],1)
    mod.ext[:parameters][:ρ_support] = data["rho_support"]  


    # Eligble for RECs?
    if data["REC"] == "YES" 
        mod.ext[:parameters][:REC] = 1
        push!(agents[:rec],m)
    else
        mod.ext[:parameters][:REC] = 0
    end

    # Covered by ETS?
    if data["ETS"] == "YES" 
        mod.ext[:parameters][:ETS] = 1
        push!(agents[:ets],m)
    else
        mod.ext[:parameters][:ETS] = 0
    end
    
    # Covered by EOM?
    if data["EOM"] == "YES" 
        mod.ext[:parameters][:EOM] = 1
        push!(agents[:eom],m)
    else
        mod.ext[:parameters][:EOM] = 0
    end

    # Covered by Hydrogen Market 
    if data["H2"] == "YES" 
        mod.ext[:parameters][:H2] = 1
        push!(agents[:h2],m)
    else
        mod.ext[:parameters][:H2] = 0
    end

    # Covered by incentive scheme for carbon neutral hydrogen?
    if data["H2CN_prod"] == "YES" 
        mod.ext[:parameters][:H2CN_prod] = 1
        push!(agents[:h2cn_prod],m)
    else
        mod.ext[:parameters][:H2CN_prod] = 0
    end

     # Covered by incentive scheme for carbon neutral hydrogen?
    if data["H2CN_cap"] == "YES" 
        mod.ext[:parameters][:H2CN_cap] = 1
        push!(agents[:h2cn_cap],m)
    else
        mod.ext[:parameters][:H2CN_cap] = 0
    end

    if data["Support"] == "YES" 
        mod.ext[:parameters][:supported] = 1
        mod.ext[:parameters][:not_supported] = 0
        push!(agents[:supported],m)
    else
        if data["H2"] == "YES" 
            mod.ext[:parameters][:not_supported] = 1
            push!(agents[:not_supported],m)
        else
            mod.ext[:parameters][:not_supported] = 0
        end
        mod.ext[:parameters][:supported] = 0
    end

     # Covered by natural gas market
     if data["NG"] == "YES" 
        mod.ext[:parameters][:NG] = 1
        push!(agents[:ng],m)
    else
        mod.ext[:parameters][:NG] = 0
    end

    return mod, agents
end