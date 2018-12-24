ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_arm.zip -O temp.zip \
    && unzip temp.zip -d /usr/bin/ \
    && rm temp.zip \
    && chmod 0755 /usr/bin/terraform

# Copy data
COPY run.sh /
COPY main.tf /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
