from __future__ import annotations

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
METRICS = ROOT / "metrics"
FIGURES = ROOT / "figures"


def render_incident_counts() -> None:
    df = pd.read_csv(METRICS / "incident_counts.csv")
    fig, ax = plt.subplots(figsize=(8, 4.8))
    ax.bar(df["metric_name"], df["count"], color=["#1f77b4", "#d62728", "#7f7f7f"])
    ax.set_ylabel("Count")
    ax.set_title("De-identified incident counts from local investigation")
    ax.tick_params(axis="x", rotation=20)
    fig.tight_layout()
    fig.savefig(FIGURES / "incident_counts.png", dpi=220)
    plt.close(fig)


def render_test_outcomes() -> None:
    df = pd.read_csv(METRICS / "test_results.csv")
    counts = df["passed"].map({1: "pass", 0: "fail"}).value_counts().reindex(["pass", "fail"], fill_value=0)
    fig, ax = plt.subplots(figsize=(5.5, 4))
    ax.bar(counts.index, counts.values, color=["#2ca02c", "#d62728"])
    ax.set_ylabel("Count")
    ax.set_title("Repository test outcomes")
    fig.tight_layout()
    fig.savefig(FIGURES / "test_outcomes.png", dpi=220)
    plt.close(fig)


def main() -> None:
    FIGURES.mkdir(parents=True, exist_ok=True)
    render_incident_counts()
    render_test_outcomes()


if __name__ == "__main__":
    main()
