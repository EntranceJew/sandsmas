#!/bin/bash
nowpath=$( dirname "${BASH_SOURCE[0]}" );
nowpath="${nowpath#./}";
rm -rf "docs";
mkdir -p "docs";
echo "<ul>" > "docs/index.html";
IFS=$'\n';
excludes="";
for f in $(find . -wholename './main.lua' -or -wholename '*/src/*.lua' -or -wholename '*/lasagna/*.lua'); do
	thepath=$(dirname "$f")
	filename=$(basename "$f" ".lua")
	
	infile="$thepath/$filename.lua";
	infile="${infile#./}";
	outpath="docs/${thepath#./}";
	outfile="$outpath/$filename.html";
	
	docfile="${thepath#./}/$filename.lua";
	docfile="${docfile#./}";
	docpath="${outfile#docs/}";
	if [ -f "$f" ]; then
		echo "<li><a href=\"$docpath\">$docfile</a></li>" >> "docs/index.html";
		
		mkdir -p "$outpath";
		lua "$nowpath/rtfm/rtfm.lua" "$infile" > "$outfile";
	fi;
done
echo "</ul>" >> "docs/index.html";