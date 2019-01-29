FROM archlinux/base

RUN set -xe \
  && pacman -Syyu --noconfirm

RUN set -xe \
  && pacman -S --noconfirm  \
    chromium                \
    git                     \
    nodejs                  \
    npm                     \
    sudo                    \
    vim

COPY ./warm-npm-cache.sh /warm-npm-cache.sh

RUN set -xe \
  && /warm-npm-cache.sh

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
