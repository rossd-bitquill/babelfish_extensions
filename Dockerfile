FROM babelfish_base AS babelfish_dev

COPY --from=babelfish_base ${PREFIX}/ /usr/local/ /opt/mssql-tools/bin/

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="${PREFIX}/bin:${PATH}"
ENV PGDATA="/var/lib/postgresql/data"
ENV DOCKER_ENTRYPOINT="/usr/local/bin/entrypoint.sh"

#RUN apt-get update && \
#    apt-get install -y libxml2 libreadline8 tzdata libldap-2.4-2 libpython2.7 libxslt1.1 libossp-uuid16 && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

# Create postgres user
#RUN useradd postgres  && usermod -a -G postgres postgres

ENV USE_PGXS=1

## [WIP] Support for ANTLR 4.8
# XXX: current make is not taking in account this environment settings 
#      ANTLR_EXECUTABLE=${PREFIX}/antlr-4.8-complete.jar ANTLR4_RUNTIME_LIBRARIES=/usr/include/antlr4-runtime
RUN ["/usr/bin/bash", "-c", "cd ${EXT_CODE_PATH}/contrib/babelfishpg_tsql/antlr ; cmake . "]

RUN PG_CONFIG=${PG_CONFIG} PG_SRC=${PG_SRC} cmake=$(which cmake) ANTLR4_RUNTIME_LIBRARIES=/usr/include/antlr4-runtime ; \
    for EXT in babelfishpg_common babelfishpg_money babelfishpg_tds babelfishpg_tsql ; \
    do \
        cd ${EXT_CODE_PATH}/contrib/${EXT} ; \
        make clean && make && make install ; \
    done


# Sample default ready for Babelfish to run
RUN set -eux; \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" "${PREFIX}/share/postgresql/postgresql.conf.sample"; \
    sed -ri "s+#?shared_preload_libraries.*+shared_preload_libraries = 'babelfishpg_tds'+g" "${PREFIX}/share/postgresql/postgresql.conf.sample"; \
    sed -i -e "\$ababelfishpg_tds.listen_addresses = '*'"  "${PREFIX}/share/postgresql/postgresql.conf.sample"; \
    grep -F "listen_addresses = '*'" "${PREFIX}/share/postgresql/postgresql.conf.sample"; \
    grep -F "shared_preload_libraries = 'babelfishpg_tds'" "${PREFIX}/share/postgresql/postgresql.conf.sample"; \
    grep -F "babelfishpg_tds.listen_addresses = '*'" "${PREFIX}/share/postgresql/postgresql.conf.sample";

RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"

COPY entrypoint.sh ${DOCKER_ENTRYPOINT}

RUN chmod -R 0750 "${PREFIX}/share" && \
    chown postgres: ${DOCKER_ENTRYPOINT} && \
    chmod +x ${DOCKER_ENTRYPOINT} && \
    chown -R postgres: ${PREFIX}

WORKDIR "${PREFIX}/bin/"

USER postgres

STOPSIGNAL SIGINT

EXPOSE 1433
EXPOSE 5432

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["postgres"]
