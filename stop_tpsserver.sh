#!/usr/bin/env bash

progam_name='dss_access_server'

pnum=`ps -ef|grep "./${progam_name}"|grep -v grep|awk 'END{print NR}'`
if [[ ${pnum} > 0 ]]; then
    ps -ef|grep "./${progam_name}"|grep -v grep|awk '{print $2}'|while read pid
    do
        echo -e "\033[31;40mPid: ${pid} - killed\033[31;0m"
        kill -9 ${pid}
    done
else
    echo -e "\033[31;40mPid: process no exting.\033[31;0m"
fi

exit 0

