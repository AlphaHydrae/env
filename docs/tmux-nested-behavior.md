# Nested tmux Behavior

This document explains how nested tmux behavior works in this repo, including
the state model, transition triggers, and which scripts are responsible for each
step.

## Goal

When tmux is used inside another tmux (often via SSH), the outer and inner
sessions should not fight for control.

- The outer tmux should become passive when controlling an inner tmux session.
- The inner tmux should use a distinct visual mode.
- Status indicators should make the current control/mode state obvious.

## Quick Triage

When nested behavior seems wrong, run these checks inside tmux first.

1. Confirm current nested state:
  - `tmux show -gv @nested_mode`
  - `tmux show -gv @nested_role`
  - `tmux show -gv @nested_passive`
2. Confirm prefix was not lost during passive handoff:
  - `tmux show -gv prefix`
  - `tmux show -gv @nested_saved_prefix`
3. Confirm status scripts resolve correctly from config wiring:
  - `tmux show -gv status-left`
  - `tmux show -gv status-right`
4. Enable debug logs for detection decisions when needed:
  - `tmux set -g @nested_debug 1`
  - Inspect `${TMPDIR:-/tmp}/tmux-nested-debug.log`

If mode/role is incorrect, focus on `tmux/auto-nested-init.sh` and hook wiring
in `.tmux.conf`. If styles are wrong with correct mode/role, focus on
`tmux/set-nested-mode.sh`. If key handoff is wrong, focus on
`tmux/set-nested-control.sh`.

## Core Concepts

There are two related concepts tracked in tmux options:

- `@nested_mode`: visual/control mode
  - `active`
  - `passive-outer`
  - `passive-inner`
- `@nested_role`: perspective of this tmux server
  - `outer`
  - `inner`

Additional flags:

- `@nested_passive`: `1` when outer session is passive, otherwise `0`
- `@nested_debug`: enables debug log writes in `auto-nested-init.sh`
- `@nested_auto_over_ssh`: allows TERM+SSH fallback for nested detection
- `@nested_saved_prefix`: remembers original prefix while outer session is passive

Theme-related shared inputs:

- `@theme_segment_separator`: separator glyph used by tmux status/window helpers
- `@theme_*`: shared palette values consumed by tmux helper scripts

## Files and Responsibilities

- `.tmux.conf`
  - Defines keybindings, hooks, theme values, and status composition.
  - Wires all helper scripts in `tmux/`.
- `tmux/auto-nested-init.sh`
  - Decides whether current session should start as nested or non-nested.
  - Applies `passive-inner` or `active` through `set-nested-mode.sh`.
- `tmux/set-nested-mode.sh`
  - Applies the full visual/style profile for a mode + role pair.
  - Persists `@nested_mode`, `@nested_role`, and `@nested_passive`.
- `tmux/set-nested-control.sh`
  - Runtime control handoff between outer active and outer passive.
  - Saves/restores prefix and root keybindings.
- `tmux/left-status.sh`
  - Renders SSH/user@host/environment segments.
- `tmux/right-status.sh`
  - Renders backup, CPU/MEM, and time (time hidden in inner role).

## Detection Inputs

`auto-nested-init.sh` uses multiple signals:

- Client terminal identity (preferred): `#{client_termname}`
- Hook-provided terminal/session values (if available)
- Environment fallback:
  - `TERM`
  - `SSH_TTY` or `SSH_CONNECTION`
  - `TMUX_NESTED_HINT`

The explicit hint `TMUX_NESTED_HINT=1` is strongest and is used by `sshx`.

## Startup and Hook Flow

Configured in `.tmux.conf`:

- `run-shell ... auto-nested-init.sh startup ...`
- Hook callbacks:
  - `client-attached`
  - `client-session-changed`
  - `session-created`
  - `after-new-session`

Each invocation can re-evaluate nested context and re-apply expected mode.

## State Transition Summary

1. Non-nested startup
   - `auto-nested-init.sh` decides not nested.
   - It ensures `active` + `outer` (unless already set).
   - Visual style uses active palette and active window formats.
2. Nested startup (inner tmux)
   - `auto-nested-init.sh` detects nested usage.
   - It applies `passive-inner` + `inner`.
   - Right status omits clock to reduce duplication.
3. Manual outer handoff to passive

   Triggered by outer binding (`F12` or `S-Up` path):

   - `set-nested-control.sh passive`
     - Saves current prefix in `@nested_saved_prefix`
     - Sends `M-F12` to inner
     - Applies `passive-outer` + `outer`
     - Changes outer prefix to `M-F12`
     - Unbinds root control keys (`C-p`, `C-h`, `C-z`, `C-q`, `C-s`)
4. Return outer to active

   Triggered by outer binding (`F12` or `S-Down` path):

   - `set-nested-control.sh active`
     - Sends `M-F11` to inner
     - Applies `active` + `outer`
     - Restores saved prefix from `@nested_saved_prefix`
     - Rebinds root control keys
5. Inner signal handling

   Configured bindings in `.tmux.conf`:

   - `M-F12` -> apply `active` + `inner`
   - `M-F11` -> apply `passive-inner` + `inner`

   This lets outer and inner coordinate state changes without manual inner
   commands.

## Status Behavior

### Left status

- SSH badge when on SSH context.
- `user@host` context, with root marker when needed.
- Optional environment badge from host-environment helper.

### Mode marker segment

Mode marker branch order in `.tmux.conf`:

1. `passive-outer` -> `PASS`
2. `passive-inner` -> muted dot
3. active + prefix -> blue chevron
4. active + copy mode -> `COPY`
5. active + synchronized panes -> `SYNC`
6. fallback -> cyan dot

### Right status

- Backup freshness indicator (cached)
- CPU and memory metrics
- Clock only when role is not `inner`

## Integration with ZSH

- `oh-my-zsh/env.zsh` sets `TMUX_NESTED_HINT=1` for SSH sessions launched from
  tmux-like terminals.
- `oh-my-zsh/functions.zsh` (`sshx`) explicitly injects `TMUX_NESTED_HINT=1` for
  remote tmux startup from inside tmux.

This reduces reliance on weaker heuristics and improves nested detection
consistency.

## Debugging and Troubleshooting

### Enable debug logging

Set in tmux:

- `set -g @nested_debug 1`

Then check:

- `${TMPDIR:-/tmp}/tmux-nested-debug.log`

### Common symptoms and likely causes

- Outer/inner styles do not change:
  - Helper script path resolution in `.tmux.conf` is broken.
- Always active when nested:
  - `TMUX_NESTED_HINT` missing and SSH fallback not matching.
- Prefix not restored after passive:
  - `@nested_saved_prefix` missing/overwritten.
- Right status missing clock in normal session:
  - `@nested_role` unexpectedly set to `inner`.

### Useful checks

Run inside tmux:

- `tmux show -gv @nested_mode`
- `tmux show -gv @nested_role`
- `tmux show -gv @nested_passive`
- `tmux show -gv prefix`

## Maintenance Notes

If changing nested behavior, keep these invariants:

- `set-nested-mode.sh` is the single source of truth for style application.
- `set-nested-control.sh` owns runtime key/prefix handoff.
- `auto-nested-init.sh` only decides nested vs non-nested startup role/mode.
- `.tmux.conf` wires bindings/hooks and status composition, but should not
  duplicate mode logic.

If changing key signals (`M-F11`/`M-F12`), update both outer control script and
inner signal bindings together.
