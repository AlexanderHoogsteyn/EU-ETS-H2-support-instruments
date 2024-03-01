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
repr_days = 16

start_scen = 2
stop_scen = 9

scen = 6

#for scen in start_scen:stop_scen
    filename = "Scenario_"*string(scen)*"_low-natural-gas-price.jld2"
    yaml_filename  = "Scenario_"*string(scen)*"_low-natural-gas-price.yaml"
    YAML_data, unload = test_KKT_conditions(joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",filename),
                                        joinpath(home_dir,"Results_"*string(repr_days)*"_repr_days",yaml_filename)                                    
    );
    ADMM = unload["ADMM"]
    results = unload["results"]

    println(filename, " passed all asserts")
#end