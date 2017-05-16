#!/bin/bash

if [ $EUID -gt 0 ] ; then
        echo "Must be root to run this script"
        exit 5
fi

 if [ -z "$(df -P /var | tail -n1 |grep /var)" ]; then
        echo "Var partition is not on it's own Mountpoint"
        exit
else
        vardev=$( df -P /var  |tail -n1 | gawk '{print $1}')
        varsize=$(df -P /var  |tail -n1 | gawk '{print $2}')
        varvg=$(echo $vardev  | sed  -e {s#^/dev/mapper/##} -e {s#-.*##})
        vgfree=$(vgdisplay $varvg --units k  -C -o vg_free  --noheadings --nosuffix)
        output_file=/tmp/var-resize-$(hostname)

        if [ $varsize -lt 2556656 ] ; then
                if [ ${vgfree%.??} -gt 2556656 ] ; then
                        echo "Resizing volume /var on $vardev " >> $output_file
                        echo "Resizing volume /var on $vardev "
                        lvresize -L +1.5G $vardev >> $output_file
                        sleep 5
                        resize2fs $vardev >> $output_file
                else
                        echo "Var is less than 2 GB but not enough space exists in $varvg " >> $output_file
                        echo "Var is less than 2 GB but not enough space exists in $varvg "
                        exit 200
                        vgdisplay $varvg >> $output_file
                fi

                curl -F filename=@$output_file http://lyn-rhnsat-01/cgi-bin/upload.pl > /dev/null

        fi
fi
