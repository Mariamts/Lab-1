#!/bin/bash

echo "Navigating to the shop/angular/cloudfront directory..."
cd shop/angular/cloudfront

echo "Running linting..."
npm run lint

echo "Running tests..."
npm run test

echo "Auditing npm packages..."
npm audit

if [ "$(npm audit --json | jq '.metadata.vulnerabilities')" != "{}" ]; then
	echo "Vulnerabilities found."
else 
	echo "No vulnerabilities found."
fi
