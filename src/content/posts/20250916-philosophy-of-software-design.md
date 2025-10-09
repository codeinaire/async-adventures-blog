---
title: Designing Software Systems
published: 2025-09-16
description: On the principles of designing software in the context of complexity
tldr: |
  The fundamental challenge of software development is problem decomposition. This is breaking a problem down into smaller, comprehensible and solvable independent parts. The reason for this is to rally against complexity which is when a software system is difficult to understand. Complexity is caused by dependencies, which is when some code needs some other code to run, and obscurities, which is when important information isn't obvious. The signs of a software system being complex are:

  - Change amplification: when a small change in one part of a software system means an has unreasonable number of changes are required through out the rest of the system.
  - Cognitive load: this is how much a developer needs to know to perform a task within the software system such as implementing a feature. The more they need to know the higher the cognitive load and higher chances of bugs.
  - Unknown unknowns: this is when important and required information isn't available or obvious. This is the worse sign of complexity as the impact of this isn't known until a bug or some other issue reveals it.
tags:
  [
    'software design',
    'philosophy',
    'development',
    'design principles',
    'complexity',
    'computer science',
  ]
---

# In the Beginning

Around 8 years ago I started to learn how to code. I worked a job I hated and wanted a change. I saw coding as a way out and, thankfully, it was.

