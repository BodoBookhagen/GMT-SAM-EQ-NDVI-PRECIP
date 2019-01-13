#!/bin/bash
gmt gmtset MAP_FRAME_PEN    0.5p,black
gmt gmtset MAP_FRAME_WIDTH    0.1
gmt gmtset MAP_FRAME_TYPE     plain
gmt gmtset FONT_TITLE    18p,Helvetica-Bold,black
gmt gmtset FONT_LABEL    12p,Helvetica-Bold,black
gmt gmtset PS_PAGE_ORIENTATION    portrait
gmt gmtset PS_MEDIA    A4
gmt gmtset FORMAT_GEO_MAP    D
gmt gmtset MAP_DEGREE_SYMBOL degree
gmt gmtset PROJ_LENGTH_UNIT cm

REGION=-80/-60/-40/-15

# DEM/Topography Data
#clip area and generate hillshade 
TOPO15_GRD_NC=/home/bodo/Downloads/earth_relief_15s.nc
TOPO15_GRD_NC_CentralAndes=earth_relief_15s_CentralAndes.nc
if [ ! -e $TOPO15_GRD_NC_CentralAndes ]
then
    echo "generate Topo15S Clip $TOPO15_GRD_NC_CentralAndes"
    gmt grdcut -R$REGION $TOPO15_GRD_NC -G$TOPO15_GRD_NC_CentralAndes
fi

TOPO15_GRD_NC=$TOPO15_GRD_NC_CentralAndes
TOPO15_GRD_HS_NC=earth_relief_15s_CentralAndes_HS.nc
if [ ! -e $TOPO15_GRD_HS_NC ]
then
    echo "generate hillshade $TOPO15_GRD_HS_NC"
    gmt grdgradient $TOPO15_GRD_NC -Ne0.6 -Es75/55+a -G$TOPO15_GRD_HS_NC
fi

#Simpler Peucker algorithm
TOPO15_GRD_HS2_NC=earth_relief_15s_CentralAndes_HS_peucker.nc
if [ ! -e $TOPO15_GRD_HS2_NC ]
then
    echo "generate hillshade $TOPO15_GRD_HS2_NC"
    gmt grdgradient $TOPO15_GRD_NC -Nt1 -Ep -G$TOPO15_GRD_HS2_NC
fi

# GRID DATA
TRMM3B42_90ptotalRAIN="trmm3b42_1998_2013_DJF_90thp_total_2d.nc"
#gdal_translate -of GTIFF trmm3b42_1998_2013_DJF_90thp_total.nc trmm3b42_1998_2013_DJF_90thp_total.tif
#gmt grdconvert trmm3b42_1998_2013_DJF_90thp_total.tif trmm3b42_1998_2013_DJF_90thp_total_2d.nc

#resample trmm to topographic TOPO15 GRID
if [ ! -e ${TRMM3B42_90ptotalRAIN::-3}_topo15_centralandes.nc ]
then
    echo "resample to ${TRMM3B42_90ptotalRAIN::-3}_topo15_centralandes.nc"
    gmt grdsample ${TRMM3B42_90ptotalRAIN::-3}.nc -R$TOPO15_GRD_NC -G${TRMM3B42_90ptotalRAIN::-3}_topo15_centralandes.nc
fi


# VECTOR data
AltiplanoPuna_1bas=GMT_vector_data/AltiplanoPuna_1basin_UTM19S_WGS84.gmt
OSM_CentralAndeslakes=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndeslakes.gmt
OSM_CentralAndesvolcano=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndesvolcano.gmt

## CREATE Topographic map
#Set Parameters for Plot
POSTSCRIPT_BASENAME=CentralAndes_TRMM3B42_P90_totalRain
#xmin/xmax/ymin/ymax
WIDTH=10
XSTEP=10
YSTEP=10
DPI=300
CITY_STAR_SIZE=0.4c

TITLE="TRMM3B42 P90 vs. total rainfall"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}.ps
#Make colorscale
RAINP90_CPT=TRMM3B42_P90_totalper.cpt

gmt makecpt -T50/100/5 -D -Ic -Cjet >$RAINP90_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage ${TRMM3B42_90ptotalRAIN::-3}_topo15_centralandes.nc -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$RAINP90_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
echo A | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -Gwhite -C0.2c -F+cTL+f24p,Helvetica-Bold -P -O -K >> $POSTSCRIPT1
#-BWSne+t"$TITLE"
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
#gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.15c -Gblack -K -O -P >> $POSTSCRIPT1
gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthick,white -K -O -P >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+h+o-2.0c/-2.0c/+w7c/0.3c -C$RAINP90_CPT -F+gwhite+r1p+pthin,black -Baf -By+l"% rainfall during 90th p" --FONT=9p --FONT_ANNOT_PRIMARY=9p --MAP_FRAME_PEN=0.5p --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg
convert -alpha off -quality 100 -density 150 $POSTSCRIPT1 ${POSTSCRIPT1::-3}.jpg
