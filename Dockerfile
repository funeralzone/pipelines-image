FROM atlassian/default-image:2

ENV NODE_VERSION=lts/dubnium

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

# nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . $HOME/.nvm/nvm.sh && \
    nvm ls-remote --lts && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Yarn
RUN npm install -g yarn

# SASS
RUN wget https://github.com/sass/dart-sass/releases/download/1.5.0/dart-sass-1.5.0-linux-x64.tar.gz && \
    tar -xvzf dart-sass-1.5.0-linux-x64.tar.gz && \
    mv -v dart-sass/* /usr/local/bin

