#/bin/bash

LIST=$(cat tasks/*.yml | grep "\- name:" | cut -d : -f 2 | sed 's/\"//g;s/^ /test_/g;s/ /_/g;s/[][{}\.]//g' | tr '[:upper:]' '[:lower:]')
TOT=0
K=0
F=0
for i in $LIST; do
    TOT=$((TOT +1))
    l=$(grep $i tests/*.py)
    if [ $? -eq 0 ]; then
        echo "OK     :   $i"
        K=$((K+1))
    elif [ $? -gt 0 ]; then
        echo "MISS   :   $i"
        F=$((F+1))
    fi
done
echo
echo "Test Coverage $((K*100/$TOT))%   [Total $TOT, OK $K, missed $F ]"
