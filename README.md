# pairs.kak
A simpler, manual version of auto-pairs, operating on the "limited smartedness principle".

It provides 2 main functionalities :
- insert matching pair at cursor location, with sensible selections extension
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

# installation
like any other plugin
todo todo.
