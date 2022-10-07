#!/bin/sh

# Setup variables for use in generator script
APP_NAME="$1"
APP_VERSION=0.1.0
APP_ICON_TYPE='svg'               # Change to suit project
APP_ICON_SRC=icon.$APP_ICON_TYPE   # Change to suit project
APP_ICON_DEST=$APP_NAME.$APP_ICON_TYPE

if [ -f $APP_NAME.spec ]
then
    # Create/Recreate package,sh script
    echo "#!/bin/sh" >./package.sh
    echo >>./package.sh

    echo "# Prepare and run pyinstaller using given .spec file" >>./package.sh
    echo "[ -e ./build ] && rm -r ./build" >>./package.sh
    echo "[ -e ./dist ] && rm -r ./dist" >>./package.sh
    echo "pyinstaller '$APP_NAME.spec'" >>./package.sh
    echo "" >>./package.sh

    echo "# Pre-create required folders for packaging" >>./package.sh
    echo "[ -e ./package ] && rm -r package" >>./package.sh
    echo "mkdir -p ./package/opt" >>./package.sh
    echo "mkdir -p ./package/usr/share/applications" >>./package.sh
    echo "mkdir -p ./package/usr/share/icons/hicolor/scalable/apps" >>./package.sh
    echo "" >>./package.sh

    echo "# Copy files (change icon file names where necessary)"  >>./package.sh
    echo "cp -r './dist/$APP_NAME' './package/opt/$APP_NAME'" >>./package.sh
    echo "cp -r './icons/$APP_ICON_SRC' './package/usr/share/icons/hicolor/scalable/apps/$APP_ICON_DEST'" >>./package.sh
    echo "cp $APP_NAME.desktop ./package/usr/share/applications" >>./package.sh
    echo "" >>./package.sh

    echo "# Change permissions" >>./package.sh
    echo "find './package/opt/$APP_NAME' -type f -exec chmod 644 -- {} +" >>./package.sh
    echo "find './package/opt/$APP_NAME' -type f -exec chmod 755 -- {} +" >>./package.sh
    echo "find './package/usr/share' -type f -exec chmod 644 -- {} +" >>./package.sh
    echo "chmod +x './package/opt/$APP_NAME/$APP_NAME'" >>./package.sh
    echo "" >>./package.sh

    echo "# Create .fpm file if it doesn't exist" >>./package.sh
    if [ ! -e .fpm ]
    then
        echo "-C package" >.fpm
        echo "-s dir" >>.fpm
        echo "-t deb" >>.fpm
        echo "-n $APP_NAME" >>.fpm
        echo "-v $APP_VERSION" >>.fpm
        echo "-p $APP_NAME.deb" >>.fpm
        echo "" >>.fpm
    fi

    echo "# Create the actual deb package" >>./package.sh
    echo "[ -e $APP_NAME.deb ] && rm $APP_NAME.deb" >>./package.sh
    echo "fpm" >>./package.sh
    echo "" >>./package.sh
    chmod +x ./package.sh

else
    echo "ERROR: Unable to find required pyinstall specification file: '$APP_NAME.spec'"
    echo "Aborting script generation."
fi
