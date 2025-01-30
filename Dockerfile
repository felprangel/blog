FROM hugomods/hugo:ci AS builder
# Base URL
ARG HUGO_BASEURL=
ENV HUGO_BASEURL=${HUGO_BASEURL}
# Build site
COPY . /src
# Replace below build command at will.
RUN hugo
