# herdr

[herdr](https://herdr.dev) is the terminal multiplexer, used instead of tmux. The hierarchy is
**workspace (one per project) > tab > pane**. Config: `home/dot_config/herdr/config.toml`, scripts
in `home/dot_config/herdr/scripts/`.

## Keys

The prefix is `ctrl+a`. Modifiers pick the target: **shift = workspace, alt = agent**.

| Key | Action |
|-----|--------|
| `prefix+v` · `prefix+s` / `prefix+minus` | Split pane |
| `prefix+hjkl` · `ctrl+shift+hjkl` | Move between panes |
| `prefix+1..9` · `prefix+n/p` · `prefix+ctrl+h/l` · `ctrl+alt+h/l` | Tabs |
| `prefix+shift+1..9` · `prefix+shift+j/k` | Workspaces |
| `prefix+alt+1..9` · `prefix+alt+j/k` | Agents |
| `prefix+shift+v` · `prefix+alt+v` | Break a pane into a new tab · join it into another tab |
| `prefix+shift+e` | Close every other pane in the tab |
| `prefix+shift+o` | Open the pane's directory in Finder |
| `prefix+o` | Jump to the pane that raised a notification |
| `prefix+comma` | Settings |

Popups:

| Key | Popup |
|-----|-------|
| `alt+s` · `ctrl+alt+s` · `prefix+shift+s` | workspace-jump |
| `prefix+alt+g` | lazygit |
| `prefix+ctrl+c` | Claude Code |
| `prefix+alt+t` | Shell |

Ghostty sends `cmd+t` (new tab), `cmd+w` (close workspace), `ctrl+tab` / `ctrl+shift+tab`
(next / previous tab) as prefix sequences, and `shift+enter` as a newline for agents.

## workspace-jump

`scripts/workspace-jump.sh`, an fzf popup that opens or creates the workspace for a project.

- The list: open workspaces with their agent status, most recent first and the current one last,
  marked `(current)`; then recently opened paths, zoxide and ghq. The top row is the last workspace,
  so `enter` right away goes back to it.
- Rows stream in, so the popup opens at once. The ghq repo list comes from
  `~/.cache/herdr/ghq-list`, refreshed in the background on every launch.
- The right pane shows the agents of the workspace under the cursor: status, tab, role, worktree
  (`main` for the main checkout, `⎇ <name>` for a linked one) and task.

| Key | Action |
|-----|--------|
| `enter` | Open or focus the workspace, or focus the agent |
| `→` | List the agents of the open workspace under the cursor |
| `←` | Back to the workspace list |
| `ctrl-x` | Close the open workspace under the cursor (asks first if an agent is working) |

When the query matches nothing, `+ clone <query>` (ghq get) and `+ create <query>` appear.
ghq repos are labelled `owner/repo`.

## Sidebar

Claude agents show the workspace and tab, then the task from Claude Code's terminal title
(`[ui.sidebar.agents.rows_by_agent]`). Agents are ordered by workspace, the default
`agent_panel_sort = "spaces"`.

## Agent roles

`~/.claude/hooks/agent-role.sh` runs before each skill or subagent and reports the role it plays
as the pane token `role`: plan, research, build or review, each with a Nerd Font icon. The
skill-to-role table lives in that script; unlisted skills leave the role as it was, and a new
session clears it. The sidebar shows it as `$role`, workspace-jump next to the tab.

## Agent integration

```bash
herdr integration install claude   # agent state for Claude Code
herdr integration install pi       # see docs/pi.md
herdr integration status           # installed versions
```

The generated hook and extension are not in the repo; reinstall them after a herdr update. The
Claude installer also adds a SessionStart hook to `~/.claude/settings.json` that duplicates the one
already there; revert it with `chezmoi apply`.

## Sessions

Session restore is built in. The layout survives a server restart, and
`[session] resume_agents_on_restore` resumes agent conversations too.

## After editing the config

```bash
chezmoi apply
herdr config check            # validate config.toml
herdr server reload-config    # herdr does not watch the file
```
