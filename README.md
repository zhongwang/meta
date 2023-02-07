# meta
a metagenome assembly/binning/classification pipeline for demonstration

# install
docker pull docker.io/lblzhongwang/meta
# run

```
docker run docker.io/lblzhongwang/meta
metagenome pipeline 1.0 (Feb 2023)

Usage: /run_pipeline.bash -1 fastqfile1 -2 fastqfile2 -o output_directory [Other Auguments]

Required Arguments:
-1 , --fastq_file_1          STR     Fastq File Read 1
-2 , --fastq_file_2          STR     Fastq File Read 2
-o , --outdir                STR     Output Directory

Optional Arguments:
-s , --save                  INT     Save Spades and GTDB-tk outputs(default 1, save all). Change it to 0 to save disk space.
-t , --threads               INT     Default (1)
-h , --help                          Print Help
```
