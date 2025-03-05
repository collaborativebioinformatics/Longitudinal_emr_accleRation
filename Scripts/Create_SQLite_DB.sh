#! /usr/bin/bash

# originally written for dnanexus use, where bash is in /usr/bin
# and not /bin like on my system ...
# and the MIMIC dataset is pulled to a node in a single folder named 'MIMIC'
# hypothetically this can serve as a template for any similar scenario
# if sqlite3 is not present
# apt-get sqlite or whatever your environment package manager is

arg1="MIMIC"
arg2='.csv'
arg3="mimic3_v3.sqlite"

targets=$(find "${arg1}" -type f -iname "*${arg2}" | sed 's/^\.\///g' | sort)
# echo ${targets}

for m1 in ${targets}; do
  echo "${m1}"
  m2=${m1%.csv}
  m3=${m2##*/}
  sqlite3 -csv "${arg3}" ".import ${m1} ${m3}"
done

echo "done!"
