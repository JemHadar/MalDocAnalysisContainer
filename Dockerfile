FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y install python3-pip \
      libssl-dev \
      wget \
      tar \
      unzip \
      git   \
      qtbase5-dev  \
      qtscript5-dev \
      qttools5-dev-tools \
      build-essential qtchooser
RUN   git clone --recursive https://github.com/horsicq/DIE-engine
WORKDIR DIE-engine
RUN bash -x build_dpkg.sh \
   && dpkg -i release/die_*.deb
WORKDIR /usr/local/bin/
RUN wget https://didierstevens.com/files/software/pdf-parser_V0_7_8.zip \
   && wget http://didierstevens.com/files/software/pdfid_v0_2_8.zip \
   && wget https://didierstevens.com/files/software/oledump_V0_0_75.zip \
   && unzip pdf-parser_V0_7_8.zip \
   && rm -rf pdf-parser_V0_7_8.zip \
   && chmod a+x pdf-parser.py \
   && unzip pdfid_v0_2_8.zip \
   && rm -rf pdfid_v0_2_8.zip \
   && chmod a+x pdfid.py \
   && unzip oledump_V0_0_75.zip \
   && rm -rf oledump_V0_0_75.zip \
   && chmod a+x oledump.py \
   && pip install -U oletools[full] 
RUN mkdir -p /home/maldoc
WORKDIR /home/maldoc/
RUN ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/local/bin/pdfid.py /usr/local/bin/pdfid \
    && ln -s /usr/local/bin/oledump.py /usr/local/bin/oledump \
    && ln -s /usr/local/bin/pdf-parser.py /usr/local/bin/pdf-parser \
    && ln -s /usr/local/bin/xlmdeobfuscator /usr/local/bin/xlmdeob