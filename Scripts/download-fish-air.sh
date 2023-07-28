#!/bin/bash
# Download Fish-AIR data for family Cyprinidae and dataset GLIN
set -e

API_KEY=$1
if [ -z "$API_KEY" ]
then
   echo "Error: Missing required Fish-AIR API key."
   echo ""
   echo "See https://fishair.org/ to create an API key."
   echo "Usage: download-fish-air.sh <FISH-AIR-API-KEY>"
   echo ""
   exit 1
fi

DESTDIR=Files/Fish-AIR/Tulane

# Make temp directory to hold the Fish-AIR files
OUTDIR=$(mktemp -d)

echo "Downloading dataset from Fish-AIR"
curl -X 'GET' \
  'https://fishair.org/api/multimedias/?family=Cyprinidae&dataset=GLIN&zipfile=true' \
  -o $OUTDIR/fish-air.zip \
  -H 'accept: application/json' \
  -H "x-api-key: $API_KEY"

echo "Extracting Fish-AIR zip file"
unzip $OUTDIR/fish-air.zip -d $OUTDIR

# Ensure destination directory exists
mkdir -p $DESTDIR

for FILENAME in meta.xml multimedia.csv imageQualityMetadata.csv citations.txt
do
    echo "Setting up $DESTDIR/$FILENAME"
    FILEPATH=$(find $OUTDIR -name $FILENAME)
    cp $FILEPATH $DESTDIR/$FILENAME
done

rm -rf $OUTDIR

echo "Done"
