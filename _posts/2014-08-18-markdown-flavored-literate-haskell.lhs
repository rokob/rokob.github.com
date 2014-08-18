---
layout: post
title: "Markdown Flavored Literate Haskell"
date: 2014-08-18 15:14:09
categories: code
tags: code haskell blog
---

I have been playing around with literate Haskell recently while working on some exercises
in [Types and Programming Languages][tapl]. The book uses OCaml for the implementations,
but I decided to do them in Haskell. I wanted a way to write a blog post in the same format
as my other posts, i.e. Markdown and processed by Jekyll. But I also did not want to copy
and paste a bunch of code examples from the implementations in order to talk about them.

Hence literate Haskell. I just write the code in a way that both the Jekyll processor can turn
in to HTML and which GHC can turn into executable bytes. It wasn't too hard to do this
either, although it was not 100% trivial. I wrote two new Jekyll plugins, one for
doing a little bit a preprocessing to the `.lhs` file to turn it into a Markdown file,
and another to load up the blog post as a module and execute commands via GHC in a subprocess
while the blog is being generated.

\## A simple function

Just to show some stuff in this post without going into all of the TAPL stuff that I want
to get to later, here are some function definitions in Haskell

> myfact 0 = 1
> myfact n = n * myfact (n-1)

> myfact' n = myfacttail n 1
> myfacttail 0 n = n
> myfacttail n m = myfacttail (n-1) m*n

You should probably know what these are.

\## Code execution

We can also easily execute code during the
blog generation pass and embed the results directly in the page. Without further ado:

{% ghci %}
:t myfact
myfact 100
:t myfact'
myfact' 100
{% endghci %}

That is pretty cool in my opinion. The output here is actually probably not that
cool, but if you look at the source and then at the output, the fact that all I had
to do was run `jekyll build` in order to get all of this put together is pretty neat.
You can see the plugins in the git repo for this blog on the `source` branch.
