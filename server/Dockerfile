FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o bin/server

FROM dart:stable

WORKDIR /app

COPY --from=build /app/bin/server ./bin/server

ENV HOST=0.0.0.0
ENV PORT=8080
EXPOSE 8080

CMD ["./bin/server"]
