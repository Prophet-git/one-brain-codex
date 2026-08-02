---
description: Ver el estado de la conexión de esta máquina a One Brain — si hay token, a qué URL apunta y si el conector responde. Se activa cuando el usuario lo pide ("¿estoy conectado a One Brain?", "chequeá la conexión", "estado de One Brain", "por qué no anda el cerebro", "$one-brain:status").
---

# Estado de One Brain

Reportás si esta máquina está conectada a One Brain y, si algo falla, el próximo paso concreto. NO cambies nada: esta skill solo diagnostica.

## Dónde están los ejecutables

Los bins de One Brain viven en `core/bin/` de este paquete, o sea **dos niveles arriba de este archivo**. Codex te dio la ruta absoluta de este `SKILL.md` cuando lo listó: usá esa para armarlas. En adelante la llamamos `<RAIZ>`.

En Codex los bins **no están en el PATH** — hay que invocarlos por ruta completa, con `sh "<RAIZ>/core/bin/<bin>"`.

## Qué hacés

1. **Token configurado.** Corré: `sh "<RAIZ>/core/bin/onebrain-token" check`. Mira `~/.config/one-brain/token` y responde si hay token **sin imprimirlo**.
   - "hay token guardado" → está conectado.
   - "sin token" (o exit ≠ 0) → NO hay token. Saltá al reporte: "no conectado, falta el token".
   - Es `check` y no `get` a propósito: `get` imprime la credencial en claro y todo lo que sale por pantalla queda escrito en el registro local de esta sesión. Para saber si hay token no hace falta verlo.

2. **El conector responde.** Solo si hay token, corré: `sh "<RAIZ>/core/bin/onebrain-token" verify`. Hace un `tools/list` contra el endpoint MCP y espera HTTP 200.
   - "conexión OK" → el conector responde.
   - "falló (<código>)" → el token existe pero el server lo rechaza o no responde (ej. 401 = token inválido/revocado, 000 = sin red).

3. **URL de destino.** Es `https://onebrain.prophet.lat` por default, o el valor de `ONE_BRAIN_URL` si está seteada. Reportá a cuál apunta.

4. **El token que usan las tools.** En Codex hay DOS lugares con el token: el archivo (paso 1) y la config de Codex, que es de donde lo toman las tools del cerebro. Los pasos 1 y 2 solo miran el archivo. Si el archivo está sano y aun así las tools de One Brain no aparecen en la sesión, es que la config quedó con otro token (o sin ninguno): el arranque lo reconcilia solo, así que el arreglo es **reiniciar Codex**.

## Reporte (claro y corto)

Decile al usuario:
- **Conectado sí/no** — sin rodeos.
- **A qué URL** apunta el conector.
- **Próximo paso** si algo falla:
  - Sin token → "pedile el token a quien te dio acceso y conectá con la skill `one-brain:connect`".
  - `verify` falló con 401/403 → "el token no es válido o fue revocado; volvé a conectar con `one-brain:connect`".
  - `verify` falló con 000/timeout → "no hay red o el server no responde; reintentá en un rato".
  - Todo OK pero las tools de One Brain no aparecen → "cerrá Codex y volvé a abrirlo: el server MCP se engancha al arrancar la sesión". En Codex no hay un comando para recargar plugins en caliente; el reinicio es el camino.

## Reglas
- No inventes: el estado que reportás sale de lo que devolvieron los dos comandos de arriba (`get` y `verify`), nada más.
- Nunca imprimas el token en claro.
