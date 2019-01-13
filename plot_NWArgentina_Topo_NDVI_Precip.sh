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

REGION=-75/-60/-35/-15

# DEM/Topography Data
#clip area and generate hillshade 
TOPO15_GRD_NC=/home/bodo/Downloads/earth_relief_15s.nc
TOPO15_GRD_NC_NWArg=earth_relief_15s_NWArg.nc
if [ ! -e $TOPO15_GRD_NC_NWArg ]
then
    echo "generate Topo15S Clip $TOPO15_GRD_NC_NWArg"
    gmt grdcut -R$REGION $TOPO15_GRD_NC -G$TOPO15_GRD_NC_NWArg
fi

TOPO15_GRD_NC=$TOPO15_GRD_NC_NWArg
TOPO15_GRD_HS_NC=earth_relief_15s_NWArg_HS.nc
if [ ! -e $TOPO15_GRD_HS_NC ]
then
    echo "generate hillshade $TOPO15_GRD_HS_NC"
    gmt grdgradient $TOPO15_GRD_NC -Ne0.6 -Es75/55+a -G$TOPO15_GRD_HS_NC
fi

#Simpler Peucker algorithm
TOPO15_GRD_HS2_NC=earth_relief_15s_NWArg_HS_peucker.nc
if [ ! -e $TOPO15_GRD_HS2_NC ]
then
    echo "generate hillshade $TOPO15_GRD_HS2_NC"
    gmt grdgradient $TOPO15_GRD_NC -Nt1 -Ep -G$TOPO15_GRD_HS2_NC
fi

# Vector data
AltiplanoPuna_1bas=GMT_vector_data/AltiplanoPuna_1basin_UTM19S_WGS84.gmt
OSM_CentralAndeslakes=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndeslakes.gmt
OSM_CentralAndesvolcano=/raid-cachi/bodo/Dropbox/Argentina/GIS_Data/OSM/CentralAndesvolcano.gmt

# Grid data
MOD13A3_NDVI_CentralAndes_rTOPO15=MOD13A3_2001-2017NDVImn_CentralAndes_Topo15S.nc
MOD13A3_EVI_CentralAndes_rTOPO15=MOD13A3_2001-2017EVImn_CentralAndes_Topo15S.nc

# Prepare TRMM data
TRMM2B31_1998_2009_MM_PER_YR=trmm2b31_annual_mm_per_year.tif
TRMM2B31_1998_2009_MM_PER_YR_NWArg=trmm2b31_annual_mm_per_year_NWArg.nc
TRMM2B31_1998_2009_MM_PER_YR_NWArg_rTOPO15=trmm2b31_annual_mm_per_year_NWArg_Topo15S.nc
if [ ! -e $TRMM2B31_1998_2009_MM_PER_YR_NWArg ]
then
    echo "generate TRMM2B31 Mean clip $TRMM2B31_1998_2009_MM_PER_YR_NWArg"
    gmt grdcut -R$REGION $TRMM2B31_1998_2009_MM_PER_YR -G$TRMM2B31_1998_2009_MM_PER_YR_NWArg
fi

if [ ! -e $TRMM2B31_1998_2009_MM_PER_YR_NWArg_rTOPO15 ]
then
    echo "resample TRMM2B31 Mean Clip $TRMM2B31_1998_2009_MM_PER_YR_NWArg_rTOPO15"
    gmt grdsample $TRMM2B31_1998_2009_MM_PER_YR_NWArg -R$REGION -I3601+/4801+ -G$TRMM2B31_1998_2009_MM_PER_YR_NWArg_rTOPO15
fi

TRMM2B31_1998_2009_EEVENT_NR=trmm2b31_eevent_nr.tif
TRMM2B31_1998_2009_EEVENT_NR_NWArg=trmm2b31_eevent_nr_NWArg.nc
TRMM2B31_1998_2009_EEVENT_NR_NWArg_rTOPO15=trmm2b31_eevent_nr_NWArg_Topo15S.nc
if [ ! -e $TRMM2B31_1998_2009_EEVENT_NR_NWArg ]
then
    echo "generate TRMM2B31 Mean clip $TRMM2B31_1998_2009_EEVENT_NR_NWArg"
    gmt grdcut -R$REGION $TRMM2B31_1998_2009_EEVENT_NR -G$TRMM2B31_1998_2009_EEVENT_NR_NWArg
