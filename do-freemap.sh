#!/bin/bash
SCRIPT=$(readlink -f "$0"); SCRIPTPATH=$(dirname "$SCRIPT")
cd $SCRIPTPATH

. $SCRIPTPATH/library.sh

datadir='/home/freemap/routing/data'; osrmdir='/home/ssd/osrm/osrm';
upgrade_remote() {
}

date
out=" starting: `date`"

update_planet > /dev/null
#update_planet > /dev/null # just in case, the first one fails


crop_freemap > /dev/null
crop_slovakia > /dev/null
#cp -p $datadir/slovakia.pbf /home/izsk/bigweby/epsilon/routing
#cp -p $datadir/bigslovakia.pbf /home/izsk/bigweby/epsilon/routing

test_file > /dev/null
rm $planetdir/tmp-bus/* $planetdir/tmp-train/*
cat $osrmdir/osrm-backend/profiles/car.lua |grep -v area > $osrmdir/oma-car.lua
upgrade_osrm car outdoor.tiles.freemap.sk > /dev/null
upgrade_osrm bus > /dev/null


if [ -r $planetdir/tmp-ski/bigslovakia.pbf ]; then rm $planetdir/tmp-ski/bigslovakia.pbf; fi
out="$out,get pistes: `date`"
osmium tags-filter $planetdir/planet-latest.osm.pbf wr/route=ski wr/piste:type wr/aerialway -o $planetdir/tmp-ski/bigslovakia.pbf > /dev/null
cp $planetdir/tmp-ski/bigslovakia.pbf $planetdir/tmp-nordic/bigslovakia.pbf
ls -lh $planetdir/tmp-nordic/bigslovakia.pbf

small=10
cat master-ski.lua | grep -v 'grep nordic' > $osrmdir/oma-ski.lua
upgrade_osrm ski > /dev/null
cat master-ski.lua | grep -v 'grep piste' > $osrmdir/oma-nordic.lua
upgrade_osrm nordic > /dev/null

small=100
upgrade_osrm train > /dev/null

out="$out,end: `date`"
#echo $out
echo $out | sed 's/,/\n/g'
