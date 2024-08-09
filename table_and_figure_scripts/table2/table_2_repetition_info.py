import pandas as pd
import networkx as nx
from glob import glob
import os
from joblib import Parallel, delayed
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import numpy as np


def get_descendents_progenitor(file_name):
    df = pd.read_csv(file_name)

    n_simulations = df["draw"].max()
    n_districts = df["district"].max()

    graph = nx.grid_2d_graph(n_simulations, n_districts)
    graph.remove_edges_from(graph.edges())

    good_node_set = set()

    for node, attrs in graph.nodes(data=True):
        attrs["n_descendents"] = 0
        attrs["generation"] = 0

    for i in range(0, 1):
        ancestor_vector = df[df["district"] == n_districts - i]["parent"] - 1
        for old, new in enumerate(ancestor_vector):
            graph.add_edge((old, i), (new, i + 1))
            graph.nodes[(new, i + 1)]["n_descendents"] += 1
            graph.nodes[(new, i + 1)]["generation"] = n_districts - i - 1
            good_node_set.add((new, int(i + 1)))

    for i in range(1, n_districts - 1):
        ancestor_vector = df[df["district"] == n_districts - i]["parent"] - 1
        for old, new in enumerate(ancestor_vector):
            if graph.degree((old, i)) > 0:
                graph.add_edge((old, i), (new, i + 1))
                graph.nodes[(new, i + 1)]["n_descendents"] += graph.nodes[(old, i)][
                    "n_descendents"
                ]
                graph.nodes[(new, i + 1)]["generation"] = n_districts - i - 1
                good_node_set.add((new, int(i + 1)))

    progenitor_descendents_list = []
    for node in good_node_set:
        if graph.nodes[node]["generation"] == 1:
            progenitor_descendents_list.append(graph.nodes[node]["n_descendents"])

    return (
        os.path.basename(file_name),
        tuple(progenitor_descendents_list),
        np.mean(progenitor_descendents_list).astype(float),
        max(progenitor_descendents_list),
    )


if __name__ == "__main__":
    state = "ny"
    n_dists = 63

    all_files = glob(f"../../data/1000_{state}_{n_dists}_results/*.csv")

    results = Parallel(n_jobs=-1)(
        delayed(get_descendents_progenitor)(file)
        for file in tqdm(all_files, desc="Processing files")
    )

    column_names = [
        "filename",
        "progenitor_descendents_count",
        "mean_descendents",
        "max_descendents",
    ]
    final_df = pd.DataFrame(results, columns=column_names)

    final_df.to_csv(
        f"./repetition_info_csvs/descendents_by_generation_{state}_5000_sims_{n_dists}_dists_1000_trials.csv",
        index=False,
    )
