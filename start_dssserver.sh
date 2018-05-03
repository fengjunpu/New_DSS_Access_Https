#!/usr/bin/env bash
# author : 
# purpose:

#下面的信息要根据实际情况来修改
progam_name='dss_access_server'
serve_ip='127.0.0.1'
serve_port='6601'
status_redis_addr='redis4status-dss.secu100.net'
status_redis_port='5121'
auth_redis_addr='redis4auth-dss.secu100.net'
auth_redis_port='5111'
#cfg_redis_addr='redis4cfg.secu100.net'

interval_time='120'

# 通过dnspod或者138获取自己的外网IP
if [ ! -e .curlip ]; then
    (curl ns1.dnspod.net:6666 > .curlip)&>/dev/null
fi
serve_ip=`cat .curlip 2>/dev/null`
if [ -z ${serve_ip} ]; then
    (curl http://www.ip138.com/ips1388.asp > .curlip)&>/dev/null
    serve_ip=`cat .curlip 2>/dev/null|grep -oP '(?<=ip=)\d+\.\d+\.\d+\.\d+(?=")'`
    (echo ${serve_ip} > .curlip) &>/dev/null
fi
echo "---serve_ip = ${serve_ip}---"

# 通过ping来获取域名对应的IP
#redis_addr=`ping ${redis_addr} -s 1 -c 1 | grep -oP '\d+\.\d+\.\d+\.\d+' | head -n 1`
#echo "---redis_addr11 = ${redis_addr}---"
#if [ -z ${redis_addr} ]; then
#		echo "---redis_addr is empty---"
#		exit 0
#fi
#echo "---redis_addr = ${redis_addr}---"

# 通过dig来获取域名对应的IP (因为ping容器中没有)
#author: ZHANGCHENG
#2014/07/30
function gethostip()
{
	result=`dig +short $1 | awk 'NR==1{print $0}'`
	url=$1
	num=`echo $result | grep -E "^(([0-2]*[0-9]+[0-9]+)\.([0-2]*[0-9]+[0-9]+)\.([0-2]*[0-9]+[0-9]+)\.([0-2]*[0-9]+[0-9]+))$" | wc -l`
	if [ $num -eq 0 ];then
		#echo "This is CNAME"
		gethostip $result
	else
		dig +short $url
	fi
}
status_redis_addr=`gethostip ${status_redis_addr}`
echo "---status_redis_addr = ${status_redis_addr}---"
if [ -z ${status_redis_addr} ]; then
		echo "---status_redis_addr is empty---"
		exit 0
fi

auth_redis_addr=`gethostip ${auth_redis_addr}`
echo "---auth_redis_addr = ${auth_redis_addr}---"
if [ -z ${auth_redis_addr} ]; then
	echo "---cfg_redis_addr is empty---"
	exit 0
fi

self_pid=$(ps -ef|grep "start_dssserver.sh"|grep -v grep|awk '{print $2}')
echo "------------ ${progam_name} ${serve_ip} ${serve_port} ${status_redis_addr} ${status_redis_port} ${interval_time}---------"
pnum=`ps -ef|grep "./${progam_name}"|grep -v grep|awk 'END{print NR}'`
if [[ ${pnum} > 0 ]]; then
    ps -ef|grep "./${progam_name}"|grep -v grep|awk '{print $2}'|while read pid
    do
        echo -e "\033[31;40mPid: ${pid} - killed\033[31;0m"
        kill -9 ${pid}
    done
	#	echo -e "\033[31;40mPid: `pidof ${progam_name}` - startd\033[31;0m"
    ./${progam_name} ${serve_ip} ${serve_port} ${status_redis_addr} ${status_redis_port}
else
   #	echo -e "\033[31;40mPid: `pidof ${progam_name}` - startd\033[31;0m"
    ./${progam_name} ${serve_ip} ${serve_port} ${status_redis_addr} ${status_redis_port}
fi

kill -9 ${self_pid}
exit 0

