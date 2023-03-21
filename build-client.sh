#!/bin/bash

echo "Cloning repository..."
# clone repository
git clone https://github.com/EPAM-JS-Competency-center/shop-angular-cloudfront.git

# navigate
cd shop-angular-cloudfront

echo "Installing npm dependencies..."
# install npm dependencies
npm install

# set environment variable
ENV_CONFIGURATION=production

echo "Building client app with specified configuration: $ENV_CONFIGURATION ..."
# build the client app with the specified configuration
npm run build -- --configuration $ENV_CONFIGURATION

echo "Removing existing zip file..."
# remove the existing zip file
if [ -f ../dist/client-app.zip ]; then 
	rm ../dist/client-app.zip
fi

echo "Compressing built content/files into a zip file..."
# compress the built content/files into a zip file
zip -r ../dist/client-app.zip dist/*
