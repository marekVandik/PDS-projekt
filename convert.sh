#!/bin/sh

for f in *.svg; do
  inkscape "$f" --export-type=eps --export-filename="${f%.svg}.eps"
done
