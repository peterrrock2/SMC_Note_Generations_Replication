import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt
import os
from multiprocessing import Pool

shapefile_name = "50x50_grid"
dists = "" 
folder = f"{shapefile_name}/{dists}"
csv_folder = f"../examples/outputs/{folder}"
    

def process_file(file):
    print(f"processing {file}")
    rng_seed = file.split("_")[0]
    # n_sims = file.split("_")[-2]
    n_sims = file.split("_")[-2]
    print(n_sims)
    df = pd.read_csv(f"{csv_folder}{file}")
    n_districts = max(df["district"])
    
    probs_df = df["b1_probs"]
    Q1 = probs_df.quantile(0.25)
    Q3 = probs_df.quantile(0.75)
    upper = Q3 + 5 * (Q3 - Q1)
    
    for i in range(1, n_districts + 1):
        plt.clf()
        sns.histplot(df[df["district"] == i]["b1_probs"], kde=True)
        
        plt.axvline(x=1.0/int(n_sims), color='r', zorder=10, label='Expected mean for uniform dist')

        # Display the legend
        plt.legend()
        plt.xlim(0, upper)
        
        graph_folder = f"../examples/graphs/{folder}{rng_seed}/"
        os.makedirs(graph_folder, exist_ok=True)
        plt.savefig(f"{graph_folder}{file[:-4]}_district_{i}.png")

if __name__ == "__main__":
    files = [f for f in os.listdir(csv_folder) if f.endswith('csv')]

    with Pool() as pool:
        pool.map(process_file, files)
