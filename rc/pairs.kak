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

define-command -hidden -params 2 pairs_surround2 %{
  evaluate-commands -save-regs 'lr' %{
    set-register l "%arg{1}"
    set-register r "%arg{2}"
    execute-keys -draft 'i<c-r>l'
    execute-keys -draft 'a<c-r>r'
  }
}
define-command -hidden -params 1 pairs_surround1 %{
  pairs_surround2 %arg{1} %arg{1}
}
define-command -docstring \
"pairs_surround <left_symbol> [<right_symbol>]: surround the selection with a pair of symbols."\
-params 1..2 pairs_surround %{
  %sh{echo pairs_surround$#} %arg{@}
}

# Disposable contexts start in normal mode, whereas non -draft context continue and alter the state of any given client.
# It implies that a command with non draft execute keys will behave differently depending on the mode it is called from.
# However, user-mode mappings are played in full from normal mode.
# In particular, entering surround mode from insert mode through <a-;> will actually yield correct results.
# More generally, a proxy user-mode would be incredibly helpful for both scripters and users alike.
# We could execute full command (or even commands, using mode lock) in normal mode from an insertion.
# TODO : see if proxy user-mode already exists.
define-command -hidden -docstring \
"pairs_insert-aux <left_symbol> <right_symbol>: auxiliary function, not intended for use. It is the normal -draft part of pairs_insert-aux."\
-params 2 pairs_insert-aux %{
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
"pairs_insert <left_symbol> <right_symbol>: insert a pair at cursor position"\
-params 2 pairs_insert %{
  evaluate-commands -save-regs '^' %{
    pairs_insert-aux %arg{@}
    execute-keys 'z'
  }
}

define-command -hidden -docstring \
"pairs_insert-insert <left_symbol> <right_symbol>: like pairs_insert, but from insert mode"\
-params 2 pairs_insert-insert %{
  evaluate-commands -save-regs '^' %{
    pairs_insert-aux %arg{@}
    execute-keys '<a-;>z'
  }
}

## mode pairs_surround() from global
# TODO register to automatically fill the mode, and count to be locked in it
# TODO enter ? semi-colon ?
# TODO custom pairs_surround
# TODO on-key ?
declare-user-mode pairs_surround

define-command -hidden -params 2 pairs_map %{
  ## map for pairs_surround
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global pairs_surround "<%arg{2}>" "<esc>: pairs_insert %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "surround selections with %arg{1}%arg{2}" global pairs_surround "<%arg{1}>" "<esc>: pairs_surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"

  ## map for insert
  map -docstring "surround selections with %arg{1}%arg{2}" global insert "<a-%arg{1}>" "<a-;>: pairs_surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global insert "<a-%arg{2}>" "<a-;>: pairs_insert-insert %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
}

# TODO check that arg 3 is a (lower case) letter.
define-command -hidden -params 3 pairs_map-alias %{
  ## map for pairs_surround
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global pairs_surround "<%arg{3}>" "<esc>: pairs_insert %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
  map -docstring "surround selections with %arg{1}%arg{2}" global pairs_surround "<a-%arg{3}>" "<esc>: pairs_surround %%🐈<%arg{1}>🐈 %%🐈<%arg{2}>🐈<ret>"
}

define-command -docstring \
"pairs_enable: enable the pairs from the module" pairs_enable %{
  map -docstring "pairs_surround mode" global user s ": enter-user-mode pairs_surround<ret>"
  map -docstring "pairs_surround mode" global user S ": enter-user-mode -lock pairs_surround<ret>"
  pairs_map  (   )  ; pairs_map-alias  (   )  b
  pairs_map  {   }  ; pairs_map-alias  {   }  B
  pairs_map  [   ]  ; pairs_map-alias  [   ]  r
  pairs_map  lt  gt ; pairs_map-alias  lt  gt a
  pairs_map '"' '"' ; pairs_map-alias '"' '"' Q
  pairs_map "'" "'" ; pairs_map-alias "'" "'" q
  pairs_map '`' '`' ; pairs_map-alias '`' '`' g
  pairs_map  |   |  ; pairs_map-alias  |   |  p
  pairs_map space space ; pairs_map-alias space space s

  # for new lines we need to raw insert enter
  # TODO indentation
  map -docstring "surround selections with %arg{1}%arg{2}" global pairs_surround <ret> '<esc>: pairs_surround "<c-v><ret>"<ret>'
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global insert <a-ret> '<a-;>: pairs_insert-insert "<c-v><ret>" "<c-v><ret>"<ret>'
  map -docstring "insert a pair %arg{1}%arg{2} at cursor locations" global pairs_surround R '<esc>: pairs_insert "<c-v><ret>" "<c-v><ret>"<ret>'
  map -docstring "surround selections with %arg{1}%arg{2}" global pairs_surround <a-R> '<esc>: pairs_surround "<c-v><ret>"<ret>'

}


