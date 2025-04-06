import pynetlogo
import os
import json
import csv
import itertools
import pandas as pd
import numpy as np

base_altruism_model = (
    "../M4/M4Model_Dresslar_base.nlogo"  # (copied into this directory!)
)
modified_altruism_model = "../M4/M4Model_Dresslar_modified.nlogo"


def initialize_netlogo(model_path: str):

    ### Some unplesantness for pynetlogo setup:
    # Get Java home (should return ARM Java if that's what's installed)
    # java_home = subprocess.check_output(["/usr/libexec/java_home"]).decode().strip()
    # jvm_path = os.path.join(java_home, "lib", "server", "libjvm.dylib")
    netlogo_path = "/Users/peterdresslar/Workspace/NetLogo-6.3.0/app"

    # Print for verification
    # print(f"Python architecture: {platform.machine()}")
    # print(f"Using JVM at: {jvm_path}")
    # print(f"Using NetLogo at: {netlogo_path}")

    # Get a netlogo instance
    netlogo = pynetlogo.NetLogoLink(
        gui=False,  # cannot set to true for macs
        netlogo_home=netlogo_path,
        # jvm_path=jvm_path
    )

    # Load the model
    netlogo.load_model(model_path)

    # return the loaded netlogo instance
    return netlogo


def do_one_altruism_run(
    model: str,
    max_ticks: int,
    altruistic_probability: float,
    selfish_probability: float,
    cost_of_altruism: float,
    benefit_from_altruism: float,
    disease: float,
    harshness: float,
):
    """
    Run one of the versions of the altruism model (base or modified) with params.

    args:
        model: str - the model to run (base or modified)
        max_ticks: int - the maximum number of ticks to run
        altruistic_probability: float - the probability of altruism
        selfish_probability: float - the probability of selfishness
        cost_of_altruism: float - the cost of altruism
        benefit_from_altruism: float - the benefit from altruism

    returns:
        results: dict - a dictionary containing the results of the run
        results["ticks_to_stop"] = base_model_ticks_to_stop
        results["pinks_count"] = base_model_pinks_count
        results["greens_count"] = base_model_greens_count
        results["voids_count"] = base_model_voids_count
        results["max_pink"] = base_model_max_pink
        results["max_green"] = base_model_max_green
        results["max_black"] = base_model_max_black
    """

    base_model_ticks_to_stop = []
    base_model_pinks_count = []
    base_model_greens_count = []
    base_model_voids_count = []
    base_model_max_pink = []
    base_model_max_green = []
    base_model_max_black = []
    base_model_min_pink = []
    base_model_min_green = []
    base_model_min_black = []

    results = {}

    netlogo = initialize_netlogo(model)
    netlogo.command(f"set altruistic-probability {altruistic_probability}")
    netlogo.command(f"set selfish-probability {selfish_probability}")
    netlogo.command(f"set cost-of-altruism {cost_of_altruism}")
    netlogo.command(f"set benefit-from-altruism {benefit_from_altruism}")
    netlogo.command(f"set disease {disease}")
    netlogo.command(f"set harshness {harshness}")
    netlogo.command("setup")
    netlogo.command(f"repeat {max_ticks} [go]")
    this_ticks = netlogo.report("ticks") if netlogo.report("ticks") > 0 else max_ticks
    base_model_ticks_to_stop.append(this_ticks)
    base_model_pinks_count.append(netlogo.report("count patches with [pcolor = pink]"))
    base_model_greens_count.append(
        netlogo.report("count patches with [pcolor = green]")
    )
    base_model_voids_count.append(netlogo.report("count patches with [pcolor = black]"))
    base_model_max_pink.append(netlogo.report("max-pink"))
    base_model_max_green.append(netlogo.report("max-green"))
    base_model_max_black.append(netlogo.report("max-black"))
    base_model_min_pink.append(netlogo.report("min-pink"))
    base_model_min_green.append(netlogo.report("min-green"))
    base_model_min_black.append(netlogo.report("min-black"))
    netlogo.kill_workspace()

    results["ticks_to_stop"] = base_model_ticks_to_stop
    results["pinks_count"] = base_model_pinks_count
    results["greens_count"] = base_model_greens_count
    results["voids_count"] = base_model_voids_count
    results["max_pink"] = base_model_max_pink
    results["max_green"] = base_model_max_green
    results["max_black"] = base_model_max_black
    results["min_pink"] = base_model_min_pink
    results["min_green"] = base_model_min_green
    results["min_black"] = base_model_min_black

    print(
        f"Ran for ticks: {this_ticks} with {altruistic_probability} {selfish_probability} {cost_of_altruism} {benefit_from_altruism} {disease} {harshness}"
    )
    print(
        f" Pops: {results['pinks_count']} {results['greens_count']} {results['voids_count']}"
    )

    return results


