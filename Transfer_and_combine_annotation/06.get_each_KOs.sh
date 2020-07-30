for f in `ls *.annotation.txt | grep -v 'total.annotation'`
do
n=$(basename $f .annotation.txt)
cat $f | cut -f 2 | sort -u > $n.KOs.txt
done
