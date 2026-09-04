FROM rocker/r-ver:4.5.1

LABEL maintainer="Shaurita Hutchins <sdhutchins@uab.edu>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    libcurl4-openssl-dev \
    libnode-dev \
    libssl-dev \
    libxml2-dev \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled renv

WORKDIR /home/app

COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
RUN RENV_CONFIG_CACHE_ENABLED=FALSE R -s -e 'renv::restore(prompt = FALSE)'

RUN addgroup --system app \
    && adduser --system --ingroup app --home /home/app --no-create-home app \
    && mkdir -p /home/app/.cache/R \
    && chown -R app:app /home/app
COPY --chown=app:app . .

ENV HOME=/home/app \
    R_USER_CACHE_DIR=/home/app/.cache/R

USER app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app', host = '0.0.0.0', port = 3838)"]