# Save checkpoint of which combinations we've completed
def save_experiment_checkpoint(completed_params):
    with open("experiment_checkpoint.json", "w") as f:
        json.dump(completed_params, f)


def process_results(results_filename: str, runs_per_node: int, max_ticks: int):
    """
    We want to do at least three things:

    - Process means and stds for all nodes (each has runs_per_node runs)
    - Identify *interesting* results where for a single node, the runs broke down to alternate states (all pink, all green, all black, etc.)
    - Correlate each parameter with all mean statistics.

    The output of this will be a new means file, and interesting results file, and a stats summary file.
    """

    results = {}

    # Process results into a df
    df = pd.read_csv(results_filename)

    # Identify *interesting* results where for a single node, the runs broke down to alternate states (all pink, all green, all black, etc.)
    # we'll just do something custom for this. run through each row of the df, and if the run_number is 0, loop through the next runs_per_node rows,
    # and check if they are all the same. if they are, add them to the very_interesting_results list.

    row_count = len(df)
    node_count = row_count // runs_per_node

    for node in range(node_count):
        # a node is one set of params
        very_interesting_results = []
        interesting_results = []

        node_rows = [df.iloc[node * runs_per_node + r] for r in range(runs_per_node)]  # grab the rows for this "node"

        # "name" our row
        params = node_rows[0][
            [
                "altruistic_probability",
                "selfish_probability",
                "cost_of_altruism",
                "benefit_from_altruism",
                "disease",
                "harshness",
            ]
        ]

        ticks_outcomes = 0  # the run made it to the max ticks
        altruists_died_outcomes = 0  # the run ended with all pinks dead
        selfish_died_outcomes = 0  # the run ended with all greens dead
        voids_died_outcomes = (
            0  # the run ended with all voids dead ... not so sure this can happen
        )

        # now we just check our runs
        for row in node_rows:
            print(f"Processing node {node}, run {row['run_number']} with params {params} and ticks {row['ticks']}x")

            print(f" altruists: {row['altruists']}, selfish: {row['selfish']}, voids: {row['void']}")
            int_ticks = int(row["ticks"])
            if int_ticks == max_ticks:
                ticks_outcomes += 1
            if row["altruists"] == 0.0:
                print(f" altruists died")
                altruists_died_outcomes += 1
            if row["selfish"] == 0.0:
                print(f" selfish died")
                selfish_died_outcomes += 1
            if row["void"] == 0.0:
                print(f" voids died")
                voids_died_outcomes += 1

            # okay, this is fun, now we get to say what is interesting.
            # and what is very interesting

            # very interesting: variable ticks_outcomes (i guess between 2 and runs_per_node -2)
            # 3 < altruists_died_outcomes < runs_per_node - 3
            # 3 < selfish_died_outcomes < runs_per_node - 3
            # 3 < voids_died_outcomes < runs_per_node - 3

        very_interesting_reasons = []
        if 3 < ticks_outcomes < runs_per_node - 3:
            very_interesting_reasons.append("high variability in ticks_outcomes")
        if 3 < altruists_died_outcomes < runs_per_node - 3:
            very_interesting_reasons.append("high variability in altruists_died_outcomes")
        if 3 < selfish_died_outcomes < runs_per_node - 3:
            very_interesting_reasons.append("high variability in selfish_died_outcomes")
        if 3 < voids_died_outcomes < runs_per_node - 3:
            very_interesting_reasons.append("high variability in voids_died_outcomes")

        if len(very_interesting_reasons) > 0:
            print(f"Very interesting results for node {node}: {very_interesting_reasons}")
            very_interesting_results.append(
                {
                    "params": params,
                    "very_interesting_reasons": very_interesting_reasons,
                }
            )

        # interesting:
        # ticks_outcomes > 0
        # 0 < altruists_died_outcomes < runs_per_node
        # 0 < selfish_died_outcomes < runs_per_node
        # 0 < voids_died_outcomes < runs_per_node

        interesting_reasons = []
        if ticks_outcomes > 0:
            interesting_reasons.append("variable ticks_outcomes")
        if 0 < altruists_died_outcomes < runs_per_node:
            interesting_reasons.append("variable altruists_died_outcomes")
        if 0 < selfish_died_outcomes < runs_per_node:
            interesting_reasons.append("variable selfish_died_outcomes")
        if 0 < voids_died_outcomes < runs_per_node:
            interesting_reasons.append("variable voids_died_outcomes")

        if len(interesting_reasons) > 0:
            print(f"Interesting results for node {node}: {interesting_reasons}")
            interesting_results.append(
                {"params": params, "interesting_reasons": interesting_reasons}
            )

    # write all interesting results to one file. can just be text-y
    with open("interesting_results.txt", "w") as f:
        f.write("Very interesting results:\n")
        for result in very_interesting_results:
            # Convert Series to string representation
            param_series = result['params']
            param_str = ", ".join([f"{k}={param_series[k]}" for k in param_series.index])
            f.write(f"{param_str}: {result['very_interesting_reasons']}\n")
        f.write("\nInteresting results:\n")
        for result in interesting_results:
            # Convert Series to string representation
            param_series = result['params']
            param_str = ", ".join([f"{k}={param_series[k]}" for k in param_series.index])
            f.write(f"{param_str}: {result['interesting_reasons']}\n")

    #############
    # Get means and stds for all nodes (each has runs_per_node runs)
    # Group by parameter combinations
    param_columns = [
        "altruistic_probability",
        "selfish_probability",
        "cost_of_altruism", 
        "benefit_from_altruism",
        "disease",
        "harshness"
    ]
    
    # Columns for which we want means and standard deviations
    stat_columns = ["ticks", "altruists", "selfish", "void", "max_pink", "max_green", "max_black"]
    
    # Group by parameter combinations and calculate statistics
    grouped = df.groupby(param_columns)
    
    # Create a list to hold our data rows
    data_rows = []
    
    # For each parameter combination
    for params, group in grouped:
        # Start with the parameters
        row_data = {}
        for i, param in enumerate(param_columns):
            row_data[param] = params[i]
        
        # Add means and standard deviations for each statistic
        for stat in stat_columns:
            row_data[f"{stat}_mean"] = round(group[stat].mean(), 1)
            row_data[f"{stat}_std"] = round(group[stat].std(), 1)
        
        data_rows.append(row_data)
    
    # Create new DataFrame from the collected data
    new_df = pd.DataFrame(data_rows)
    
    # Save means and standard deviations to a file
    new_df.to_csv(f"{results_filename.replace('.csv', '')}_statistics.csv", index=False)
    
    # For correlation analysis later
    means_df = new_df.copy()
    stds_df = new_df.copy()
    

    # For correlation analysis
    corr_matrix = means_df.corr()
    corr_matrix.to_csv(f"{results_filename.replace('.csv', '')}_correlations.csv")

    std_corr_matrix = stds_df.corr()
    std_corr_matrix.to_csv(f"{results_filename.replace('.csv', '')}_std_correlations.csv")


    return


