---
title: Architecturalling *sic* or something
published: 2019-11-04
description: At first there's excitement then there's hair pulling
tags: ['typeorm', 'logging', 'dependencies', 'dependency injection']
---

I feel like I've not had any in-depth formal training as a web developer. I done a 5 month, 40 hours a week, 8+ hours a day "coding bootcamp" course and then got a job as a "full stack" web developer not too long after. I don't really consider that in-depth formal training. There was a lot that I felt I missed out on like the theory side of web development or software development in general. Mainly there was a lot of time spent on rote learning the technical skills required to get a job.

And that's great! I got a job! I was super happy!

Yes, there's a but. It's not a big one though. It's just that I'm seeing the limitations of this program as I'm working on this personal project. Here's the but; I literally have next to no experience in architecting a software, let alone a lambda function.

It's current architecture is based off of the [fullstack-tutorial](https://github.com/apollographql/fullstack-tutorial) by Apollo. I don't know if it's the best way to architect a lambda function. Hell, I was just happy to get it working when I first gave Apollo a test drive through this tutorial. I don't fault the Apollo team for this. I give them props for putting out such a comprehensive tutorial showing how to use Apollo Client and Server. I learnt a lot from it!

But, yes another but (do you want to start counting?), I'm coming across limitations as I stretch into increasingly unfamiliar ground, as I'm stepping beyond the comfort of the tutorial landscape. It feels like this has been a slow progress, but I've been seeing it coming. When I got the client and server hooked up and working on a basic level I felt I'd taken a step forward; when I transformed some auth code into a class I felt I'd take a step forward; when I adjusted the client logging library to implement using an API Gateway I felt I'd taken a step forward.

Basically there have been all these little steps forward where I felt like I'd learnt something or accomplished something beyond following a tutorial. Now I feel like I'm hitting another point where I'm going to have to go beyond a tutorial, but I'm not entirely sure if it's a limitation in the architecture I'm hitting or my lack of understanding.

What prompted this was a couple of reasons. The first was my implementation of TypeORM. I couldn't follow the pattern as set-out by the Apollo fullstack tute. Instead of passing the store into the datasource class into the constructor I had to import it in. I couldn't pass it through because it was an async function and had to be resolved to return the database object which was used to pass entities in to perform database actions on.

This didn't seem like the "right" way or **Best Practice** way of doing things.

The second was when I was creating a logging function. I wanted to set the options of the logger from the top scope, the scope in which a request enters first, and pass it down to the other elements like the datasources and auth function. I wanted to do this because I wanted to pass in some info from the event and context arguments.

I realised I couldn't do that. I'd have to import this function into the different components and set different options for information to pass through. These would overwrite each other because the options were globally set.

I wondered if there's a better way and... I don't actually know. This is where the in-depth knowledge would come in handy. I could've gotten that from a longer course dare I say it a "Software Developer" course. But alas, I didn't. Instead I'm left to rote learning architecture with a background hum of "Is this the best way to do this?" in my head.

And I cannot answer that! But what I realised I can do is look for those who seem like they might know. At the very least it seems like they know more than me. To that end I came across the idea of Dependency Injection. I don't fully understand it but I've come across an article by Martin Fowler about [Inversion of Control Containers](https://www.martinfowler.com/articles/injection.html) or Dependency Injection. I've also come across a [repo](https://github.com/tomyitav/apollo-typed-lambda) that implements Dependency Injection. I'm not sure if it follows the article.

So this is the way I find to increase my understanding and knowledge of architecturalling _sic_ or something kind of like that. The pitfall that I can see with this is tied in with the background hum above, except in this case it's more like "Is it appropriate to use **insert whatever architectural style here** in this situation?".

I cannot answer that. At least not yet. But if it solves the above two limitations then maybe, just maybe it is.
