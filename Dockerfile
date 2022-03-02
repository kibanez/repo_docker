FROM ensemblorg/ensembl-vep@sha256:ff5e18b67d3d3688c8cc3265946a50dd115886adb2df475c66d7716e303d0817
USER root
RUN apt-get update --allow-releaseinfo-change --fix-missing \
  && apt-get install procps wget -y

# Conda installation
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh && \
    /bin/bash Miniconda.sh -b -p /opt/conda && \
    rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

ARG ENV_NAME="base"
COPY environment.yml /
#RUN conda env update -n ${ENV_NAME} -f /environment.yml && conda clean -a
RUN conda env create -n venv -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity (~ pip freeze)
RUN conda env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Initialise bash for conda
RUN conda init bash

WORKDIR /data/
COPY . .
RUN chmod +x /data/*.py
ENV PATH /data:$PATH

USER root
CMD [ "bash"]
