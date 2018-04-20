FROM redis:4.0.9
ADD ./scripts/start-server.sh /root
ADD ./config/defaults.conf /root
RUN chmod +x /root/start-server.sh
EXPOSE 6379
ENTRYPOINT ["/root/start-server.sh"]