The quickest way for me to learn was through a coding bootcamp. I had a few months free before the bootcamp and decided to prepare by studying [Harvard's CS50 Intro to Comp Sci course](https://www.edx.org/learn/computer-science/harvard-university-cs50-s-introduction-to-computer-science). It was probably a mistake as it didn't really prepare me for the web development focused bootcamp, but it did make me aware of what the bootcamp was missing. While the bootcamp excelled at teaching the minimal level of skills required to competently get coding work done, it sorely lacked any teachings on algorithms, data structures, design patterns, and other important comp sci concepts.

It was fine that comp sci type teachings weren't offered in the bootcamp, after all we were on a tight deadline. We had 40+ hours a week for 20 weeks over a 5 month period to get enough skills under our belts to become employable junior fullstack developers. And it worked, mostly. The majority of our 30ish cohort were employed within at least a couple of months of finishing. It was one of the best career choices I'd made. I was super grateful to get my foot in the door and excited to start working.

My first job as a software developer was very challenging and often frustrating. I regularly got stuck on issues that were, due to my ignorance of coding or coding conventions, of my own making. It took me ages to get anything done as I didn't fully understood how the code worked or I continually questioned why the code was written the way it was and not another. It didn't really help that the codebase I worked on was a Rails project as I questioned its opinionated structure. Eventually, I realised that some code seemed better and easier to understand in spite of my limited experience of coding abstractions and design. By the time I was to move on from that role I had learnt a wide range of important technical skills and read a lot about coding but I still felt a confusion and uncertainty about why code was structured in one way and not another.

# A bit of a Revelation

However, when I left that role a senior software engineer gifted me The Philosophy of Software Design by John Ousterhout. It went a long way in clarifying the confusion and uncertainty more so than anything else I'd read about software development at the time. The coding bootcamp didn't teach me this and the CS50 course taught parts of it though not as a cohesive whole. But what either course certainly didn't teach was the why of certain patterns and design choices. John Ousterhout's book went a long way to doing that.

Before I get into that I'll tell you a bit about John Ousterhout in case you haven't heard of him. John was a [professor of comp sci at Stanford](https://web.stanford.edu/~ouster/cgi-bin/home.php) (he's retired) and has been working with software for about 45 years. He’s written 3 operating systems from scratch, multiple file and storage systems, debuggers, a scripting language, and interactive editors for text, drawings, presentations, and integrated circuits. And this was all before the era of vibe coding! So, he's very experienced in the world of software development and has had the opportunity to think about it deeply and look at it from many different angles. All those years of experience were distilled into a software design course that he taught and all that he learnt from the course was distilled into the software design book. Even though I'd say he's a bit of an authority on the subject he'd be the first to admit that he's isn't the final word on the subject.

Now, back to the book!

# Decomposing Problems

When the senior dev gave me "The Book" (obviously, said in hushed tones) all those years ago it was a bit of a revelation. It gave me a way to understand software development on a deeper level beyond the hodgepodge, though useful, design patterns and the disconnected, but reasonable, coding conventions. It gave me an understanding of software design grounded in abstracted principles that can be used to make concrete decisions. These principles are based on what John sees to be the fundamental problem of computer science: problem decomposition. He defines this as being able to take a complex problem and divide it up into pieces that can be solved independently. It's not something I'd ever thought about before. All the codebases I'd worked on had already decomposed the problems and any codebase I started myself I'd immediately implement the decomposition patterns I'd previously learnt. Basically, it had become an unquestioned convention.

Then I took a step back and wondered what would it be like if any of the codebases I worked on had all the code in one single file. Imagine that! All the Ruby or Node or JavaScript or whatever code was in just one. Big. File. No abstracting into functions or modules or anything else that would make the code easier to work with, just one big file full of code. That would be an absolute nightmare to work with! Yet, that doesn't happen because throughout the 80 or so years humans have been writing software we have come up with ways to decompose the problems of software development. From the go-to statements in assembly to functions with actual parameters in C to actual modules in modula-2 to object orientated programming in Smalltalk to functional programming with Haskell right up to today with the JavaScript explosion that introduced closures and functions as values amongst a whole variety of other languages available today.

But, why?

# Decomplexification

The only real physical limitation on us programmers is our access to compute and memory. Besides that, whatever we or others can conceive we can probably implement as a program. Entire new worlds have been created in virtual space that started as a single simple idea. For this reason, the more significant limitation on us is our ability to understand the system we are creating — it's our own minds that limit us. We have a max capacity on the amount of things we can hold in our head about a system at any point in time before we start having trouble understanding the system.

When we've reached or get close to reaching our max capacity of understanding it's likely to slow us down and increase the likelihood of bugs. After all, we've still got to get the new feature done, fix that bug, optimise a bit of code, etc all within reasonable time constraints that'll keep the various stakeholders happy. We understand it enough to get it working, to get the job down though it may not be enough to completely avoid bugs which probably won't be noticed until it's in production being used by a whole bunch of different people who don't care how it's meant to work.

Then it's on to the next feature and surprise a bug! and other people working on the codebase and the code gets more and more complex and...

This is why we've used problem decomposition to break a system down into manageable parts that we can understand as a totality in relation to the totality of other manageable parts. Thanks complexity, why you gotta be like that!

But, if we want to blame complexity it'll probably be a good idea to understand what it is.

# What Even is Complexity

O Complexity, Complexity whatfore art thou Complexity? Professor Ousterhout defines complexity as:

> anything related to the structure of a software system that makes it hard to understand and modify the system

This is a pretty straightforward definition that's grounded in our actual experience. We've all been there reading code and wondering WTF mate. Like I said at the start of this article, when I was learning it was hard to tell if it was me being dense or if the code was hard to understanding. But as I've gained more experience I became increasingly better at discerning this difference.

There are variable and function names that don't make sense or don't represent what they are doing, the overall structure of some code is tangled and not really logical, there's functions doing lots of different things, there's needless redundancy and duplication, etc. Overall, there's a difficulty in making changes to the codebase that can make it kind of annoying, frustrating, and full of WTF mate moments. These are all signs of code complexity.

We may have worked on codebases of varying sizes and it would be understandable to call larger codebases complex though not if they were easy to understand and work on. While relatively small codebases could be difficult to understand and work on. Size, in and of itself, doesn't necessarily determine complexity. Sometimes more code can make the codebase less complex.

This brings me to an important point. The reader of the code is more likely to be a better arbiter of what's complex code and what isn't. This makes sense to me. I know when I've been in the midst of writing code, making sure everything worked and made sense to me, I wasn't really thinking about how understandable it would be to others. It wasn't until it was pointed out to me by a peer that I was able to see how I can improve upon it and make it easier to understand which, in turn, decreased its complexity.

# Seeing Signs of Complexity

We may have come across code that is hard to understand and we have our own ways to define what makes code hard to understand. Thankfully, however, Professor Ousterhout has come up with some ways we can see the symptoms of complexity.

1. **Change amplification** - this is when a seemingly simple change requires code modifications in many different places. It could be a literal value that is used throughout the codebase but it doesn't use a const or enum so if that needs to be changed it has to be changed in all. The. Places. The. Value. Is. Used. That type of code is a symptom of complexity.

2. **Cognitive load** - this is how much a developer needs to know of the system in order to complete a task. When the cognitive load is higher we have to spend more time learning the required information to complete the task and the more time taken to do this the higher chance a bug could be introduced. I imagine this is why it's harder to integrate a new external service to an existing system because we have to understand the externals of a completely new system and how it can be integrated in our current system.

3. **Unknown unknowns** - this is when it is not obvious which pieces of code must be modified to complete a task, or what information a developer must have to carry out the task successfully. There was a codebase I was working on that had cloud functions using env vars. One of the functions was updated with new functionality that required a new env var but it wasn't added to the others because it didn't seem necessary. However, there ended up being an error because one function called another function and that function called the function with the new code. However, the new env var wasn't available in the context so an error was thrown. This dependency wasn't known but became known later through an error.

Out of the three, unknown unknowns are the worst. They are the little surprises that produce a massive influx of error messages from monitoring systems or random and unexpected crashes of a prod deploy when everything worked fine in local and staging. There was something that we missed but we didn't know we even missed it and it only comes about when the rubber meets the road aka when the end user does something completely out of left field.

The other two aren't as bad. If the code is clear and understandable having to change it in multiple places is more of an annoyance than a problem. If there's lot we need to know to make the desired change, at least we can know it and it won't be missed out on leading to unexpected results.

# You are the Alpha

You've seen the symptoms of complexity and surely you'd want to know what causes it, right? _stares intensely at you through the screen_ It's true, we do (kind of, thanks AI!) write the code so it's probably our fault that complexity exists. Well, yes in a manner of speaking but before you get flagellatting lets look at the factors that cause it and that can be avoided in order to design less complex systems.

The causes of complexity can be bucketed into the following two categories:

1. **Dependencies** - this is when a given piece of code cannot be understood and modified in isolation; the code relates in some way to other code, and the other code must be considered and/or modified if the given code is changed. We are all very familiar we dependencies, and not just external ones but those in our own codebase. Certain public functionality in a class are dependent on various methods inside that class. These are dependencies.

2. **Obscurities** - this occurs when important information is not obvious. This can happen when a function or variable name is ambiguous and doesn't align to what it's being used for or there's some dependency that isn't obvious. Basically, regardless of how much we read or search the codebase important information isn't clear.

It's not possible to get rid of dependencies in code, external or otherwise, and we wouldn't want to. They're doing important work. But we do want to make them clear and obvious, not obscure, so we know what we're working with.

# All in All

When I first started as a software developer all those years ago it was very difficult for me to see the difference between good and bad code as I was just learning to understand and write code. Gaining more experience helped but when I combined that with the conceptual framework provided by Professor Ousterhout in his book The Philosophy of Software Design I felt a shift in my understanding. It was a deepening that gave me a way to read, understand, and write code with design principles that I could apply to continually improve it by reducing the complexity.

Importantly, these principles are general enough to work with other ways of understanding and writing code. We have a direct and immediate response to code that's unreasonably difficult to understand. The concept of complexity applied to this experience by Professor Ousterhout helps us understanding that dependencies and obscurities contribute to this complexity. We can see this through change amplification and increased cognitive load though seeing unknown unknowns is a bit more difficult, but at least we know they exist.

Equipped with conceptual framework we can begin to understand where complexity arises in our codebase and start to minimise it. In future articles I'll cover in more detail the practical principles Professor Ousterhout outlines throughout the rest of his book.