def run_altruism_experiment(
    model: str,
    experiment_name: str,
    max_ticks: int,
    runs_per_node: int,
    altruistic_probability_range: list[float],
    selfish_probability_range: list[float],
    cost_of_altruism_range: list[float],
    benefit_from_altruism_range: list[float],
    disease_range: list[float],
    harshness_range: list[float],
):

    checkpoint_file = f"{experiment_name}_checkpoint.json"
    results_file = f"{experiment_name}_results.csv"

    # Create results file with headers if it doesn't exist
    if not os.path.exists(results_file):
        with open(results_file, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(
                [
                    "altruistic_probability",
                    "selfish_probability",
                    "cost_of_altruism",
                    "benefit_from_altruism",
                    "disease",
                    "harshness",
                    "run_number",
                    "ticks",
                    "altruists",
                    "selfish",
                    "void",
                    "max_pink",
                    "max_green",
                    "max_black",
                ]
            )

    # Load checkpoint if exists
    completed_runs = []
    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, "r") as f:
            completed_runs = json.load(f)

    # Generate parameter combinations
    parameter_combinations = list(
        itertools.product(
            altruistic_probability_range,
            selfish_probability_range,
            cost_of_altruism_range,
            benefit_from_altruism_range,
            disease_range,
            harshness_range,
        )
    )

    # Track progress
    total_combinations = len(parameter_combinations) * runs_per_node
    runs_completed = len(completed_runs)
    print(f"Starting experiment with {total_combinations} total runs.")
    print(f"completed: {runs_completed} runs")

    # Run simulations
    for params in parameter_combinations:
        # Unpack parameters
        ap, sp, ca, ba, d, h = params

        # Run multiple times per parameter set
        for run_num in range(runs_per_node):
            # Create a unique run identifier
            run_id = (*params, run_num)

            # Skip if already completed
            if run_id in completed_runs:
                continue

            print(
                f"params: ap={ap}, sp={sp}, ca={ca}, ba={ba}, d={d}, h={h}, run_num={run_num+1}"
            )

            # Run simulation
            result = do_one_altruism_run(model, max_ticks, ap, sp, ca, ba, d, h)

            # Append to results file
            with open(results_file, "a", newline="") as f:
                writer = csv.writer(f)
                writer.writerow(
                    [
                        ap,
                        sp,
                        ca,
                        ba,
                        d,
                        h,
                        run_num,
                        result["ticks_to_stop"][0],
                        result["pinks_count"][0],
                        result["greens_count"][0],
                        result["voids_count"][0],
                        result.get("max_pink", [0])[0],
                        result.get("max_green", [0])[0],
                        result.get("max_black", [0])[0],
                    ]
                )

            # Mark as complete
            completed_runs.append(run_id)
            runs_completed += 1

            # Update checkpoint periodically
            if runs_completed % 10 == 0:
                with open(checkpoint_file, "w") as f:
                    json.dump(completed_runs, f)
                print(
                    f"{runs_completed}/{total_combinations} runs completed ({runs_completed/total_combinations*100:.1f}%)"
                )

    # Final checkpoint
    with open(checkpoint_file, "w") as f:
        json.dump(completed_runs, f)

    print(f"{runs_completed} total runs")