fi

if [ ! -e $TRMM2B31_1998_2009_EEVENT_NR_NWArg_rTOPO15 ]
then
    echo "resample TRMM2B31 Mean Clip $TRMM2B31_1998_2009_EEVENT_NR_NWArg_rTOPO15"
    gmt grdsample $TRMM2B31_1998_2009_EEVENT_NR_NWArg -R$REGION -I3601+/4801+ -G$TRMM2B31_1998_2009_EEVENT_NR_NWArg_rTOPO15
fi

## CREATE Topographic map
#Set Parameters for Plot
POSTSCRIPT_BASENAME=NWArg
#xmin/xmax/ymin/ymax
WIDTH=10
XSTEP=10
YSTEP=10
DPI=300
CITY_STAR_SIZE=0.4c

TITLE="Topo NW Arg"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_topo.ps
#Make colorscale
DEM_CPT=relief_color.cpt
gmt makecpt -T-8000/5000/250 -D -Cmby >$DEM_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TOPO15_GRD_NC -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$DEM_CPT -R$TOPO15_GRD_NC -Q  -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
#gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne+t"$TITLE" -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.2c -Gblack -K -O -P >> $POSTSCRIPT1
gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthick,darkblue -K -O -P >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,white -Gblack -K -O -P >> $POSTSCRIPT1
gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+o1.0c/-2.0c/+w5c/0.3c -C$DEM_CPT -F+gwhite+r1p+pthin,black -Baf -By+l"Elevation (m)" --FONT=8p --FONT_ANNOT_PRIMARY=6p --MAP_FRAME_PEN=0.5p --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg

TITLE="NDVI - NW Arg"
POSTSCRIPT1=${POSTSCRIPT_BASENAME}_ndvi.ps
#Make colorscale
NDVI_CPT=ndvi_color.cpt
#gmt makecpt -T0.0/0.8/0.042 -D -Cprecip4_diff_19lev >$NDVI_CPT
gmt makecpt -T0.0/0.8/0.067 -D -Cprecip_diff_12lev.cpt >$NDVI_CPT
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $MOD13A3_NDVI_CentralAndes_rTOPO15 -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$NDVI_CPT -R$TOPO15_GRD_NC -Q -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -Swhite -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -P -K >> $POSTSCRIPT1
gmt psxy $OSM_CentralAndeslakes -R -J -L -Wfaint,lightblue -Glightblue -K -O -P >> $POSTSCRIPT1
#gmt psxy $OSM_CentralAndesvolcano -R -J -L -St0.15c -Gred -K -O -P >> $POSTSCRIPT1
gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthin,darkblue -K -O -P >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
echo "A" | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -C0.2c -F+cTL+f24p,Helvetica-Bold --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -P -O -K >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+o-1.0c/-2.0c/+w6c/0.3c -C$NDVI_CPT -F+gwhite+r1p+pthin,black -Baf -By+l"NDVI" --FONT=8p --FONT_ANNOT_PRIMARY=8p --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg
#convert -quality 100 -density 150 $POSTSCRIPT1 ${POSTSCRIPT1::-3}.jpg

POSTSCRIPT1=${POSTSCRIPT_BASENAME}_trmm2b31.ps
#Make colorscale
RAINFALL_CPT=rainfall_color.cpt
#gmt makecpt -T0.0/2000/167 -D -Cprecip_diff_12lev >$RAINFALL_CPT
gmt makecpt -T0.0/2000/182 -D -Cprecip_11lev >$RAINFALL_CPT
TITLE="Rainfall - NW Arg"
echo " "
echo "Creating file $POSTSCRIPT1"
echo " "
gmt grdimage $TRMM2B31_1998_2009_MM_PER_YR_NWArg_rTOPO15 -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$RAINFALL_CPT -R$TOPO15_GRD_NC -Q -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -P -K >> $POSTSCRIPT1
gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthin,darkblue -K -O -P >> $POSTSCRIPT1
gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
#gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
echo "B" | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -C0.2c -F+cTL+f24p,Helvetica-Bold -P -O -K >> $POSTSCRIPT1
gmt psscale -R -J -DjBC+o-3.0c/-2.0c/+w7c/0.3c -C$RAINFALL_CPT -F+gwhite+r1p+pthin,black -Baf -By+l"Mean annual rainfall 1998-2014 (mm/yr)" --FONT=8p --FONT_ANNOT_PRIMARY=8p --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
gmt psconvert $POSTSCRIPT1 -A -P -Tg


