## Dockerfile to build and package website content as a Docker image.
# Sample build command:
# docker build --rm -t btnguyen2k:mpn -f Dockerfile .

FROM golang:1.19-alpine AS builder_docs
RUN mkdir /build
COPY . /build
RUN cd /build \
    && go install github.com/btnguyen2k/docms/docli@880d080442b93f33cad6bf065d22a16e30851924 \
    && docli build --purge --src dosrc --out dodata

FROM btnguyen2k/docmsruntime:latest as docmsruntime
LABEL maintainer="Thanh Nguyen"
COPY --from=builder_docs /build/dodata /app/dodata
WORKDIR /app
EXPOSE 8000
CMD ["/app/main"]
