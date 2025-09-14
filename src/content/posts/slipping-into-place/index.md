---
title: Two, at least, ways of seeing solutions
published: 2019-12-03
description: A consideration of two ways of solution fetching
tags: ['formik', 'two ways', 'thinking', 'problem solving', 'solutions']
---

It's been a while since I wrote a blog post, almost two weeks. I haven't had the opportunity to sit down and type one out. A week ago I wanted to write a post about the blind spots in problem solving such as missing crucial bits of knowledge. This idea came from an issue I was having with the implementation, through [Formik](https://jaredpalmer.com/formik/docs/overview), of a modal using [react-modal](https://github.com/reactjs/react-modal).

I'd created a component of the modal, however, I got stuck in conditionally rendering the component because the modal component from the library took a boolean to render it. I had it in my head that I had to create a state in the component and change that state to conditionally rendering it or not. I was fiddling around with getting the best set of conditional statements using the state of the component I'd created.

It just wouldn't work and I was at wits end trying to figure out why. Then it struck me like a ton of duhhh bricks. I need to pass the boolean _into_ the component and not bother with creating state in the component itself. Once I realised that, I got it working.

This seems like a crucial part of React to me. How could I forget something so fundamental? This is interesting to me. I'm not sure how I missed this. It wasn't something that I was explicitly aware of. If someone asked me what happens when props are passed into a React component I could probably say it'd render that component, if the prop is different from when it previously entered. But for whatever reason I didn't think of it when I actually needed it and spent more time on figuring out how to get it working than I should've.

Not too long after that I got stuck braining it out on tweaking the relations between my database entities. I felt I didn't really understand how relationships actually worked. I thought about the entities as static, singular objects. I'm not sure why I thought about it this way. They looked singular on the entity relation diagram! But obviously they are not. I imagined them as the class instead of instances of the class. I thought about them as static objects. This prevented me from seeing the relations clearly. I had to explicitly think about what was going on and think about _how_ I was understanding the entities.

After a bit of researching, and thinking I saw what the relations actually meant and I created an appropriate relation between the entities I was using (as well as trim the fat from the database overall).

The reason I bring up these two situations in that there seem to be two different processes in play here. The first was a matter of being struck by a knowledge bolt. Once struck, I realised what I was doing wrong. Before that I was too busy focusing on solving the problem in the way that I believed was the solution. I didn't stop to question that maybe, just maybe it _wasn't_ the solution.

It wasn't after I exhausted as many options as I could think of to solve it within the parameters of my current solution that I became frustrated, felt I was getting nowhere, and thought it didn't make any sense. And it _actually didn't_ make any sense because I was applying an incorrect solution to the problem. You know, the whole square peg, round hole thing.

Then I stopped focusing on implementing my solution. I'm guessing this let my brain have a breather because the old bugga, out of nowhere, then gave me what I needed - the _actual_ solution.

Whereas the challenge I was having with understanding database relations required a different approach. I had to discover why I was misunderstanding the concept of relations. So I did some research, thought about it a bit, and saw the error of my way. Then I was able to create relations between the entities that made sense!

I'm not sure of the mechanism of these two ways. It might be useful to know. They remind me of the [Thinking, Fast and Slow](https://en.wikipedia.org/wiki/Thinking,_Fast_and_Slow). I'm also curious if there are any other "ways". It'll be something to keep an eye out for while traversing the coding landscape.
