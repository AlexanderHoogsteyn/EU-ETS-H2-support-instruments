function test_KKT_conditions(jld2_filename::String,yaml_filename::String)
    # Load results
    unload = load(jld2_filename)
    ADMM = unload["ADMM"]
    results = unload["results"]

    # Load scenario details
    YAML_data = YAML.load_file(yaml_filename)

    # Test residuals
    @assert abs(sum(sum(results["h2cn_prod"][m][end][11:20] for m in keys(results["h2cn_prod"])))/33
                - YAML_data["General"]["contract_duration"]*YAML_data["scenario"]["CNH2_demand_2030"] 
                ) < ADMM["Tolerance"]["H2CN_prod"]
     @assert abs.(sum(results["h2_y"][m][end] for m in keys(results["h2_y"]))[10:30]./33 - [(YAML_data["scenario"]["H2_demand_2050"]-YAML_data["scenario"]["H2_demand_2030"])/20*y+YAML_data["scenario"]["H2_demand_2030"] for y in 0:20]
                 ) < ADMM["Tolerance"]["H2_y"]*ones(21)
    # Test the non-linear MMC
    @assert abs(sum(results["h2_y"]["Alkaline_peak_supported"][end][11:20]) + sum(results["h2_y"]["Alkaline_base_supported"][end][11:20]) 
                + sum(results["h2_y"]["Alkaline_base"][end][11:20]) + sum(results["h2_y"]["Alkaline_peak"][end][11:20]) 
                ) > YAML_data["General"]["contract_duration"]*YAML_data["scenario"]["CNH2_demand_2030"]*33
    return YAML_data, results
end