def convert_netlogo_question_param(param: str):
    """
    Convert a NetLogo question parameter to a Python variable name.
    """
    return param.replace("?", "_q").replace("-", "_")


def get_sorted_turtle_data(netlogo: pynetlogo.NetLogoLink, *params: str):
    """
    Get sorted turtles from NetLogo.
    """
    # Get data

    turtle_data_lists = {}

    x = netlogo.report("map [t -> [xcor] of t] sort turtles")
    turtle_data_lists["x"] = x
    y = netlogo.report("map [t -> [ycor] of t] sort turtles")
    turtle_data_lists["y"] = y
    color = netlogo.report("map [t -> [color] of t] sort turtles")
    turtle_data_lists["color"] = color

    # Get data for each parameter

    for param in params:
        var_name = convert_netlogo_question_param(param)
        values = netlogo.report(f"map [t -> [t.{param}] of t] sort turtles")
        turtle_data_lists[var_name] = values

    return turtle_data_lists


def get_sorted_patch_data(netlogo: pynetlogo.NetLogoLink, *params: str):
    """
    Get sorted patches from NetLogo.
    """
    # Get data
    patch_data_lists = {}

    # note that we need to do pxcor not xcor and pycor not ycor

    x = netlogo.report("map [p -> [pxcor] of p] sort patches")
    patch_data_lists["x"] = x
    y = netlogo.report("map [p -> [pycor] of p] sort patches")
    patch_data_lists["y"] = y
    color = netlogo.report("map [p -> [pcolor] of p] sort patches")
    patch_data_lists["color"] = color

    # Get data for each parameter

    for param in params:
        var_name = convert_netlogo_question_param(param)
        values = netlogo.report(f"map [p -> [p.{param}] of p] sort patches")
        patch_data_lists[var_name] = values

    return patch_data_lists


# end # hah
