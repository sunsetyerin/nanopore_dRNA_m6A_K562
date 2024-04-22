def get_fast5_dir(wildcards):
    return samplesheet.at[wildcards.sample, "fast5_dir"]

def get_fastq_zip (wildcards): # custom-yerin
    return samplesheet.at[wildcards.sample, "fastq_zip"]
