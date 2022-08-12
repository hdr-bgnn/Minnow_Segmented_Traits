FROM ghcr.io/rocker-org/r-ver:4.2.1
ADD Scripts /src/Minnow_Traits/Scripts
RUN Rscript /src/Minnow_Traits/Scripts/dependencies.R
