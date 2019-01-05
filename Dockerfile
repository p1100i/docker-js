FROM archlinux/base

RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm nodejs chromium

ENTRYPOINT ["/mnt/project/docker-entry.sh"]
