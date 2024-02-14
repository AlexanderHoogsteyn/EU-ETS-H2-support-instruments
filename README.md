This code was developed to study the interaction between the power sector, the energy intensive industry and the hydrogen sector on the auctions of the European Emission Trading System, the energy-only electricity market, the hydrogen market. It calculates an equilibrium between a set of representative price-taking agents on these markets and allows enforcing renewable targets and different defnitions of the "additionality" principle (putting requirements on the electricity used in the electrolysis proces). It allows to enforce hydrogen and renewable energy targets. An auctioned fixed premium and hydrogen contract for difference can be applied. It employs an iterative price-search algorithm based on ADMM to calculate this equilibrium iteratively.  The emissions of the energy-intensive industry are represented via marginal abatement cost curves, which can be automatically calibrated to reproduce allowance prices post MSR reform (2019).

The research code is forked from the framework used in the following paper, and uses an identical representation of the power sector and ETS-sector than considered there:

[1] K. Bruninx & Marten Ovaere, "COVID-19, Green Deal & the recovery plan permanently change emissions and prices in EU ETS Phase IV", Nature Communications, Volume 13, art. no. 1165, 2022.

The research code documented below has been used in the following paper, where the adaptations form the original paper are pointed out:

[2] A. Hoogsteyn , K. Bruninx, J.  Meus, E. Delarue, "Support mechanisms for hydrogen: Interactions and distortions of different instruments", Working paper, 2024.

