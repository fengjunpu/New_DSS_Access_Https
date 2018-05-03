#Dockerfile
FROM daocloud.io/geyijun/open_resty:v0.07
MAINTAINER geyijun<geyijun@xiongmaitech.com>

COPY supervisord.conf /etc/supervisord.conf
COPY libjson_linux-gcc-4.4.7_libmt.so /usr/lib64/
COPY conf/ /xm_workspace/xmcloud3.0/DssAccessServer/
COPY libmatch.so /xm_workspace/xmcloud3.0/DssAccessServer/
COPY libmatchisp.so /xm_workspace/xmcloud3.0/DssAccessServer/
COPY isp_ip.json /xm_workspace/xmcloud3.0/DssAccessServer/
COPY dss_access_server /xm_workspace/xmcloud3.0/DssAccessServer/
COPY *.sh /xm_workspace/xmcloud3.0/DssAccessServer/

RUN chmod 777 /xm_workspace/xmcloud3.0/DssAccessServer/*

WORKDIR /xm_workspace/xmcloud3.0/DssAccessServer/

EXPOSE 6601 6501
CMD ["supervisord"]
