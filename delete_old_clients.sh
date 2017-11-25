#!/bin/bash

################################################

### variables needed, some of them defined on prompt
################################################
dnesni_datum=$(date +%Y-%m-%d)
echo -n “—————————————- 
Insert Avamar server domain to be searched:”
read domena
echo “Define start date in format YYYY-MM-DD:”
read start_date
echo “Define end date in format YYYY-MM-DD:”
read end_date
echo -n “—————————————-”
echo -e “\n”
echo “From: $start_date”;
echo “To: $end_date”;
echo “domain to be searched is $domena”;

#############################################################

## listing all clients having no backup between start/end date and writing them into log
#############################################################
for klienti in $(mccli client show –domain=$domena –recursive=true | grep -o “\w*.cpas.\w*”) 
do
    if (( $(mccli backup show –after=$start_date –before=$end_date –name=$domena/$klienti | tail -n +4 | wc -l) < 2 )) ;
        then
                echo “$klienti” | grep -o “\w*.cpas.\w*” >> BackupClients-$dnesni_datum-DeleteLog ;
              else echo “$klienti ma bekap” ;
    fi
done

############################################################

## would you really wanna delete those clients? – check the file zoznam first

############################################################

echo “Success. There is file with clients with no backup between $start_date and $end_date. I recommend to see BackupClients-$dnesni_datum-DeleteLog prior deleting. (for deleting choose YES or NO):”
read potvrzeni

case $potvrzeni in
 
 YES)
  echo “Starting deletion”
  ;;
 NO)
  echo “Cancelling deletion and leaving”
  exit 1
  ;;
 *) echo “YES or NO – case sensitive! Exiting now.”
  exit 1 
  ;;

esac
  
############################################################

### lets go, deleting clients from avamar server

############################################################

while read line
do
echo “$line”
mazani=”mccli client delete –name=$domena/$line”
eval $mazani
done < BackupClients-$dnesni_datum-DeleteLog
