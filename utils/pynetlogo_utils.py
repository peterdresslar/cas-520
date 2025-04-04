import pynetlogo
import os
import subprocess

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


