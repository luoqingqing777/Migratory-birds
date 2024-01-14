###Download data samples

`prefetch SRRXXX`

`fastq-dump -split-3 ${SRRXXX}.sra -O  ${OUTDIR}` 

###Preliminary data processing

`fastp -I ${sample}_1.fq.gz -I ${sample}_2.fq.gz -o ${sample}_fastp_1.fq.gz -O ${sample}_fastp_2.fq.gz`

###Remove 16S and host reads

PE1=${sample}_fastp_1.fq.gz;PE2=${sample}_fastp_2.fq.gz
PE_SAM=${OUTPUT_BAM_DIR}/${sample}_PE.sam
PE_BAM=${OUTPUT_BAM_DIR}/${sample}_PE.bam
PE_UN=${OUTPUT_DIR}/${sample}.decon.fastq
PE_LOG=${OUTPUT_LOG_DIR}/${sample}_PE.log

`bowtie2 -p 16 --no-unal --un-conc ${PE_UN} -x ${BOWTIE2_REFERENCE} -1 ${PE1} -2 ${PE2} -S ${PE_SAM} 2> ${PE_LOG}`
`samtools view -b -S ${PE_SAM} > ${PE_BAM}; rm ${PE_SAM}`

###Assemble contig

`megahit -1 ./${sample}.decon_1.fastq -2 ./${sample}.decon_2.fastq -o ./${sample}_megahit_output.fasta -t 6`

`vsearch --sortbylength ./${sample}_megahit_output.fasta --relabel ${sample}.contig –minseqlength 1000 --maxseqlength -1 --output ./${sample}_1k.fa`

###Metaphlan 

`metaphlan ./${sample}.decon_1.fastq,./${sample}.decon_2.fastq \
--bowtie2db /${database}\
--bowtie2out /${sample}.bowtie2.bz2 \
--nproc 10 --input_type fastq -s sams/${sample}.sam.bz2 -o /${sample}.mpa.out`

###Humann

`cat ./${sample}.decon_1.fastq ./${sample}.decon_2.fastq > ${sample}.fastq`
`humann --input ${sample}.fastq --output ${OUTPUT_DIR} –threads 30`

`humann_renorm_table	--input	./${sample}_genefamilies.tsv --output ./${sample}_genefamilies_relab.tsv --units relab --special n`

`humann_regroup_table --input ${sample}_genefamilies_relab.tsv --groups ${GROUPS} --output ${TABLE2}`

###Ariba

`ariba prepareref -f out.card.fa -m out.card.tsv card.prepareref.out`

###Midas2

#Deposit the number of the bacterium you are interested in 

`midas2 database --init --midasdb_name gtdb --midasdb_dir my_midasdb_gtdb`
`echo -e "145629" > species_list.txt`

`midas2 database --download --midasdb_name gtdb --midasdb_dir my_midasdb_Catellicoccus --species_list species_list.txt`

`midas2 run_species --sample_name ${sample} -1 reads/${sample}.decon_1.fastq.gz -2 reads/${sample}.decon_2.fastq.gz --midasdb_name gtdb --midasdb_dir my_midasdb_Catellicoccus --num_cores 12  midas2_output`

##Merge Midas results

`echo -e "sample_name\tmidas_outdir" > list_of_samples.tsv`
`ls reads | awk -F '.' '{print $1}' | awk -v OFS='\t' '{print $1, "midas2_output"}' >> list_of_samples.tsv`

###Strainphlan

`extract_markers.py -c t__SGB7914 -o db_markers`
`sample2markers.py  -i metaphlan/sams/${sample}.sam.bz2 -o consensus_markers -n 60`

`strainphlan -s consensus_markers/*.pkl -m db_markers/t__SGB7914.fna  -r reference_genomes/${reference}.fasta.bz2 -o output  -n 40 -c t__SGB7914 --mutation_rates`
