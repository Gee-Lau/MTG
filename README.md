# MTG

# Data preprocessing & annotation

Raw data from bcl2fastq -> QC -> kneaddata for trimmomatic and remove host genome -> compress trimmed, rmhost files -> 
remove unmatched/contamination files -> Metaphlan for species annotation -> merge pair end data for Humann preparation ->
QC for rmhost data

1. Environment preparation
  1 ) Upload the bash file (.sh) to the output file of bcl2fastq (with raw fastq.gz data)
   eg. `/srv/raw_data/MOMmy/20220401/` or `/srv/raw_data/IMPACT220819`
   2 ) Give permission to the bash file
 eg. `chmod 700 Prepro_Anno_MTP3_1.0.sh` for the current version
 3 ) Prepare the required tools
Kneaddata： `module load kneaddata-0.10.0`
Metaphlan3 (activate python with Metaphlan installed): `conda activate py3` 
* In case you are running metaphlan 4, or wish to change current options, you could edit the .sh file through any text editor, and modify the script accordingly.
eg. for metaphlan 4 change `--unknown_estimation` to `unclassified_estimation`

2. Running bash
Under the same path (with raw data), run:
`./Prepro_Anno_MTP3_1.0.sh` 

3. After running
  1 ) Check two QC files
  2 ) move all the output files to the Project file accordingly
eg. `cp -r kneaddata_merge /srv/projects/MOMmy/kneaddata/Date_of_data_release`
and do it to merge/metaphlan results as well.

Please let me know if there are any warnings/errors popped up, thank you.
