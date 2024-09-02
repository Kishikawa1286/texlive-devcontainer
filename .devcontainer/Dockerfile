FROM ubuntu:jammy

ARG ARCHIVE_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
ARG TL_MIRROR_URL="https://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet"

ENV DEBIAN_FRONTEND noninteractive
ENV TEXLIVE_PATH /usr/local/texlive/current/bin/linux

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
      cpanminus build-essential wget perl zsh \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y

# Install Oh My Zsh
# See: https://ohmyz.sh
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

COPY ./texlive.profile /tmp
# Official Installation Procedure
# See: https://tug.org/texlive/quickinstall.html
RUN cd /tmp \
    && wget -nv $ARCHIVE_URL \
    && zcat < install-tl-unx.tar.gz | tar xf - \
    && cd install-tl-* \
    && perl ./install-tl --profile=/tmp/texlive.profile --repository=$TL_MIRROR_URL --no-interaction

# Create a symbolic link for the installed version of texlive to a more generic path
RUN ln -s $(find /usr/local/texlive -maxdepth 1 -type d -name "20??") /usr/local/texlive/current

# Create a symbolic link for the installed texlive regardless of architecture
RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then \
           REAL_TEXLIVE_PATH="/usr/local/texlive/current/bin/x86_64-linux"; \
       elif [ "$ARCH" = "aarch64" ]; then \
           REAL_TEXLIVE_PATH="/usr/local/texlive/current/bin/aarch64-linux"; \
       else \
           echo "Unsupported architecture: $ARCH"; exit 1; \
       fi \
    && ln -s $REAL_TEXLIVE_PATH $TEXLIVE_PATH

# Install latexindent and latexmk
RUN export PATH=$PATH:$TEXLIVE_PATH \
    && tlmgr update --self --all \
    && tlmgr install latexindent latexmk

# Add the texlive path to the PATH environment variable
RUN echo "export PATH=$PATH:$TEXLIVE_PATH" >> ~/.bashrc \
    && echo "export PATH=$PATH:$TEXLIVE_PATH" >> ~/.zshrc

# Install perl modules for latexindent
RUN cpanm Log::Log4perl Log::Dispatch::File YAML::Tiny File::HomeDir Unicode::GCString

COPY ./.latexmkrc /root/
