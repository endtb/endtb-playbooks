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

# For a given String $1, split on delimiter $2, and return element number $3 (1-index)
# Example:  splitAndReturnElementFromStart my-package-name-versionNum-buildNum - 4 -> versionNum
function splitAndReturnElementFromStart() {
	local STRING_TO_CUT="$1"
	local DELIMITER="$2"
	local NUM_FROM_END="$3"
	local SPLIT_OP="echo $STRING_TO_CUT | cut -d$DELIMITER -f$NUM_FROM_END"
	eval "$SPLIT_OP"
}

# For a given String $1, split on delimiter $2, and return element number $3 from the end (1-index)
# Example:  splitAndReturnElementFromEnd my-package-name-versionNum-buildNum - 2 -> versionNum
function splitAndReturnElementFromEnd() {
	local STRING_TO_CUT="$1"
	local DELIMITER="$2"
	local NUM_FROM_END="$3"
	local SPLIT_OP="echo $STRING_TO_CUT | rev | cut -d$DELIMITER -f$NUM_FROM_END | rev"
	eval "$SPLIT_OP"
}

## Returns everything after the last occurrance of a particular string in a string
## Example:  afterLastOccurrenceOfValue my-package-1.2.2 -  -> 1.2.2
function afterLastOccurrenceOfValue() {
	local SOURCE_STRING="$1"
	local VALUE_TO_FIND="$2"
	local CUT_VAL="${SOURCE_STRING##*$VALUE_TO_FIND}"
	echo $CUT_VAL
}

## Returns everything up to the first occurrance of a particular string in a string
## Example:  upToFirstOccurrenceOfValue package-version-build -  -> package
function upToFirstOccurrenceOfValue() {
	local SOURCE_STRING="$1"
	local VALUE_TO_FIND="$2"
	local CUT_VAL="${SOURCE_STRING%%$VALUE_TO_FIND*}"
	echo $CUT_VAL
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
#   $1:  FILE_PATH_TO_UPLOAD	The path to the artifact you wish to upload
#	$2:  PACKAGE_NAME			The name of the package in bintray
#   $3:  VERSION				The version of the package
#   $4:  BUILD_NUM				The build number of the package
#   $5:  FILE_NAME				The file name of the package as it should be published in bintray
###############################
function createVersionUploadAndPublishArtifact {

	local FILE_PATH_TO_UPLOAD="$1"
	local PACKAGE_NAME="$2"
	local VERSION="$3"
	local BUILD_NUM="$4"
	local FILE_NAME="$5"

	echo "Creating Version $VERSION, Build $BUILD_NUM for Package $PACKAGE_NAME"
	local CREATE_VERSION_RESPONSE=$(createVersionIfNeeded "$PACKAGE_NAME" "$VERSION")
	echo "Response: $CREATE_VERSION_RESPONSE"

	echo "Uploading artifact at $FILE_PATH_TO_UPLOAD to $PACKAGE_NAME version $VERSION as $FILE_NAME"
	local UPLOAD_RESPONSE=$(uploadArtifact "$PACKAGE_NAME" "$VERSION" "$FILE_PATH_TO_UPLOAD" "$FILE_NAME")
	echo "Response: $UPLOAD_RESPONSE"

	if [ "$UPLOAD_RESPONSE" == "201" ]; then
		echo "Publishing Artifacts"
		local PUBLISH_RESPONSE=$(publishArtifacts "$PACKAGE_NAME" "$VERSION")
		echo "Response: $PUBLISH_RESPONSE"

		echo "Updating version $VERSION, Build $BUILD_NUM for Package $PACKAGE_NAME"
		local UPDATE_VERSION_RESPONSE=$(updateVersion "$PACKAGE_NAME" "$VERSION" "$BUILD_NUM")
		echo "Response: $UPDATE_VERSION_RESPONSE"
	fi
}

###############################
# INPUT ARGUMENTS
#   $1:  BUILD NUMBER
#
# This is expected to be run from the module root
# And expects to find a single artifact to upload at
# omod/target/<projectName>-<version>.omod
###############################
function publishOmod {
	local BUILD_NUM=$1
	local FILE_PATH_TO_UPLOAD=$(ls omod/target/*.omod)
	local FILE_NAME=$(afterLastOccurrenceOfValue "$FILE_PATH_TO_UPLOAD" "/")
	local NAME_VERSION=$(upToFirstOccurrenceOfValue "$FILE_NAME" ".omod")
	local MODULE_ID=$(upToFirstOccurrenceOfValue "$NAME_VERSION" "-")
	local VERSION=$(afterLastOccurrenceOfValue "$NAME_VERSION" "$MODULE_ID-" 1)
	local VERSION_NO_SNAPSHOT=$(upToFirstOccurrenceOfValue "$VERSION" "-SNAPSHOT" 1)
	local PACKAGE_NAME="openmrs-module-$MODULE_ID"

	createVersionUploadAndPublishArtifact "$FILE_PATH_TO_UPLOAD" "$PACKAGE_NAME" "$VERSION_NO_SNAPSHOT" "$BUILD_NUM" "$FILE_NAME"
}

###############################
# NO INPUT ARGUMENTS
#
# This is expected to be run from the project root
# And expects to find a single artifact to upload at
# build/distributions/<project-name>-<version>-<buildNum>.noarch.rpm
###############################
function publishRpm {
	local FILE_PATH_TO_UPLOAD=$(ls build/distributions/bahmni-endtb-batch-*.noarch.rpm)
	local FILE_NAME=$(afterLastOccurrenceOfValue "$FILE_PATH_TO_UPLOAD" "/")
	local NAME_VERSION_BUILD=$(upToFirstOccurrenceOfValue "$FILE_NAME" ".noarch.rpm")
	local BUILD_NUM=$(splitAndReturnElementFromEnd "$NAME_VERSION_BUILD" "-" 1)
	local VERSION=$(splitAndReturnElementFromEnd "$NAME_VERSION_BUILD" "-" 2)
	local PACKAGE_NAME=$(upToFirstOccurrenceOfValue "$NAME_VERSION_BUILD" "-$VERSION-$BUILD_NUM")
	local NAME_VERSION=$(upToFirstOccurrenceOfValue "$FILE_NAME" "-$BUILD_NUM.noarch.rpm")

	createVersionUploadAndPublishArtifact "$FILE_PATH_TO_UPLOAD" "$PACKAGE_NAME" "$VERSION" "$BUILD_NUM" "$NAME_VERSION.noarch.rpm"
}