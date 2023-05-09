# Save results
function save_results(mdict::Dict,EOM::Dict,ETS::Dict,H2::Dict,ADMM::Dict,results::Dict,data::Dict,agents::Dict,sens) 
    # note that type of "sens" is not defined as a string stored in a dictionary is of type String31, whereas a "regular" string is of type String. Specifying one or the other may trow errors.
    Years = range(2021,stop=2021+data["nyears"]-1)
    Iterations = range(1,stop=data["CircularBufferSize"])

    if isfile(joinpath(home_dir, string("agent_costs_",temp_data["General"]["nReprDays"],"_repr_days.csv"))) != 1
        CSV.write(joinpath(string("agent_costs_",temp_data["General"]["nReprDays"],"_repr_days.csv")), DataFrame(), delim=";", 
                    header=["scen_number";"sensitivity";"n_iter";string.(agents[:all])]
        )
    end
    if isfile(joinpath(home_dir, string("agent_profits_",temp_data["General"]["nReprDays"],"_repr_days.csv"))) != 1
        CSV.write(joinpath(string("agent_profits_",temp_data["General"]["nReprDays"],"_repr_days.csv")), DataFrame(), delim=";", 
                    header=["scen_number";"sensitivity";"n_iter";string.(agents[:all])]
        )
    end
    if isfile(joinpath(home_dir, string("agent_profits_before_support",temp_data["General"]["nReprDays"],"_repr_days.csv"))) != 1
        CSV.write(joinpath(string("agent_profits_before_support_",temp_data["General"]["nReprDays"],"_repr_days.csv")), DataFrame(), delim=";", 
                    header=["scen_number";"sensitivity";"n_iter";string.(agents[:all])]
        )
    end

    # Aggregate metrics 
    tot_cost = sum(value(mdict[m].ext[:expressions][:tot_cost]) for m in agents[:all])
    h2cfd_cost = sum(value(mdict[m].ext[:expressions][:h2CfD_cost]) for m in agents[:h2s])
    h2f_cost = sum(value(mdict[m].ext[:expressions][:h2f_cost]) for m in agents[:h2s])
    h2_cap_grant_cost = sum(value(mdict[m].ext[:expressions][:h2_cap_grant_cost]) for m in agents[:h2s])

    tot_em = sum(results["e"][m][end][jy] for m in agents[:ets],jy in mdict[agents[:ps][1]].ext[:sets][:JY]) 
    H2_policy_cost = ( sum(sum(results["h2cn_prod"][m][end].*results["λ"]["H2CN_prod"][end])  for m in agents[:h2cn_prod])
                    + sum(sum(results["h2cn_cap"][m][end].*results["λ"]["H2CN_cap"][end]) for m in agents[:h2cn_cap])
                    + h2cfd_cost
                    + h2f_cost
                    + h2_cap_grant_cost )
    if data["import"] == "YES" 
        α_1 = mdict["Import"].ext[:parameters][:α_1]
        α_2 = mdict["Import"].ext[:parameters][:α_2]
    else
        α_1 = 0
        α_2 = 0
    end

    vector_output = [data["scen_number"]; sens; ADMM["n_iter"];
                     ADMM["walltime"];ADMM["Residuals"]["Primal"]["ETS"][end];ADMM["Residuals"]["Primal"]["MSR"][end]; 
                     ADMM["Residuals"]["Primal"]["EOM"][end];
                     ADMM["Residuals"]["Primal"]["REC_y"][end]+ADMM["Residuals"]["Primal"]["REC_m"][end]+ADMM["Residuals"]["Primal"]["REC_d"][end]+ADMM["Residuals"]["Primal"]["REC_h"][end]; 
                     ADMM["Residuals"]["Primal"]["H2_y"][end]; ADMM["Residuals"]["Primal"]["H2CN_prod"][end]; ADMM["Residuals"]["Primal"]["H2CN_cap"][end]; 
                     ADMM["Residuals"]["Dual"]["ETS"][end]; ADMM["Residuals"]["Dual"]["EOM"][end]; 
                     ADMM["Residuals"]["Dual"]["REC_y"][end]+ADMM["Residuals"]["Dual"]["REC_m"][end]+ADMM["Residuals"]["Dual"]["REC_d"][end]+ADMM["Residuals"]["Dual"]["REC_h"][end]; 
                     ADMM["Residuals"]["Dual"]["H2_y"][end];ADMM["Residuals"]["Dual"]["H2CN_prod"][end]; 
                     ADMM["Residuals"]["Dual"]["H2CN_cap"][end]; mdict["Ind"].ext[:parameters][:β]; α_2;
                     results[ "λ"]["EUA"][end][2]; tot_em; tot_cost;H2_policy_cost
                     ]
    CSV.write(joinpath(home_dir,string("overview_results_",data["nReprDays"],"_repr_days.csv")),
             DataFrame(reshape(vector_output,1,:),:auto), 
             delim=";",
             append=true
             );

    # Agent specific metrics
    agent_costs = [data["scen_number"]; sens; ADMM["n_iter"]]
    for m in agents[:all]
        append!(agent_costs, value(mdict[m].ext[:expressions][:tot_cost]))
    end
    CSV.write(
        joinpath(home_dir, string("agent_costs_", data["nReprDays"], "_repr_days.csv")), 
        DataFrame(reshape(agent_costs,1,:),:auto), 
        delim=";",
        append=true
    )

    agent_profits_before_support = [data["scen_number"]; sens; ADMM["n_iter"]]
    for m in agents[:all]
        append!(agent_profits_before_support, value(mdict[m].ext[:expressions][:agent_revenue_before_support]))
    end
    CSV.write(
        joinpath(home_dir, string("agent_profits_before_support_", data["nReprDays"], "_repr_days.csv")), 
        DataFrame(reshape(agent_profits_before_support,1,:),:auto), 
        delim=";",
        append=true
    )

    agent_profits = [data["scen_number"]; sens; ADMM["n_iter"]]
    for m in agents[:all]
        append!(agent_profits, value(mdict[m].ext[:expressions][:agent_revenue_after_support]))
    end
    CSV.write(
        joinpath(home_dir, string("agent_profits_", data["nReprDays"], "_repr_days.csv")), 
        DataFrame(reshape(agent_profits,1,:),:auto), 
        delim=";",
        append=true
    )


    # ETS
        # Note: 
        # TNAC will be shifted by 2 years (i.e., TNAC[y] is the TNAC at the end of year y-2)
        # MSR will be shifted by 1 yeare (i.e., MSR[y,12] is the MSR at the end of year y-1)
    mat_output = [Years ETS["CAP"] ETS["S"] sum(ETS["C"][:,:],dims=2) ETS["MSR"][2:end,12] ETS["TNAC"][3:end] sum(results["e"][m][end] for m in agents[:ind]) sum(results["e"][m][end] for m in setdiff(agents[:ets],union(agents[:ind],agents[:ps]))) sum(results["e"][m][end] for m in setdiff(agents[:ets],union(agents[:ind],agents[:h2s]))) results[ "λ"]["EUA"][end] sum(results["b"][m][end] for m in agents[:ind]) sum(results["b"][m][end] for m in setdiff(agents[:ets],agents[:ind]))]
    CSV.write(joinpath(home_dir,string("Results_",data["nReprDays"],"_repr_days"),string("Scenario_",data["scen_number"],"_ETS_",sens,".csv")), DataFrame(mat_output,:auto), delim=";",header=["Year";"CAP";"Supply";"Cancellation";"MSR";"TNAC";"Emissions_Ind";"Emissions_H2S"; "Emissions_PS"; "EUAprice"; "EUAs_Ind"; "EUAs_PS"]);
     
    # Power sector
    fuel_shares = zeros(length(agents[:ps]),data["nyears"])
    available_cap = zeros(length(agents[:ps]),data["nyears"])
    add_cap = zeros(length(agents[:ps]),data["nyears"])
    mm = 1
    for m in agents[:ps]
        gw = value.(mdict[m].ext[:expressions][:gw])
        fuel_shares[mm,:] = sum(gw[jh,jd,:] for jh in mdict[m].ext[:sets][:JH], jd in mdict[m].ext[:sets][:JD])
        CAP_LT = mdict[m].ext[:parameters][:CAP_LT]
        LEG_CAP = mdict[m].ext[:parameters][:LEG_CAP]
        add_cap[mm,:] = cap = value.(mdict[m].ext[:variables][:cap])
        available_cap[mm,:] = [sum(CAP_LT[y2,jy]*cap[y2] for y2=1:jy) + LEG_CAP[jy] for jy in mdict[m].ext[:sets][:JY]]
        mm = mm+1
    end
    gw = Dict()
    for m in agents[:eom] # including electrolysis demand
        gw[m] = value.(mdict[m].ext[:expressions][:gw])
    end
    gw_tot = sum(gw[m] for m in agents[:eom]) # total electricity generation
    gw_res_tot = sum(results["r_y"][m][end][:] for m in agents[:rec]) # total renewable electricty generation participating in the res auctions
    # For the production weighted averages below I assume that REC support for RES from electrolyzers (or electricity costs) are internal transfers - not taken into account:
    λ_EOM_avg = [sum(gw_tot[:,:,jy].*results[ "λ"]["EOM"][end][:,:,jy])./sum(gw_tot[:,:,jy]) for jy in mdict[agents[:ps][1]].ext[:sets][:JY]] # production weighted average electricity price
    λ_REC_avg = [gw_res_tot[jy].*results[ "λ"]["REC_y"][end][jy]./gw_res_tot[jy] for jy in mdict[agents[:ps][1]].ext[:sets][:JY]] # production weighted support for RES  
    mat_output = [Years λ_EOM_avg λ_REC_avg transpose(add_cap) transpose(available_cap) transpose(fuel_shares)]
    CSV.write(joinpath(home_dir,string("Results_",data["nReprDays"],"_repr_days"),string("Scenario_",data["scen_number"],"_PS_",sens,".csv")), DataFrame(mat_output,:auto), delim=";",header=["Year";"EOM_avg";"REC_y";string.("ADD_CAP_",agents[:ps]);string.("CAP_",agents[:ps]);string.("FS_",agents[:ps])]);
    
    # Hydrogen sector 
    h2_cap = zeros(length(agents[:h2s]),data["nyears"])
    h2_prod = zeros(length(agents[:h2s]),data["nyears"])
    h2_add_cap = zeros(length(agents[:h2s]),data["nyears"])
    h2_import = zeros(length(agents[:h2import]),data["nyears"])

    mm = 1
    for m in agents[:h2s]
        CAP_LT = mdict[m].ext[:parameters][:CAP_LT]
        LEG_CAP = mdict[m].ext[:parameters][:LEG_CAP]
        h2_add_cap[mm,:] = cap = value.(mdict[m].ext[:variables][:capH])
        h2_cap[mm,:] = [sum(CAP_LT[y2,jy]*cap[y2] for y2=1:jy) + LEG_CAP[jy] for jy in mdict[m].ext[:sets][:JY]]    
        h2_prod[mm,:] = value.(mdict[m].ext[:expressions][:gH_y])./data["conv_factor"] # Convert to Mt
        mm = mm+1
    end
    h2cn_prod = zeros(length(agents[:h2cn_prod]),data["nyears"])
    h2cn_cap = zeros(length(agents[:h2cn_prod]),data["nyears"])
    h2cfd = zeros(length(agents[:h2cn_prod]),data["nyears"])
    h2fp = zeros(length(agents[:h2cn_prod]),data["nyears"])

    mm = 1
    for m in agents[:h2cn_cap]
        h2cn_cap[mm,:] = value.(mdict[m].ext[:variables][:capHCN])
        mm = mm+1
    end
    mm = 1
    for m in agents[:h2cn_prod]
        h2cn_prod[mm,:] = value.(mdict[m].ext[:variables][:gHCN])./data["conv_factor"] # Convert to Mt
        h2cfd[mm,:] = value.(mdict[m].ext[:variables][:gHCfD])./data["conv_factor"] # Convert to Mt
        h2fp[mm,:] = value.(mdict[m].ext[:variables][:gHFP])./data["conv_factor"] # Convert to Mt

        mm = mm+1
    end
    mm = 1
    for m in agents[:h2import]
        h2_import[mm,:] = value.(mdict[m].ext[:expressions][:gH_y])./data["conv_factor"] # Convert to Mt
        mm = mm+1
    end

    gHw_h = Dict()
    gHw_d = Dict()
    gHw_m = Dict()
    for m in agents[:h2s]  
        gHw_h[m] = value.(mdict[m].ext[:expressions][:gH_h_w])
        gHw_d[m] = value.(mdict[m].ext[:expressions][:gH_d_w])
        gHw_m[m] = value.(mdict[m].ext[:variables][:gH_m])
    end
    for m in agents[:h2import]
        gHw_h[m] = value.(mdict[m].ext[:expressions][:gH_h_w])
        gHw_d[m] = value.(mdict[m].ext[:expressions][:gH_d_w])
        gHw_m[m] = value.(mdict[m].ext[:variables][:gH_m])
    end
    gHw_h_tot = sum(gHw_h[m] for m in keys(gHw_h)) # total hydrogen production, weighted
    gHw_d_tot = sum(gHw_d[m] for m in keys(gHw_d)) # total hydrogen production, weighted
    gHw_m_tot = sum(gHw_m[m] for m in keys(gHw_m)) # total hydrogen production 

    if data["H2_balance"] == "Hourly"
        λ_H2_avg = [sum(gHw_h_tot[:,:,jy].*results["λ"]["H2_h"][end][:,:,jy])./sum(gHw_h_tot[:,:,jy])*data["conv_factor"]/1000 for jy in mdict[agents[:h2s][1]].ext[:sets][:JY]]
    elseif data["H2_balance"] == "Daily"
        λ_H2_avg = [sum(gHw_d_tot[:,jy].*results["λ"]["H2_d"][end][:,jy])./sum(gHw_d_tot[:,jy])*data["conv_factor"]/1000 for jy in mdict[agents[:h2s][1]].ext[:sets][:JY]]
    elseif data["H2_balance"] == "Monthly"
        λ_H2_avg = [sum(gHw_m_tot[:,jy].*results["λ"]["H2_m"][end][:,jy])./sum(gHw_m_tot[:,jy])*data["conv_factor"]/1000 for jy in mdict[agents[:h2s][1]].ext[:sets][:JY]]
    elseif data["H2_balance"] == "Yearly"
        λ_H2_avg = results["λ"]["H2_y"][end]*data["conv_factor"]/1000
    end

    mat_output = [Years transpose(h2_cap) transpose(h2_prod) transpose(h2_import) transpose(h2cn_cap) transpose(h2cn_prod) transpose(h2cfd) transpose(h2fp) λ_H2_avg results["λ"]["H2CN_prod"][end]*data["conv_factor"]/1000 results["λ"]["H2CN_cap"][end]]
    CSV.write(
        joinpath(
            home_dir,
            string("Results_",data["nReprDays"],"_repr_days"),
            string("Scenario_",data["scen_number"],"_H2_",sens,".csv")), 
        DataFrame(mat_output,:auto), delim=";",
        header=["Year";string.("CAP_",agents[:h2s]);string.("PROD_",agents[:h2s]);
                string.("IMPORT_",agents[:h2import]) ; 
                string.("CN_CAP_",agents[:h2cn_prod]);string.("CN_PROD_",agents[:h2cn_prod]);string.("H2CfD_",agents[:h2cn_prod]);string.("H2FP_",agents[:h2cn_prod]);
                "PriceH2";"PremiumH2CN_prod";"PremiumH2CN_cap"]);

                   
    # Operational data
    # Extract hydrogen and electricity production and import data
    Hours = collect(1:data["nTimesteps"]*data["nReprDays"])
    year = data["operationalYear"]-2020
    h2 = zeros(length(agents[:h2]),data["nReprDays"]*data["nTimesteps"])
    el_prod = zeros(length(agents[:ps]), data["nReprDays"] * data["nTimesteps"])

    mm = 1
    for m in agents[:h2]
        h2[mm,:] = -vec(value.(mdict[m].ext[:variables][:gH][:,:,year]))
        mm = mm+1
    end
    mm = 1
    for m in agents[:ps]
        el_prod[mm, :] = vec(value.(mdict[m].ext[:variables][:g][:, :, year]))
        mm += 1
    end
    eom_price = vec(values.(results["λ"]["EOM"][1][:,:,year]))
    mat_output = [Hours eom_price transpose(h2) transpose(el_prod)]
    CSV.write(
        joinpath(
            home_dir,
            string("Results_", data["nReprDays"], "_repr_days"),
            string("Scenario_", data["scen_number"], "_operation_", sens, ".csv")
        ),
        DataFrame(mat_output, :auto),
        delim=";",
        header=[
            "Hour"; 
            "EOM_price";
            string.("PROD_", agents[:h2]);
            string.("PROD_", agents[:ps])
            ]
    )

end
