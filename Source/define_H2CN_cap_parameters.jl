function define_H2CN_cap_parameters!(H2CN_cap::Dict,data::Dict,ts::DataFrame,repr_days::DataFrame)
    # carbon neutral hydrogen production capacity target
    H2CN_cap["H2CN_CAPT"] = [zeros(10); data["CNH2_cap_target_2030"]*ones(10);zeros(data["nyears"]-20)]

    return H2CN_cap
end
