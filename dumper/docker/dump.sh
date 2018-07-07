#!/usr/bin/env bash

set -e

ls -l /home/$(whoami)/data
LAYERS=();
mkdir -p $(pwd)/data/image && tar -xf $(pwd)/data/image.tar -C $(pwd)/data/image
for layer in $(pwd)/data/image/*/layer.tar; do
    echo layer: ${layer};

    for element in $(tar -tf ${layer} | grep -E '^dev/.*' | sort -r -n); do echo delete ${element}; tar --delete -f ${layer} "${element}" || echo error on delete ${element}; done
    #for element in $(tar -tf ${layer} | grep -E '^etc/'   | sort -r -n); do echo delete ${element}; tar --delete -f ${layer} "${element}" || echo error on delete ${element}; done

    if [ -n "$(tar -tf ${layer} | grep 'glibc-compat')" ]; then echo found glibc-compat in ${layer}; LAYERS+=(${layer}); fi
done

echo -e "merge layers '${LAYERS[@]}' into one\n"
if [ ${#LAYERS[@]} -gt 0 ]; then tar Af ${LAYERS[@]}; fi
echo -e "layers merged into ${LAYERS[0]} $(du -sh ${LAYERS[0]})\n"

echo copy ${LAYERS[0]} to $(pwd)/data/layer.tar
cp -f ${LAYERS[0]} $(pwd)/data/layer.tar

echo find empty directories
tar_entries=($(tar tf data/layer.tar))
tar_directories=($(tar tf data/layer.tar | grep -E '.*/$' | grep -v 'glibc-compat' | sort -r -n))
tar_empty_directories=()
for directory in ${tar_directories[@]}; do
    if [ -z "$(printf -- '%s\n' "${tar_entries[@]}" | grep -E "${directory}.+")" ]; then tar_empty_directories+=(${directory}); fi
done
echo tar_empty_directories
printf -- '%s\n' "${tar_empty_directories[@]}"
#tar --delete -f data/layer.tar ${tar_empty_directories[@]}

sudo mkdir -p /data/root && sudo chown -R $(whoami):$(id -gn) /data && tar xf $(pwd)/data/layer.tar -C /data/root/
rm -rf $(pwd)/data/image && sudo rm -f $(pwd)/data/image.tar

rm -rf /data/root/data
rm -rf /data/root/etc/apk
rm -rf /data/root/lib/apk

# /data/root/usr/bin/* no such file or directory
if [ -L /data/root/usr/bin/strings ]; then
    mv /data/root/usr/bin/strings /data/root/strings;
    rm -rf /data/root/usr/bin; mkdir -p /data/root/usr/bin
    mv /data/root/strings /data/root/usr/bin/strings
else
    rm -rf /data/root/usr/bin
fi

rm -rf /data/root/usr/lib

# /data/root/usr/x86_64-alpine-linux-musl: no such file or directory
if [ -d /data/root/usr/bin ]; then
    mv /data/root/usr/bin /data/root/bin
    mv /data/root/usr/glibc-compat /data/root/glibc-compat
    rm -rf /data/root/usr; mkdir -p /data/root/usr
    mv /data/root/bin /data/root/usr/bin
    mv /data/root/glibc-compat /data/root/usr/glibc-compat
fi

rm -rf /data/root/var
