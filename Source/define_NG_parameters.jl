function define_NG_parameters!(NG::Dict,data::Dict,ts::DataFrame,repr_days::DataFrame,scenario_overview_row::DataFrameRow)
    NG["λ"] = [data["P_2017"]; data["P_2018"]; data["P_2019"]; data["P_2020"].*[(1+data["YoY"]/100)^(jy-1) for jy in 1:data["nyears"]-3]]
    return NG
end