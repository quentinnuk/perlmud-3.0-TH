cp $1.dm $1.db
perl muddltoperl.pl $1
cp $1.db ../telehack/2.0/data/mud/mud.db
