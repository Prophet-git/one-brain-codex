# One Brain for Codex: the memory your team keeps losing

Every session starts from zero and forgets it all on close. One Brain gives Codex permanent
memory, shared by the whole team. What one person records, everyone has, with the name and
the date still attached.

[Create your brain](https://onebrain.prophet.lat) · Free during the open beta ·
[Leer en español](plugins/one-brain/README.md)

Using Claude Code instead? There's a [Claude Code build](https://github.com/Prophet-git/one-brain-plugin)
of the same brain.

## Getting in

All four steps matter. Skip one and the package installs but stays mute: no error, no
warning, you just never see your team's context.

1. Sign in with Google at [onebrain.prophet.lat](https://onebrain.prophet.lat) and copy the
   token it gives you.
2. Install the package from your terminal, outside Codex:

   ```sh
   codex plugin marketplace add Prophet-git/one-brain-codex
   codex plugin add one-brain@prophet
   ```
3. Open Codex. The first time, it asks whether you trust this package's hooks. Say yes. A
   freshly installed hook starts out unapproved and does not run, even though the package
   shows as installed and active. Without that approval you get no context at startup and
   nothing tells you why. Codex asks again after any update that touches those hooks.
4. Ask for the `one-brain:connect` skill and pass it your token. It gets stored in
   `~/.config/one-brain/token`, on this machine, readable only by you. One token per person
   per machine: connecting a different one moves this machine to that brain.
5. Restart Codex. It holds the copy of the package it loaded at startup and the token it read
   back then, so until you close and reopen it you keep seeing the previous state. There is no
   hot reload.

Ask for the `one-brain:status` skill to confirm which brain this machine is connected to, and
`one-brain:doctor` when something doesn't add up.

## Once it's connected

At startup it brings what's current for the team: decisions, what each person is on, your last
handoff, and any mentions left for you. While you work you can query the brain with
`brain_search` and `brain_context`, or record something yourself with `brain_save`. On close it
tells you if work went unrecorded and offers to distill it.

## Keeping it up to date

```sh
codex plugin marketplace upgrade prophet
codex plugin add one-brain@prophet
```

Then close and reopen Codex. If the update touched the hooks, approve them again.

## Your data

One Brain stores what your team decides and learns, not your repository. It doesn't read your
source code. Every brain is isolated from every other one, you can see and edit every entry,
and you can export the whole thing whenever you want without asking anyone.

More on the [security](https://onebrain.prophet.lat/seguridad) and
[privacy](https://onebrain.prophet.lat/privacy) pages.

## Support

[bautista@prophet.lat](mailto:bautista@prophet.lat) · Built by [Prophet](https://prophet.lat)

## License

Source-available, not open source: see [LICENSE](LICENSE). You can read and audit every
line before installing it, and run it against the One Brain service. You can't redistribute
it or point it at a different service.
