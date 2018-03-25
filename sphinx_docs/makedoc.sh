#!/bin/bash

echo "################################################################################################################"

/usr/local/bin/ansigenome gendoc ../roles

echo "################################################################################################################"

mkdir -p ./source/roles
roles=$(find ../roles -type f | grep "README.rst" | gawk -F "/" '{print $3}')

for rolename in $roles
do
	echo "Copy readme for $rolename"
	cp ../roles/$rolename/README.rst ./source/roles/$rolename.rst
done

echo "################################################################################################################"

make html

echo "################################################################################################################"

which ansigenome
cd ../roles/

echo "==== Generate FLEP dependencies graph"
list=$(find . -type d -name "flep_*" | cut -d "/" -f 2 | grep -v "\." | while read x; do echo -en "$x,"; done | sed 's/,$//')
echo "$list"
/usr/local/bin/ansigenome export ./ -s 20,10 -d 300 -o ../sphinx_docs/build/html/flep_dependencies.png -l "$list"

echo "==== Generate Other dependencies graph"
list=$(find . -type d -maxdepth 1| grep -vi "flep_.*" | cut -d "/" -f 2 | grep -v "\." | while read x; do echo -en "$x,"; done | sed 's/,$//' )
echo "$list" 

/usr/local/bin/ansigenome export ./ -s 20,10 -d 300 -o ../sphinx_docs/build/html/dependencies.png -l "$list"

cd ../sphinx_docs/build/html
tar -zcvf ansibledoc.tar.gz *