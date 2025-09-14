---
title: Crystal Clear Problem
published: 2019-09-26
description: A musing on the lack of knowing and understand as to the problem and the solution.
tags: ['apollo', 'musing', 'apollo links', 'practice']
---

Yesterday, during part of my afternoon session I was struggling to find a way to pass the access token to the Authorization header. I’d taken it from the Auth0 login redirect and saved to the local cache. I wasn’t entirely sure why it wasn’t working. I quickly realised that the initial state I was using to hydrate the local cache was being overridden by the initial state, which I’d made an empty string, with every single refresh.

Easy fix. I thought it’d be a simple matter of putting a conditional before the query that wrote the initial state to the cache. It would test whether the user was signed in. I’d set this to be a boolean in local storage that'd be set to true after the user logged in.

Makes sense right!? It sure did. Until I implemented it.

I got an error about how the localStorage method wasn’t available. This confused me. It’s available in the window, why’s it undefined!? I tried to access the cookie storage, but got a similar error. I did a bit of googling and realised that the withApollo function being used in App.js was server side rendered. Of course, there’s no local storage method in that environment.

I figured I could do some conditional magic. I would add some logic to test whether it’s in the browser and if it is it’ll get access to the local storage and then another conditional to test if the user is signed in and then do a read of the cache for the access token and etc. Things seemed to be getting a bit complicated. Surely, it couldn’t be THAT hard get an access token in the authorization header.

With that suspicion in mind I scoped out the Apollo docs, looked up how others had implemented the Authorization header, investigated the next-with-apollo source code hoping I’d glean some hints from it, scoured stackoverflow, and also the Apollo forum. I didn’t explicitly KNOW what exactly.

I remembered seeing the Apollo docs implementing exactly what I wanted. I didn’t really understand what was going on, nor why it was necessary to do it that way so it didn’t really occur to me that it’d be a solution. But it was the solution. I implemented what the docs showed and it worked. I read more about why it was necessary and got a better understand about how Apollo works.

This process is interesting to me and seems to be a common theme in my development as a developer. I’m wonder if there is a way to quicken this process or short-circuit it so as to not get stuck too long in the “I-don’t-even-know-what-a-possible-solution-actually-is” phase. There has to be a certain degree of awareness about what I know is going on and also of the actual problem. Perhaps, if I more clearly stated and broke down the problem I’d be more clearly guided to an answer.

That’d make a good practice in my software development development - clear articulation and break down of the problem.
