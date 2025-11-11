#!/usr/bin/env bash
# This script update configuration and restart LANDINGPAGES Service

USER="www-data"
CONTAINERNAME="mkdocs"
ROOTFOLDER="/opt/services"
SCRIPTFOLDER="${ROOTFOLDER}/updates"
PAGESFOLDER="${SCRIPTFOLDER}/${CONTAINERNAME}"
STATICFOLDER="${SCRIPTFOLDER}/static/${CONTAINERNAME}"
SERVICEFOLDER="${ROOTFOLDER}/${CONTAINERNAME}"

echo "Make services resources"
sudo mkdir -p "${ROOTFOLDER}"
sudo mkdir -p "${SERVICEFOLDER}"
sudo chown -R "${USER}":"${USER}" "${SERVICEFOLDER}"
sudo chmod -R 755 "${SERVICEFOLDER}"
echo "-------------------------------"

echo "Pull assets from gitlab"
cd "${PAGESFOLDER}"
git pull --prune
git reset --hard
git remote set-url --push origin git@github-rulink-docs:developer-rulink/rulink-docs.git
git fetch -p origin
git push --mirror
cd ..
echo "-------------------------------"
echo ""

echo "Copy assets to production"
cp -rf "${PAGESFOLDER}/" "${ROOTFOLDER}"
echo "Copied assets and static files"
echo "-------------------------------"
echo ""

echo "Makes sites"
cd "${SERVICEFOLDER}"
source venv/bin/activate
echo "Activate python venv"
IFS=$'\n'
SITES=($(find . -maxdepth 1 -mindepth 1 -type d -not -name venv))
unset IFS
for ONESITE in "${!SITES[@]}"
do
  echo "Generate site for: ${SITES[$ONESITE]}"
  cd "${SITES[$ONESITE]}"
  cp -rf "${STATICFOLDER}/docs/" .
  mkdocs build
  cd ..
done

echo "Sites with venv build completed"
echo
echo "Set permissions for ${USER}"
sudo chown -R "${USER}":"${USER}" "${SERVICEFOLDER}"
sudo chmod -R 755 "${SERVICEFOLDER}"
echo "restarting..."
sleep 2
echo "Service has been restarted"
echo "------------------------------"
echo "Script completed"
echo "-------------------------------"
echo ""
