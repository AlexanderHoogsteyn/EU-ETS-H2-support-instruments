function define_H2CN_prod_parameters!(H2CN_prod::Dict,data::Dict,ts::DataFrame,repr_days::DataFrame)
    # H2 demand
    if data["run_theoretical_min"] == "NO"
        H2CN_prod["H2CN_PRODT"] = [
            zeros(3);
            data["conv_factor"]*data["CNH2_demand_2024"]*ones(6); 
            data["conv_factor"]*data["CNH2_demand_2030"]*ones(10); 
            data["conv_factor"]*data["CNH2_demand_2040"]*ones(data["nyears"]-19)
            ]
    elseif data["run_theoretical_min"] == "YES"
        h2_results = CSV.read(
            joinpath(
                home_dir,
                string("Results_", data["nReprDays"], "_repr_days"),
                string("Scenario_", data["scen_number"], "_H2_", sens, ".csv")
            ),
            DataFrame;delim=";"
        )

        H2CN_prod["H2CN_PRODT"] =  h2_results[!,:PROD_Alkaline_base] + h2_results[!,:PROD_Alkaline_peak]
    else
        print("Scenario overview ill-defined")
    end
    return H2CN_prod
end