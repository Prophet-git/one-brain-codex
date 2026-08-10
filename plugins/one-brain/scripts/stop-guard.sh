#!/bin/sh
# Stop hook de CODEX (corre al cerrar cada turno): estado de captura + recordatorio suave.
# - Mantiene el marker pending-<session> si hay trabajo posterior al último guardado.
# - Recuerda UNA vez por sesión que la captura se va a ofrecer al cerrar, y reinsiste cada 5.
#
# Espejo de plugin/scripts/stop-guard.sh. La política (cuándo marcar, cuándo avisar, cada cuánto
# reinsistir, el fail-loud) es la misma y vive en core/; acá cambian dos cosas de este host:
#
#  1. El LECTOR. El rollout de Codex no se parece en nada al transcript de Claude Code (no hay
#     tools Edit/Write, las ediciones son apply_patch, los turnos del usuario son event_msg),
#     así que se carga core/scripts/capture-codex.sh y se usa ob_unsaved_kind_codex.
#  2. El campo del input. En Codex el hook Stop recibe session_id, cwd, turn_id,
#     last_assistant_message y transcript_path — y transcript_path ES el archivo de rollout
#     .jsonl. No existe un rollout_path aparte, así que no hay fallback que buscar.
#
# LIMITACIÓN CONOCIDA (no es un bug de acá): en Codex el hook Stop NO dispara si el turno
# termina en error. Una sesión que muere en un error de red o de cuota no deja marca. El arranque
# siguiente igual detecta pendientes de sesiones anteriores, que es la red que cubre ese hueco.
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Gate por feature: si el usuario desactivó "Captura automática" (auto-capture:false
# explícito en features.json), salir sin marcar nada. Si el bin no existe o no es
# ejecutable (instalación rota), NO desactivamos la captura por default — solo
# salimos cuando el helper responde exit 1 explícito.
FEATURE_BIN="$DIR/../core/bin/onebrain-feature"
if [ -x "$FEATURE_BIN" ]; then
  "$FEATURE_BIN" auto-capture
  [ "$?" -eq 1 ] && exit 0
fi

# Las librerías compartidas viven en core/ (fuente única, copiada acá por scripts/sync-core.sh).
[ -r "$DIR/../core/scripts/capture-lib.sh" ] || exit 0
. "$DIR/../core/scripts/capture-lib.sh"
[ -r "$DIR/../core/scripts/capture-codex.sh" ] || exit 0
. "$DIR/../core/scripts/capture-codex.sh"

INPUT=$(cat)
TRANSCRIPT=$(ob_json_field transcript_path "$INPUT")
SESSION=$(ob_json_field session_id "$INPUT")
CWD=$(ob_json_field cwd "$INPUT")

# FAIL-LOUD: si LLEGÓ input pero no pudimos sacar session/transcript, la captura automática
# está ROTA (cambio de formato de Codex, o falta jq/python3/perl en el entorno). NO salir en
# silencio — así fue como un cambio de formato tumbó la red de seguridad en Claude Code sin que
# nadie se enterara. Avisamos visible (1×/día para no spamear) para que el usuario lo note.
if [ -n "$INPUT" ] && { [ -z "$SESSION" ] || [ -z "$TRANSCRIPT" ]; }; then
  PDIR=$(ob_pending_dir); mkdir -p "$PDIR" 2>/dev/null
  DAY=$(date +%Y%m%d 2>/dev/null)
  WARN="$PDIR/degraded-$DAY"
  if [ -n "$DAY" ] && [ ! -e "$WARN" ]; then
    printf '' > "$WARN" 2>/dev/null
    # El bin va por RUTA COMPLETA, no pelado: en Codex los bins del paquete no están en el PATH
    # del shell donde el modelo corre comandos (eso es de Claude Code). Y este aviso es el peor
    # lugar para una orden que no resuelve: sale justo cuando la captura automática NO anda, o
    # sea cuando guardar a mano es la ÚNICA salida que queda.
    printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"⚠️ One Brain: la captura automática NO está funcionando — no pude leer el input del hook (posible cambio de formato de Codex, o falta jq/python3/perl en este entorno). Tus avances NO se están registrando solos. Decíselo al usuario de forma visible AHORA y guardá manualmente al cerrar con: sh \\"%s/../core/bin/onebrain-save\\" --type avance --title ... --content ... ; avisale al operador de One Brain para que lo arregle."}}' "$DIR"
  fi
  exit 0
