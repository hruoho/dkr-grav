GVER=v1.1.8
wget https://github.com/getgrav/grav/releases/download/1.1.8/grav-$GVER.zip \
    && unzip grav-$GVER.zip \
    && rm grav-$GVER.zip \
    && rsync -av --exclude 'user' grav/ .
