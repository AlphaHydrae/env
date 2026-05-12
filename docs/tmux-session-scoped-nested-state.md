# Session-Scoped Nested tmux State Plan

## Desired Outcome

Nested control and visual state should be isolated per tmux session instead of
shared across the entire tmux server.

When one local session enters nested mode, other local sessions attached to the
same server should keep their own state unchanged.

## Current Behavior

Nested state is currently server-global because options are written and read as
global user options:

- @nested_mode
- @nested_role
- @nested_passive
- @nested_saved_prefix

These are updated by [tmux/set-nested-mode.sh](tmux/set-nested-mode.sh),
[tmux/set-nested-control.sh](tmux/set-nested-control.sh), and
[tmux/auto-nested-init.sh](tmux/auto-nested-init.sh), with hooks wired in
[.tmux.conf](.tmux.conf).

## Target Behavior

- Each tmux session should maintain its own nested state and saved prefix
  independently.
- Two sessions on the same server should be able to show different nested
  mode/state at the same time.

## Required Changes

1. Move nested options from global scope to session scope.
2. Ensure every read/write of nested options addresses the correct target
   session.
3. Keep existing keyboard behavior and visuals unchanged from the user
   perspective.
4. Keep startup and hook behavior deterministic when multiple clients/sessions
   are attached.

## Implementation Outline

### 1. Define session-aware option helpers

Add helpers in a shared script (or in each script if preferred) to centralize
option access:

- session option set: tmux set-option -t <session> -s <name> <value>
- session option get: tmux show-options -t <session> -sv <name>

Helpers should resolve a session name in this order:

1. Explicit script argument
2. Hook-provided session name
3. #{session_name} from current client context

### 2. Update set-nested-mode.sh

Convert all nested state writes to session-scoped writes for:

- @nested_mode
- @nested_role
- @nested_passive

Ensure script accepts an optional session identifier so hooks can target the
correct session.

### 3. Update set-nested-control.sh

Convert reads/writes of:

- @nested_saved_prefix
- @nested_passive

to session scope.

Keep prefix/binding operations scoped to the intended session target where
possible.

### 4. Update auto-nested-init.sh

Read and write nested state per session.

Hook invocations already pass a session name from [.tmux.conf](.tmux.conf); use
that argument as primary context and avoid implicit global reads.

### 5. Update .tmux.conf formats

Audit status format expressions that read @nested_*.

Confirm they resolve using session context and do not rely on global option
lookup.

If needed, use explicit format expressions that read session option values in
the current session context.

### 6. Backward compatibility fallback

During transition, allow scripts to:

1. read session option first
2. fall back to global option if missing
3. migrate value into session option on first write

This avoids abrupt behavior changes for long-running servers.

## Validation Checklist

1. Start two local sessions on same server.
2. Put session A into nested passive mode.
3. Verify session B remains active.
4. Toggle A back to active and verify no side effects in B.
5. Attach/detach clients across both sessions and verify state remains
   session-specific.
6. Verify status-left/status-right and mode marker accuracy in each session.
7. Verify SSH nested detection still works and only affects the targeted
   session.

## Risks and Notes

- tmux option scoping is subtle; incorrect scope flags can silently fall back to
  globals.
- Existing hooks that execute without a clear session context must be guarded.
- Prefix handoff logic is the most sensitive area and should be tested first.

## Out of Scope

- Redesigning key bindings.
- Changing visual theme values.
- Changing remote sshx semantics.

## Follow-up Task Entry Point

When implementing, start from:

1. [tmux/set-nested-mode.sh](tmux/set-nested-mode.sh)
2. [tmux/set-nested-control.sh](tmux/set-nested-control.sh)
3. [tmux/auto-nested-init.sh](tmux/auto-nested-init.sh)
4. [.tmux.conf](.tmux.conf)

Then run the validation checklist above end-to-end.
