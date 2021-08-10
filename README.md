# TVM_interpolation_tools
This tool help interpolate velocity model from [Taiwan Velocity Models](https://tecdc.earth.sinica.edu.tw/TWtomo/VerticalProfile.php).

## Data and Citation
[Model Information](https://tecdc.earth.sinica.edu.tw/TWtomo/ModelInfo.php)

## Prerequisite
- [C shell](https://help.sap.com/viewer/d1d04c0d65964a9b91589ae7afc1bd45/2020.0/en-US/dffd295dc2b0462ca9e265e32f30d940.html)
- [GMT6](https://github.com/GenericMappingTools/gmt)
- [ImageMagick convert](https://imagemagick.org/script/convert.php)

## Usage
### preprocess
- put velocity model text file in the /data/[velocity model]/
- revise velocity model to the following format
```
# model.Vp.txt
longitude latitude depth Vp

# model.Vs.txt
longitude latitude depth Vs

# model.VpVs.txt
longitude latitude depth VpVs
```
### process
The result will be stored in the /statistics/[velocity model]/.
- run /process/interpolate_surface.csh
```
csh interpolate_surface.csh [model.txt] [Vp/Vs/VpVs] [interval] [unit] [tension_factor] [blockmean]
e.g. interpolate_surface.csh ../data/RAU1995/RAU1995.Vp.txt Vp 10 m 0.25 1"
# It will interpolate the velocity model with surface command.
# [unit]: (d)egree [Default], (m)inute, (s)econd, m(e)ter, (f)oot, (k)ilometer, (M)ile
# [tension_factor]: 0 ~ 1"
# [blockmean]: 0 or 1"
```
### plot
The figures will be stored in the /plot/[velocity model]/.
- /plot/mapview.gmt: the velocity model distribution
- /plot/mapview_compare.gmt: the differences of model distribution between raw data and interpolated data
- /plot/contour.gmt: the contour of velocity model
- /plot/contour_compare.gmt: the differences of contour between raw data and interpolated data
- /plot/map_profile.gmt: the mapview of profile of the velocity model
- /plot/profile.csh: the profile of the velocity model
- /plot/profile_compare.gmt: the differences of profile between raw data and interpolated data

### results
<table align="center">
   <tr>
      <td> <img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/mapview/Vp/10m/RAU1995_Vp_I10m_T0.25_blockmean.mapview.jpg?raw=true" width="100%"></td>
      <td><img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/mapview/Vp/10m/RAU1995.mapview.compare.jpg?raw=true" width="100%"></td>
   </tr>
   <tr>
      <td>mapview</td>
      <td>mapview_compare</td>
   </tr>
      <tr>
      <td> <img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/contour/Vp/10m/RAU1995_Vp_I10m_T0.25_blockmean_D0.contour.jpg?raw=true" width="100%"></td>
      <td><img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/contour/Vp/10m/RAU1995.Vp.D0m.contour.compare.jpg?raw=true" width="100%"></td>
   </tr>
   <tr>
      <td>contour</td>
      <td>contour_compare</td>
   </tr>
      <tr>
      <td> <img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/profile/Vp/10m/RAU1995_profile_120_24_122_24_map.jpg?raw=true" width="100%"></td>
      <td><img src="https://github.com/IESDMC/TVM_interpolation_tools/blob/main/plot/RAU1995/profile/Vp/10m/RAU1995_profile_120_24_122_24_W20km.compare.jpg?raw=true" width="100%"></td>
   </tr>
   <tr>
      <td>map_profile</td>
      <td>profile_compare</td>
   </tr>
</table>

## Command used
- coast
- plot
- pscontour
- colorbar
- text
- psxy
- makecpt
- basemap
- blockmean
- surface
- grd2xyz
