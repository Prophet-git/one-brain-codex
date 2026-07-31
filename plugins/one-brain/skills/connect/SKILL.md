---
description: Conectar esta computadora a One Brain con tu token de acceso. Se activa cuando el usuario lo pide ("conectame a One Brain", "acá está mi token", "$one-brain:connect").
---

# Conectar a One Brain

El usuario quiere conectar esta máquina a One Brain. Su token está en el mensaje (empieza con `ob_`), o se lo tenés que pedir.

## Dónde están los ejecutables

Los bins de One Brain viven en `core/bin/` de este paquete, o sea **dos niveles arriba de este archivo**. Codex te dio la ruta absoluta de este `SKILL.md` cuando lo listó: usá esa para armarlas.

Ejemplo: si este archivo es `/…/plugins/cache/prophet/one-brain/0.1.1/skills/connect/SKILL.md`,
el bin es `/…/plugins/cache/prophet/one-brain/0.1.1/core/bin/onebrain-codex-config`.

En adelante lo llamamos `<RAIZ>`. (Si en tu entorno la variable `PLUGIN_ROOT` está seteada apunta a esa misma carpeta, pero no cuentes con eso: se la define Codex a los hooks, no necesariamente al shell donde vos corrés comandos.)

## Qué hacés

1. Guardá el token en el archivo, que es la fuente de verdad para los avisos de arranque:

   mkdir -p ~/.config/one-brain && printf '%s' "<TOKEN>" > ~/.config/one-brain/token

2. Escribilo también en la config de Codex, que es de donde lo toman las tools del cerebro:

   sh "<RAIZ>/core/bin/onebrain-codex-config" "<TOKEN>"

   El comando imprime en qué archivo lo escribió. Esa es la config que Codex lee de verdad: si la persona usa `CODEX_HOME` para tener su Codex en otra carpeta, la ruta no va a ser `~/.codex/config.toml`. Repetile la ruta que imprimió, no una inventada.

3. Decile que **reinicie Codex** (cerrarlo y volver a abrirlo) para que las tools del cerebro queden disponibles, y que después escriba "¿qué sabés de mi equipo?" para confirmar que quedó conectado. El reinicio no es una formalidad: el server MCP se levanta al arrancar la sesión, cuando el token todavía no estaba escrito.

## Cuando falla

- **exit 2** — el token tiene caracteres que no puede tener (espacios, comillas, algo pegado de más). No escribió nada. Pedile que lo copie de nuevo del panel, sin comillas ni espacios.
- **exit 3** — la config de Codex ya tiene una sección de one-brain escrita de una forma que el comando no puede reescribir sin romperla, así que **no tocó nada**. El mensaje de error dice la ruta exacta del archivo: pedile que borre esa sección a mano de ESE archivo y volvé a correr el paso 2.

## Reglas

- Nunca imprimas el token en claro ni lo repitas.
- Si el paso 1 avisa que estás reemplazando otro cerebro, decíselo textual antes de seguir: sólo se puede estar en un cerebro por máquina y sin el token viejo no se vuelve al anterior.
