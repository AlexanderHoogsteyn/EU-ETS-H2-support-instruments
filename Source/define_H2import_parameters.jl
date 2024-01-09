function define_H2import_parameters!(mod::Model, data::Dict,ts::DataFrame,repr_days::DataFrame,REC::Dict)
    mod.ext[:parameters][:LT] = data["Leadtime"]

    # Equal reduction of import cost compared to capex cost decrease of PtH
    mod.ext[:parameters][:SF] = ones(data["nyears"],1)     # Discount rate, 2021 as base year due to calibration to 2019 data
    for jy in 1:9
        mod.ext[:parameters][:SF][jy] = (1+data["YoY_OC_pre_2030"]/100)^(jy-1)/(1+data["YoY_OC_pre_2030"]/100)^9
    end
    for jy in 10:data["nyears"]
        mod.ext[:parameters][:SF][jy] = (1+data["YoY_OC_post_2030"]/100)^(jy-10) # EUR/MW or MEUR/TW        
    end
    
    # α-value
    if data["scen_number"] - data["ref_scen_number"] == 0 && data["sens_number"] == 1 # this is a calibration run - provide an initial estimate
        mod.ext[:parameters][:α_2] = 602.328623   #data["a_2"]
    else # get beta from reference result
        overview_results = CSV.read(joinpath(home_dir,string("overview_results_",data["nReprDays"],"_repr_days.csv")),DataFrame;delim=";")
        overview_results_row = filter(row -> row.scen_number in [data["ref_scen_number"]], overview_results)
        mod.ext[:parameters][:α_2] = overview_results_row[!,:Alpha][1]
    end
    mod.ext[:parameters][:α_1] = data["a_1"]

    mod.ext[:parameters][:ADD_SF] = REC["RT"] # Scaling factor for RECs when additionality is not applied = RES target

    return mod
end