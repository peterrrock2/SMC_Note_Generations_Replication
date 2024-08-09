from glob import glob
from os.path import basename
import pandas as pd

if __name__ == "__main__":
    csv_files = glob("./repetition_info_csvs/*.csv")

    results = []
    for file in csv_files:
        file_name_list = basename(file).split("_")
        state = file_name_list[3]
        n_dists = file_name_list[6]

        state_df = pd.read_csv(file)
        results.append(
            [
                state,
                n_dists,
                state_df["mean_descendents"].mean(),
                state_df["max_descendents"].mean(),
                state_df["max_descendents"].max(),
            ]
        )

    df = pd.DataFrame(
        results,
        columns=[
            "state",
            "n_dists",
            "mean_mean_repetition",
            "mean_max_repetition",
            "max_max_repetition",
        ],
    )
    print(df.to_string(index=False))
    df.to_csv("./table_2_aggregated_data.csv", index=False)
