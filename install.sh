#!/bin/bash

packageTailwindcss="tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9"
packCRACO="@craco/craco"
bold=$(tput bold)
normal=$(tput sgr0)

echo -n "Select Package Manager... [ yarn | npm ]: "
read packageManager

message () {
  echo "$2\e[0;32m$1$3"
}

messageBold () {
  message "${bold}$1${normal}"
}

messageError () {
  echo "\e[0;31m$1"
}

installTailwindcss () {
  if [ $packageManager = 'yarn' ]; then
    messageBold "Adding tailwindcss"
    yarn add $packageTailwindcss

    messageBold "\nAdding CRACO"
    yarn add $packCRACO

  elif [ $packageManager = 'npm' ]; then

    messageBold "Installing tailwindcss"
    npm i $packageTailwindcss

    messageBold "\nInstalling CRACO" 
    npm i $packCRACO

  else
    messageError "The argument '$packageManager' is not correct."
    exit 1 
  fi
}

remplacePackageJSON () {
  messageBold "\nUse CRACO instead of react-scripts"
  sed -i -e 's/"start": "react-scripts start"/"start": "craco start"/g' package.json
  sed -i -e 's/"build": "react-scripts build"/"build": "craco build"/g' package.json
  sed -i -e 's/"test": "react-scripts test"/"test": "craco test"/g' package.json
}

copyCRACOConfig () {
  messageBold "Create a craco.config.js at the root of our project and add the tailwindcss and autoprefixer as PostCSS plugins"
  echo "module.exports = {
  style: {
    postcss: {
      plugins: [require('tailwindcss'), require('autoprefixer')],
    },
  },
};" > craco.config.js
}

tailwindcssInit () {
  messageBold "Create your configuration file"
  npx tailwindcss-cli@latest init -p
  rm postcss.config.js
  messageBold "Configure Tailwind to remove unused styles in production"
  sed -i -e "s/purge: \[\]/purge: \['.\/src\/**\/*.{js,jsx,ts,tsx}', '.\/public\/index.html'\]/g" tailwind.config.js
}

overwriteIndexCSS () {
  messageBold "Include Tailwind in your index.css"
  sed -i '1i @tailwind base;\n@tailwind components;\n@tailwind utilities;' src/index.css
}


if [ -z $packageManager ]; then
  messageError "\e[0;31mPlease enter the package manager."
  exit 1
else
  installTailwindcss
  remplacePackageJSON && copyCRACOConfig && tailwindcssInit && overwriteIndexCSS && message "\n\n✔ All done, happy hacking 😎!\nby \e[0;36mhttps://github.com/F34th3R\n"
fi



