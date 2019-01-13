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

# Vector data
AltiplanoPuna_1bas=GMT_vector_data/AltiplanoPuna_1basin_UTM19S_WGS84.gmt
OSM_CentralAndeslakes=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndeslakes.gmt
OSM_CentralAndesvolcano=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndesvolcano.gmt
USGS_EQ_LT4=GMT_vector_data/USGS_EQ_CentralAndes_1970_2018_mag3.5_to_4.csv.bz2
USGS_EQ_GT4_LT5=GMT_vector_data/USGS_EQ_CentralAndes_1970_2018_mag4_to_5.csv.bz2
USGS_EQ_GT5_LT6=GMT_vector_data/USGS_EQ_CentralAndes_1970_2018_mag5_to_6.csv.bz2
USGS_EQ_GT6=GMT_vector_data/USGS_EQ_CentralAndes_1970_2018_mag6_to_9.csv.bz2

## CREATE Topographic map
#Set Parameters for Plot
POSTSCRIPT_BASENAME=CentralAndes_Topo15S
#xmin/xmax/ymin/ymax
WIDTH=10
XSTEP=10
YSTEP=10
DPI=300
CITY_STAR_SIZE=0.4c

TITLE="Topography C. Andes"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_relieftopo.ps
#Make colorscale
DEM_CPT=relief_color.cpt
#gmt makecpt -T-5000/4000/250 -D -Carctic >$DEM_CPT
#gmt makecpt -T-6000/6000/250 -D -Crelief >$DEM_CPT
gmt makecpt -T-8000/5000/250 -D -Cmby >$DEM_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
echo A | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -Gwhite -C0.2c -F+cTL+f24p,Helvetica-Bold -P -O -K >> $POSTSCRIPT1
#-BWSne+t"$TITLE"
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.15c -Gred -K -O -P >> $POSTSCRIPT1
gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthick,darkblue -K -O -P >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+h+o-0.0c/-3.0c/+w7c/0.3c+ml -C$DEM_CPT -F+c0.1c/0.3c+gwhite+r1p+pthin,black -Baf1000:"Bathymetry and Elevation":/:"[m]": --FONT=12p --FONT_ANNOT_PRIMARY=12p --MAP_FRAME_PEN=0.5p --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg
convert -alpha off -quality 100 -density 150 -trim $POSTSCRIPT1 ${POSTSCRIPT1::-3}.jpg

POSTSCRIPT1=${POSTSCRIPT_BASENAME}_reliefgray_EQ.ps
#Make colorscale
DEM_CPT=relief_gray.cpt
gmt makecpt -T-6000/6000/250 -D -Cgray >$DEM_CPT
EQ_DEPTH_CPT=EQ_color.cpt
gmt makecpt -Ic -T0/400/25 -D -Cviridis >$EQ_DEPTH_CPT
TITLE="USGS EQ 1970-2019"
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
echo B | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -Gwhite -C0.2c -F+cTL+f24p,Helvetica-Bold -P -O -K >> $POSTSCRIPT1
#gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthick,brown -K -O -P >> $POSTSCRIPT1
bzip2 -dc $USGS_EQ_GT4_LT5 | gmt select -i2,1,3 | gmt psxy -R -J -Wfaint,black -Sc0.07c -C$EQ_DEPTH_CPT -O -P -K >> $POSTSCRIPT1
bzip2 -dc $USGS_EQ_GT6 | gmt select -i2,1,3 | gmt psxy -R -J -Wfaint,black -Sc0.25c -C$EQ_DEPTH_CPT -O -P -K >> $POSTSCRIPT1
bzip2 -dc $USGS_EQ_GT5_LT6 | gmt select -i2,1,3 | gmt psxy -R -J -Wfaint,black -Sc0.12c -C$EQ_DEPTH_CPT -O -P -K >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
#-BWSne+t"$TITLE"
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -O -P -K >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+h+o-0.5c/-3.0c/+w7c/0.3c+ml -C$EQ_DEPTH_CPT -F+c0.1c/0.3c+gwhite+r1p+pthin,black -Baf100:"EQ Depth":/:"[km]": --FONT=12p --FONT_ANNOT_PRIMARY=12p --MAP_FRAME_PEN=0.5p --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg
convert -alpha off -quality 100 -density 150 -trim $POSTSCRIPT1 ${POSTSCRIPT1::-3}.jpg

# COMBINE plots with imagemagick
convert -quality 50 -density 150 ${POSTSCRIPT_BASENAME}_relieftopo.png ${POSTSCRIPT_BASENAME}_reliefgray_EQ.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_relief_topo_EQ_combined.jpg

convert -quality 100 -density 300 ${POSTSCRIPT_BASENAME}_relieftopo.png ${POSTSCRIPT_BASENAME}_reliefgray_EQ.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_relief_topo_EQ_combined.png
