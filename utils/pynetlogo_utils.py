import pynetlogo
import os
import subprocess

base_altruism_model = "../M4/M4Model_Dresslar_base.nlogo"  # (copied into this directory!)
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

def do_one_altruism_run(model: str, max_ticks: int, altruistic_probability: float, selfish_probability: float, cost_of_altruism: float, benefit_from_altruism: float, disease: float, harshness: float):
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

    runs_each = 100

    for i in range(runs_each):
        print(f"Running base model {i+1} of {runs_each}")
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
        base_model_greens_count.append(netlogo.report("count patches with [pcolor = green]"))
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

    print(f"Ran for ticks: {this_ticks} with {altruistic_probability} {selfish_probability} {cost_of_altruism} {benefit_from_altruism} {disease} {harshness}")
    print(f" Pops: {results['pinks_count']} {results['greens_count']} {results['voids_count']}")

    return results
    







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

#end # hah


