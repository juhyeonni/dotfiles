# pi

[pi](https://pi.dev) is a minimal coding agent. Its config, `~/.pi/agent/settings.json`, is not
managed here: credentials (`auth.json`) and sessions live in the same directory.

## Settings

```json
{ "defaultTools": ["read","bash","edit","write","grep","find","ls"] }
```

pi enables only `read`, `bash`, `edit` and `write` by default. `defaultTools` turns on the built-in
`grep`, `find` and `ls` too. Check with `pi -p "list your tools"`.

- An unauthenticated `defaultProvider` / `defaultModel` falls back silently. Check with
  `pi auth check --provider <name>`.
- Global rules go in `~/.pi/agent/AGENTS.md`; a pi package cannot carry one.

## herdr

```bash
herdr integration install pi                        # ~/.pi/agent/extensions/herdr-agent-state.ts
herdr --skill > ~/.pi/agent/skills/herdr/SKILL.md   # lets pi drive herdr
```

Both files are generated; regenerate them after a herdr update (`herdr integration status` shows
the versions). With the skill, pi can open panes and start agents through the herdr CLI, but only
when the request mentions herdr.

herdr shows pi as working, done or idle. It never shows `blocked`, because pi has no approval
prompt for herdr to detect.