# POSTSCRIPT1=${POSTSCRIPT_BASENAME}_trmm2b31_eevents.ps
# #Make colorscale
# RAINFALL_CPT=rainfall_color.cpt
# #gmt makecpt -T0.0/2000/167 -D -Cprecip_diff_12lev >$RAINFALL_CPT
# gmt makecpt -T0.0/5/0.3 -D -CBlueDarkRed18 >$RAINFALL_CPT
# TITLE="EEvents - NW Arg"
# echo " "
# echo "Creating file $POSTSCRIPT1"
# echo " "
# gmt grdimage $TRMM2B31_1998_2009_EEVENT_NR_NWArg_rTOPO15 -I$TOPO15_GRD_HS_NC -JM$WIDTH -C$RAINFALL_CPT -R$TOPO15_GRD_NC -Q -Xc -Yc -E$DPI -K -P > $POSTSCRIPT1
# gmt pscoast -Bx$XSTEP -By$YSTEP -BWSne -W1/thin,black -R -J -N1/thin,black -O -Df --FORMAT_GEO_MAP=ddd:mm:ssF --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -P -K >> $POSTSCRIPT1
# gmt psxy $AltiplanoPuna_1bas -R -J -L -Wthin,white -K -O -P >> $POSTSCRIPT1
# gmt psxy SdC.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
# #gmt pstext SdC.txt -D-0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
# gmt psxy lapaz.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
# #gmt pstext lapaz.txt -D+0.9c/0.2c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
# gmt psxy salta.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
# #gmt pstext salta.txt -D+0.8c/0.0c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
# gmt psxy mendoza.txt -Sa${CITY_STAR_SIZE} -R -J -L -Wthin,black -Gblack -K -O -P >> $POSTSCRIPT1
# #gmt pstext mendoza.txt -D+1.0c/-0.5c -F+f12p,Helvetica -W0.1p,black -Gwhite -R -J -K -O -P >> $POSTSCRIPT1
# echo "C: EEvents" | gmt pstext -R -J -D0.1c/-0.1c -W0.5p,black -C0.2c -F+cTL+f24p,Helvetica-Bold -P -O -K >> $POSTSCRIPT1
# gmt psscale -R -J -DjBL+o1.3c/6.0c/+w5c/0.3c -C$RAINFALL_CPT -F+gwhite+r1p+pthin,black -Baf -By+l"EEvents (#/yr)" --FONT=8p --FONT_ANNOT_PRIMARY=8p --MAP_FRAME_PEN=0.5p,black --MAP_FRAME_WIDTH=0.1 -O -P >> $POSTSCRIPT1
# gmt psconvert $POSTSCRIPT1 -A -P -Tg


# COMBINE plots with imagemagick
convert -quality 50 -density 150 ${POSTSCRIPT_BASENAME}_ndvi.png ${POSTSCRIPT_BASENAME}_trmm2b31.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_ndvi_rainfall.jpg

convert -quality 100 -density 300 ${POSTSCRIPT_BASENAME}_ndvi.png ${POSTSCRIPT_BASENAME}_trmm2b31.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_ndvi_rainfall.png

# convert -quality 50 -density 150 ${POSTSCRIPT_BASENAME}_trmm2b31.png ${POSTSCRIPT_BASENAME}_trmm2b31_eevents.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_trmm2b31_rainfall_eevents.jpg
# 
# convert -quality 100 -density 300 ${POSTSCRIPT_BASENAME}_trmm2b31.png ${POSTSCRIPT_BASENAME}_trmm2b31_eevents.png -fuzz 1% -trim -bordercolor white -border 10x0 +repage +append ${POSTSCRIPT_BASENAME}_trmm2b31_rainfall_eevents.png
