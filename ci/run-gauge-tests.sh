#!/usr/bin/env bash

# This is a first-pass script at writing a script that will run the gauge tests on Snap-CI
# Currently this does not work due to not yet getting the chromedriver for selenium installed.

# requires environment variables:  TEST_SERVER_URL, TEST_SERVER_USER, TEST_SERVER_PASSWORD

STARTING_DIR="$(pwd)"

sudo yum -y upgrade

echo "Installing Gauge"
sudo /bin/bash install_latest_gauge.sh
gauge --install java
gauge --install html-report

cd $STARTING_DIR

echo "Installing Chrome"

sudo curl -s "https://chrome.richardlloyd.org.uk/install_chrome.sh" > install_chrome.sh
sudo echo assumeyes=1 >> /etc/yum.conf
sudo /bin/bash install_chrome.sh -f -f

echo "Installing Selenium Chrome Driver"

sudo yum install -y ruby ruby-devel gcc xorg-x11-server-Xvfb
gem install selenium-webdriver headless

LATEST_CHROMEDRIVER_RELEASE=`curl -s http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
sudo curl -s "http://chromedriver.storage.googleapis.com/$LATEST_CHROMEDRIVER_RELEASE/chromedriver_linux64.zip" > chromedriver.zip

sudo unzip chromedriver.zip && sudo mv chromedriver /usr/local/bin/

echo "Setting Environment Variables"

export BAHMNI_GAUGE_APP_URL="$TEST_SERVER_URL"
export BAHMNI_GAUGE_APP_USER="$TEST_SERVER_USER"
export BAHMNI_GAUGE_APP_PASSWORD="$TEST_SERVER_PASSWORD"
export BAHMNI_GAUGE_APP_IMPL_NAME="endtb"
export BAHMNI_GAUGE_PIH_USER="$TEST_SERVER_USER"
export BAHMNI_GAUGE_MSF_USER="$TEST_SERVER_USER"
export BAHMNI_GAUGE_IRD_USER="$TEST_SERVER_USER"
export BAHMNI_GAUGE_PIH_PASSWORD="$TEST_SERVER_PASSWORD"
export BAHMNI_GAUGE_MSF_PASSWORD="$TEST_SERVER_PASSWORD"
export BAHMNI_GAUGE_IRD_PASSWORD="$TEST_SERVER_PASSWORD"

echo "Configuring XVFB"

Xvfb -ac :99 -screen 0 1280x1024x16 &
export DISPLAY=:99

echo "Building Project"

cd $STARTING_DIR
mvn clean install

echo "Running Tests"

cd bahmni-gauge-endtb
mvn gauge:execute

echo "Testing Completed"