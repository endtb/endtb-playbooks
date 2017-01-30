#!/bin/bash

#############
# ENVIRONMENT VARIABLE DEPENDENCIES
#
# BINTRAY_USER:  The user for logging into bintray
# BINTRAY_API_KEY:  The key for authenticating into bintray
#
##############

CURL_ARGS="--write-out %{http_code} --silent --output /dev/null"
JSON_HEADER="-H \"Content-Type: application/json\""
BINTRAY_AUTH="-u$BINTRAY_USER:$BINTRAY_API_KEY"

function executeCurlCommand() {
	local CURL_RESPONSE=$(eval "$1")
	echo "$CURL_RESPONSE"
}

###############################
# INPUT ARGUMENTS
# 	$1:  PACKAGE NAME IN BINTRAY (eg. openmrs-module-bahmniendtb)
#	$2:  VERSION
###############################
function createVersionIfNeeded() {
	local JSON_URL="https://api.bintray.com/packages/endtb/snapshots/$1/versions"
	local CHECK_EXISTS_OP="curl -X GET $JSON_HEADER $BINTRAY_AUTH $CURL_ARGS $JSON_URL/$2"
	local CHECK_EXISTS_CODE=$(executeCurlCommand "$CHECK_EXISTS_OP")
	if [ "$CHECK_EXISTS_CODE" == "404" ]; then
		local JSON_CONTENT="{\"name\": \"$2\", \"desc\": \"Version $2\"}"
		local CURL_OP="curl -X POST $JSON_HEADER -d '$JSON_CONTENT' $BINTRAY_AUTH $CURL_ARGS $JSON_URL"
		executeCurlCommand "$CURL_OP"
	else
		echo "$CHECK_EXISTS_CODE"
	fi
}

###############################
# INPUT ARGUMENTS
# 	$1:  PACKAGE NAME IN BINTRAY (eg. openmrs-module-bahmniendtb
#	$2:  VERSION
#	$3:  FILE PATH TO UPLOAD (eg. omod/target/bahmniendtb-xyz.omod)
#   $4:  FILE NAME IN BINTRAY TO PUBLISH UNDER
###############################
function uploadArtifact() {
	local PUBLISH_URL="https://api.bintray.com/content/endtb/snapshots/$1/$2/$4?override=1"
	local CURL_OP="curl -T $3 $BINTRAY_AUTH $CURL_ARGS $PUBLISH_URL"
	executeCurlCommand "$CURL_OP"
}

###############################
# INPUT ARGUMENTS
# 	$1:  PACKAGE NAME IN BINTRAY (eg. openmrs-module-bahmniendtb
#	$2:  VERSION
###############################
function publishArtifacts() {
	local PUBLISH_URL="https://api.bintray.com/content/endtb/snapshots/$1/$2/publish"
	local CURL_OP="curl -X POST $BINTRAY_AUTH $CURL_ARGS $PUBLISH_URL"
	executeCurlCommand "$CURL_OP"
}

###############################
# INPUT ARGUMENTS
# 	$1:  PACKAGE NAME IN BINTRAY (eg. openmrs-module-bahmniendtb
#	$2:  VERSION
#   $3:  BUILD NUMBER
###############################
function updateVersion() {
	echo "Updating the version of $1 to $2, Build $3"
	local JSON_URL="https://api.bintray.com/packages/endtb/snapshots/$1/versions/$2"
	local JSON_CONTENT="{\"name\": \"$2\", \"desc\": \"$2 Build $3\"}"
	local CURL_OP="curl -X PATCH $JSON_HEADER -d '$JSON_CONTENT' $BINTRAY_AUTH $CURL_ARGS $JSON_URL"
	executeCurlCommand "$CURL_OP"
}

###############################
# INPUT ARGUMENTS
#   $1:  BUILD NUMBER
###############################
function publishOmod {
	local BUILD_NUMBER=$1
	local OMOD_PATH=$(ls omod/target/*.omod)
	local OMOD_NAME="${OMOD_PATH##*/}"
	local MODULE_ID="${OMOD_NAME%%-*}"
	local VERSION_AND_SUFFIX="${OMOD_NAME##$MODULE_ID-}"
	local VERSION_FULL="${VERSION_AND_SUFFIX%%.omod}"
	local VERSION="${VERSION_FULL%%-*}"
	local PACKAGE_NAME="openmrs-module-$MODULE_ID"

	echo "Creating Version $VERSION, Build $BUILD_NUMBER for Package $PACKAGE_NAME"
	local CREATE_VERSION_RESPONSE=$(createVersionIfNeeded "$PACKAGE_NAME" "$VERSION")
	echo "Response: $CREATE_VERSION_RESPONSE"

	echo "Uploading artifact at $OMOD_PATH to $PACKAGE_NAME version $VERSION as $OMOD_NAME"
	local UPLOAD_RESPONSE=$(uploadArtifact "$PACKAGE_NAME" "$VERSION" "$OMOD_PATH" "$OMOD_NAME")
	echo "Response: $UPLOAD_RESPONSE"

	if [ "$UPLOAD_RESPONSE" == "201" ]; then
		echo "Publishing Artifacts"
		local PUBLISH_RESPONSE=$(publishArtifacts "$PACKAGE_NAME" "$VERSION")
		echo "Response: $PUBLISH_RESPONSE"

		echo "Updating version $VERSION, Build $BUILD_NUMBER for Package $PACKAGE_NAME"
		local UPDATE_VERSION_RESPONSE=$(updateVersion "$PACKAGE_NAME" "$VERSION" "$BUILD_NUMBER")
		echo "Response: $UPDATE_VERSION_RESPONSE"
	fi
}