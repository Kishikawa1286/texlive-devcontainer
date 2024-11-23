FROM ubuntu:jammy

ENV DEBIAN_FRONTEND="noninteractive"

ARG TEXLIVE_HOME="/usr/local/texlive"
ARG TEXLIVE_ROOT="${TEXLIVE_HOME}/current"
ARG TEXLIVE_PATH="${TEXLIVE_ROOT}/bin/linux"

ENV PATH="${PATH}:${TEXLIVE_PATH}"

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cpanminus \
        git \
        perl \
        wget \
        zsh

# Install Oh My Zsh
# See: https://ohmyz.sh
ARG OH_MY_ZSH_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
RUN wget ${OH_MY_ZSH_INSTALL_SCRIPT_URL} -O /tmp/install.sh \
    && sh /tmp/install.sh --unattended \
    && rm /tmp/install.sh

# Install TeXLive
COPY ./texlive.profile /tmp/
ARG ARCHIVE_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
ARG TL_MIRROR_URL="https://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet"
# Install TeXLive using the official procedure
# See: https://tug.org/texlive/quickinstall.html
RUN cd /tmp \
    && wget -nv ${ARCHIVE_URL} \
    && zcat < install-tl-unx.tar.gz | tar xf - \
    && cd install-tl-* \
    && perl ./install-tl --profile=/tmp/texlive.profile --repository=$TL_MIRROR_URL --no-interaction \
    && rm -rf /tmp/install-tl-* /tmp/install-tl-unx.tar.gz

# Create symbolic links for TeXLive
RUN ln -s $(find ${TEXLIVE_HOME} -maxdepth 1 -type d -name "20??") ${TEXLIVE_ROOT}
ARG X86_REAL_TEXLIVE_PATH="${TEXLIVE_ROOT}/bin/x86_64-linux"
ARG AARCH64_REAL_TEXLIVE_PATH="${TEXLIVE_ROOT}/bin/aarch64-linux"
RUN ARCH=$(uname -m) \
    && if [ "${ARCH}" = "x86_64" ]; then \
           REAL_TEXLIVE_PATH="${X86_REAL_TEXLIVE_PATH}"; \
       elif [ "${ARCH}" = "aarch64" ]; then \
           REAL_TEXLIVE_PATH="${AARCH64_REAL_TEXLIVE_PATH}"; \
       else \
           echo "Unsupported architecture: ${ARCH}"; exit 1; \
       fi \
    && ln -s ${REAL_TEXLIVE_PATH} ${TEXLIVE_PATH}

# Install LaTeX packages and tools used by the extensions
RUN tlmgr update --self --all \
    && tlmgr install latexindent latexmk

# Install perl modules for latexindent
RUN cpanm --notest -n \
    Log::Log4perl \
    Log::Dispatch::File \
    YAML::Tiny \
    File::HomeDir \
    Unicode::GCString

# Copy configuration files
COPY ./.latexmkrc /root/

RUN apt-get clean -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
