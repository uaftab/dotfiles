# Install theme
mkdir -p ~/.themes
cd $_
wget https://github.com/shimmerproject/Greybird/archive/master.zip
unzip master.zip
rm master.zip


# Install Icons
mkdir -p ~/.icons
cd $_

wget https://github.com/shimmerproject/elementary-xfce/archive/master.zip
unzip master.zip
mv elementary*/* .
rm master.zip

# update icon cache (optional)
gtk-update-icon-cache-3.0 -f -t ~/.icons

sudo apt-get install xfce4-whiskermenu-plugin
