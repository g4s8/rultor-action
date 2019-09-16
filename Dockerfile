FROM alpine:3.10

WORKDIR /app
RUN apk --update --no-cache add bash git jq python3 && \
  pip3 install --upgrade pip && pip3 install yq

COPY action.sh action.sh

CMD ["bash", "/app/action.sh"]
