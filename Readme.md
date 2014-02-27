Simple ideogram plotting and annotation in R.

Basic usage:

Rscript Ideoplot.R --heatmap hm.bed --annotate annotations.bed --out ideogram.pdf
-or-
Rscript Ideoplot.R --annotate annotations.bed 

To swap to a different reference version, use the --ideobed option to
specifiy an alternative ideogram bed file. 

The ideogram bed file and coordinates are obtaned from ucsc:
http://genome.ucsc.edu/cgi-bin/hgTables?hgsid=364576305&clade=mammal&org=Human&db=hg19&hgta_group=map&hgta_track=cytoBandIdeo&hgta_table=0&hgta_regionType=genome&position=chrX%3A146991161-146996160&hgta_outputType=selectedFields

The layout geometry is organized in terms of stripes for each
chromosome.  The current layout is fixed to (5,5,15,10), where there
are two stripes of width 5, one of width 15, and one of 10.  The
chromosome is drawn in the 3rd stripe (width 15).  Annotations can go
into any stripe.  The widths of stripes are relative.  Eventually it
will be possible to change the stripes on the command line, and change
which stripe contains the chromosomes. 

For now drawing of banding is disabled, but that will be done... soon.  


There are two ways to annotate an ideogram: annotations, and heatmap.
The annotations are characters (for now just points, eventually text
as well) that are drawn.  Each column is:

chrom   start           end        stripe      pch      color

Example:
...
chr1    39411519        39413487        2       23      "#377eb8"
chr1    46169019        46171853        2       23      "#377eb8"
chr1    46176404        46178211        2       23      "#377eb8"
chr1    55705907        55707516        2       23      "#377eb8"
chr1    73595641        73603844        1       15			"green"
chr1    82721748        82724869        1       15      "green"
chr1    87512436        87514550        1       20      "blue"
...

The stripe is the stripe to render the point.  So, for a stripe layout
of (5,5,15,10), the first 4 points are drawn in the 2nd stripe
(position 5), and last 3 are drawn in the 1st stripe (pos 0).

The pch and the color are the colors to draw the annotation.


The heatmap is specified by a bed file with:

...
chr1    20000000        25000000        4351
chr1    25000000        30000000        4574
chr1    30000000        35000000        9274
... 


The 4th column is some value that scales the heatmap.  For now this is
normalized by chromosome and scaled into 9 possible colors.

