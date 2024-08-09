import pandas as pd
import networkx as nx
import matplotlib as mp
import matplotlib.pyplot as plt
from glob import glob
from os.path import basename
from multiprocessing import Pool
from tqdm import tqdm


def add_orig_count(file_name):
    df = pd.read_csv(file_name)

    n_simulations = df["draw"].max()
    n_districts = df["district"].max()

    graph = nx.grid_2d_graph(n_simulations, n_districts)
    graph.remove_edges_from(graph.edges())

    good_node_set = set()

    for node, attrs in graph.nodes(data=True):
        attrs["n_descendents"] = 0

    for i in range(0, 1):
        ancestor_vector = df[df["district"] == n_districts - i]["parent"] - 1
        for old, new in enumerate(ancestor_vector):
            graph.add_edge((old, i), (new, i + 1))
            graph.nodes[(new, i + 1)]["n_descendents"] += 1
            good_node_set.add((new, i + 1))

    for i in range(1, n_districts - 1):
        ancestor_vector = df[df["district"] == n_districts - i]["parent"] - 1
        for old, new in enumerate(ancestor_vector):
            if graph.degree((old, i)) > 0:
                graph.add_edge((old, i), (new, i + 1))
                graph.nodes[(new, i + 1)]["n_descendents"] += graph.nodes[(old, i)][
                    "n_descendents"
                ]
                good_node_set.add((new, i + 1))

    good_node_list = list(good_node_set)

    # So that we start from the top and work our way down
    good_node_list.sort(key=lambda item: (-item[1], item[0]))

    runfile_name = file_name.split("/")[-1].split(".")[0]
    count = 0
    for i in range(n_simulations):
        count += graph.degree((i, n_districts - 1)) > 0

    thresholds = [0.01, 0.1, 0.25, 0.5, 0.75, 1.0]

    thresholds = sorted(thresholds)
    threshold_generations = [-1] * len(thresholds)

    for node in good_node_list:
        generation = n_districts - node[1]
        share = graph.nodes[node]["n_descendents"]

        for i, threshold in enumerate(thresholds):
            if share >= threshold * n_simulations:
                threshold_generations[i] = generation
            else:
                break  # Break loop if a threshold not met since remaining thresholds are larger

    return [basename(file_name), count] + threshold_generations


if __name__ == "__main__":

    state = "ny"
    n_dists = 63

    file_list = glob(f"../../data/1000_{state}_{n_dists}_results/*.csv")

    me_df = pd.DataFrame()
    file_name_list = []
    counts = [-1 for i in range(len(file_list))]

    for file_name in file_list:
        file_name_list.append(file_name.split("/")[-1].split(".")[0])

    me_df["File Name"] = file_name_list
    me_df["Number Original Ancestors"] = counts
    me_df["Mega Parent 0.01"] = counts
    me_df["Mega Parent 0.10"] = counts
    me_df["Mega Parent 0.25"] = counts
    me_df["Mega Parent 0.50"] = counts
    me_df["Mega Parent 0.75"] = counts
    me_df["Mega Parent 1.00"] = counts

    results = []
    with Pool() as pool:
        for res in tqdm(pool.imap(add_orig_count, file_list), total=len(file_list)):
            results.append(res)

    me_df = pd.DataFrame(
        results,
        columns=[
            "File Name",
            "Number Original Ancestors",
            "Mega Parent 0.01",
            "Mega Parent 0.10",
            "Mega Parent 0.25",
            "Mega Parent 0.50",
            "Mega Parent 0.75",
            "Mega Parent 1.00",
        ],
    )

    me_df.to_csv(f"{state}_{n_dists}_mega_parent_info.csv", index=False)
