#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo # if using a theme, replace by `hugo -t <yourtheme>`

cp -rv archetypes public/source/
cp -rv data public/source/
cp -rv layouts public/source/
cp -rv content public/source/
cp -rv resources public/source/
cp -rv static public/source/
cp -fv config.toml public/source/config.toml
cp -fv deply.sh public/source/deply.sh

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master 

# Come Back
cd ..