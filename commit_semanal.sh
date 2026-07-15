#!/usr/bin/env bash
#
# commit_semanal.sh
# Automatiza el "upload" semanal de código de un repositorio Git:
#   1. Detecta y agrega TODOS los cambios del repositorio (git add -A).
#   2. Cuenta la cantidad de líneas que se modifican (agregadas + eliminadas).
#   3. Si hubo cambios: hace commit + push al remoto y muestra un mensaje
#      con la cantidad de líneas modificadas.
#   4. por si NO hubo cambios se muestra un mensaje de ALERTA.
#   5. En los dos casos se guarda la info en el archivo README.md del repo,
#      en la sección "Registro de commits automáticos".
# Uso:
#   ./commit_semanal.sh [RUTA_REPO] [RAMA]
#   RUTA_REPO : ruta al repositorio git (el directorio actual).
#   Main: rama a la que se hace push.
# Pensado para ejecutarse de forma semanal mediante crontab.

# Modo estricto: corta ante errores, variables no definidas y errores en pipes.
set -euo pipefail

# Parámetros 
REPO_DIR="${1:-$(pwd)}"      # 1er argumento o directorio actual
BRANCH="${2:-main}"          # 2do argumento o "main"
PREFIX="[commit_semanal]"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"


# validamos si el directorio existe
if [ ! -d "$REPO_DIR" ]; then
  echo "$PREFIX ERROR: el directorio '$REPO_DIR' no existe." >&2
  exit 1
fi

cd "$REPO_DIR"

# nos fijamos si es un repositorio Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "$PREFIX ERROR: '$REPO_DIR' no es un repositorio Git." >&2
  exit 1
fi

# contamos los cambios
# Agregamos todo (nuevos, modificados y borrados) al área de staging.
git add -A
ADDED="$(git diff --cached --numstat | awk '{a += $1} END {print a + 0}')"
REMOVED="$(git diff --cached --numstat | awk '{r += $2} END {print r + 0}')"
TOTAL=$((ADDED + REMOVED))

# nos fijamos si esta el README.md y la sección de registro.
README="README.md"
SECTION="## Registro de commits automáticos"
if [ ! -f "$README" ]; then
  printf '# %s\n\n%s\n' "$(basename "$REPO_DIR")" "$SECTION" > "$README"
elif ! grep -qF "$SECTION" "$README"; then
  printf '\n%s\n' "$SECTION" >> "$README"
fi

# principal 
if git diff --cached --quiet; then
  # por si: no hubo cambios -> alerta
  MENSAJE="$TIMESTAMP | ALERTA: no se realizaron commits (sin cambios en el repositorio)."
  echo "$PREFIX $MENSAJE"

  # el único cambio de la semana es el registrar la alerta en README
  printf -- '- %s\n' "$MENSAJE" >> "$README"
  git add "$README"
  git commit -m "Registro automático: sin cambios de código esta semana ($TIMESTAMP)"
else
  # si- hubo cambios -> commit + push
  MENSAJE="$TIMESTAMP | Commit semanal: $TOTAL líneas modificadas (+$ADDED / -$REMOVED)."
  echo "$PREFIX $MENSAJE"

  # Ponemos el resumen en el README y incluimos README en commit.
  printf -- '- %s\n' "$MENSAJE" >> "$README"
  git add "$README"
  git commit -m "Commit semanal automático: $TOTAL líneas modificadas (+$ADDED/-$REMOVED)"
fi

# El Push 
echo "$PREFIX Enviando cambios al remoto (origin/$BRANCH)..."
if git push origin "$BRANCH"; then
  echo "$PREFIX Push realizado correctamente."
else
  echo "$PREFIX ERROR: el push falló. Revisar credenciales/conexión." >&2
  exit 1
fi

echo "$PREFIX Proceso finalizado."
