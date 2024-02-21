##  Tests whether KKT conditioons are met for a certain scenario
#   Author: Alexander Hoogsteyn
#   Last update: Februari 2024

const home_dir = @__DIR__

# Include packages
using DataFrames, CSV, YAML, DataStructures # dataprocessing
using ProgressBars, Printf # progress bar
using JLD2

# Include functions
include(joinpath(home_dir,"Source","KKT_tests.jl"))

# Set number of representive days to test
repr_days = 2


#Test Scenario 1
filename = "Scenario_1_low-natural-gas-price.jld2"
yaml_filename  = "Scenario_1_low-natural-gas-price.yaml"
YAML_data, results = test_KKT_conditions(joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",filename),
                                    joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",yaml_filename)                                    
);

#Test Scenario 2
filename = "Scenario_2_low-natural-gas-price.jld2"
yaml_filename  = "Scenario_2_low-natural-gas-price.yaml"
YAML_data, results = test_KKT_conditions(joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",filename),
                                    joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",yaml_filename)                                    
);

#Test Scenario 3
filename = "Scenario_3_low-natural-gas-price.jld2"
yaml_filename  = "Scenario_3_low-natural-gas-price.yaml"
YAML_data, results = test_KKT_conditions(joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",filename),
                                    joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",yaml_filename)                                    
);