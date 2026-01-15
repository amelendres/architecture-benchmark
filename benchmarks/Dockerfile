FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libssl-dev \
    libz-dev \
    libreadline-dev \
    git jq curl unzip
    
    # doesn't work git clone wrk2
    # DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \


# Install Lua 5.1
RUN curl -R -O https://lua.org/ftp/lua-5.1.5.tar.gz && \
    tar -zxf lua-5.1.5.tar.gz && \
    cd lua-5.1.5 && \
    make linux test && \
    make install
    

# Install LuaRocks
RUN curl -R -O https://luarocks.github.io/luarocks/releases/luarocks-3.5.0.tar.gz && \
    tar -xzvf luarocks-3.5.0.tar.gz && \
    cd luarocks-3.5.0 && \
    ./configure && \
    make bootstrap

RUN luarocks install lua-cjson

# Clone and build wrk2 (ARM64 compatible fork)
RUN git clone https://github.com/AmpereTravis/wrk2-aarch64.git wrk2 && \
    cd wrk2 && \
    make && \
    cp wrk /usr/local/bin/


# Set working directory
WORKDIR /wrk2
ENTRYPOINT ["./wrk-entrypoint.sh"]
CMD ["wrk --version"]