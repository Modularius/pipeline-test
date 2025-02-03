#cat archive/incoming/hifi_1/logs/digitiser-aggregator.log | grep earlier > LogAnalysis/temp
#cat LogAnalysis/temp | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" > LogAnalysis/temp1
#cat LogAnalysis/temp1 | awk -f LogAnalysis/logs.awk > LogAnalysis/temp2
cat LogAnalysis/temp2 | awk '!/ , /' > LogAnalysis/temp3