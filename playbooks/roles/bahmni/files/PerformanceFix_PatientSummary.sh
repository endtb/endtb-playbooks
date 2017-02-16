#!/bin/bash

original_filename='/var/www/bahmniapps/common/displaycontrols/tabularview/views/obsToObsFlowSheet.html'
original_md5='8c9cf5cbd3b32a51d32987c7985c8254'
patched_md5='b037ef310e4dd7d854c70cee578e8a72'

echo 'Verifying existing file...'
current_md5=`md5sum $original_filename | cut -c 1-32`

if [[ $current_md5 == $original_md5 ]]; then
        echo 'Making backup of existing file...'
        cp $original_filename $original_filename'.backup'

        echo 'Patching file...'
        sed -i 's/{{getHeaderName/{{::getHeaderName/g' $original_filename
        sed -i 's/{{commafy/{{::commafy/g' $original_filename

        echo 'Verifying patched file...'
        current_md5=`md5sum $original_filename | cut -c 1-32`

        if [[ $current_md5 == $patched_md5 ]]; then
                echo 'SUCCESS: File patched successfully.'
                exit 0
        else
                echo 'ERROR: patched file does not match expectations.'
                exit 1
        fi
else
        echo 'ERROR: File to be patched does not match expectations.'
        exit 1
fi
