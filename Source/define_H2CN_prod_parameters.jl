function define_H2CN_prod_parameters!(H2CN_prod::Dict,data::Dict,ts::DataFrame,repr_days::DataFrame)
    # H2 demand
    H2CN_prod["H2CN_PRODT"] = [zeros(3); data["conv_factor"]*data["CNH2_demand_2024"]*ones(6); data["conv_factor"]*data["CNH2_demand_2030"]*ones(10); data["CNH2_demand_2040"]*ones(data["nyears"]-19)]
    H2CN_prod["H2FP_BIDT"] = [zeros(9); data["H2FP_tender_2030"]; zeros(data["nyears"]-10)]
    H2CN_prod["H2CfD_BIDT"] = [zeros(9); data["H2CfD_tender_2030"]; zeros(data["nyears"]-10)]
    return H2CN_prod
end