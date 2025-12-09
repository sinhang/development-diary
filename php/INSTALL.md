### INSTALL PHP

1. [php.net](https://www.php.net/)
2. [download](https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-debian&version=8.5&multiversion=Y&source=Y)
3. [github](https://github.com/php/php-src)
4. [install docs](https://github.com/php/php-src/blob/master/README.md)
5. [手册](https://www.php.net/manual/zh/)

```bash
mkdir php
cd php
wget https://www.php.net/distributions/php-8.5.0.tar.gz
tar -xzvf php-8.5.0.tar.gz
cd php-8.5.0
```

### 安装依赖
```bash
sudo apt install -y \
    autoconf \
    bison \
    build-essential \
    libxml2-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libonig-dev \
    libreadline-dev \
    libzip-dev \
    pkg-config \
    zlib1g-dev \
    libargon2-dev \
    libsystemd-dev \
    libxpm-dev \
    libx11-dev \
    libxext-dev \
    libgd-dev \
    libsodium-dev
```

### 配置参数调整
```bash
./configure \
    --prefix=/usr/local/php8.5 \
    --with-config-file-path=/usr/local/php8.5/etc \
    --enable-fpm \
    --with-fpm-systemd \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --enable-mbstring \
    --enable-intl \
    --with-pdo-mysql \
    --with-zip \
    --with-curl \
    --with-openssl \
    --with-readline \
    --with-pear \
    --enable-cli \
    --with-zlib \
    --with-bz2 \
    --enable-gd \
    --with-jpeg \
    --with-webp \
    --with-freetype \
    --with-xpm \
    --enable-sockets \
    --with-gettext \
    --with-mysqli \
    --enable-exif \
    --enable-pcntl \
    --enable-shmop \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --with-ffi \
    --with-sodium \
    --with-password-argon2
```

### 编译安装
```bash
sudo make test
sudo make install
php -v
```

### 软链
```bash
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/bin/php-config /usr/bin/php-config
```

### 扩展
```bash
echo "extension=mysqli" > /usr/local/php/etc/conf.d/mysqli.ini
echo "extension=pdo_mysql" > /usr/local/php/etc/conf.d/pdo_mysql.ini
echo "extension=gd" > /usr/local/php/etc/conf.d/gd.ini
echo "extension=iconv" > /usr/local/php/etc/conf.d/iconv.ini
echo "extension=openssl" > /usr/local/php/etc/conf.d/openssl.ini
echo "extension=curl" > /usr/local/php/etc/conf.d/curl.ini
echo "extension=freetype" > /usr/local/php/etc/conf.d/freetype.ini
echo "extension=jpeg" > /usr/local/php/etc/conf.d/jpeg.ini
echo "extension=webp" > /usr/local/php/etc/conf.d/webp.ini
echo "extension=xpm" > /usr/local/php/etc/conf.d/xpm.ini
```