#!/bin/bash

#############################
#
# Resample image content in PDF
#
# Usage:
#
#    resample_pdf.sh -i <input file> -r <resample_resolution> -o <output_file>
#
#############################

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ -z "$ARG_i" ] && [ -z "$ARG_o" ] && [ -z "$ARG_r" ]; then
	echo "usage:  resample-pdf.sh -i <input_file> -r <resample_resolution> -o <output_file>"
else
	gs \
	  -o $ARG_o \
	  -sDEVICE=pdfwrite \
	  -dPDFSETTINGS=/prepress \
	  `# font settings` \
	  -dSubsetFonts=true \
	  -dCompressFonts=true \
	  `# color format` \
	  -sProcessColorModel=DeviceRGB \
	  -sColorConversionStrategy=sRGB \
	  -sColorConversionStrategyForImages=sRGB \
	  -dConvertCMYKImagesToRGB=true \
	  `# image resample` \
	  -dDetectDuplicateImages=true \
	  -dDownsampleColorImages=true -dDownsampleGrayImages=true -dDownsampleMonoImages=true \
	  -dColorImageResolution=$ARG_r -dGrayImageResolution=$ARG_r -dMonoImageResolution=$ARG_r \
	  `# preset overrides` \
	  -dDoThumbnails=false \
	  -dCreateJobTicket=false \
	  -dPreserveEPSInfo=false \
	  -dPreserveOPIComments=false \
	  -dPreserveOverprintSettings=false \
	  -dUCRandBGInfo=/Remove \
	  -f $ARG_i
fi