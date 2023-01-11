# Getting water density

rule get_water_density:
    '''
    Gets water density
    '''
    input:
        tpr = 'runs/{folder}/em.tpr',
        xtc = 'runs/{folder}/combined_wat.xtc',
    output:
        'results/{folder}/water_density/water.dx'
    script:
        '../scripts/mda_water_density.py'


rule plot_water_density:
    '''
    Plots water density in PyMOL
    Important to use complex_ions.pdb here
    - Waters removed, so the only waters are from complex.gro (the
      crystallographic waters)
    - remove complex_ions after aligning, otherwise I have many atoms

    Since there were no crystallographic waters in this model, I need to use a template to get the waters
    - Used t33a_6wat_forMD.pdb as a template, removed 1 water (resi 60) to make consistent with T33B
    - File: t33a_3u5n_5wat.pdb

    Saves a png at sigma level 2.0, xtal waters only
    '''
    input:
        complex = 'runs/{folder}/complex.gro',
        complex_ions = 'runs/{folder}/complex_ions.pdb',
        complex_w_wat = 'config/t33a_3u5n_5wat.pdb',
        water = rules.get_water_density.output,
    output:
        pymol_script = 'results/{folder}/water_density/water.pml',
        pse = 'results/{folder}/water_density/water_density.pse',
        png_20 = 'results/{folder}/water_density/water_xtal_2.0.png',
        png_15 = 'results/{folder}/water_density/water_xtal_1.5.png',
        png_10 = 'results/{folder}/water_density/water_xtal_1.0.png',
    shell:
        '''
        echo -e "load {input.complex} \
                 \nload {input.complex_ions} \
                 \nload {input.complex_w_wat} \
                 \nload {input.water} \
                 \nalign complex, complex_ions \
                 \nalign t33a_3u5n_5wat, complex_ions \
                 \ndelete complex_ions \
                 \nextract bd_wat, t33a_3u5n_5wat and resname HOH \
                 \ndelete t33a_3u5n_5wat \
                 \nhide sticks lines \
                 \nshow lines, resi 18 and not name H* \
                 \nhide everything, bd_wat \
                 \nshow spheres, bd_wat and name OW \
                 \nset sphere_scale, 0.2, bd_wat \
                 \n \
                 \nisomesh mesh_2.0, water, 2.0, bd_wat, carve=2.0 \
                 \nisomesh mesh_1.5, water, 1.5, bd_wat, carve=2.0 \
                 \nisomesh mesh_1.0, water, 1.0, bd_wat, carve=2.0 \
                 \nisomesh mesh_all_2.0, water, 2.0 \
                 \nisomesh mesh_all_1.5, water, 1.5 \
                 \nisomesh mesh_all_1.0, water, 1.0 \
                 \nhide mesh, mesh_all* \
                 \nset mesh_width, 1.5 \
                 \nset mesh_color, gray50 \
                 \nset_view (\\ \
                    \n-0.754295111,    0.347425848,    0.557064712,\\ \
                    \n-0.560487330,   -0.782624364,   -0.270831615, \\ \
                    \n0.341878682,   -0.516520083,    0.785064340, \\ \
                    \n0.001027936,   -0.000312755,  -59.663555145, \\ \
                   \n77.691284180,   54.890041351,   30.358160019, \\ \
                  \n-33851.292968750, 33970.625000000,   20.000000000 ) \
                 \n \
                 \nsel PHD, resi 885-934 \
                 \nsel linker, resi 935-958 \
                 \nsel bromodomain, resi 959-1089 \
                 \nsel peptide, resi 1-21 \
                 \n \
                 \nutil.cba('palegreen', 'PHD') \
                 \nutil.cba('helium', 'linker') \
                 \nutil.cba('lightpink', 'bromodomain') \
                 \nutil.cba('36', 'peptide') \
                 \n \
                 \nsave {output.pse} \
                 \nhide mesh, mesh_1.* \
                 \npng {output.png_20}, ray=1, dpi=600, height=1000, width=1000 \
                 \nshow mesh, mesh_1.5 \
                 \nhide mesh, mesh_2.0 \
                 \npng {output.png_15}, ray=1, dpi=600, height=1000, width=1000 \
                 \nhide mesh, mesh_1.5 \
                 \nshow mesh, mesh_1.0 \
                 \npng {output.png_10}, ray=1, dpi=600, height=1000, width=1000 \
                 \nhide mesh, mesh_1.0 \
                 \nshow mesh, mesh_1.5 \
                 \ndeselect" > {output.pymol_script} 
        pymol -c {output.pymol_script} 
        '''
