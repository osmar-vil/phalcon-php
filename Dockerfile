# Use the official PHP 8.1 Alpine image
FROM php:8.1-cli-alpine

# Install necessary packages and dependencies for building Phalcon and Composer
RUN apk update && apk add --no-cache \
    build-base \
    autoconf \
    curl-dev \
    pcre-dev \
    git \
    libtool \
    re2c \
    unzip \
    && docker-php-ext-install pdo_mysql

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clone the Phalcon source code and build it
RUN git clone --depth=1 https://github.com/phalcon/cphalcon.git /usr/src/cphalcon \
    && cd /usr/src/cphalcon/build \
    && ./install

# Enable the Phalcon extension
RUN echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini

# Install Phalcon DevTools globally using Composer
RUN composer global require phalcon/devtools \
    && ln -s /root/.composer/vendor/phalcon/devtools/phalcon.php /usr/local/bin/phalcon \
    && chmod ugo+x /usr/local/bin/phalcon

# Clean up
RUN apk del build-base autoconf curl-dev git libtool re2c \
    && rm -rf /usr/src/cphalcon

# Set the working directory
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html

# Expose port 80
EXPOSE 80

# Start the PHP built-in server
CMD ["php", "-S", "0.0.0.0:80", "-t", "public/"]
