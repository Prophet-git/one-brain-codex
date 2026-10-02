---
description: Generar un handoff del estado actual y guardarlo en One Brain para retomar después o pasárselo a un compañero. Se activa cuando el usuario quiere cortar o traspasar contexto ("hagamos handoff", "voy a cerrar esto para retomar", "pasale el contexto a X", "reseteemos", "estamos usando muchos tokens", "$one-brain:handoff").
---

# Handoff a One Brain

Destilás el estado de la sesión en un handoff conciso y lo guardás en el cerebro (`type: handoff`), para que vos u otra persona lo retomen sin perder el hilo.

## Cuándo actuás
- El usuario pide cortar/pasar: "hagamos handoff", "voy a cerrar esto", "pasale el contexto a X", "reseteemos", "arranquemos fresh".
- La sesión cierra una fase grande y conviene dejar un punto de retorno.

## Qué hacés
1. **Si el proyecto tiene ficha, actualizala primero.** Hace falta la tool `brain_ficha` del server MCP `one-brain`; si no está cargada en la sesión, salteá este paso. Pedí la ficha con `brain_ficha`; si existe, dejala al día con `brain_ficha_editar`: mové a `hecho` lo que cerró (con su `fuente`), mové a `bloqueado` lo trabado (con `bloqueado_en`), agregá las tareas nuevas y las salvedades que aparecieron, y reescribí el `estado` en una o dos frases. La ficha es el estado; el handoff no lo repite.
2. Relevá lo que la ficha no guarda: goal original, decisiones tomadas (con el PORQUÉ), qué quedó a mitad, qué NO hacer (caminos descartados), próximo paso concreto. Con ficha, el handoff cuenta sólo eso: lo que quedó a mitad y cómo seguirlo. Sin ficha, cuenta también el estado.
3. Si estás en un repo git, agregá UNA línea de estado técnico: rama + último commit + si hay cambios sin commitear. Si no hay repo, omitila (el handoff debe servir igual al no-técnico).
4. Armá el handoff (destilá, NO copies la conversación; < 100 líneas):
   - **Dónde quedamos** (1-2 líneas; con ficha, sólo lo que quedó a mitad)
   - **Decisiones** (cada una con su porqué)
   - **Qué falta** (con ficha, omitilo: ya está en las tareas)
   - **Qué NO hacer**
   - **Próximo paso** (concreto)
   - **Estado técnico** (opcional, si hay repo)
5. Proponéselo al usuario: "este es el handoff, ¿lo guardo así o ajustás?".
6. Con el OK, guardalo y reportá el `entry_id` que devuelve.

## Cómo se guarda en Codex

Por el **canal Bash**, que no depende de que la tool MCP esté cargada en esta sesión:

    sh "<RAIZ>/core/bin/onebrain-save" --type handoff --title "<título con el proyecto>" \
       --content "<el handoff completo>" --entities "<proyecto,tema>"

`<RAIZ>` es la raíz de este paquete: **dos niveles arriba de este archivo**. Codex te dio la ruta absoluta de este `SKILL.md` cuando lo listó — usá esa para armarla. En Codex los bins no están en el PATH, así que van por ruta completa.

Si el proyecto tiene ficha, sumá `--sin-cambios-en-tareas` (las tareas ya se movieron en el paso 1) o `--cierra-tareas "id1,id2"` con las que cierra este handoff: sin una de las dos el server lo rechaza y lista las tareas abiertas con su id.

El comando imprime el `entry_id` si salió bien. Si el server no responde, **encola el guardado para reintentar**: el handoff no se pierde, pero avisáselo al usuario igual.

Si la tool `brain_save` del server MCP `one-brain` está disponible en la sesión, también sirve (mismo destino, `type: "handoff"`). El canal Bash es el que conviene por default porque anda siempre.

## Reglas
- Concreto > vago: "resume en el wizard paso 3, falta el submit" gana a "seguir con el wizard".
- Nunca guardes secrets ni datos personales sensibles.
- Si el guardado falla, avisá y no des el handoff por perdido: mostráselo al usuario en pantalla.
