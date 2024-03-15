# pairs.kak
A simpler, manual version of auto-pairs, operating on the "limited smartedness principle".

It provides 2 main functionalities :
- insert matching pair around the cursor, with sensible extension of the current selection
- surround selection with matching pair

Compared to auto-pairs :
Cons
- does not handle automatic indentation (yet ?)
- does not automatically insert and overwrite closing symbols out of the box, though I suppose one could add their own hooks. So requires more key strokes and modifier keys for the same result.
Pros
- Manual controls allows to support ambiguous delimiter such as <, >, | `, <ret>, <space> etc. which are used both as matching pairs and as individual symbols
- No hooks, no try catch, no weird hidden option => less chance to break with along other plugins, or kakoune base features.
- Speaking of which, it works with the repeat operation by default `.`, using kakoune from october 2023. As of now, it seems the interaction between auto-pairs and `.` has been broken for some years and is only now getting fixed.
- Works by default with multi selection, including a mix and match of 1-length and >1-length selection.

# Installation
like any other plugin
use plug.kak or copy paste
```
# pairs
plug "42xel/pairs.kak" config %{
  enable-pairs
}
```

# Usage
A user mode mapped by default to s (S for locking mode) with mapping for a dozen of single symbol pairs, easily extensible.
Some mapping in insert mode for most of them.
A function surround (-params 1..2) qaccepting a pair of arguments of arbitrary length.

For pairs of different symbols, such as <, >, the opening symbol is used for surround selection, the closing symbol for inserting a pair at cursor location :
```
map -docstring "insert a pair <> at cursor locations" global surround > # snip
map -docstring "surround selections with <>" global surround < # snip
map -docstring "surround selections with <>" global insert <a-\<>" # snip
map -docstring "insert a pair <> at cursor locations" global insert <a-\>> # snip
```
For pairs of identical symbols, such as | |, the symbol itself is associated to pair insertion in insert mode and surrounding in user-mode.
In any case, an alphabetic alias is available in user-mode :
```
map -docstring "insert a pair of chariot returns at cursor locations" global surround R # snip
map -docstring "surround selections with chariot returns" global surround <a-R> # snip
```

The command enable-pairs should provide some informations to make other pairings and change mappings.
