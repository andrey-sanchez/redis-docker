FROM openjdk:8u151-jre-alpine

ENV VERSION 0.4.14

RUN wget -O /root/redis-stats.jar https://github.com/junegunn/redis-stat/releases/download/${VERSION}/redis-stat-${VERSION}.jar
ADD ./scripts/start-stats.sh /root
RUN chmod +x /root/start-stats.sh

EXPOSE 63790

ENTRYPOINT ["/root/start-stats.sh"]