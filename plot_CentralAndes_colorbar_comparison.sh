#!/bin/bash
gmt gmtset MAP_FRAME_PEN    0.5p,black
gmt gmtset MAP_FRAME_WIDTH    0.1
gmt gmtset MAP_FRAME_TYPE     plain
gmt gmtset FONT_TITLE    14p,Helvetica-Bold,black
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

## CREATE Topographic map
#Set Parameters for Plot
POSTSCRIPT_BASENAME=CentralAndes_Topo15S
#xmin/xmax/ymin/ymax
WIDTH=10
XSTEP=10
YSTEP=10
DPI=300
CITY_STAR_SIZE=0.4c

TITLE="Topo C. Andes - mby cs"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_mbytopo.ps
#Make colorscale
DEM_CPT=relief_color.cpt
#gmt makecpt -T-5000/4000/250 -D -Carctic >$DEM_CPT
#gmt makecpt -T-6000/6000/250 -D -Crelief >$DEM_CPT
gmt makecpt -T-8000/5000/250 -D -Cmby >$DEM_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne+t"$TITLE" -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.1c -Gblack -K -O -P >> $POSTSCRIPT1
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

TITLE="Topo C. Andes - arctic cs"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_arctictopo.ps
#Make colorscale
DEM_CPT=relief_color.cpt
gmt makecpt -T-5000/4000/250 -D -Carctic >$DEM_CPT
#gmt makecpt -T-6000/6000/250 -D -Crelief >$DEM_CPT
#gmt makecpt -T-8000/5000/250 -D -Cmby >$DEM_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne+t"$TITLE" -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.1c -Gblack -K -O -P >> $POSTSCRIPT1
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

TITLE="Topo C. Andes - relief cs"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_relieftopo.ps
#Make colorscale
DEM_CPT=relief_color.cpt
#gmt makecpt -T-5000/4000/250 -D -Carctic >$DEM_CPT
gmt makecpt -T-6000/6000/250 -D -Crelief >$DEM_CPT
#gmt makecpt -T-8000/5000/250 -D -Cmby >$DEM_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne+t"$TITLE" -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.1c -Gblack -K -O -P >> $POSTSCRIPT1
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

#combine all plots into one row
# COMBINE plots with imagemagick
convert -quality 100 -density 300 ${POSTSCRIPT_BASENAME}_relieftopo.png ${POSTSCRIPT_BASENAME}_arctictopo.png ${POSTSCRIPT_BASENAME}_mbytopo.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_topo_colorscales.png

convert -quality 50 -density 150 ${POSTSCRIPT_BASENAME}_relieftopo.png ${POSTSCRIPT_BASENAME}_arctictopo.png ${POSTSCRIPT_BASENAME}_mbytopo.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_topo_colorscales.jpg
