## deck2pdf tool
FROM dgricci/javafx:0.0.2
MAINTAINER Didier Richard <didier.richard@ign.fr>

## different versions - use argument when defined otherwise use defaults
ARG DECK2PDF_VERSION
#ENV DECK2PDF_VERSION ${DECK2PDF_VERSION:-master}
ENV DECK2PDF_VERSION ${DECK2PDF_VERSION:-RELEASE_0_3_0}
ARG DECK2PDF_URL
ENV DECK2PDF_URL ${DECK2PDF_URL:-https://github.com/melix/deck2pdf/archive/$DECK2PDF_VERSION.zip}

RUN \
    apt-get -qy update && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL "$DECK2PDF_URL" -o deck2pdf.zip && \
    unzip deck2pdf.zip -d /tmp && \
    rm deck2pdf.zip && \
    { \
        cd /tmp/deck2pdf-$DECK2PDF_VERSION ; \
        ./gradlew distZip ; \
        find build/distributions/ -name "*.zip" -exec unzip {} -d /usr/local \; ; \
        cd .. ; \
        rm -fr deck2pdf-$DECK2PDF_VERSION ; \
    } && \
    { \
        cd /usr/local ; \
        DECK2PDF_DIR="`find . -name "deck2pdf*" -type d`" ; \
        ln -s $DECK2PDF_DIR deck2pdf ;\
    }

ENV PATH /usr/local/deck2pdf/bin:$PATH

