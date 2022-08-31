FROM eclipse-temurin:17-jre

ENV APP_DIR /app
ENV HOMEDIR ${APP_DIR}/data
ENV MISC_DIR ${APP_DIR}/startup
ENV MC_RAM "" 
ENV JAVA_OPTS ""

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests jq \
    && mkdir -p ${MISC_DIR} \
    && mkdir -p ${HOMEDIR}

VOLUME ${HOMEDIR}

COPY entry.sh ${MISC_DIR}
RUN set -x \
    && chmod +x ${MISC_DIR}/entry.sh
COPY eula.txt ${MISC_DIR}

RUN useradd -ms /bin/bash paperman -u 1000
RUN chown -R paperman ${APP_DIR}
RUN chmod 755 ${APP_DIR}
USER paperman

WORKDIR ${HOMEDIR}

EXPOSE 25565/tcp
EXPOSE 25565/udp

ENTRYPOINT bash ${MISC_DIR}/entry.sh