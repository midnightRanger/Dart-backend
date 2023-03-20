FROM dart:stable

WORKDIR /api-app

ADD pubspec.* /api-app/
RUN dart pub get --no-precompile -y
ADD . /api-app/

RUN dart pub get --offline --no-precompile 

COPY . . 
 
EXPOSE 8888

ENTRYPOINT [ "dart", "run", "conduit:conduit", "serve", "--port", "8888" ]