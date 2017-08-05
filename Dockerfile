FROM node:6

RUN apt-get -q update \
	&& apt-get install apt-utils --assume-yes \
  && apt-get install ruby-dev --assume-yes \
  && apt-get install rubygems --assume-yes \
  && gem update --system \
  && gem install compass \
#  && gem install dpl \
#  && gem install aws-sdk
  && rm -rf /var/lib/apt/lists/*

WORKDIR derivaciones

# EXPOSE 3001
# EXPOSE 3002
# EXPOSE 35730

ENTRYPOINT '/bin/bash'
