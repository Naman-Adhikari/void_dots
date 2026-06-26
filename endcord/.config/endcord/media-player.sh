#!/bin/bash  
file="$1"  
hint="$2"  
  
if [ "$hint" = "img" ] || [ "$hint" = "gif" ]; then  
    imv "$file"  
else  
    mpv "$file"  
fi
