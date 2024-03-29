rule make_protein_rmsd_xvgs:
    """
    Calculating backbone RMSD of protein residues
    Align to em.tpr

    Note that -tu ns makes the last few decimal places for time a bit weird
    But it doesn't affect plotting/analysis

    Put single quotes around the index group so it is read correctly
    """
    input:
        xtc="runs/{folder}/{i}-whole_fit.xtc",
        ndx="runs/{folder}/index.ndx",
    output:
        "results/{folder}/protein/data/{i}-backbone_rmsd.xvg",
    params:
        prefix="runs/{folder}",
        ndx_group="r_3-207_&_Backbone",
    shell:
        """
        echo '{params.ndx_group}' '{params.ndx_group}' |
        gmx rms -f {input.xtc} -s {params.prefix}/{config[em_tpr]} \
                -n {input.ndx} -o {output} -tu ns
        """


def get_rmsd_xvgs(wildcards):
    return [
        os.path.join(
            "results", wildcards.folder, "protein/data", run + "-backbone_rmsd.xvg"
        )
        for run in IDS
    ]


rule plot_protein_rmsd_all:
    """
    Specify time units (usually ns)
    """
    input:
        get_rmsd_xvgs,
    output:
        "results/{folder}/protein/t33a_backbone_rmsd.png",
    params:
        ylabel="RMSD (Å)",
        time_unit="ns",
        ymax=5,
    script:
        "../scripts/plot_time_series_multi.py"


rule make_protein_rmsf_xvgs:
    """
    Calculating backbone RMSF of protein residues
    Alignment to em.tpr not needed here since it's a fluctuation
    """
    input:
        xtc="runs/{folder}/{i}-whole_fit.xtc",
        ndx="runs/{folder}/index.ndx",
    output:
        "results/{folder}/protein/data/{i}-backbone_rmsf.xvg",
    params:
        prefix="runs/{folder}",
    shell:
        """
        echo 'r_3-207_&_Backbone' |
        gmx rmsf -f {input.xtc} -s {params.prefix}/{config[md_tpr]} \
                 -n {input.ndx} -o {output} -res
        """


def get_rmsf_xvgs(wildcards):
    return [
        os.path.join(
            "results", wildcards.folder, "protein/data", run + "-backbone_rmsf.xvg"
        )
        for run in IDS
    ]


rule plot_t33a_rmsf:
    input:
        get_rmsf_xvgs,
    output:
        "results/{folder}/protein/t33a_rmsf.png",
    script:
        "../scripts/plot_protein_rmsf.py"


rule plot_t33a_rmsf_indiv_resi:
    '''
    For zooming in on specific protein residues (backbone RMSF here)
    '''
    input:
        get_rmsf_xvgs,
    output:
        "results/{folder}/protein/t33a_rmsf_specific_resi.png",
    params:
        resi_of_interest = [981, 990, 993, 1038, 1039, 1061, 1062],
        ymax = 3,
    script:
        "../scripts/plot_rmsf_specific_resi.py"
