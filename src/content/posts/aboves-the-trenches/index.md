---
title: Above the trenches
published: 2019-10-29
description: When madness is really negligence, what gives birth to the baby of negligence?
tags: ['logging', 'uml', 'activity diagram', 'class diagram', 'abstractions']
author: John Stewart
---

The heretofore mentioned "madness" of API Gateway was, to no-one's surprise I'm sure, _not_ madness. Unless we are now counting a lack of RTFM as madness. In some respect it could be, but in this situation it wouldn't be an apt description. It'd be better described as regular everyday negligence.

If I'd cared to look [here](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration_response.html) I would've seen the seen the note at the top of the page about how the integration response resources depends on the integration resource. If I wanted a clear run, which I most certainly did, I might need to explicitly make the integration response resource aware that it depends on the integration resource.

However, it's not that I didn't care to look, like it was something I knew about and was actively ignoring. I _wanted_ a solution! I cared about _the_ solution! So what did I do but follow the _problem_. If I couldn't solve the issue within 5 seconds I turned to the well worn habit of The Googles. Throw the error message into The Googles then dive into the various Stack Overflow posts and github issues. And it's worked before what's not to trust.

Well, it can sometimes lead one astray. I was taken to a seemingly relevant github issue that had the _exact_ error message as mine, the answer _must_ be here. By the time I started to read the issue I came to the conclusion that I actually didn't want to read it, that my capacity for understanding this type of material had reached it's limit for the time. It was at the end of the working day, I was feeling the solveamine hit after successfully setting up API Gateway tinged with frustration when it didn't completely work, and slightly weary from an enjoyably social weekend with a couple of late nights.

Basically, I wasn't in an optimal condition. This combined with a narrow focus on a specific problem and the fact that it worked once before didn't bring to mind that it couldn't be something as simple as creating an explicit dependency between two resources.

I had a half formed thought that my terraform configuration could've been an issue because I wasn't getting a clean apply. I'd always had to apply again just to get the integration response provisioned. In the past I've noticed that for certain settings to work with API Gateway I'd have to destroy the currently provision infrastructure then provision the updates I've made otherwise it wouldn't run the updated infrastructure correctly. I was experiencing it this time around with the logs being sent to CloudWatch for an execution of an API Gateway endpoint. I updated my log settings from `INFO` to `ERROR`. If I just updated it the logs wouldn't show the error info, once I'd destroyed it and provisioned it anew I'd get the appropriate error info.

However, I didn't follow that half formed thought because I felt it'd be too much effort to investigate and I couldn't be bothered to get into the nitty gritty details of it. But that was based on the assumption that I would've had to read the details of some github issue. Instead, I would've solved it by simply doing a bit of RTFMing.

I guess future me might be wise to mental checklist the most basic things that I can think of before delving into the thickets of The Googles. There have been a few other situations in which I've done this. One that comes to mind is with Apollo Client. I was dumbfounded as to how to get the `Authorization` credentials into the request. I created a Stack Overflow question and asked someone online. It wasn't until I RTFM that I noticed `Apollo Link` and an example that was relevant to what I needed.

In _that_ situation the limiting factor was a lack of understanding of the how it works. I didn't even _know_ that a thing was necessary for its proper functioning because I didn't have an understanding about how that thing worked. I did a bit of reading of the Apollo docs and came to understand `Apollo Link` is necessary even though I don't understand the detail of Apollo's implementation.

Anyway, is this just a long blog that could've been TLDR'd as **RTFM**?

p.s. this was going to be a blog about the difference between thinking about designing an application using UML and it's various diagrams and the more detailed orientated coding. Hence, the title above the trenches. But it wasn't and I'm going to leave the title anyway.
