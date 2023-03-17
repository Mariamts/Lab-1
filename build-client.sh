#!/bin/bash

# clone repository
git clone https://github.com/EPAM-JS-Competency-center/shop-angular-cloudfront.git

# navigate
cd shop-angular-cloudfront

# install npm dependencies

npm install

# set environment variable
ENV_CONFIGURATION=production

# build the client app with the specified configuration
npm run build -- --configuration $ENV_CONFIGURATION

# remove the existing zip file

if [-f ../dist/client-app.zip]; then 
	rm ../dist/client-app.zip
fi

# compress the built content/files into a zip file
zip -r ../dist/client-app.zip dist/*
