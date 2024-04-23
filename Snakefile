from pathlib import Path
import pandas as pd
from typing import Dict, Set


# =====================================
# Workflow config items
configfile: "config/config.yaml"


samplesheet = pd.read_csv(config["samplesheet"], index_col="name")
GB = 1_024
CTRL = samplesheet.query("condition=='control'").index[0]
TESTS = list(samplesheet.query("condition=='test'").index)
containers: Dict[str, str] = config["containers"]
GUPPY_VERSION = containers["guppy"].split(":")[-1]
workflow_dir = Path("workflow").resolve()
scripts_dir = workflow_dir / "scripts"
rules_dir = workflow_dir / "rules"
envs_dir = workflow_dir / "envs"
logs_dir = Path("logs/rules").resolve()
data_dir = Path("data").resolve()
results = Path("results").resolve()
fast5_dir = Path(config["fast5_dir"]).resolve()
transcriptome_url = config["transcriptome_url"]
# =====================================
targets: Set[Path] = set()

for sample in TESTS:
    targets.add(results / f"xpore/diffmod2/{sample}/diffmod.table")
    # targets.add(results / f"nanocompore/{sample}/nanocompore_results_GMM_context_0.tsv")
    targets.add(results / f"m6anet/inference/{sample}/data.site_proba.csv")
    targets.add(results / f"m6anet/inference/{sample}/data.indiv_proba.csv")

# for sample in TESTS:
#     targets.add(results / f"xpore/eventalign2/{sample}_data.tsv"),
#     targets.add(results / f"xpore/eventalign2/{sample}_summary.tsv") 

targets.add(results / f"m6anet/inference/SRSF2-WT_IDH2-WT/data.site_proba.csv")
targets.add(results / f"m6anet/inference/SRSF2-WT_IDH2-WT/data.indiv_proba.csv")

rule all:
    input:
        targets,

include: str(rules_dir / "common.smk")
# include: str(rules_dir / "reference.smk")
include: str(rules_dir / "basecalling.smk")
include: str(rules_dir / "alignment.smk")
include: str(rules_dir / "resquiggle.smk")
include: str(rules_dir / "xpore.smk")
# include: str(rules_dir / "nanocompore.smk")
include: str(rules_dir / "m6anet.smk")
