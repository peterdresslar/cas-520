import pandas as pd
import matplotlib.pyplot as plt
import re # Need to import re


# New function for plotting evolution
def clean_col_name(col):
    """Cleans column names from NetLogo BehaviorSpace output."""
    col = col.strip()
    # Handle simple count like 'count households'
    if col.startswith('count '):
        # Assumes simple name like 'count households'
        parts = col.split(' ')
        if len(parts) == 2:
             return 'count_' + parts[1]
        else: # Fallback for more complex count names if needed
             return '_'.join(parts)

    # Use regex to capture variable inside brackets and handle optional 'of households/patches'
    match = re.match(r'mean \[(.*?)\](?: of (?:households|patches))?', col)
    if match:
        # Extract variable name, replace hyphen with underscore
        var_name = match.group(1).replace('-', '_')
        return 'mean_' + var_name

    # Handle simple columns like '[run number]', 'farm_cost', 'step' etc.
    # Remove brackets, replace space/hyphen with underscore
    col = col.replace('[', '').replace(']', '').replace(' ', '_').replace('-', '_')
    return col

def plot_randos_exp(csv_path: str, farm_cost_to_plot: float):
    """
    Loads data from a NetLogo BehaviorSpace CSV and plots the mean evolution
    of key variables over time for a specific farm_cost.

    Args:
        csv_path: Path to the BehaviorSpace CSV file.
        farm_cost_to_plot: The specific farm_cost value to plot.
    """
    try:
        # Load the full time-series data, skipping header rows
        df_full = pd.read_csv(csv_path, skiprows=6)
    except FileNotFoundError:
        print(f"Error: CSV file not found at {csv_path}")
        return
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        return

    # Clean column names using the refined function
    original_columns = df_full.columns.tolist()
    df_full.columns = [clean_col_name(col) for col in original_columns]

    # Define the variables we want to plot based on expected cleaned names
    # These should now reliably match the output of clean_col_name
    plot_vars = ['count_households', 'mean_fission_rate', 'mean_farm_dist', 'mean_min_fertility', 'mean_move_threshold', 'mean_vegetation']
    required_cols = ['farm_cost', 'step'] + plot_vars

    # Check if all required columns exist after cleaning
    missing_cols = [col for col in required_cols if col not in df_full.columns]
    if missing_cols:
        print(f"Error: Missing expected columns after cleaning: {missing_cols}")
        # print(f"Original columns: {original_columns}") # Uncomment for debugging
        # print(f"Cleaned columns: {df_full.columns.tolist()}") # Uncomment for debugging
        return

    # Filter for the specific farm_cost
    # Use pd.to_numeric to handle potential type mismatches if farm_cost is read as object
    df_full['farm_cost'] = pd.to_numeric(df_full['farm_cost'], errors='coerce')
    df_filtered = df_full[df_full['farm_cost'] == farm_cost_to_plot]

    if df_filtered.empty:
        print(f"Error: No data found for farm_cost = {farm_cost_to_plot}")
        print(f"Available farm_cost values: {df_full['farm_cost'].unique()}")
        return

    # Calculate mean trajectories
    try:
        # Group by step and calculate mean for plot variables
        grouped_means = df_filtered.groupby(['step'])[plot_vars].mean().reset_index()
    except KeyError as e:
         print(f"Error during grouping/mean calculation. Missing column: {e}")
         print(f"Available columns in filtered data: {df_filtered.columns.tolist()}")
         return
    except Exception as e:
         print(f"An unexpected error occurred during grouping/mean: {e}")
         return


    # Create plots
    fig, axes = plt.subplots(2, 3, figsize=(15, 8), sharex=True)
    fig.suptitle(f'Evolution of Mean Variables over Time (farm_cost = {farm_cost_to_plot})', fontsize=16)
    axes = axes.flatten() # Flatten the 2x3 grid for easy iteration

    for i, var in enumerate(plot_vars):
        if var not in grouped_means.columns:
             print(f"Warning: Column '{var}' not found in grouped data. Skipping plot.")
             continue
        # Check if data exists for the variable before plotting
        if not grouped_means[var].isnull().all():
             axes[i].plot(grouped_means['step'], grouped_means[var], label=f'Mean {var}')
        else:
             print(f"Warning: No valid data to plot for '{var}'.")
        axes[i].set_title(var)
        axes[i].set_ylabel('Mean Value')
        axes[i].grid(True)
        if i >= 3: # Add x-label only to bottom row
             axes[i].set_xlabel('Step')

    # Adjust layout and display
    plt.tight_layout(rect=[0, 0.03, 1, 0.95]) # Adjust layout to prevent title overlap
    plt.show()