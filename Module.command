#! /bin/bash
cd "${0%/*}"
dest=$0
moduleWithExtension=${dest##*/}
module=${moduleWithExtension%.*}
ECHO "module name: [$module]"
./ViperGenerator.swift $module