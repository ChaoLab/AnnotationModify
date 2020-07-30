# AnnotationModify
Combined annotation of GhostKOALA, KAAS, and eggNOG-mapper    
This pipeline contains 1) all the scripts to combine the annotation result of GhostKOALA, KAAS, and eggNOG-mapper; 2) all the scripts to find the top hits of BLASTP result.        

1) Methods:       
GhostKOALA and KAAS annotations provide results in KO identifier style. For eggNOG-mapper annotation, we use the following method to translate its annotations to KO identifiers: a) we use its first KO hit as the final result; b) if it only has a COG hit, we translate the COG identifier to KO identifier by ‘ko2cog.xl’ provided by KEGG database (http://www.genome.jp/kegg/files/ko2cog.xl) and take this as the final result. When combining the result of these software, we use the annotation (the KO identifier) from the first software as the final annotation; if there is no annotation from the first software, then we will move to the next software accordingly. 

2) Methods:        
Annotation using NCBI nr database was done by DIAMOND BLASTP with default settings. Only the top 10 hits were retained for each BALSTP run. Within the top 10 BLASTP hits of each annotation, we used the first ranked hit as the final annotation. When the first ranked hit is “hypothetical protein”, we will move downward and use the next one, until we find an annotation result which is not “hypothetical protein”. 

