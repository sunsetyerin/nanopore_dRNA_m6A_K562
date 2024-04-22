from os.path import join

# rule basecall:
#     input:
#         fast5_dir=get_fast5_dir,
#     output:
#         summary=(
#             data_dir
#             / f"basecalls/guppy_v{GUPPY_VERSION}/{{sample}}/sequencing_summary.txt"
#         ),
#         save_path=directory(data_dir / f"basecalls/guppy_v{GUPPY_VERSION}/{{sample}}/"),
#     log:
#         logs_dir / "basecall/{sample}.log",
#     threads: 2
#     params:
#         opt=" ".join(
#             [
#                 "-c rna_r9.4.1_70bps_hac.cfg",
#                 "--recursive",
#                 "--disable_pings",
#                 "--calib_detect",
#                 "--num_callers 8",
#                 "--gpu_runners_per_device 1",
#                 "--device cuda:all:100%",
#             ]
#         ),
#     resources:
#         mem_mb=6 * GB,
#         time="12h",
#         partition="gpgpu",
#         slurm="gres=gpu:2 qos=gpgpumdhs",
#     container:
#         containers["guppy"]
#     shell:
#         "guppy_basecaller {params.opt} -i {input.fast5_dir} -s {output.save_path} &> {log}"

rule_name="copy_fastq"
rule copy_fastq:
    input: fastq_zip=get_fastq_zip
    output: fastq_zip=join("results", "basecalls", "merge_fastq", "{{sample}}.fastq.gz")
    log: logs_dir / join("logs","basecalls", "copy_fastq", "{sample}.log")
    threads: 50
    params: opt=""
    resources: mem_mb=1000
    shell: "cp {input.fastq_zip} {output.fastq_zip}"

rule_name="merge_fastq"
rule merge_fastq:
    input: fastq_dir=rules.copy_fastq.output.fastq_zip
    output: fastq=join("results", "basecalls", "merge_fastq", "{{sample}}.fastq")
    log: logs_dir / join("logs","basecalls", "merge_fastq", "{sample}.log")
    threads: 50
    params: opt="--remove_duplicates --min_len 100 --min_qual 7"
    resources: mem_mb=1000
    shell: "gunzip -d {input.fastq_dir}"
    

# rule merge_fastq:
#     input:
#         fastq_dir=rules.basecall.output.save_path,
#     output:
#         fastq=data_dir / f"basecalls/guppy_v{GUPPY_VERSION}/{{sample}}.fq.gz",
#     log:
#         logs_dir / "merge_fastq/{sample}.log",
#     params:
#         opt="--remove_duplicates --min_len 100 --min_qual 7 -v",
#     container:
#         containers["pybiotools"]
#     resources:
#         time="30m",
#     shell:
#         "pyBioTools Fastq Filter {params.opt} -i {input.fastq_dir}/pass -o {output.fastq} &> {log}"
