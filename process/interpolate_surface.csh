#!/bin/csh

# Input arguments
if($#argv != 6) then
  echo
  echo "interpolate_surface.csh [model.txt] [Vp/Vs/VpVs] [interval] [unit] [tension_factor] [blockmean]"
  echo "-EX: interpolate_surface.csh ../data/RAU1995/RAU1995.Vp.txt Vp 10 m 0.25 1"
  echo "-It will intepolate the velocity model with surface command."
  echo "[unit]: (d)egree [Default], (m)inute, (s)econd, m(e)ter, (f)oot, (k)ilometer, (M)ile"
  echo "[tension_factor]: 0 ~ 1"
  echo "[blockmean]: 0 or 1"
  echo
  exit 1
endif

# Parameters settings
set input_file = $1
set velocity_type = $2
set interval = $3
set unit = $4
set tension = $5
set is_blockmean = $6

# Path
set base_dir = `pwd | awk -F'/process' '{print $1}'`
set input_file_tmp = `echo $input_file | awk -F'data/' '{print $2}'`
set input_file_path = $base_dir/data/$input_file_tmp
set tmp_depth = './temp_depth.txt'
set tmp_ready4surface = './temp_ready4surface.xyz'

# Geographic location
set gmtinfo_content = `gmt gmtinfo $input_file_path`
set beglo = `echo $gmtinfo_content | awk -F'<' '{print $2}' | awk -F'/' '{print $1}'`
set endlo = `echo $gmtinfo_content | awk -F'<' '{print $2}' | awk -F'/' '{print $2}' | awk -F'>' '{print $1}'`
set begla = `echo $gmtinfo_content | awk -F'<' '{print $3}' | awk -F'/' '{print $1}'`
set endla = `echo $gmtinfo_content | awk -F'<' '{print $3}' | awk -F'/' '{print $2}' | awk -F'>' '{print $1}'`
echo $beglo $endlo $begla $endla

# Processing
set input_file_name = `echo $input_file_path | awk -F'/' '{print $(NF-1)}'`
set depth_array = `awk '{print $3}' $input_file_path | sort -u -n`
set output_dir = $base_dir/statistics/$input_file_name
set velocity_type_folder = $output_dir/$velocity_type
set interval_folder = $velocity_type_folder/$interval$unit
set prefix = $input_file_name\_$velocity_type\_I$interval$unit\_T$tension
if ( ! -d $output_dir ) mkdir $output_dir
if ( ! -d $velocity_type_folder ) mkdir $velocity_type_folder
if ( ! -d $interval_folder ) mkdir $interval_folder
cd $interval_folder

foreach dep ($depth_array)
  if ( $is_blockmean == 1 ) then
    set prefix_dep = $prefix\_blockmean_D$dep\m
  else
    set prefix_dep = $prefix\_D$dep\m
  endif
  set grd = $prefix_dep.grd
  set xyz = $prefix_dep.xyz
  set xyzd = $prefix_dep.xyzd
  
  awk '{if($3 == dep ){print $1,$2,$4}}' dep=$dep $input_file_path > $tmp_depth
  if ( $is_blockmean == 1 ) then
    # blockmean: pre-processor before running surface to avoid aliasing short wavelengths
    gmt blockmean $tmp_depth -R$beglo/$endlo/$begla/$endla -I$interval$unit > $tmp_ready4surface
  else
    mv $tmp_depth $tmp_ready4surface
  endif
  # To grid 6 by 6 minute velocity from the data in $tmp_ready4surface, using a tension_factor = 0.25, a convergence_limit = 0.1 milligal, writing the result to a file called $xyz, and monitoring each iteration
  gmt surface $tmp_ready4surface -R$beglo/$endlo/$begla/$endla -I$interval$unit -T$tension -C0.1 -Vl -Lld -Lud -G$grd
  gmt grd2xyz $grd -R$beglo/$endlo/$begla/$endla > $xyz
  awk '{printf ("%0.6f %0.6f %0.2f %0.2f\n",$1,$2,dep,$3)}' dep=$dep $xyz > $xyzd
  rm -f $tmp_depth $tmp_ready4surface
end

# Merge & sort
if ( $is_blockmean == 1 ) then
  set merged_file = $prefix\_blockmean.merged
  set sorted_file = $prefix\_blockmean.sorted
  set complete_file = $prefix\_blockmean.txt
  cat ./*_$velocity_type\_I$interval$unit\_T$tension\_blockmean_D*m.xyzd > $merged_file
else
  set merged_file = $prefix.merged
  set sorted_file = $prefix.sorted
  set complete_file = $prefix.txt
  cat ./*_$velocity_type\_I$interval$unit\_T$tension\_D*m.xyzd > $merged_file
endif
awk '{print $1,$2,$3,$4}' $merged_file | sort -k1 -k2 -k3 -n > $sorted_file
set z = `awk '{print $3}' $sorted_file | sort -u | wc -l`
set y = `awk '{print $2}' $sorted_file | sort -u | wc -l`
set x = `awk '{print $1}' $sorted_file | sort -u | wc -l`
echo "Dimension: $x $y $z" > $complete_file
echo "lon      lat     dep $velocity_type" >> $complete_file
awk '{print $1,$2,$3,$4}' $sorted_file >> $complete_file
