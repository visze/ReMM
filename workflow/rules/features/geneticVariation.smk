## use script getISCApath38 to get ISCApath from the file with all variants


rule getISCApath:
    output:
        "results/features/{genomeBuild}/ISCApath/ISCApath.nstd37_nstd45_nstd75.bed.gz.vartmp",
    params:
        nstd75=lambda wildcards: "%s%s.GRCh38.variant_call.tsv.gz" % (
            config[wildcards.genomeBuild]["ISCApath"]["url"],
            "nstd75",
        ),
        nstd37=lambda wildcards: "%s%s.GRCh38.variant_call.tsv.gz" % (
            config[wildcards.genomeBuild]["ISCApath"]["url"],
            "nstd37",
        ),
        nstd45=lambda wildcards: "%s%s.GRCh38.variant_call.tsv.gz" % (
            config[wildcards.genomeBuild]["ISCApath"]["url"],
            "nstd45",
        ),
    shell:
        """       
        (
            curl {params.nstd75} | zcat; \
            curl {params.nstd37} | zcat; \
            curl {params.nstd45} | zcat
        )  | cut -f 1,8,12,13 | \
        awk -vIFS='\\t' -vOFS='\\t' '{{print "chr"$2,$3-1,$4,$1}}' | \
        egrep -v "^chr\s" | \
        sort -k 1,1 -k2,2n | \
        bgzip -c > {output}
        """


rule getDbVARCount:
    output:
        "results/features/{genomeBuild}/dbVARCount/dbVARCount.all.bed.gz.vartmp",
    params:
        url=config["hg38"]["dbVARCount"]["url"],
    shell:
        """
        curl {params.url}| zcat  | egrep -v "#" | \
        egrep -v "benign|Benign" | sed  -E "s/[\|\;]/\\t/g" | \
        awk -vIFS='\\t' -vOFS='\\t' '{{print $1,$4-1,$5,$9}}' | \
        sort -k 1,1 -k2,2n | bgzip -c > {output}
        """


'''     
rule get_feature_DGVCount:
    output:
        "input/features/{genomeBuild}/DGVCount/DGVCount.all.bed.gz.vartmp"
    params:
        url=config['hg38']['DGVCount']['url']
    shell:
        """ 
        curl {params.url}  | egrep -v "^chr" | awk -vIFS='\\t' -vOFS='\\t' '{{print "chr"$2,$3-1,$4,$5,$6,$1}}' | sort -k 1,1 -k2,2n | awk '{{ for (i=1; i<NF;i++) {{ printf("%s\t",$i)}}; print $NF }}' | bgzip -c > {output} 
        """
'''


rule getDGVCount:
    output:
        "results/features/{genomeBuild}/DGVCount/DGVCount.all.bed.gz.st",
    params:
        url=lambda wc: config[wc.genomeBuild]["DGVCount"]["url"],
    shell:
        """ 
        curl {params.url}   | \
        awk -vIFS='\\t' -vOFS='\\t' '{{print "chr"$2,$3-1,$4,$5,$6,$1}}' | \
        sort -k 1,1 -k2,2n | bgzip -c > {output} 
        """


rule getNumTFBSConserved:
    output:
        "results/features/{genomeBuild}/numTFBSConserved/numTFBSConserved.all.bed.gz.st",
    params:
        url=lambda wc: config[wc.genomeBuild]["numTFBSConserved"]["url"],
    shell:
        """
        curl {params.url}  > {output}
        """


rule getChromosomes:
    input:
        "results/features/{genomeBuild}/{feature}/{file}.all.bed.gz.st",
    output:
        "results/features/{genomeBuild}/{feature}/{file}.{chr}.bed.gz.vartmp",
    script:
        "../../scripts/numTFBSConserved.py"


rule getIntervals:
    input:
        "results/features/{genomeBuild}/{feature}/{feature}.{files}.bed.gz.vartmp",
    output:
        "results/features/{genomeBuild}/{feature}/{feature}.{files}.var.bed.gz",
    script:
        "../../scripts/createIntervals.py"