import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

import warnings

warnings.filterwarnings("ignore")


def plt_hist(data, title, color="#d81b60"):
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    sns.histplot(data=data, binwidth=50, color=color, ax=ax)

    ax.set_ylabel("")

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    ax.grid(False)  # Turn off the grid

    ax.set_xlim([0, 5000])
    ax.tick_params(labelsize=14)

    ax.set_xticklabels(ax.get_xticks(), fontweight="bold")
    ax.set_yticklabels(ax.get_yticks(), fontweight="bold")
    plt.tight_layout()
    plt.savefig(title)
    plt.clf()


if __name__ == "__main__":
    colors = {
        "nm": "#d81b60",
        "ny": "#009688",
    }

    state = "ny"
    n_dists = 63

    level_df = pd.read_csv(
        f"./number_of_decendents_by_generation_{state}_5000_sims_1000_trials.csv"
    )

    for i in range(1, n_dists):
        data = np.array(level_df[f"gen_{i}"])
        title = f"./{state}_{n_dists}_hists/{state.upper()}_{n_dists}_G(D,{i})_5000_sims_1000_trials.png"
        plt_hist(data, title, color=colors[state])
