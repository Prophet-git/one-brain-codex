#!/bin/sh
# SessionStart de CODEX — adaptador.
#
# El arranque (qué se le pide al server, en qué orden se ensambla, el presupuesto de caracteres,
# la instrucción de atribución, la telemetría de entrega) vive en core/scripts/session-start-lib.sh,
# compartido con el paquete de Claude Code. Acá quedan SOLO las cuatro diferencias de este host:
# la reconciliación del token, la ruta del canal de guardado, el header x-client y la emisión
# en sobre JSON.
#
# Silencioso ante cualquier fallo (nunca bloquea el arranque).
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# --- Diferencia 1: el token de las tools ---------------------------------------------------
# Codex no tiene headersHelper (el mecanismo con el que Claude Code resuelve el token en cada
# conexión al MCP): acá el token vive ESCRITO en la config de Codex, además del archivo. Si la
# persona lo rota en el panel y lo pega con /connect, el archivo queda con el nuevo y la config
# con el viejo — o sea, los avisos de arranque andarían y las tools no. Medio producto
# funcionando es el peor error posible: no se ve roto, se ve caprichoso. Se reconcilia ANTES de
# cualquier llamada, y en silencio: si no hay nada que emparejar, el bin sale sin tocar nada.
[ -x "$DIR/../core/bin/onebrain-codex-config" ] && sh "$DIR/../core/bin/onebrain-codex-config" --reconciliar >/dev/null 2>&1

# Las librerías compartidas viven en core/ (fuente única, copiada acá por scripts/sync-core.sh).
[ -r "$DIR/../core/scripts/capture-lib.sh" ] || exit 0
. "$DIR/../core/scripts/capture-lib.sh"
[ -r "$DIR/../core/scripts/session-start-lib.sh" ] || exit 0
. "$DIR/../core/scripts/session-start-lib.sh"

OB_PKG_ROOT="$DIR/.."
# --- Diferencia 2: el canal de guardado que se le informa al modelo -------------------------
# Acá se nombra el bin del core directo. En Claude Code se nombra el puente de bin/ porque esa
# ruta ya circula en sesiones abiertas de clientes; en Codex el paquete nace sin historia.
OB_SAVE_BIN="$DIR/../core/bin/onebrain-save"
# --- Diferencia 3: qué programa es esta máquina ---------------------------------------------
OB_CLIENT=codex

ob_session_start

# --- Diferencia 4: la emisión ----------------------------------------------------------------
# Codex acepta las dos formas (stdout plano y sobre JSON) y acá va el sobre por una razón
# medida: el techo de 10.000 bytes se aplica al texto YA PARSEADO, así que con el sobre el
# escapeo no consume presupuesto (17.900 bytes de stdout crudo con 8.927 de additionalContext
# llegaron enteros). En texto plano, el andamiaje cuenta contra el mismo techo.
#
# El escapeo es el punto de falla obvio de todo esto: el brief real trae comillas, barras,
# saltos de línea, tabs, acentos y emojis, y un JSON inválido no degrada — hace desaparecer el
# contexto del equipo entero. Por eso NO se arma con un sed/awk a mano:
#
#  - Los caracteres de control (tab, \r, \b, y cualquier cosa < 0x20) NO pueden ir literales
#    adentro de un string JSON. El parser de Codex es estricto: un solo tab del brief y el
#    sobre entero se descarta. Un `sed` que escape sólo barras y comillas lo deja pasar.
#  - El orden importa: primero las barras, porque escapar comillas mete barras nuevas que no
#    hay que volver a escapar. json.dumps lo hace bien por construcción.
#
# Cascada python3 → perl → awk, el mismo criterio que ob_json_field/ob_clip en capture-lib:
# jq casi nunca está en Windows/Git Bash, python3 o perl casi siempre.
ob_json_escape() { # stdin -> el CONTENIDO de un string JSON (sin las comillas de afuera)
  if command -v python3 >/dev/null 2>&1; then
    # ensure_ascii=False deja los acentos y los emojis como UTF-8 crudo (válido en JSON y más
    # barato en bytes); las comillas, las barras y los controles los escapa json.dumps.
    python3 -c 'import json,sys
s = sys.stdin.buffer.read().decode("utf-8", "replace")
sys.stdout.write(json.dumps(s, ensure_ascii=False)[1:-1])' 2>/dev/null
    return
  fi
  if command -v perl >/dev/null 2>&1; then
    # Orden: barra, comilla, y recién después los controles (para entonces los \n ya son dos
    # caracteres y el rango [\x00-\x1f] no los vuelve a tocar).
    perl -CSD -0777 -ne '
      s/\\/\\\\/g; s/"/\\"/g;
      s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g;
      s/([\x00-\x1f])/sprintf("\\u%04x", ord($1))/ge;
      print' 2>/dev/null
    return
  fi
  # Último recurso. Los controles que no tienen escape corto se BORRAN antes de entrar al awk:
  # perder un carácter invisible es un daño que nadie nota, emitir JSON inválido borra el
  # contexto del equipo entero. LC_ALL=C para trabajar por bytes y no romper el UTF-8.
  LC_ALL=C tr -d '\000\001\002\003\004\005\006\007\010\013\014\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037' \
    | LC_ALL=C awk 'BEGIN { ORS="" }
        { linea = $0
          gsub(/\\/, "\\\\", linea); gsub(/"/, "\\\"", linea)
          gsub(/\t/, "\\t", linea);  gsub(/\r/, "\\r", linea)
          if (NR > 1) printf "\\n"
          printf "%s", linea }'
}

# printf '%s' y no un here-string: el bloque puede empezar con "-" o traer barras, y hay que
# pasarlo tal cual. La salida del escapeo no termina en saltos de línea REALES (los convirtió en
# "\n" de dos caracteres), así que la sustitución de comandos no le come nada del final.
OB_JSON=$(printf '%s' "$OB_STDOUT" | ob_json_escape)
[ -n "$OB_STDOUT" ] && printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$OB_JSON"

# exit 0 explícito: sin esto, el último comando es el `[ -n ... ] &&` y un arranque sin nada que
# decir (lo normal en una instalación sin token) saldría con código 1, o sea un hook "fallado"
# en los logs de Codex por hacer exactamente lo que tiene que hacer.
exit 0
