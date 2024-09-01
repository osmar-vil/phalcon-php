# Use the official PHP image as the base
FROM php:8.1-cli

# Install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    autoconf \
    pkg-config \
    libpcre3-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Clone the Phalcon C source code from GitHub and compile it
RUN git clone --depth=1 "https://github.com/phalcon/cphalcon.git" \
    && cd cphalcon/build \
    && ./install

# Enable Phalcon extension
RUN echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini

# Set the working directory
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html

# Expose port 80
EXPOSE 80

# Start the PHP built-in server
CMD ["php", "-S", "0.0.0.0:80", "-t", "public/"]
