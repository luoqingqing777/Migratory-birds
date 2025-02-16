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

###Assemble contig(MEGAHIT v1.2.9)

`megahit -1 ./${sample}.decon_1.fastq -2 ./${sample}.decon_2.fastq -o ./${sample}_megahit_output.fasta -t 6`
`vsearch --sortbylength ./${sample}_megahit_output.fasta --relabel ${sample}.contig –minseqlength 1000 --maxseqlength -1 --output ./${sample}_1k.fa`

###balstn&blastx
`blastn -query ${sample}_1k.fa  -db ~/NR_NT/nt.gz/nt  -outfmt "6 qseqid sseqid pident nident qlen slen length mismatch positive ppos gapopen gaps qstart qend sstart send evalue bitscore qcovs qcovhsp qcovus qseq sstrand frames " -num_threads 10 -max_target_seqs 1 -out ${sample}.blastn`

`diamond blastx --db ~/NR_NT/fasta/NR/nr --query ${sample}_1k.fa  --more-sensitive --threads 40  --query-cover 10 --max-target-seqs 1 --outfmt 6 qseqid sseqid pident nident qlen slen length mismatch positive ppos gapopen gaps qstart qend sstart send qseq sseq evalue bitscore  qframe  qcovhsp --out ${sample}.blastx`
#annotation with taxonomizrR 
#Confirmation of virus host type based on ICTV data
#TPM analysis for Virus abundance

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


###Long-read Assemble
`flye --nano-raw /$sample.fastq.gz' --out-dir /$sample --threads 4`

###Instrain
`prodigal -i ${genome}.fasta -d ${genome}.fna -a ${genome}.faa`
`bowtie2 -x /${genome}.fasta/${genome} -1 /${sample}.decon_1.fastq.gz -2 /${sample}.decon_2.fastq.gz -S ./${sample}.sam`
`samtools view  --threads 10 -Sb ./${sample}.sam > ./${sample}.bam`
`inStrain profile ./${sample}.bam  ${genome}.fasta   -o ./${sample}.IS -p 8 -g ${genome}.fna`
`inStrain compare -i  ./sample1.IS/ ./sample2.IS/ -p 6 -o ./combine_test.IS.COMPARE`
`inStrain genome_wide -i ./test.IS.COMPARE/`
`inStrain plot -i ./test.IS.COMPARE/ -pl a`


###The phylogenetic analysis
`mafft --auto Hepatovirus.fasta > Hepatovirus_mafft.fasta` 
`trimal -in Hepatovirus_mafft.fasta -out Hepatovirus_filter.fasta -gappyout`
`iqtree -s Hepatovirus_filter.fasta   -m MF -mtree -nt AUTO`
`iqtree -s  Hepatovirus_filter.fasta    -bb 10000  -nt AUTO`#boostrap analysis

##VF-like genes of Catellicoccus
#use blastp to identify the potential VF-like genes with core.dmnd(from VFDB database)
 ` bowtie2 --threads 60  -x related_VFD_in_Catellicoccus  -1 ${sample}.decon_1.fastq -2 ${sample}.decon_2.fastq -S ~/1_publish/B_2_function/virulence_factor/bowtie_out/${sample}.sam \ 	
  samtools view  --threads 60 -Sb ${sample}.sam  >  ${sample}.bam \
 samtools sort --threads 60 ${sample}.bam -o ${sample}_sort.bam\
 samtools index  ${sample}_sort.bam\
 samtools idxstats  ${sample}_sort.bam >  ${sample}.tsv `


