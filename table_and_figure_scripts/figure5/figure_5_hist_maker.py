import pandas as pd
import seaborn as sns
from functools import partial
import matplotlib.pyplot as plt
import os
from multiprocessing import Pool


def process_file(file, shapefile_name):
    print(f"processing {file}")
    file = os.path.basename(file)
    rng_seed = file.split("_")[0]
    n_sims = file.split("_")[-2]
    df = pd.read_csv(f"{csv_folder}{file}")
    n_districts = max(df["district"])

    probs_df = df["b1_probs"]
    Q1 = probs_df.quantile(0.25)
    Q3 = probs_df.quantile(0.75)
    upper = Q3 + 5 * (Q3 - Q1)

    for i in range(1, n_districts + 1):
        plt.clf()
        sns.histplot(df[df["district"] == i]["b1_probs"], kde=True)
        plt.axvline(
            x=1.0 / int(n_sims),
            color="r",
            zorder=10,
            label="Expected mean for uniform dist",
        )

        # Display the legend
        plt.legend()
        plt.xlim(0, upper)

        plt.tight_layout()

        graph_folder = f"./graphs/{shapefile_name}/{rng_seed}/"
        os.makedirs(graph_folder, exist_ok=True)
        plt.savefig(f"{graph_folder}{file[:-4]}_district_{i}.png")


if __name__ == "__main__":
    state = "nm"
    n_dists = 42

    shapefile_dir = "../../data/shapefiles/"
    shapefile_name = "new_mexico_precincts"
    csv_folder = f"../../data/1000_{state}_{n_dists}_results/"

    files = [f for f in os.listdir(csv_folder) if f.endswith("csv")]
    # Comment out the following line to process all files for the given state
    files = files[:1]

    process_file_with_name = partial(process_file, shapefile_name=shapefile_name)

    with Pool() as pool:
        pool.map(process_file_with_name, files)
