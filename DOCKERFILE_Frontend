# Environemnt to install flutter and build web
FROM debian:latest AS build-env

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

#clone flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# setup the flutter path as an enviromental variable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN /usr/local/flutter/bin/flutter --version
# doctor to see if all was installes ok
RUN /usr/local/flutter/bin/flutter doctor -v

# create folder to copy source code
RUN mkdir /app
# copy source code to folder
COPY . /app
# stup new folder as the working directory
WORKDIR /app

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN /usr/local/flutter/bin/flutter clean
RUN /usr/local/flutter/bin/flutter pub get
RUN /usr/local/flutter/bin/flutter build web

# use nginx to deploy
FROM nginx:latest

# copy the info of the builded web app to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose and run nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]