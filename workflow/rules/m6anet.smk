from pathlib import Path

m6anet_dir = results / "m6anet"


dataprep_dir = m6anet_dir / "dataprep"

rule m6anet_dataprep:
    input:
        eventalign=rules.xpore_eventalign.output.tsv,
    output:
        data=multiext(
            str(dataprep_dir / "{sample}/data"),
            ".json",
            ".info",
            ".log",
        ),
        idx=dataprep_dir / "{sample}/eventalign.index",
    log:
        logs_dir / "m6anet_dataprep/{sample}.log",
    threads: 100
    params:
        opt="--readcount_max 1000000",
        outdir=lambda wildcards, output: Path(output.idx).parent,
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 8 * GB,
        time="1d",
    conda:
        "m6anet"
    shell:
        """
        m6anet dataprep {params.opt} --eventalign {input.eventalign} \
            --n_processes {threads} --out_dir {params.outdir} 2> {log}
        """

inference_dir = m6anet_dir / "inference"

rule m6anet_inference_indiv:
    input:
        json=dataprep_dir / "{sample}/data.json",
    output:
        site_prob=inference_dir / "{sample}/data.site_proba.csv",
        indiv_prob=inference_dir / "{sample}/data.indiv_proba.csv",
    log:
        logs_dir / "m6anet_inference_indiv/{sample}.log",
    threads: 
        100
    params:
        readcount_min=15,
        readcount_max=1_000,
        indir=lambda wildcards, input: Path(input.json).parent,
        outdir=lambda wildcards, output: Path(output.site_prob).parent,
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 8000,
        time="1h",
    conda:
        "m6anet"
    script: 
        "m6anet inference --input_dir {params.indir} --out_dir {params.outdir} --batch_size 512 --n_processes 100 --num_iterations 5 --device cpu"
        # "m6anet inference --input_dir {params.indir} --out_dir {params.outdir} --batch_size 512 --n_processes {threads} --num_iterations 5 --device cpu 2> {log}"
        