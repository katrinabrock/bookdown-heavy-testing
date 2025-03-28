FROM  rocker/r-ver:4

# Add linux dependencies here
RUN apt update \
    && apt install -y --no-install-recommends \
    curl \
    git \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgit2-dev \
    libicu-dev \
    libmagick++-dev \
    libpng-dev \
    libssl-dev \
    libx11-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    pandoc \
    libudunits2-dev \
    texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/* 

# Add R dependencies from CRAN here
RUN install2.r --error --ncpus -1 \
    renv \
    && rm -rf /tmp/downloaded_packages \
    && strip /usr/local/lib/R/site-library/*/libs/*.so

COPY base-env base-env
RUN R -e "renv::restore('base-env')"

WORKDIR /opt

ENTRYPOINT ["Rscript", "run_test.R"]