## Installation, hardware & software requirements
### Installation
After downloading the repository, no specific installation is required. The user should, however, have the following software installed to be able to execute the program:
- Julia (https://julialang.org/downloads/)
- Gurobi (https://www.gurobi.com/) and have a license for this solver. If the user doesn't have access to Gurobi, any alternative (open source) solver capable of solving quadratic programming problems can be used. 

The program can be executed in the Julia terminal. Any text editor can be used to modify the code. However, it may be more convenient to work with a tool such as Visual Studio Code (https://code.visualstudio.com/).

If the user does not have any of these programs installed, the installation should take approximately one hour.

### Software requirements: 
This code has been developed using Julia v1.5 and is verified to be compatible up to v1.7.2 . The solver used is Gurobi v.9.0.

The following Julia packages are required:
- JuMP v.0.21.5
- Gurobi v.0.8.1
- DataFrames v.0.21.7
- CSV v.0.7.7
- YAML v0.4.2
- DataStructures
- ProgressBars v0.7.1
- Printf
- TimerOutputs
- JLD2
- ArgParse
- RepresentativePeriodsFinder (https://ucm.pages.gitlab.kuleuven.be/representativeperiodsfinder.jl/)

If the user does not have any of these programs installed, the installation should take less than one hour.

### Hardware requirements 
No specific hardware is required. Depending on the configuration (number of agents and markets considered), computational effort may significantly increase.

## Running the program
### Input
There are three places where the user can change the input.

2. The specifications of each scenario can be found in the file "overview_scenarios.csv"
    - scen_number (Integer): the number of the scenario
    - LRF_2021 (Float): the Linear Reduction Factor applied in the period 2021-2030 (default: 0.022)
    - LRF_2031 (Float): the Linear Reduction Factor applied as of 2021 (default: 0.022)
    - COVID (0/1): consider the negative demand shock induced by COVID-19 yes (1) or no (0)
    - MSR (2018/2021): the MSR design considered (2018: current design, based on 2018 directive or 2021: as proposed in the Fit for 55 Package)
    - gamma (Float): exponent in the functional form of the abatement cost curve
    - ref_scen (Integer): reference scenario. If this is the same as the scenario number (scen_number), the beta-parameter in the marginal abatement cost curve will be calibrated to reproduce emission allowance prices in 2019. If it differs from the scenario number in the  same row, the beta-value from the reference scenario will be retrieved and used in the marginal abatement cost curve. Note that the user must ensure that the results of the reference scenario are available.
3. The file "overview_data.yaml" contains a number of input parameters that are common to all scenarios. Examples include the number of years the analysis considers, the historical emissions and prices that will be used to calibrate the marginal abatement cost curve and the parameters of the market stability reserve for each of the two designs. Note that the impact of COVID (240 MtCO2, linearly decreasing between 2020-2025) can only be switched on/off (see above).

### Running the code (to be updated)
The code can be run by executing the "MAIN.jl"file, there are different ways to select which scenarios to run.

1. On line 167 of the "Main.jl"-file, the user can specify the set of scenarios one would like to study, ranging from "start_scen" to "stop_scen". This determines which scenarios in the "overview_scenarios.csv"-file will be executed. Similarly,  the user can select a set of sensitivities using "start_sens" and "stop_sens" as defined in "overview_sensitivity.csv" To use this option, make sure to set "HPC" on line 7 to "NA".
2. Alternatively, the scenario and sensitivity instructions can be parsed as arguments from the command line. To use this option, make sure to set "HPC" on line 7 to "DelftBlue". For example, the following line executes scenario 1 to 10 in the central reference sensitivity:
```
julia --threads=16 MAIN.jl --start_scen 1 --stop_scen 10 --start_sens 1  --stop_sens 1 > output.log
```

If the scenario at hand is a scenario in which the marginal abatement cost needs to be calibrated, the ADMM procedure will be executed a number of times until the emission allowance price in 2019 is replicated with a user-specified tolerance (default: 80 EUR/tCO2 with a 0.1 €/MWh tolerance, see "overview_data.yaml"). The code will report (in the terminal) the progress of the ADMM procedure and the difference between the computed emission allowance price in 2019 and the historical value. Only the final result (i.e., based on the calibrated MACC) will be stored. Similarly, if you decide to include hydrogen import, the import cost will be calibrated such that a user-defined amount of import is present in 2030 (default: 10 Mt H2 in 2030 with a 0.1 Mt tolerance, see "overview_data.yaml").

If the scenario at hand can use a calibrated marginal abatement cost curve from the specified reference scenario (see above), the ADMM procedure is executed once. When the user desides to alter the cost information in "overview_data.yaml" it is important that such a recalibration is carried out, otherwise, the current cost calibration of the MAC and import cost curve can be used.

## Running the code on a HPC with SLURM scheduler
Below instructions are given to execute the code on a high-performance computer (HPC) that uses the SLURM scheduler,  such as DelftBlue and wICE (KU Leuven/UHasselt).
# Simple single scenario run
```
#!/bin/bash -l
#!/bin/bash -l
#SBATCH --cluster="wice"
#SBATCH --nodes="1"
#SBATCH --job-name="calibration"
#SBATCH --mail-user="your.email@youruniversity.be"
#SBATCH --mail-type=FAIL,END,BEGIN
#SBATCH --time="48:00:00"
#SBATCH --ntasks="1"
#SBATCH --cpus-per-task=16
#SBATCH --account="your_account"
#SBATCH --partition="batch"
#SBATCH --array=1-10

cd Documents/EU-ETS-H2-support-mechanisms

srun julia --threads=16  MAIN.jl --start_scen 1 --stop_scen 1 --start_sens 1 --stop_sens 1

```
# Multiple scenario using batch submission
```
#!/bin/bash -l
#SBATCH --cluster="wice"
#SBATCH --nodes="1"
#SBATCH --job-name="scenario 1 to 10, sensitivity 1"
#SBATCH --mail-user="your.email@youruniversity.be"
#SBATCH --mail-type=FAIL,END,BEGIN
#SBATCH --time="8:59:00"
#SBATCH --ntasks="1"
#SBATCH --cpus-per-task=16
#SBATCH --account="your_account"
#SBATCH --partition="batch"
#SBATCH --array=1-10

cd Documents/EU-ETS-H2-support-mechanisms

srun julia --threads 16 MAIN.jl --start_scen $SLURM_ARRAY_TASK_ID --stop_scen $SLURM_ARRAY_TASK_ID --start_sens 1 --stop_sens 1 > hpc/Scenario_$SLURM_ARRAY_TASK_ID.log
```
# Multiple sensetivities using batch submission
```
#!/bin/bash -l
#SBATCH --cluster="wice"
#SBATCH --nodes="1"
#SBATCH --job-name="scenario 2, sensitivity 1-10"
#SBATCH --mail-user="your.email@youruniversity.be"
#SBATCH --mail-type=FAIL,END,BEGIN
#SBATCH --time="8:59:00"
#SBATCH --ntasks="1"
#SBATCH --cpus-per-task=16
#SBATCH --account="your_account"
#SBATCH --partition="batch"
#SBATCH --array=1-10

cd Documents/EU-ETS-H2-support-mechanisms

srun julia --threads 16 MAIN.jl --start_scen 2 --stop_scen 2 --start_sens $SLURM_ARRAY_TASK_ID --stop_sens $SLURM_ARRAY_TASK_ID  > hpc/Sensetivity_$SLURM_ARRAY_TASK_ID.log


```
Tips: 
- Adapt the script so that it points to the direction where "MAIN.jl" can be found
- The decision problems of the agents are solved in parallel in each iteration. Gurobi uses 4 threads to solve each problem.
- The number of cpus should be equal to the number of agents + 1 (1 master and 1 per agent)
- Set the number of cpu's equal to the number of threads used for julia x 4 (e.g., 17 x 4 = 68), as by default 4 threads are used by Gurobi
- Check resource use via seff [job_id]


Resources: 
- For basic info on how to use DelftBlue, see https://doc.dhpc.tudelft.nl/delftblue/crash-course/.
- For basic info on wICE, see https://docs.vscentrum.be/leuven/wice_quick_start.html/

### Output & Postprocessing (to be updated)
Running the code will generate X output files:

1. "overview_results.csv", in which aggregate metrics of all simulations will be listed:
    -   n_iter: number of iterations required to compute equilibrium
    -	walltime: number seconds required to compute equilibrium
    -   PrimalResidual: Primal residual on solution, one for each considered market (metric for quality of solution, lower is better, see [2])
    -   DualResidual: Dual residual on solution, one for each considered market (metric for quality of solution, lower is better, see [2])		
    -   Beta: Employed beta-value in this scenario
    -	EUA_2021: Emission allowance price in 2021 (€/tCO2)
    -   CumulativeEmissions: Cumulative emissions 2020-end horizon (MtCO2)
2. "Scenario_X_ETS_Y.csv" in "Results_Z_repr_days" (X = scenario number, Y= sensitivity, Z = number of representative days ), a csv-file per simulation with more detailed results on the Emission trading scheme
    -   CAP: annual cap on emissions (MtCO2)
    -   Supply: annual supply of emission allowances after corrections MSR (MtCO2)
    -   Cancellation: annual volume of invalidated or cancelled allowances (MtCO2)
    -   MSR: holdings of the MSR at the end of each year (MtCO2)
    -   TNAC: total number of allowances in circulation at the end of each year (MtCO2)
    -   Emissions: annual emissions (MtCO2)
    -   EUAprice: price of emission allowances (€/tCO2)
    -   EUAs: annually procured emission allowances (MtCO2)
3. "Scenario_X_PS_Y.csv" in "Results_Z_repr_days" (X = scenario number, Y= sensitivity, Z = number of representative days ), a csv-file per simulation with more detailed results on the power system
    -   EOM_avg: Refers to the average electricity-only market (EOM) price in euros per megawatt-hour (EUR/MWh).
    -   REC_y: Indicates the renewable energy certificate (REC) price in euros per megawatt-hour (EUR/MWh) for the given year.
    -   ADD_CAP_CCGT_new: Represents the additional capacity investment (in gigawatts, GW) for Combined Cycle Gas Turbine (CCGT) power plants.
    -   ADD_CAP_WindOffshore: Signifies the additional capacity investment (in GW) for offshore wind power plants.
    -   ADD_CAP_SPP_coal: Denotes the additional capacity investment (in GW) for coal-fired Single Point Producer (SPP) plants.
    -   ADD_CAP_WindOnshore: Represents the additional capacity investment (in GW) for onshore wind power plants.
    -   ADD_CAP_Nuclear: Indicates the additional capacity investment (in GW) for nuclear power plants.
    -   ADD_CAP_Solar: Refers to the additional capacity investment (in GW) for solar power plants.
    -   ADD_CAP_OCGT: Represents the additional capacity investment (in GW) for Open Cycle Gas Turbine (OCGT) power plants.
    -   CAP_CCGT_new: Denotes the total installed capacity (in GW) for Combined Cycle Gas Turbine (CCGT) power plants.
    -   CAP_WindOffshore: Represents the total installed capacity (in GW) for offshore wind power plants.
    -   CAP_SPP_coal: Signifies the total installed capacity (in GW) for coal-fired Single Point Producer (SPP) plants.
    -   CAP_WindOnshore: Indicates the total installed capacity (in GW) for onshore wind power plants.
    -   CAP_Nuclear: Refers to the total installed capacity (in GW) for nuclear power plants.
    -   CAP_Solar: Denotes the total installed capacity (in GW) for solar power plants.
    -   CAP_OCGT: Represents the total installed capacity (in GW) for Open Cycle Gas Turbine (OCGT) power plants.
    -   FS_CCGT_new: Represents the fuel share (production) in terawatt-hours (TWh) for Combined Cycle Gas Turbine (CCGT) power plants.
    -   FS_WindOffshore: Signifies the fuel share (production) in TWh for offshore wind power plants.
    -   FS_SPP_coal: Denotes the fuel share (production) in TWh for coal-fired Single Point Producer (SPP) plants.
    -   FS_WindOnshore: Indicates the fuel share (production) in TWh for onshore wind power plants.
    -   FS_Nuclear: Refers to the fuel share (production) in TWh for nuclear power plants.
    -   FS_Solar: Represents the fuel share (production) in TWh for solar power plants.
    -   FS_OCGT: Signifies the fuel share (production) in TWh for Open Cycle Gas Turbine (OCGT) power plants.
5. "Scenario_X_H2_Y.csv" in "Results_Z_repr_days" (X = scenario number, Y= sensitivity, Z = number of representative days ), a csv-file per simulation with more detailed results on the hydrogen sector
    -   CAP_SMR: Total installed capacity (GW) for Steam Methane Reforming (SMR) hydrogen production.
    -   CAP_SMRCCS: Total installed capacity (in GW) for SMR with Carbon Capture and Storage (CCS) hydrogen production.
    -   CAP_Alkaline_base: Total installed capacity (in GW) for alkaline electrolysis-based hydrogen production (base load).
    -   CAP_Alkaline_peak: Total installed capacity (in GW) for alkaline electrolysis-based hydrogen production (peak load).
    -   PROD_SMR: Annual hydrogen production (in Mt) from Steam Methane Reforming.
    -   PROD_SMRCCS: Annual hydrogen production (in Mt) from SMR with CCS.
    -   PROD_Alkaline_base: Annual hydrogen production (in Mt) from alkaline electrolysis (base load).
    -   PROD_Alkaline_peak: Annual hydrogen production (in Mt) from alkaline electrolysis (peak load).
    -   IMPORT_Import: Annual import of hydrogen (in Mt).
    -   CN_CAP_Alkaline_peak_supported: Carbon neutral installed capacity (in GW) for alkaline electrolysis-based hydrogen production (peak load) with government support.
    -   CN_CAP_Alkaline_base_supported: Carbon neutral total installed capacity (in GW) for alkaline electrolysis-based hydrogen production (base load) with government support.
    -   CN_PROD_Alkaline_peak_supported: Carbon neutral annual hydrogen production (in Mt) from alkaline electrolysis (peak load) with government support.
    -   CN_PROD_Alkaline_base_supported: CCarbon neutral annual hydrogen production (in Mt) from alkaline electrolysis (base load) with government support.
    -   PriceH2: Price of hydrogen (in euros per kilogram, €/kg).
    -   PremiumH2CN_prod: Premium for carbon-neutral hydrogen production (in €/kg).
    -   PremiumH2CN_cap: Premium for carbon-neutral hydrogen capacity (in  M€/GW).
    -   PremiumFP: Fixed Premium for fuel production (in €/kg).
    -   StrikeH2CfD: Strike price for hydrogen Contracts for Difference (CfD) (in €/kg).
    -   RefH2CfD: Reference price for hydrogen CfD (in €/kg).
    -   CapacityGrant: Capacity grant for hydrogen production (in euros per kilowatt, €/kW).
    -   TaxDeduction: Tax deduction for hydrogen production (in euros per kilogram, €/kg).
    -   CAP_Alkaline_peak_supported: Total installed capacity (in GW) for alkaline electrolysis-based hydrogen production (peak load) with government support.
    -   CAP_Alkaline_base_supported: Total installed capacity (in GW) for alkaline electrolysis-based hydrogen production (base load) with government support.
    -   PROD_Alkaline_peak_supported: Annual hydrogen production (in Mt) from alkaline electrolysis (peak load) with government support.
    -   PROD_Alkaline_base_supported: Annual hydrogen production (in Mt) from alkaline electrolysis (base load) with government support.

### Demos & reproducing the results (to be updated)
## Some simulation
## Studying overlapping policies

### Extensions/future developments
- Allow user to study subset of markets, defined based on participating agents in yaml file (e.g. if "empty" power sector?)
- Additionality on monthly basis 
- Integrated selection of representative days?

## License
The software is made available under the MIT license (https://opensource.org/licenses/MIT).
 
## Contributors
K. Bruninx (k.bruninx@tudelft.nl)
J. A. Moncada (jorgeandres.moncadaescudero@kuleuven.be)
A. Hoogsteyn (alexander.hoogsteyn@kuleuven.be)
