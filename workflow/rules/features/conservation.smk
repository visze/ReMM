rule getPriPhyloP:
    output:
        "results/features/priPhyloP/hg38/priPhyloP.all.wig.gz",
    params:
        url=features["priPhyloP"]["hg38"]["url"],
    shell:
        """
        curl {params.url} | zcat | \
        awk -v 'put="F"' '{{
          if ($0 ~ /chrom/) {{
            if ($0 ~ /(\schrom=(chr([0-9]+|X|Y|M))\sstart=[0-9]+\sstep=[0-9]+)/) {{
              print $0;
              put="T";
            }} else {{
              put="F";
            }}
          }} else {{
            if (put=="T") {{
              print $0;
            }}
          }} }}' | bgzip -c > {output}
        """


rule getPriPhastCons:
    output:
        "results/features/priPhastCons/hg38/priPhastCons.all.wig.gz",
    params:
        url=features["priPhastCons"]["hg38"]["url"],
    shell:
        """
        curl {params.url} | zcat | \
        awk -v 'put="F"' '{{
          if ($0 ~ /chrom/) {{
            if ($0 ~ /(\schrom=(chr([0-9]+|X|Y|M))\sstart=[0-9]+\sstep=[0-9]+)/) {{
              print $0;
              put="T";
            }} else {{
              put="F";
            }}
          }} else {{
            if (put=="T") {{
              print $0;
            }}
          }} }}' | bgzip -c > {output}
        """


rule getVerPhyloP:
    output:
        "results/features/verPhyloP/hg38/verPhyloP.{chr}.wig.gz",
    params:
        url=lambda wildcards: "%s%s.phyloP100way.wigFix.gz" % (
            features["verPhyloP"]["hg38"]["url"],
            wildcards.chr,
        ),
    shell:
        """
        curl {params.url} > {output}
        """


rule getVerPhastCons:
    output:
        "results/features/verPhastCons/hg38/verPhastCons.{chr}.wig.gz",
    params:
        url=lambda wildcards: "%s%s.phastCons100way.wigFix.gz" % (
            features["verPhastCons"]["hg38"]["url"],
            wildcards.chr,
        ),
    shell:
        """
        curl {params.url} > {output}
        """


rule getMamPhastCons:
    output:
        "results/features/mamPhastCons/hg38/mamPhastCons.{chr}.wig.gz",
    params:
        url=lambda wildcards: "%s%s.phastCons30way.wigFix.gz" % (
            features["mamPhastCons"]["hg38"]["url"],
            wildcards.chr,
        ),
    shell:
        """
        curl {params.url} > {output}
        """


rule getMamPhyloP:
    output:
        "results/features/mamPhyloP/hg38/mamPhyloP.{chr}.wig.gz",
    params:
        url=lambda wildcards: "%s%s.phyloP30way.wigFix.gz" % (
            features["mamPhyloP"]["hg38"]["url"],
            wildcards.chr,
        ),
    shell:
        """
        curl {params.url} > {output}
        """



# TODO hard coded path!

rule getGERP:
    input:
        "/fast/groups/ag_kircher/CADD/dependencies/annotations/gerp/gerp2_elements_hg38_MAM.bg.gz",
    output:
        "results/features/gerpElement/hg38/gerpElement.all.bed.gz",
    shell:
        """
        zcat {input} | \
        awk -v 'OFS=\\t' '{{print "chr"$0}}' | bgzip -c > {output}
        """


# cut -f 1,2,76-77 | \
# uniq | grep -v NA | \
# awk -v 'OFS=\\t' 'BEGIN {{chr=$1;start=$2-1;end=$2;rs=$3;p=$4}} {{ if (chr==$1 && end == ($2-1) && rs==$3 && p==$4) {{end=$2;}} else {{print "chr"chr,start,end,rs,p; chr=$1;start=($2-1);end=$2;rs=$3;p=$4}} }}' | \
# tail -n +2 | bgzp -c >
