i="All_faa.total"

diamond blastp --db /mnt/storage7/PubDB/nr_diamond_db/nr --query ${i} --outfmt 6 --max-target-seqs 10 --out ${i}_blast_result.txt --threads 150

