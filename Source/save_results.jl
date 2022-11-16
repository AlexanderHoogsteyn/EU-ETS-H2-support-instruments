# Save results
function save_results(mdict::Dict,EOM::Dict,ETS::Dict,ADMM::Dict,results::Dict,data::Dict,agents::Dict,scenario_overview_row::DataFrameRow) 
    Years = range(2017,stop=2017+data["nyears"]-1)
    Iterations = range(1,stop=data["CircularBufferSize"])

    # Aggregate metrics 
    vector_output = [scenario_overview_row["scen_number"]; ADMM["n_iter"]; ADMM["walltime"];ADMM["Residuals"]["Primal"]["ETS"][end];ADMM["Residuals"]["Primal"]["MSR"][end]; 
                     ADMM["Residuals"]["Primal"]["EOM"][end];ADMM["Residuals"]["Primal"]["REC"][end]; ADMM["Residuals"]["Dual"]["ETS"][end];
                     ADMM["Residuals"]["Dual"]["EOM"][end]; ADMM["Residuals"]["Dual"]["REC"][end]; mdict["Ind"].ext[:parameters][:β];
                     results[ "λ"]["EUA"][end][5]; sum(results["e"][m][end][jy] for m in agents[:ets],jy in mdict[agents[:ps][1]].ext[:sets][:JY])]
    CSV.write(joinpath(home_dir,"overview_results.csv"), DataFrame(reshape(vector_output,1,:),:auto), delim=";",append=true);

    # ADMM Convergence
    # mat_output = [Iterations ADMM["Residuals"]["Primal"]["ETS"][1:end] ADMM["Residuals"]["Primal"]["MSR"][1:end] ADMM["Residuals"]["Primal"]["EOM"][1:end] ADMM["Residuals"]["Primal"]["REC"][1:end] ADMM["Residuals"]["Primal"]["H2"][1:end] ADMM["Residuals"]["Primal"]["H2CN_prod"][1:end] ADMM["Residuals"]["Primal"]["H2CN_cap"][1:end] ADMM["Residuals"]["Dual"]["ETS"][1:end] ADMM["Residuals"]["Dual"]["EOM"][1:end]  ADMM["Residuals"]["Dual"]["REC"][1:end] ADMM["Residuals"]["Dual"]["H2"][1:end] ADMM["Residuals"]["Dual"]["H2CN_prod"][1:end] ADMM["Residuals"]["Dual"]["H2CN_cap"][1:end]]
    # CSV.write(joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_convergence.csv")), DataFrame(mat_output,:auto), delim=";",header=["Iterations";"PrimalResidual_ETS";"PrimalResidual_MSR";"PrimalResidual_EOM";"PrimalResidual_REC";"PrimalResidual_H2";"PrimalResidual_H2CN_prod";"PrimalResidual_H2CN_cap";"DualResidual_ETS";"DualResidual_EOM";"DualResidual_REC";"DualResidual_H2";"DualResidual_H2CN_prod";"DualResidual_H2CN_cap"])

    # # Temporary - plot of residuals 
    # p = plot(Iterations,[ADMM["Residuals"]["Primal"]["ETS"][1:end]./ADMM["Residuals"]["Primal"]["ETS"][1] ADMM["Residuals"]["Primal"]["MSR"][1:end]./ADMM["Residuals"]["Primal"]["MSR"][1] ADMM["Residuals"]["Primal"]["EOM"][1:end]./ADMM["Residuals"]["Primal"]["EOM"][1] ADMM["Residuals"]["Primal"]["REC"][1:end]./ADMM["Residuals"]["Primal"]["REC"][1] ADMM["Residuals"]["Primal"]["H2"][1:end]./ADMM["Residuals"]["Primal"]["H2"][1]], label = ["PrimalResidual_ETS" "PrimalResidual_MSR" "PrimalResidual_EOM" "PrimalResidual_REC" "PrimalResidual_H2"], yaxis=(:log10))
    # savefig(p, joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_primal_convergence.pdf"))) 

    # p = plot(Iterations[2:end],[ADMM["Residuals"]["Dual"]["ETS"][2:end]./ADMM["Residuals"]["Dual"]["ETS"][2] ADMM["Residuals"]["Dual"]["EOM"][2:end]./ADMM["Residuals"]["Dual"]["EOM"][2] ADMM["Residuals"]["Dual"]["REC"][2:end]./ADMM["Residuals"]["Dual"]["REC"][2] ADMM["Residuals"]["Dual"]["H2"][2:end]./ADMM["Residuals"]["Dual"]["H2"][2]], label = ["DualResidual_ETS" "DualResidual_EOM" "DualResidual_REC" "DualResidual_H2"],yaxis=(:log10))
    # savefig(p, joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_dual_convergence.pdf"))) 

    # p = plot(Iterations[2:end],[ADMM["Residuals"]["Primal"]["ETS"][2:end]./ADMM["Residuals"]["Dual"]["ETS"][2:end] ADMM["Residuals"]["Primal"]["EOM"][2:end]./ADMM["Residuals"]["Dual"]["EOM"][2:end] ADMM["Residuals"]["Primal"]["REC"][2:end]./ADMM["Residuals"]["Dual"]["REC"][2:end] ADMM["Residuals"]["Primal"]["H2"][2:end]./ADMM["Residuals"]["Dual"]["H2"][2:end]], label = ["DualResidual_ETS" "DualResidual_EOM" "DualResidual_REC" "DualResidual_H2"],yaxis=(:log10))
    # savefig(p, joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_ratio_convergence.pdf"))) 

    # ADMM["Residuals"]["Primal"]["H2CN_prod"][1:end] ADMM["Residuals"]["Primal"]["H2CN_cap"][1:end]
    # "PrimalResidual_H2CN_prod" "PrimalResidual_H2CN_cap"
   
    # ETS
    mat_output = [Years ETS["CAP"] ETS["S"] sum(ETS["C"][:,:],dims=2) ETS["MSR"][:,12] ETS["TNAC"] sum(results["e"][m][end] for m in agents[:ind]) sum(results["e"][m][end] for m in setdiff(agents[:ets],agents[:ind])) results[ "λ"]["EUA"][end] sum(results["b"][m][end] for m in agents[:ind]) sum(results["b"][m][end] for m in setdiff(agents[:ets],agents[:ind]))]
    CSV.write(joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_ETS.csv")), DataFrame(mat_output,:auto), delim=";",header=["Year";"CAP";"Supply";"Cancellation";"MSR";"TNAC";"Emissions_Ind"; "Emissions_PS"; "EUAprice"; "EUAs_Ind"; "EUAs_PS"]);
     
    # Power sector
    fuel_shares = zeros(length(agents[:ps]),data["nyears"])
    available_cap = zeros(length(agents[:ps]),data["nyears"])
    mm = 1
    for m in agents[:ps]
        gw = value.(mdict[m].ext[:expressions][:gw])
        # gy = value.(mod.ext[:expressions][:g_y])
        # gd = value.(mod.ext[:expressions][:g_d])
        fuel_shares[mm,:] = sum(gw[jh,jd,:] for jh in mdict[m].ext[:sets][:JH], jd in mdict[m].ext[:sets][:JD])
        CAP_LT = mdict[m].ext[:parameters][:CAP_LT]
        LEG_CAP = mdict[m].ext[:parameters][:LEG_CAP]
        cap = value.(mdict[m].ext[:variables][:cap])
        available_cap[mm,:] = [sum(CAP_LT[y2,jy]*cap[y2] for y2=1:jy) + LEG_CAP[jy] for jy in mdict[m].ext[:sets][:JY]]
        mm = mm+1
    end
    λ_EOM_avg = [sum(EOM["Dw"][:,:,jy].*results[ "λ"]["EOM"][end][:,:,jy])./sum(EOM["Dw"][:,:,jy]) for jy in mdict[agents[:ps][1]].ext[:sets][:JY]]
    λ_REC_d_avg = [sum(results[ "λ"]["REC_d"][end][:,jy])/data["nReprDays"]  for jy in mdict[agents[:ps][1]].ext[:sets][:JY]]
    λ_REC_h_avg = [sum(results[ "λ"]["REC_h"][end][:,:,jy])/(data["nReprDays"]*data["nTimesteps"]) for jy in mdict[agents[:ps][1]].ext[:sets][:JY]]
    mat_output = [Years λ_EOM_avg results["λ"]["REC_y"][end] λ_REC_d_avg λ_REC_h_avg transpose(available_cap) transpose(fuel_shares)]
    CSV.write(joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_PS.csv")), DataFrame(mat_output,:auto), delim=";",header=["Year";"EOM_avg";"REC_y";"REC_d";"REC_h";string.("CAP_",agents[:ps]);string.("FS_",agents[:ps])]);
    
    # Hydrogen sector 
    h2_cap = zeros(length(agents[:h2s]),data["nyears"])
    h2_prod = zeros(length(agents[:h2s]),data["nyears"])
    mm = 1
    for m in agents[:h2s]
        CAP_LT = mdict[m].ext[:parameters][:CAP_LT]
        LEG_CAP = mdict[m].ext[:parameters][:LEG_CAP]
        cap = value.(mdict[m].ext[:variables][:capH])
        h2_cap[mm,:] = [sum(CAP_LT[y2,jy]*cap[y2] for y2=1:jy) + LEG_CAP[jy] for jy in mdict[m].ext[:sets][:JY]]    
        h2_prod[mm,:] = value.(mdict[m].ext[:variables][:gH])./data["conv_factor"]
        mm = mm+1
    end
    mat_output = [Years transpose(h2_cap) transpose(h2_prod) results["λ"]["H2"][end]*data["conv_factor"]/1000 results["λ"]["H2CN_prod"][end]*data["conv_factor"]/1000 results["λ"]["H2CN_cap"][end]]
    CSV.write(joinpath(home_dir,"Results",string("Scenario_",scenario_overview_row["scen_number"],"_H2.csv")), DataFrame(mat_output,:auto), delim=";",header=["Year";string.("CAP_",agents[:h2s]);string.("PROD_",agents[:h2s]);"PriceH2";"PremiumH2CN_prod";"PremiumH2CN_cap"]);

# to be computed 
# Hydrogen: cost per kg or Mt => price of hydrogen? does this cover the REC as well? 
# Hydrogen: carbon content per kg or Mt -> can this be done? or only ex-post by comparing system emissions? or marginal emission intensity?
# Total system cost
end