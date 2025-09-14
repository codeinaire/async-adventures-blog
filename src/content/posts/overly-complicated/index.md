---
title: Overly Complicated
published: 2019-10-22
description: When a potential solution is a tangled mess untangle the thread and simplify it!
tags: ['jest', 'musing', 'testing library', 'react', 'async', 'formik', 'gamification']
---

Today I started the morning by researching `Gamification`. This is a when app introduces game mechanic elements to increase its useability and enjoyment for the users. I'm learning about this because I'm working on an app that will have this at its core. It's a broad field and there is a lot to learn, but what I've learnt so far is that Self Determination Theory (SDT) is a fundamental framework from which to understand Gamification.

SDT is a humanist theory of motivation and personality that proproses the idea that self-development fundamental to our health and well-being. It rests on three aspects, namely, autonomy, competence, and relatedness. These three elements work together in conjunction with and mediate a persons intrinsic motivation which is the driver for their behaviour. There's a lot more to it, but it's helping me get a clearer understanding of potential ways to implement gamified features.

I was intending to start to implement a logging feature that I'd be able to use for whatever features I'll implement in the future. However, I got stuck on testing the validation function that I implemented for the `Formik` forms. I took an annoyingly long amount of time to finally get a solution. Now that I look back on it the biggest problem was a combination of a lack of understanding what was **actually** going on and overly complicating any potential solution.

The underlying problem was that `Jest` runs its code synchronously while `Formik` run's its handlers asynchronously. This caused me much confusion! Not to mention a bunch of confusion coming from the weird result I was getting from the debug statements I had strew throughout.

In then end it came down to me stripping back all the `awaits` I had littered through-out a couple of the tests that I was focusing on and seeing what happens without them. They'd made their way in these tests through my partial understanding of the problem. I'd read a potential solution in the pages of a github issue and try to apply it as a solution. It'd work, but only partially.

At one point in my half-blind copypasta problem-solving I thought I had it functioning correctly but when I changed my code THE TESTS STILL PASSED. Now **that** makes for useless tests!

In any case, I strip a test back to the bare necessities and gradually added `async/await` logic in. What eventually brought back the beloved green was adding in a `wait` function from [Testing Library](https://testing-library.com/). Happy days!

BTW - Testing Library is great! It's a wonderful replacement for `Enzyme`. It what originally helped me solve the `Formik` async issue I was having.
