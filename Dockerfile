FROM node:20

ENV FASTLY_CLI_VERSION="10.4.0"
ENV C_AT_E_VERSION="c-at-e-file-server-dev-x86_64-unknown-linux-gnu.tar.xz"
ENV POLYFILL_RELEASE="v4.50.5"


# install fastly CLI tool (needed to serve traffic)
RUN wget https://github.com/fastly/cli/releases/download/v${FASTLY_CLI_VERSION}/fastly_${FASTLY_CLI_VERSION}_linux_amd64.deb
RUN dpkg -i fastly_${FASTLY_CLI_VERSION}_linux_amd64.deb

# install c-at-e-file-server (needed to serve traffic from the fastly CLI)
RUN wget https://github.com/JakeChampion/c-at-e-file-server/releases/download/main/$C_AT_E_VERSION
RUN tar xvf ${C_AT_E_VERSION}
RUN cp c-at-e-file-server-dev-x86_64-unknown-linux-gnu/c-at-e-file-server /usr/local/bin/

# clone service
RUN git clone https://github.com/JakeChampion/polyfill-service.git
WORKDIR polyfill-service
RUN git checkout $POLYFILL_RELEASE

# install NPM dependencies
RUN npm i --legacy-peer-deps
RUN npm run build

# update local fastly object stores
RUN ./update-local-object-stores.sh

# Expose and run
EXPOSE 7676
CMD ["fastly", "compute", "serve", "--verbose", "--addr=0.0.0.0:7676"]
