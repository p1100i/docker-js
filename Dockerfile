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

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
