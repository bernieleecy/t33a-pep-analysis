rule make_pep_rmsd_xvgs:
    """
    Calculating backbone RMSD of peptide residues
    Align to protein backbone to em.tpr

    Note that -tu ns makes the last few decimal places for time a bit weird
    But it doesn't affect plotting/analysis

    Put single quotes around the index group so it is read correctly
    """
    input:
        xtc="runs/{folder}/{i}-whole_fit.xtc",
        ndx="runs/{folder}/index.ndx",
    output:
        "results/{folder}/peptide/data/{i}-pep_backbone_rmsd.xvg",
    params:
        prefix="runs/{folder}",
        ndx_group="r_208-228_&_Backbone",
    shell:
        """
        echo '{params.ndx_group}' '{params.ndx_group}' |
        gmx rms -f {input.xtc} -s {params.prefix}/{config[em_tpr]} \
                -n {input.ndx} -o {output} -tu ns
        """


def get_pep_rmsd_xvgs(wildcards):
    return [
        os.path.join(
            "results", wildcards.folder, "peptide/data", run + "-pep_backbone_rmsd.xvg"
        )
        for run in IDS
    ]


rule plot_pep_rmsd_all:
    """
    Specify time units (usually ns)
    """
    input:
        get_pep_rmsd_xvgs,
    output:
        "results/{folder}/peptide/t33a_pep_backbone_rmsd.png",
    params:
        ylabel="RMSD (Å)",
        time_unit="ns",
        ymax=5,
    script:
        "../scripts/plot_time_series_multi.py"


rule make_pep_rmsf_xvgs:
    """
    Calculating backbone RMSF of peptide residues
    Alignment to em.tpr not needed here since it's a fluctuation
    """
    input:
        xtc="runs/{folder}/{i}-whole_fit.xtc",
        ndx="runs/{folder}/index.ndx",
    output:
        "results/{folder}/peptide/data/{i}-pep_backbone_rmsf.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        echo 'r_208-228_&_Backbone' |
        gmx rmsf -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                 -n {input.ndx} -o {output} -res
        """


def get_pep_rmsf_xvgs(wildcards):
    return [
        os.path.join(
            "results", wildcards.folder, "peptide/data", run + "-pep_backbone_rmsf.xvg"
        )
        for run in IDS
    ]


rule plot_pep_rmsf:
    input:
        get_pep_rmsf_xvgs,
    output:
        "results/{folder}/peptide/t33a_pep_backbone_rmsf.png",
    script:
        "../scripts/plot_pep_rmsf.py"
