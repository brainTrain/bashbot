#!/bin/bash

if [ -z "$AIRQUALITY_API_KEY" ]; then
  echo "Missing Air Now API Key..."
  echo "<https://docs.airnowapi.org/|Air Now API>"
  exit 0
fi

zip=$1
if [ -z "$zip" ]; then
  echo "Usage: $0 [zip]"
  exit 0
fi

response=$(curl -s "http://www.airnowapi.org/aq/observation/zipCode/current/?zipCode=${zip}&distance=5&format=application/json&API_KEY=${AIRQUALITY_API_KEY}")

if [[ "$response" == "[]" ]]; then
  echo "There is no <https://docs.airnowapi.org/|aqi value> for this zip: $zip"
  exit 0
fi

aqi=$(echo "$response" | jq '.[0]')
reporting_area=$(echo "$aqi" | jq -r '.ReportingArea')
aqi_value=$(echo "$aqi" | jq -r '.AQI')
time_stamp="$(echo "$aqi" | jq -r '.DateObserved')$(echo "$aqi" | jq -r '.HourObserved'):00"
category=$(echo "$aqi" | jq -r '.Category.Name')
case $category in
  "Good") emoji=":large_green_circle:";;
  "Moderate") emoji=":large_yellow_circle:";;
  "Unhealthy for Sensitive Groups") emoji=":large_orange_circle:";;
  "Unhealthy") emoji=":red_circle:";;
  "Very Unhealthy") emoji=":large_purple_circle:";;
  "Hazardous") emoji=":black_circle:";;
esac

echo "$emoji The <https://docs.airnowapi.org/aq101|Air Quality Index> in $reporting_area is $aqi_value ($category) as of $time_stamp";
