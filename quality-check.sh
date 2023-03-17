#!/bin/bash

cd shop/angular/cloudfront

npm run lint


npm run test

npm audit


if ["$(npm audit --json | jq '.metadata.vulnerabilities')" != "{}" ]; then
	echo "vulnerabilities found"
else 
	echo "no vulnerabilities foudn"
fi
