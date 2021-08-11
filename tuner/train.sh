#!/bin/bash

clear

beginTime=$(date +%s%N)

# initiate the comp_results.csv file
sshpass -p 1423 ssh jieun@10.178.15.229 "echo "index,TIME,RATE,WAF,SA" > comp_results.csv"

for (( i=16; i<=21; i++ ))
do
    let cal_num=$i-16
    best_configs_file_name="20210810/best_config-20210810-0$cal_num.csv"
    # train model and get the best configuration
    python train.py --mode "multi" --exmetric "SCORE" --iscombined true --target $i
    # parsing the best configuration with the form of .cnf
    python parse_best_conf.py --n ./final_solutions/$best_configs_file_name
    # send the best configuration to the test server (data-generation-28)   
    sshpass -p 1423 scp /home/jieun/RS-OtterTune/tuner/config0.cnf jieun@10.178.15.229:/home/jieun/data_generation_rocksdb/conf_tmp/
    # test the best configuration on the test server (data-generation-28)
    sshpass -p 1423 ssh jieun@10.178.15.229 ./testing.sh $i
done

endTime=$(date +%s%N)
elapsed=`echo "($endTime - $beginTime) / 1000000" | bc`
elapsedSec=`echo "scale=2;$elapsed / 1000" | bc | awk '{printf "%d", $1}'`
echo 
echo TOTAL: $elapsedSec sec
echo 