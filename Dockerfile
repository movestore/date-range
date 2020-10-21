FROM registry.gitlab.com/couchbits/movestore/movestore-groundcontrol/co-pilot-v1-r:1648

# install system dependencies required by this app
######### if this app requires any system libraries add them here
# RUN apt-get update && apt-get install -y \
#    lib-a \
#    lib-b \
#    && apt-get clean
######### end-if
RUN apt-get update && apt-get install -qq -y --no-install-recommends libxml2-dev
RUN apt-get update && apt-get install -qq -y --no-install-recommends libgdal-dev

WORKDIR /root/app

# install the R dependencies this app needs
RUN Rscript -e 'remotes::install_version("move")'
RUN Rscript -e 'remotes::install_version("lubridate")'
RUN Rscript -e 'packrat::snapshot()'

# copy the app
# copy the app as last as possible
# therefore following builds can use the docker cache of the R dependency installations
COPY RFunction.R .
