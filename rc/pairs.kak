### An opiniated manual pairing to make it easier to surround selection with parenthesis and such.
#
# Limited smartness
#
# Compared to auto-pairs :
# - no hook, no dynamic remapping
# - no remapping of default keys. Along with the previous point, it makes it works nicer with other functionalities hopefully, like `.` for a start.
# - you can surround the selection
# TODO tester multi selection and autopair. I got a hunch it doesn't work well together.
# Heck even VSCode's multi selection and auto autopair don't work well together.

## Composability
# thought with multi selection in mind from the ground up
# thought with . repetition in mind from the ground up
# in particular, standard commands don't go in or out of insert mode
# command with parameters. standard commands don't read magical persistent register.
# standard command count as zero or one step in the history (undo/redo, selection, jumps ...)
# command-completion ?
# user-mode
# mapping combined with count and register ?

# # yet another advantage of manual over auto is that an option is less of a neccessity
# # (the only downside to having more pairing than desired is shortcut space)
# declare-option -docstring "list of surrounding pairs" str-list pairs ()b {}B

define-command -hidden -params 2 surround2 %{
  evaluate-commands -save-regs 'lr' %{
    set-register l "%arg{1}"
    set-register r "%arg{2}"
    execute-keys -draft 'i<c-r>l'
    execute-keys -draft 'a<c-r>r'
  }
}
define-command -hidden -params 1 surround1 %{
  surround2 %arg{1} %arg{1}
}
define-command -docstring \
"surround <left_symbol> [<right_symbol>]: surround the selection with a pair of symbols."\
-params 1..2 surround %{
  %sh{echo surround$#} %arg{@}
}

# Disposable contexts start in normal mode, whereas non -draft context continue and alter the state of any given client.
# It implies that a command with non draft execute keys will behave differently depending on the mode it is called from.
# However, user-mode mappings are played in full from normal mode.
# In particular, entering surround mode from insert mode through <a-;> will actually yield correct results.
# More generally, a proxy user-mode would be incredibly helpful for both scripters and users alike.
# We could execute full command (or even commands, using mode lock) in normal mode from an insertion.
# TODO : see if proxy user-mode already exists.
define-command -hidden -docstring \
"insert-pair <left_symbol> <right_symbol>: auxiliary function, not intended for use. It is the normal -draft part of insert-pair."\
-params 2 __insert-pair-aux %{
  evaluate-commands -draft -save-regs 'lr' %{
    set-register l "%arg{1}"
    set-register r "%arg{2}"
    # TODO explain how selections function. Essentially, it depends on whether you are writing between the cursor and anchor.
    execute-keys -draft ';i<c-r>l'
    execute-keys -draft -save-regs '' 'H<a-;>H<a-;>Z\
;a<c-r>r'
    execute-keys -draft -save-regs '' 'zL<a-;>L<a-;>Z'
  }
}

define-command -hidden -docstring \
"insert-pair <left_symbol> <right_symbol>: insert a pair at cursor position"\
-params 2 insert-pair %{
  evaluate-commands -save-regs '^' %{
    __insert-pair-aux %arg{@}
    execute-keys 'z'
  }
}

define-command -hidden -docstring \
"insert-pair-insert <left_symbol> <right_symbol>: like insert-pair, but from insert mode"\
-params 2 insert-pair-insert %{
  evaluate-commands -save-regs '^' %{
    __insert-pair-aux %arg{@}
    execute-keys '<a-;>z'
  }
}

## mode surround() from global
# TODO register to automatically fill the mode, and count to be locked in it
# TODO enter ? semi-colon ?
# TODO custom surround
# TODO on-key ?
declare-user-mode surround

define-command -hidden -params 2 map-pair %{
  ## map for surround
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global surround "<%arg{2}>" "<esc>: insert-pair %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "surround selections with %arg{1}%arg{2}" global surround "<%arg{1}>" "<esc>: surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"

  ## map for insert
  map -docstring "surround selections with %arg{1}%arg{2}" global insert "<a-%arg{1}>" "<a-;>: surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global insert "<a-%arg{2}>" "<a-;>: insert-pair-insert %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
}

# TODO check that arg 3 is a (lower case) letter.
define-command -hidden -params 3 map-pair-alias %{
  ## map for surround
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global surround "<%arg{3}>" "<esc>: insert-pair %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "surround selections with %arg{1}%arg{2}" global surround "<a-%arg{3}>" "<esc>: surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
}

define-command -docstring \
"enable-pairs: enable the pairs from the module" enable-pairs %{
  map -docstring "surround mode" global user s ": enter-user-mode surround<ret>"
  map -docstring "surround mode" global user S ": enter-user-mode -lock surround<ret>"
  map-pair  (   )  ; map-pair-alias  (   )  b
  map-pair  {   }  ; map-pair-alias  {   }  B
  map-pair  [   ]  ; map-pair-alias  [   ]  r
  map-pair  lt  gt ; map-pair-alias  lt  gt a
  map-pair '"' '"' ; map-pair-alias '"' '"' Q
  map-pair "'" "'" ; map-pair-alias "'" "'" q
  map-pair '`' '`' ; map-pair-alias '`' '`' g
  map-pair  |   |  ; map-pair-alias  |   |  p
  map-pair space space ; map-pair-alias space space s

  # for new lines we need to raw insert enter
  # TODO indentation
  map -docstring "surround selections with %arg{1}%arg{2}" global surround <ret> '<esc>: surround "<c-v><ret>"<ret>'
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global insert <a-ret> '<a-;>: insert-pair-insert "<c-v><ret>" "<c-v><ret>"<ret>'
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global surround R '<esc>: insert-pair "<c-v><ret>" "<c-v><ret>"<ret>'
  map -docstring "surround selections with %arg{1}%arg{2}" global surround <a-R> '<esc>: surround "<c-v><ret>"<ret>'

}


