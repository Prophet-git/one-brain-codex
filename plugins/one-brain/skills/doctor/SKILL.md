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
   - **perfil** — en qué perfil de esta máquina corre la sesión y qué cerebro tiene conectado (el nombre del cerebro sale del token, sin llamar al server). Si el token todavía es el heredado del perfil de siempre — no se reconectó éste aparte —, avisa en `aviso` con el comando para separarlos.
   - **curl** — si está la herramienta que usa el plugin para hablar con el cerebro.
   - **parser** — si los hooks pueden leer el input que les manda el programa. Si esto falla, la captura automática no anda aunque todo lo demás esté bien.
   - **hooks** — si los avisos de One Brain están aprobados en la configuración de Codex. Es el chequeo que más importa acá: un aviso recién instalado nace **sin aprobar y no se ejecuta**, aunque el plugin figure instalado y activo, y no hay ninguna señal de eso. Vuelve a pedirse después de cada actualización que toque esos avisos.
   - **carpeta** — si hay un `AGENTS.md` (en esta carpeta o en las de arriba) con las reglas del cerebro. Si falta, se las podés escribir vos cuando te lo pida: agregadas al final, sin pisar lo que el archivo ya tenga (`brain_context` al arrancar, `brain_search` para consultar, `brain_save` al cerrar).
   - **entrega** — si el contexto que el cerebro manda al arrancar la sesión llegó entero o hubo que recortarlo por tamaño. Es la falla que más contexto se comió históricamente y desde afuera no se ve.
   - **captura** — cuántas sesiones anteriores quedaron con trabajo sin destilar.
   - **conexion** — si el cerebro responde con este token.
   - **version** — qué versión del paquete está corriendo.

Cada línea habla de ESTA máquina: reportá lo que dice, sin traducir ni omitir nada.

## Cómo lo reportás

Primero **el veredicto en una línea**: "está todo bien" o "encontré N problemas". Después solo lo que no está en verde, con el arreglo concreto:

| Falla | Qué le decís que haga |
|---|---|
| `token` | Pedile el token a quien le dio acceso y conectá con la skill `one-brain:connect` |
| `perfil` en `aviso` | No es una falla: el token de este perfil es el heredado del de siempre. Si esta persona quiere un cerebro DISTINTO acá, que conecte el suyo con la skill `one-brain:connect` — a partir de ahí este perfil deja de usar el heredado |
| `curl` | Instalar curl (en Windows: usar Git Bash o WSL, que ya lo traen) |
| `parser` | Actualizar el plugin (ver "Cómo se actualiza", abajo) y reiniciar Codex |
| `hooks` en `aviso` | Cerrar Codex, volver a abrirlo y **aceptar los avisos de One Brain** cuando los pregunte. Es lo primero a probar si no aparece el contexto del equipo al arrancar: sin esa aprobación los avisos no corren, aunque todo lo demás esté bien |
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
