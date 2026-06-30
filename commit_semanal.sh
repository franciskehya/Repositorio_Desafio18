#!/usr/bin/env bash
#
# commit_semanal.sh
# -----------------------------------------------------------------------------
# Automatiza el "upload" semanal de código de un repositorio Git:
#   1. Detecta y agrega TODOS los cambios del repositorio (git add -A).
#   2. Cuenta cuántas líneas se modificaron (agregadas + eliminadas).
#   3. Si hubo cambios -> hace commit + push al remoto y muestra un mensaje
#      con la cantidad de líneas modificadas.
#   4. Si NO hubo cambios -> muestra un mensaje de ALERTA.
#   5. En ambos casos guarda esa información en el archivo README.md del repo,
#      bajo la sección "Registro de commits automáticos".
#
# Uso:
#   ./commit_semanal.sh [RUTA_REPO] [RAMA]
#
#   RUTA_REPO : ruta al repositorio git (por defecto: directorio actual).
#   RAMA      : rama a la que se hace push (por defecto: main).
#
# Pensado para ejecutarse de forma semanal mediante crontab (ver README).
# -----------------------------------------------------------------------------

# Modo estricto: corta ante errores, variables no definidas y errores en pipes.
set -euo pipefail

# ----------------------------- Parámetros ------------------------------------
REPO_DIR="${1:-$(pwd)}"      # 1er argumento o directorio actual
BRANCH="${2:-main}"          # 2do argumento o "main"
PREFIX="[commit_semanal]"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# --------------------------- Validaciones ------------------------------------
# ¿Existe el directorio?
if [ ! -d "$REPO_DIR" ]; then
  echo "$PREFIX ERROR: el directorio '$REPO_DIR' no existe." >&2
  exit 1
fi

cd "$REPO_DIR"

# ¿Es realmente un repositorio Git?
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "$PREFIX ERROR: '$REPO_DIR' no es un repositorio Git." >&2
  exit 1
fi

# ----------------------- Conteo de cambios -----------------------------------
# Agregamos todo (nuevos, modificados y borrados) al área de staging.
git add -A

# Sumamos columnas de 'git diff --cached --numstat':
#   columna 1 = líneas agregadas, columna 2 = líneas eliminadas.
# Para archivos binarios numstat devuelve "-", que en awk vale 0.
ADDED="$(git diff --cached --numstat | awk '{a += $1} END {print a + 0}')"
REMOVED="$(git diff --cached --numstat | awk '{r += $2} END {print r + 0}')"
TOTAL=$((ADDED + REMOVED))

# Aseguramos que exista el README.md y la sección de registro.
README="README.md"
SECTION="## Registro de commits automáticos"
if [ ! -f "$README" ]; then
  printf '# %s\n\n%s\n' "$(basename "$REPO_DIR")" "$SECTION" > "$README"
elif ! grep -qF "$SECTION" "$README"; then
  printf '\n%s\n' "$SECTION" >> "$README"
fi

# ----------------------- Lógica principal ------------------------------------
# 'git diff --cached --quiet' devuelve:
#   - código 0  -> NO hay cambios en staging
#   - código !=0 -> SÍ hay cambios en staging
if git diff --cached --quiet; then
  # ---------- CASO: no hubo cambios -> ALERTA ----------
  MENSAJE="$TIMESTAMP | ALERTA: no se realizaron commits (sin cambios en el repositorio)."
  echo "$PREFIX $MENSAJE"

  # Registramos la alerta en el README (esto es el único cambio de la semana).
  printf -- '- %s\n' "$MENSAJE" >> "$README"
  git add "$README"
  git commit -m "Registro automático: sin cambios de código esta semana ($TIMESTAMP)"
else
  # ---------- CASO: hubo cambios -> commit + push ----------
  MENSAJE="$TIMESTAMP | Commit semanal: $TOTAL líneas modificadas (+$ADDED / -$REMOVED)."
  echo "$PREFIX $MENSAJE"

  # Registramos el resumen en el README e incluimos el README en el commit.
  printf -- '- %s\n' "$MENSAJE" >> "$README"
  git add "$README"
  git commit -m "Commit semanal automático: $TOTAL líneas modificadas (+$ADDED/-$REMOVED)"
fi

# ----------------------------- Push ------------------------------------------
# Nota: para que el push funcione SIN intervención (cron), la autenticación
# debe estar configurada por SSH (clave sin passphrase o agente) o por un
# credential helper con un Personal Access Token. Ver el informe (sección 4).
echo "$PREFIX Enviando cambios al remoto (origin/$BRANCH)..."
if git push origin "$BRANCH"; then
  echo "$PREFIX Push realizado correctamente."
else
  echo "$PREFIX ERROR: el push falló. Revisar credenciales/conexión." >&2
  exit 1
fi

echo "$PREFIX Proceso finalizado."
