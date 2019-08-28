#!/bin/sh

ID=${1}
REPO="jeedom_$ID"
USER="lunarok"

echo "*** ${ID} ***"

#Clone or pull latest commit if repo exist
if [ ! -d "$ID" ]; then
    echo "Git clone repo"
    git clone git@github.com:$USER/$REPO.git $ID
    cd $ID
  else
    cd $ID
    echo "Git pull repo"
    git pull
fi

#Version minimum requise du plugin pour avoir les prérequis classe et css ...
echo "Update required version in json"
sed -i "s/\"require\" : .*/\"require\" : \"3.3.24\",/g" plugin_info/info.json

#Icones Fontawesome
echo "Upgrade fontawesome icons"
bash ../fontawesome4to5.sh -d core -e php
bash ../fontawesome4to5.sh -d core -e json
bash ../fontawesome4to5.sh -d core -e html
bash ../fontawesome4to5.sh -d desktop -e php
bash ../fontawesome4to5.sh -d desktop -e js

#Class object -> jeeObject 
echo "Move to jeeObject"
sed -i "s/object::all()/jeeObject::all()/g" desktop/php/${ID}.php

#Icone link 
echo "Move icone link"
sed -i "s/docs\/images/plugin_info/g" desktop/php/${ID}.php

#Remove old doc directories
echo "Remove old doc directories"
rm -rf docs/
rm -rf doc/

#Page équipement conforme
echo "Check eqlogic page"
grep -q in_searchEqlogic desktop/php/$ID.php
if [ $? -eq 0 ]
then
    echo "eqlogic page ok"
else
    echo "Please update manualy eqlogic page"
fi

#Search for python2 to migrate to python3
echo "Check python2 in use"
grep -q "python " core/class/$ID.class.php
if [ $? -eq 0 ]
then
    echo "No python2 found"
else
    echo "Python 2 is found, please update"
fi

#Présence de widgets
echo "Check if there is widgets"
grep -q _widgetPossibility core/class/$ID.class.php
if [ $? -eq 0 ]
then
    echo "Dedicated widget in usage, please check compliancy manualy"
else
    echo "No widgets in use"
fi

#Push changes
git commit -a -m "Compliancy script v4, icon link ..."
git push

cd ..
