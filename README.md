# !!!!!!!!!!!!!!!!!!!!!!!!
# ARCHIVED
**THIS TOOLS WILL BE MOVED TO OTHER REPOSITORY OR REMOVED COMPLETELY SOON**
**IF YOU RELY ON THIS TOOLKIT, PLEASE CONTACT ME: daniel.gomez.sanchez@hotmail.com**
# !!!!!!!!!!!!!!!!!!!!!!!!

CallableGenome
==============

This repository contains a bash script to compute the callable genome using the
[GEM-library](http://algorithms.cnag.cat/wiki/The_GEM_library) that should be
install in the $PATH.

It use a stand-alone java program (in the java folder)
that parse the [mappability output](algorithms.cnag.cat/wiki/FAQ:The_GEM_mappability_format)
and compute the ranges of gaps from a FASTA file. For it usage as stand-alone:

```
java -jar java/MappabilityTools.jar

```

## License

The script with the pipeline and the java program are under a 
[MIT license](http://opensource.org/licenses/MIT).
