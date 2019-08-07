FROM atlassian/default-image:2

# PHP 7.2
RUN apt-key update && \
    apt-get -y update && \
    apt-get -y install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get -y upgrade && \
    apt-get -y update --fix-missing

RUN apt-get -y --force-yes install \
        php7.2-common \
        php7.2-cli \
        php7.2-mysqlnd \
        php7.2-curl \
        php7.2-bcmath \
        php7.2-mbstring \
        php7.2-soap \
        php7.2-xml \
        php7.2-zip \
        php7.2-json \
        php7.2-imap \
        php7.2-intl \
        php7.2-pgsql

# AWS cli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    EXPECTED_SIGNATURE="$(curl https://composer.github.io/installer.sig)" && \
    ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" && \
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ] ; then >&2 echo 'ERROR: Invalid installer signature' && \
        rm composer-setup.php && \
        exit 1 ; fi && \
    echo "Installer Verified!" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require hirak/prestissimo --no-plugins --no-scripts

ENV NVM_VERSION=0.34.0 \
    NVM_DIR=/root/.nvm \
    NODE_VERSION=lts/dubnium

# npm & yarn
RUN curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
    && . $NVM_DIR/nvm.sh && \
    nvm ls-remote --lts && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    echo "nvm use default" >> /root/.bashrc && \
    npm install -g yarn

# SASS
RUN wget https://github.com/sass/dart-sass/releases/download/1.5.0/dart-sass-1.5.0-linux-x64.tar.gz && \
    tar -xvzf dart-sass-1.5.0-linux-x64.tar.gz && \
    mv -v dart-sass/* /usr/local/bin

# GDCP (Google Drive API client)
RUN apt-get install -qy python python-pip
RUN pip install pydrive && pip install backoff
RUN pip install --upgrade google-api-python-client
RUN mkdir -p /usr/src/gdcp \
    && cd /usr/src/ \
    && git clone https://github.com/ctberthiaume/gdcp.git \
    && cp gdcp/gdcp /usr/bin
RUN mkdir $HOME/.gdcp
RUN echo "client_config_file: "$HOME"/.gdcp/client_secrets.json" > $HOME/.gdcp/settings.yaml \
    &&  echo "get_refresh_token: True" >> $HOME/.gdcp/settings.yaml \
    &&  echo "save_credentials: True" >> $HOME/.gdcp/settings.yaml \
    &&  echo "save_credentials_backend: file" >> $HOME/.gdcp/settings.yaml \
    &&  echo "save_credentials_file: "$HOME"/.gdcp/credentials.json" >> $HOME/.gdcp/settings.yaml \
    &&  echo "client_config_backend: file" >> $HOME/.gdcp/settings.yaml
