FROM hugomods/hugo:ci AS builder

ARG HUGO_BASEURL=
ENV HUGO_BASEURL=${HUGO_BASEURL}

COPY . /src

RUN hugo build