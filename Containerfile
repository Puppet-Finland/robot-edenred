FROM docker.io/ubuntu:24.04

WORKDIR /home/ubuntu
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    npm

RUN yes | npx playwright install-deps

USER ubuntu
RUN pip3 install --break-system-packages robotframework robotframework-browser robotframework-imaplibrary2
RUN /home/ubuntu/.local/bin/rfbrowser init
ENV PATH=$PATH:/home/ubuntu/.local/bin

ENTRYPOINT ["robot", "robot-edenred/tasks/charge-edenred.robot"]