fi
[ -r "$TRANSCRIPT" ] || exit 0
[ -n "$SESSION" ] || exit 0

PDIR=$(ob_pending_dir)
PEND="$PDIR/pending-$SESSION"
# KIND ("edits" | "cola" | "conversacion" | ""): el motivo queda ANOTADO en el marker. El aviso
# de arranque lo necesita para no gritar por una sesión que guardó y después siguió charlando.
KIND=$(ob_unsaved_kind_codex "$TRANSCRIPT")
[ -n "$KIND" ] && UNSAVED=1 || UNSAVED=0

CNT_FILE="$PDIR/unsaved-count-$SESSION"
SAVED_FILE="$PDIR/saved-at-$SESSION"
mkdir -p "$PDIR" 2>/dev/null

# El contador cuenta TURNOS de la sesión, no turnos con deuda: se incrementa siempre, incluso
# cuando no hay nada pendiente. Es lo que permite medir cuánto pasó desde el último guardado —
# antes se reiniciaba justo al guardar, y el aviso volvía al turno siguiente.
CNT=$(cat "$CNT_FILE" 2>/dev/null); [ -n "$CNT" ] || CNT=0
CNT=$((CNT + 1))
printf '%s' "$CNT" > "$CNT_FILE" 2>/dev/null

if [ "$UNSAVED" = "1" ]; then
  # marker con lo que el fallback necesita para destilar la sesión anterior
  { printf 'transcript=%s\n' "$TRANSCRIPT"; printf 'cwd=%s\n' "$CWD"; printf 'reason=%s\n' "$KIND"; } > "$PEND"
else
  # Se guardó (o no hay trabajo): se levanta la deuda y se ANOTA en qué turno pasó. Lo que NO se
  # borra es el ciclo de recordatorio: borrarlo era pedir de nuevo dos turnos después de guardar.
  rm -f "$PEND" 2>/dev/null
  printf '%s' "$CNT" > "$SAVED_FILE" 2>/dev/null
  exit 0
fi

# Una charla larga se anota para el aviso de ARRANQUE (que sabe leer el transcript entero), pero
# no se reclama turno a turno: interrumpir una conversación para pedir que la guarde es
# exactamente lo que llenaba el cerebro de versiones intermedias de una idea sin cerrar.
[ "$KIND" = "conversacion" ] && exit 0

# Recordatorio: la primera vez por sesión (marker reminded-), y de ahí en más REINSISTE cada 5
# turnos con trabajo sin guardar — un aviso único al arrancar se pierde de vista en sesiones
# largas y el trabajo queda sin registrar más tiempo del necesario. Con un piso de turnos
# después de cada guardado (ob_should_remind).
MARK="$PDIR/reminded-$SESSION"
[ -e "$MARK" ] && REMINDED=1 || REMINDED=0
SAVED_AT=$(cat "$SAVED_FILE" 2>/dev/null)

[ "$(ob_should_remind "$CNT" "$REMINDED" "$SAVED_AT")" = "1" ] || exit 0
printf '' > "$MARK" 2>/dev/null
# El sobre JSON, igual que en session-start.sh de este paquete. El texto es una constante con el
# escapeo ya resuelto a mano (las únicas comillas internas son las de la frase que se le sugiere
# pedir): no entra nada dinámico, así que no hace falta el escapador de session-start.
#
# ESTE AVISO LE HABLA A LA PERSONA, NO AL MODELO. En Codex la salida de un hook entra al hilo
# como un ítem propio: no es un susurro al asistente, es texto que la persona ve en pantalla.
# Antes decía "guardá los avances con la skill session-capture (destilá, proponé y guardá)", que
# es una orden para el modelo: quien la leía era la persona, y le llegaba en imperativo, con el
# nombre técnico de dos skills que no sabe invocar. Decisión de Bauti (2-ago): que hable en
# criollo y le diga qué pedir. Por eso tampoco se nombra ningún bin ni ninguna skill acá.
printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"One Brain: quedó trabajo de esta sesión sin guardar en el cerebro del equipo.\\n\\nAntes de cerrar, pedime \\"guardá lo que hicimos\\" y lo dejo registrado para el resto del equipo."}}'
exit 0
