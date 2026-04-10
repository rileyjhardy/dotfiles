# Personal Claude Rules — Riley Hardy

## Environment

- macOS, zsh, Neovim, tmux, Ghostty
- Version manager: asdf (not rbenv, nvm, etc.)
- Dotfiles managed with GNU Stow at `~/.dotfiles/`

## Communication

- Explain the reasoning behind changes — context is valuable
- Keep explanations in responses, not in code comments
- Do not add code comments unless they are necessary to understand a domain-specific problem that isn't obvious from the code itself

## Ruby Style

- Use the `it` keyword (Ruby 3.4+) instead of block parameters in single-line blocks (e.g., `users.map { it.name }` not `users.map { |u| u.name }`)
- Prefer `tap` to avoid intermediate variable assignments
- When iterating on migrations that haven't been deployed to production, rollback and edit the existing migration instead of creating new ones — keep the migration list clean

## Git

- Commit messages should explain **why** the change was made, not what changed — the diff speaks for itself
- Keep commit message subjects concise; use the body for motivation and context when needed
