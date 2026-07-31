---
description: Generar un handoff del estado actual y guardarlo en One Brain para retomar después o pasárselo a un compañero. Se activa cuando el usuario quiere cortar o traspasar contexto ("hagamos handoff", "voy a cerrar esto para retomar", "pasale el contexto a X", "reseteemos", "estamos usando muchos tokens", "$one-brain:handoff").
---

# Handoff a One Brain

Destilás el estado de la sesión en un handoff conciso y lo guardás en el cerebro (`type: handoff`), para que vos u otra persona lo retomen sin perder el hilo.

## Cuándo actuás
- El usuario pide cortar/pasar: "hagamos handoff", "voy a cerrar esto", "pasale el contexto a X", "reseteemos", "arranquemos fresh".
- La sesión cierra una fase grande y conviene dejar un punto de retorno.

## Qué hacés
1. Relevá el estado real: goal original, decisiones tomadas (con el PORQUÉ), qué quedó en progreso, qué falta, qué NO hacer (caminos descartados), próximo paso concreto.
2. Si estás en un repo git, agregá UNA línea de estado técnico: rama + último commit + si hay cambios sin commitear. Si no hay repo, omitila (el handoff debe servir igual al no-técnico).
3. Armá el handoff (destilá, NO copies la conversación; < 100 líneas):
   - **Dónde quedamos** (1-2 líneas)
   - **Decisiones** (cada una con su porqué)
   - **Qué falta**
   - **Qué NO hacer**
   - **Próximo paso** (concreto)
   - **Estado técnico** (opcional, si hay repo)
4. Proponéselo al usuario: "este es el handoff, ¿lo guardo así o ajustás?".
5. Con el OK, guardalo y reportá el `entry_id` que devuelve.

## Cómo se guarda en Codex

Por el **canal Bash**, que no depende de que la tool MCP esté cargada en esta sesión:

    sh "<RAIZ>/core/bin/onebrain-save" --type handoff --title "<título con el proyecto>" \
       --content "<el handoff completo>" --entities "<proyecto,tema>"

`<RAIZ>` es la raíz de este paquete: **dos niveles arriba de este archivo**. Codex te dio la ruta absoluta de este `SKILL.md` cuando lo listó — usá esa para armarla. En Codex los bins no están en el PATH, así que van por ruta completa.

El comando imprime el `entry_id` si salió bien. Si el server no responde, **encola el guardado para reintentar**: el handoff no se pierde, pero avisáselo al usuario igual.

Si la tool `brain_save` del server MCP `one-brain` está disponible en la sesión, también sirve (mismo destino, `type: "handoff"`). El canal Bash es el que conviene por default porque anda siempre.

## Reglas
- Concreto > vago: "resume en el wizard paso 3, falta el submit" gana a "seguir con el wizard".
- Nunca guardes secrets ni datos personales sensibles.
- Si el guardado falla, avisá y no des el handoff por perdido: mostráselo al usuario en pantalla.
