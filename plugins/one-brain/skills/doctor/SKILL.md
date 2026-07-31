---
description: Revisar por qué One Brain no está funcionando en esta máquina y decir el próximo paso concreto. Se activa cuando el usuario dice "no anda el cerebro", "no me guarda nada", "no aparece nada de One Brain", "revisá la instalación", "$one-brain:doctor", o cuando falla algo del plugin y no está claro por qué.
---

# Doctor de One Brain

Diagnosticás la instalación de esta máquina y devolvés un veredicto claro con el próximo paso. **No cambiás nada**: el doctor mira, no toca.

## Dónde están los ejecutables

Los bins de One Brain viven en `core/bin/` de este paquete, o sea **dos niveles arriba de este archivo**. Codex te dio la ruta absoluta de este `SKILL.md` cuando lo listó: usá esa para armarlas. En adelante la llamamos `<RAIZ>`. En Codex los bins **no están en el PATH**: se invocan por ruta completa.

## Qué hacés

1. Corré: `sh "<RAIZ>/core/bin/onebrain-doctor"`.
   Devuelve una línea por chequeo con el formato `clave|estado|detalle`, donde estado es `ok`, `aviso` o `falla`.

2. Leé la salida y armá el reporte. Los chequeos son:
   - **token** — si hay credencial guardada en esta máquina.
   - **curl** — si está la herramienta que usa el plugin para hablar con el cerebro.
   - **parser** — si los hooks pueden leer el input que les manda el programa. Si esto falla, la captura automática no anda aunque todo lo demás esté bien.
   - **hooks** — **no aplica en Codex** (ver abajo).
   - **carpeta** — **se lee distinto en Codex** (ver abajo).
   - **entrega** — si el contexto que el cerebro manda al arrancar la sesión llegó entero o hubo que recortarlo por tamaño. Es la falla que más contexto se comió históricamente y desde afuera no se ve.
   - **captura** — cuántas sesiones anteriores quedaron con trabajo sin destilar.
   - **conexion** — si el cerebro responde con este token.
   - **version** — **puede no aparecer en Codex** (ver abajo).

## Tres líneas que en Codex NO se leen literal

El diagnóstico es compartido con el otro paquete de One Brain (el del asistente de Anthropic) y
hay chequeos que miran archivos que en Codex no existen. En una máquina que solo tiene Codex
dicen cosas que no corresponden. **No se las repitas al usuario tal cual y no lo mandes a
arreglar nada por ellas:**

- **`hooks`** mira `disableAllHooks` en `~/.claude/settings.json`, un archivo que en Codex no existe. Siempre va a decir `ok`, y ese `ok` no dice nada sobre esta máquina — **omitilo del reporte**. El equivalente real acá es la confianza de hooks: Codex ata el permiso de correr cada hook a un hash de su definición, y si el usuario no lo aprobó, el hook simplemente no corre. Si la sospecha es esa (no llega el contexto del equipo al arrancar), lo que corresponde es reiniciar Codex y aprobar el hook cuando lo pregunte.
- **`carpeta`** busca las reglas del cerebro en un `CLAUDE.md`. Acá el archivo equivalente es **`AGENTS.md`**, así que una instalación sana puede dar `aviso` en esta línea. Antes de reportarlo como problema, fijate vos si hay un `AGENTS.md` (en esta carpeta o en las de arriba) que nombre `brain_context` y `brain_save`. Si lo hay, está todo bien y no lo menciones. Si no lo hay, ahí sí decilo: falta dejar las reglas de One Brain en el `AGENTS.md` de la carpeta donde trabaja, y se las podés escribir vos si te lo pide (agregadas al final, sin pisar lo que el archivo ya tenga: `brain_context` al arrancar, `brain_search` para consultar, `brain_save` al cerrar).
- **`version`** sale de un registro de plugins que en Codex no existe: en esta máquina la línea puede directamente no aparecer. Eso es lo esperado, no un problema. No lo reportes como falta.

## Cómo lo reportás

Primero **el veredicto en una línea**: "está todo bien" o "encontré N problemas". Después solo lo que no está en verde, con el arreglo concreto:

| Falla | Qué le decís que haga |
|---|---|
| `token` | Pedile el token a quien le dio acceso y conectá con la skill `one-brain:connect` |
| `curl` | Instalar curl (en Windows: usar Git Bash o WSL, que ya lo traen) |
| `parser` | Actualizar el plugin (ver "Cómo se actualiza", abajo) y reiniciar Codex |
| `entrega` en `aviso` | Nada se perdió: el material recortado se vuelve a pedir en el próximo arranque. Si pasa en todos los arranques, desde el panel se pueden apagar los bloques que no use (Digest del equipo, Resumen de sesión) para que el que sí le importa entre completo; si no, avisarle al operador |
| `captura` en `aviso` | No es un problema: hay trabajo de sesiones anteriores esperando destilarse. Ofrecele guardarlo ahora |
| `conexion` 401/403 | El token no vale más: pedir uno nuevo y volver a conectar con `one-brain:connect` |
| `conexion` sin respuesta | Probar la red/VPN y reintentar; si sigue, avisarle al operador |

Si todo dio `ok`, decilo derecho y agregá que si igual no ve las tools del cerebro, cierre Codex y lo vuelva a abrir para que tome el token.

## Cómo se actualiza (decílo cuando haga falta actualizar, o cuando te lo pregunten)

Se corre en la **terminal**, no adentro de Codex:

    codex plugin marketplace upgrade prophet
    codex plugin add one-brain@prophet

Y después **cerrar Codex y volver a abrirlo**. El reinicio es parte del arreglo, no una
formalidad: Codex cachea el paquete por versión y mientras el proceso siga vivo sigue usando la
copia vieja aunque el update haya bajado bien, y la persona concluye que actualizar no sirvió.
En Codex no hay un comando para recargar plugins en caliente.

Para ver qué hay instalado: `codex plugin list`.

## Reglas

- **Nunca imprimas el token** ni lo repitas, aunque aparezca en pantalla.
- No inventes chequeos que el comando no hizo: reportás lo que devolvió, nada más.
- Un `aviso` no es una falla: mencionalo al final, sin alarma.
- Hablá en criollo, sin jerga: quien corre esto suele no ser técnico.
- El programa que esta persona usa es **Codex**. No la mandes a reiniciar, actualizar ni configurar ningún otro.
