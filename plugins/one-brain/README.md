# One Brain para Codex

La memoria de tu equipo, adentro de Codex. Al arrancar cada sesión te trae el contexto vigente
—qué se decidió, en qué anda cada uno, dónde quedaste vos— y al cerrar guarda lo que avanzaste
para que lo tenga el resto.

## Instalación: cuatro pasos

Los cuatro hacen falta. Si salteás uno, el paquete queda instalado y **mudo**: no da error, no
avisa nada, simplemente nunca ves el contexto de tu equipo.

### 1. Instalá el paquete

En la terminal (no adentro de Codex):

```sh
codex plugin marketplace add Prophet-git/one-brain-codex
codex plugin add one-brain@prophet
```

### 2. Aprobá los avisos cuando Codex te los pregunte

Abrí Codex. La primera vez te va a preguntar si confiás en los avisos (*hooks*) de este
paquete: **decile que sí**.

Esto no es un trámite. Un aviso recién instalado nace sin aprobar y **no se ejecuta**, aunque el
paquete figure como instalado y activo. Sin la aprobación no recibís el contexto del equipo al
arrancar ni el recordatorio de guardar al cerrar, y nada te indica por qué.

Lo mismo vale después de cada actualización que toque esos avisos: Codex vuelve a preguntar
porque la aprobación está atada al contenido exacto del archivo. Si un día dejás de ver el
contexto al arrancar, empezá por acá.

### 3. Conectá tu token

Pedile el token a quien te dio acceso al cerebro (lo saca del panel) y, ya adentro de Codex,
pedí **la skill `one-brain:connect`** pasándole el token. Queda guardado en
`~/.config/one-brain/token`, en esta computadora, con permisos sólo para vos.

Un token es por persona y por máquina: si conectás otro, esta computadora pasa a ese cerebro y
sale del anterior.

### 4. Reiniciá Codex

Cerralo y abrilo de nuevo. Codex se queda con la copia del paquete que cargó al arrancar y con
el token que leyó en ese momento, así que hasta que no reinicies vas a seguir viendo el estado
anterior. No hay forma de recargarlo en caliente.

Listo: al abrir la próxima sesión tendría que aparecerte el contexto de tu equipo.

## Cómo saber si quedó andando

Pedí **la skill `one-brain:status`**: te dice si esta máquina está conectada y a qué cerebro.
Si algo no cierra, **la skill `one-brain:doctor`** revisa la instalación entera y te dice el
próximo paso concreto.

## Qué hace, una vez conectado

| | |
|---|---|
| **Al arrancar** | Te trae lo vigente del equipo: decisiones, en qué anda cada uno, tu último handoff y las menciones que te dejaron. |
| **Mientras trabajás** | Podés preguntarle al cerebro (`brain_search`, `brain_context`) y guardar a mano (`brain_save`). |
| **Al cerrar** | Te avisa si quedó trabajo sin registrar y te ofrece destilarlo con la skill `one-brain:session-capture`. |
| **Al soltar un proyecto** | `one-brain:proyecto-dejar` deja repo, cómo se levanta y las credenciales para que otro lo retome. |

## Actualizarlo

```sh
codex plugin marketplace upgrade prophet
codex plugin add one-brain@prophet
```

Y **cerrá y volvé a abrir Codex** (por lo del paso 4). Si la actualización tocó los avisos,
Codex te los va a volver a preguntar: aprobalos de nuevo.

Para ver qué tenés instalado: `codex plugin list`.

## Si algo no anda

1. **La skill `one-brain:doctor`** — revisa token, conexión, permisos y avisos, y dice qué
   hacer. Es el primer lugar donde mirar.
2. ¿No aparece nada del equipo al arrancar? Casi siempre es el paso 2 (los avisos sin aprobar)
   o el paso 4 (falta reiniciar).
3. ¿Sigue sin andar? Avisale a quien te dio el acceso.

---

Prophet · [onebrain.prophet.lat](https://onebrain.prophet.lat)
