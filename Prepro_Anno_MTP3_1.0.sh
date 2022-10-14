#!/bin/bash

echo "
Running seqkit for raw data QC..." &&

time seqkit stats *.fastq.gz -j 64 -o Sum_Raw_reads_QC.txt &&

mkdir metaphlan &&
mkdir kneaddata_pair &&
mkdir kneaddata_merge &&

echo "
Running Kneaddata...
" &&

time parallel --ungroup -j 4 --link 'kneaddata --input {1} --input {2} --threads 32 --processes 32 --bypass-trf --trimmomatic-options "ILLUMINACLIP:/home/yingzhiliu/software/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:40:15 SLIDINGWINDOW:4:20 MINLEN:50" --bowtie2-options "--very-sensitive --dovetail"  --reorder -db '/srv/db/kneaddata' --remove-intermediate-output --output kneaddata_pair' ::: *_R1_001.fastq.gz ::: *_R2_001.fastq.gz  &&

echo "
Kneaddata done, compressing...
" &&
time parallel --ungroup -j 4 'crabz -I -p 32 {1}' ::: kneaddata_pair/*_kneaddata_paired_*.fastq && 

rm kneaddata_pair/*bowtie* &&
rm kneaddata_pair/*unmatched* &&
rm kneaddata_pair/*log &&

echo "
Kneaddata temp_output removed, running Metaphlan...	
" &&
cd kneaddata_pair
time parallel --ungroup -j 4 --link 'metaphlan {1},{2} --bowtie2out ../metaphlan/{1}.bowtie2.bz2 --bowtie2db "/srv/db/metaphlan3/201901" --input_type fastq --read_min_len 70 --bt2_ps very-sensitive --min_cu_len 2000 --tax_lev a --avoid_disqm --stat_q 0.2 --stat tavg_g -t rel_ab_w_read_stats --unknown_estimation --add_virus --nproc 32 -o ../metaphlan/{1}.tsv -s ../metaphlan/{1}.sam.bz2 --sample_id {1}' ::: *_1.fastq.gz ::: *_2.fastq.gz  &&

cd ../metaphlan
rename -v 's/_R1_001_kneaddata_paired_1.fastq.gz//' *.sam.bz2 &&
rename -v 's/_R1_001_kneaddata_paired_1.fastq.gz//' *.bowtie2.bz2 &&
rename -v 's/_R1_001_kneaddata_paired_1.fastq.gz//' *.tsv &&

echo "
Metaphlan done, merge paired files for Humann...
" &&

cd ../kneaddata_pair &&
time parallel --ungroup -j 4 --link 'reformat.sh in1={1} in2={2} out=../kneaddata_merge/merged_{1}.fastq.gz' ::: *_1.fastq.gz ::: *_2.fastq.gz &&

cd ../kneaddata_merge

rename -v 's/_R1_001_kneaddata_paired_1.fastq.gz//' *.gz &&

cd ../

echo "
Running seqkit for rmhost data QC...
" &&

time seqkit stats kneaddata_pair/*.fastq.gz -j 64 -o Sum_rmhost_reads_QC.txt &&

echo "Bash done"
