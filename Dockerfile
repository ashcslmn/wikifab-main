FROM mediawiki:1.31.3

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    xvfb \
    inkscape \
    libxrender1 \
    libfontconfig1 \
    libxext6 \
    xfonts-75dpi \
    xfonts-base \
    openssh-client 

## install composer 

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_arm64.deb
RUN dpkg -i wkhtmltox_0.12.6-1.buster_arm64.deb

# Set working directory
WORKDIR /var/www/html

# Copy the script into the image
COPY . /var/www/html/

# Install Wikifab
RUN wget -cO - https://getcomposer.org/composer-1.phar > composer.phar
RUN php composer.phar config minimum-stability dev
RUN php composer.phar update --no-dev

COPY LocalSettings.php /var/www/html/LocalSettings.php

# clone extensions single branch without .git just plain files 
# RUN git clone --depth 1 --branch master https://github.com/HydraWiki/Tabber extensions/Tabber
# RUN git clone --depth 1 --branch REL1_31 https://github.com/wikimedia/mediawiki-extensions-Flow.git extensions/Flow

# RUN wget -cO - https://extdist.wmflabs.org/dist/extensions/Flow-REL1_35-1e3b3b4.tar.gz | tar -xz -C extensions
RUN wget -cO - https://extdist.wmflabs.org/dist/extensions/LocalisationUpdate-REL1_35-ba7d734.tar.gz | tar -xz -C extensions 
# RUN mv extensions/LocalisationUpdate-REL1_35-ba7d734 extensions/LocalisationUpdate

# RUN php maintenance/update.php

# RUN php maintenance/initWikifab.php --setWikifabHomePage --int

# RUN mv vendor/mediawiki/flow extensions/Flow
# Expose port 80d
EXPOSE 80

# Start Apache service
ENTRYPOINT ["apache2-foreground"]