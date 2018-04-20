FROM redis:4.0.9

ADD ./scripts/start-sentinel.sh /root
ADD ./scripts/notification-script.sh /root
ADD ./scripts/client-reconfig-script.sh /root

RUN chmod +x /root/start-sentinel.sh
RUN chmod +x /root/notification-script.sh
RUN chmod +x /root/client-reconfig-script.sh

EXPOSE 26379

ENTRYPOINT ["/root/start-sentinel.sh"]