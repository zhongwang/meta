FROM ubuntu:22.04

LABEL base.image="ubuntu:22.04"
LABEL dockerfile.version="1"
LABEL software="metagenome"
LABEL software.version="1.0"
LABEL description="Whole metagenome pipeline"
LABEL maintainer="ZHONG WANG"
LABEL maintainer.email="zhong.wang@memverge.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-18-openjdk-amd64/
ENV PATH="$PATH:$JAVA_HOME/bin"

# install java and BBTools
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y build-essential file python3 wget samtools curl openjdk-18-jdk && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    wget https://sourceforge.net/projects/bbmap/files/BBMap_39.01.tar.gz -O BBMap.tar.gz && \
    tar -xzf BBMap.tar.gz && \
    rm BBMap.tar.gz

ENV PATH="${PATH}:/bbmap"\
 LC_ALL=C


# install metaspades (has to do a compilation)
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y g++ cmake zlib1g zlib1g-dev libbz2-dev && \
    wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5.tar.gz && \
    tar -xzf SPAdes-3.15.5.tar.gz && \
    cd SPAdes-3.15.5 && PREFIX=/usr/local ./spades_compile.sh && \
    rm -rf SPAdes-3.15.5*

# install metabat (precompiled)
ADD metabat /metabat
ENV PATH="${PATH}:/metabat:/usr/local/bin"

# install GTDB-tk
# ---------------------------------------------------------------------------- #
# --------------------- INSTALL HMMER, PYTHON3, FASTTREE---------------------- #
# ---------------------------------------------------------------------------- #
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
        libgomp1 \
#        libgsl27 \
        libgslcblas0 \
        hmmer>=3.1b2 \
        mash>=2.2 \
        prodigal>=2.6.2 \
        fasttree>=2.1.9 \
        unzip \
        git \
        python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/fasttreeMP /usr/bin/FastTreeMP

# ---------------------------------------------------------------------------- #
# ----------------------------- INSTALL PPLACER ------------------------------ #
# ---------------------------------------------------------------------------- #
RUN wget https://github.com/matsen/pplacer/releases/download/v1.1.alpha19/pplacer-linux-v1.1.alpha19.zip -q && \
    unzip pplacer-linux-v1.1.alpha19.zip && \
    mv pplacer-Linux-v1.1.alpha19/* /usr/bin && \
    rm pplacer-linux-v1.1.alpha19.zip && \
    rm -rf pplacer-Linux-v1.1.alpha19

# ---------------------------------------------------------------------------- #
# ----------------------------- INSTALL FASTANI ------------------------------ #
# ---------------------------------------------------------------------------- #
RUN wget https://github.com/ParBLiSS/FastANI/releases/download/v1.33/fastANI-Linux64-v1.33.zip -q && \
    unzip fastANI-Linux64-v1.33.zip -d /usr/bin && \
    rm fastANI-Linux64-v1.33.zip

# ---------------------------------------------------------------------------- #
# --------------------- SET GTDB-TK MOUNTED DIRECTORIES ---------------------- #
# ---------------------------------------------------------------------------- #
RUN mkdir /refdata && \
    mkdir /data
ENV GTDBTK_DATA_PATH="/refdata/"

# ---------------------------------------------------------------------------- #
# --------------------------- INSTALL PIP PACKAGES --------------------------- #
# ---------------------------------------------------------------------------- #
RUN python3 -m pip install numpy==1.23.1 gtdbtk

COPY run_pipeline.bash /

WORKDIR /data

ENTRYPOINT  ["/run_pipeline.bash"]
CMD ["-h"]        
