#!/bin/bash
# ============================================================
# docker-entrypoint.sh — Canchas La 103
# Ajusta el puerto de Apache según la variable $PORT de Render.
# Si $PORT no existe (dev local), usa 80.
# ============================================================

PORT="${PORT:-80}"

# Reemplazar el puerto por defecto de Apache
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-enabled/000-default.conf

exec apache2-foreground
