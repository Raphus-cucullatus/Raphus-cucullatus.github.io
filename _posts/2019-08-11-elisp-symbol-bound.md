---
layout: post
title: "Elisp Symbols: What are Symbol, Variable, \"boundp\", \"intern\" all about?"
date: 2019-08-11 00:00:00 +0800
categories: tech emacs
comments: true
---

Let's start from some small experiments.

### Symbols and Variables

First,

    (setq a (gensym))

Now with `gensym`, we have a new unique symbol (named "g1" in my machine).  And a new variable `a` is bound to this new symbol.

    (symbol-name a)				; => "g1"

Before a function is called, its arguments are evaluated.  In the expression above, `a` is evaluated to its value (the symbol `g1`).  And `symbol-name` returns the name of the symbol `g1`, "g1".

To return the name and value of `a` itself, "`quote`" or "`'`" can be used to let the arguments be evaluated to themselves.

    (symbol-name 'a)		     ; => "a"
    (symbol-value (quote a))	     ; => g1

First of all, `a` itself is a symbol.  Each symbol in elisp has 4 cells (components), among which are "name" and "value" cells.  The symbol `a` has a name of `"a"` and its value is another symbol (the symbol we created using `gensym`).

From here, we can see that *Symbol* is a low-level *mechanism*, and is used to implement the concept of *Variable* (and *Function*, and more).  Specifically, in elisp, a variable is implemented by a symbol: the variable's name is stored in the symbol's "name" cell, and the variable's value is stored in the symbol's "value" cell.

One can say that a variable is just a symbol under the hood.  But what is rather confusing for beginners is that, unlike other popular languages (e.g. C) who commonly hide *Symbol* and expose only *Variable* to the programmers, elisp use *Symbol* and *Variable* at the same time.  It is powerful, and sometimes overwhelming.


### `boundp`

    (symbol-value a)	              ; => Symbol’s value as variable is void: g1

Again, before `symbol-value` is called, `a` is first evaluated to its value (the symbol `g1`).

Then the evaluation of this expression gives an error message.  Indeed, we have created a symbol `g1` with its "value" cell unassigned.  In elisp, a variable is void if its symbol has an unassigned "value" cell.  Although we did not declare a variable `g1` (we only created such a symbol), but recall that *Variable* is implemented using *Symbol*, and from the *Variable*'s view, `g1` is a variable with its value unassigned.  So comes the error message.

In elisp, a void-variable (a variable whose "value" cell is empty) is also called unbound.

    (boundp 'a)				; => t
    (boundp a)				; => nil

The symbol `a` is bound since its "value" cell is non-empty (the value is the symbol `g1`).  While the symbol `g1` is unbound since we assigned nothing to it.

The "value" cell of a symbol can be emptied,

    (makunbound 'a)				; => a

`makunbound` empties the "value" cell of the given symbol and return the symbol.  Now accessing the value of `a` gives an error message too,

    (symbol-value 'a)			; Symbol’s value as variable is void: a


### `intern`

"interning" in elisp means put a symbol into a given symbol table (a global table named `obarray` by default), so that it can be searched instead of just a lonely structure.  Let's go through some examples to make it clear.

    (intern-soft 'a)			; => a
    (intern-soft a)				; => nil

1.  The `intern-soft` returning non-nil means the symbol `a` is "interned" (in the global symbol table `obarray`).
2.  The `inter-soft` returning nil tells that `g1` is an uninterned symbol (This echos the expected behavior of `gensym` who creates a new uninterned symbol).

Next,

    (intern-soft 'g1)			; => t
    (eq a 'g1)				; => nil

The above expressions may seem confusing at first glance!

It seems a contradiction that `(intern-soft 'g1)` returns `t` while `(intern-soft a)` returns nil.  Isn't `a` evaluated to `g1`?

The second expression gives us a hint: the value of `a` is different from the symbol `g1`.  When the function is called, lisp reader sees `g1` (note that it is not evaluated in the function argument evaluation phase due to quote).  It tries to search `g1` in the global symbol table but fails.  Then it creates a new symbol and interned it into the global symbol table.  This symbol also has a name "g1".

Therefore, the symbol we generated with `gensym` previously (and is pointed to by `a`'s value) and the symbol in the global symbol table are different objects, even though they have a same content in their own "name" cell.

This is also why we need a symbol table.  It enables us to find the exact symbol by a string name.  Otherwise, we end up with "talking in the same language but indicating different things"!

