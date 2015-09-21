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
chromosome.  The current layout is default at (5,5,15,10), where there
are two stripes of width 5, one of width 15, and one of 10.  The
chromosome is drawn in the 3rd stripe (width 15).  Annotations can go
into any stripe.  The widths of stripes are relative.

The stripes may be changed using the option -s stripes.txt, where the
format of stripes.txt is stripe_width stripe_label, with the single
reserved label "c" to label which stripe to draw the chromosome
in. The default stripes are described in
<pre>
5 a
5 a
5 a
15 c
10 s
</pre>

Although here the 'a' and 's' don't mean anything, it is just not 'c'.



For now drawing of banding is disabled, but that will be done... soon.  


There are three ways to annotate an ideogram: rectangles, annotations,
and a heatmap.

Rectangles are bars drawn roughly the width of the stripes.
chrom start end stripe color
Example:
...
<pre>
chr1	32665	63507	1	green
chr1	163156	194165	1	green
chr1	731738	740486	1	green
</pre>

You can have Ideoplot try and have fancy coloring of enumerated groups
by adding an additional column.  Columns with group index 0 are
rendered with the value in the color column. Group indices greater
than 0 are assigned a color, hash combination so that each group has a
unique color, hash.  Right now up to 420 combinations are supported,
but it's pretty hard to distinguish lots of them so that may change.


chrom start end stripe color index
Example:
...
<pre>
chr1	32665	63507	1	green  0
chr1	163156	194165	1	green 1
chr1	731738	740486	1	green 2
chr4	117223	497282	1	green 1
</pre>

Finally you can add a strand to the plot with an additional column:

chrom start end stripe color index strand
Example:
...
<pre>
chr1	32665	63507	1	green  0 0
chr1	163156	194165	1	green 1 1
chr1	731738	740486	1	green 2 -1
chr4	117223	497282	1	green 1 1
</pre>

-1: ignore strand
0: forward
1: reverse


The annotations are characters (for now just points, eventually text
as well) that are drawn.  Each column is:

chrom   start           end        stripe      pch      color

Example:
...
<pre>
chr1    39411519        39413487        2       23      "#377eb8"
chr1    46169019        46171853        2       23      "#377eb8"
chr1    46176404        46178211        2       23      "#377eb8"
chr1    55705907        55707516        2       23      "#377eb8"
chr1    73595641        73603844        1       15      "green"
chr1    82721748        82724869        1       15      "green"
chr1    87512436        87514550        1       20      "blue"
</pre>
...


The stripe is the stripe to render the point.  So, for a stripe layout
of (5,5,15,10), the first 4 points are drawn in the 2nd stripe
(position 5), and last 3 are drawn in the 1st stripe (pos 0).

The pch and the color are the colors to draw the annotation.


The heatmap is specified by a bed file with:
<pre>
...
chr1    20000000        25000000        4351
chr1    25000000        30000000        4574
chr1    30000000        35000000        9274
... 
</pre>

The 4th column is some value that scales the heatmap.  For now this is
normalized by chromosome and scaled into 9 possible colors.

