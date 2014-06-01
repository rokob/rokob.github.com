---
layout: post
title: "Eloquent Objective-C: Write Code That Looks Like Objective-C"
date: 2014-06-01 00:20:04
categories: code
tags: code objc eloquent
published: false
---

When I look at someone's code, I immediately make a value judgement about the likelihood
that their code will work and that the person knows what they are doing based on the
style of the their code. Basically, if the code matches my expectations for the language
and it is clear then I have a feeling that this person is probably legit. I know this is
not a great thing to do for some reasons, mostly that this should not be a sign of positive
quality but more a negative signal when the code is missing some of the qualities that
one expects. This is a similar filter to FizzBuzz. Most people who write code have no idea
what they are doing, they don't understand code design or architecture,
they have terrible naming and syntax usage, and they typically cannot solve the most basic
problems. Poor style is a strong indicator of a lack of skills in the same way as struggling
to complete FizzBuzz. This post is about what Objective-C is supposed to look like and why.

The most important set of guidelines for Objective-C that the community has accepted are
those handed down [from above][apple-guidelines]. You should read through all of these guidelines
at least once, if not multiple times as you encounter questions. The set of things that are
covered are:

* Code Naming Basics
* Naming Methods
* Naming Functions
* Naming Properties and Data Types
* Acceptable Abbreviations and Acronyms

Every language has to decide whether it uses snake_case or camelCase, and Objective-C has
chosen the camel. Don't fight it, consistent naming is incredibly important for writing
code that is maintainble.

[apple-guidelines]:  https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html