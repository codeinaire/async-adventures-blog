---
title: Standing on the shoulders of regularly sized people
published: 2019-10-30
description: A non-comprehensive thought trail of why BSD license and the like are great.
tags: ['logging', 'open source', 'aws-cloudwatch-logger-browser']
---

I'm grateful for the open source licenses. They let us stand on the shoulders of each other.

I did such a thing today, thanks to a BSD license. This stands for Berkeley Source Distribution. I'm not surprised such a permissive license originates from Berkley, in particular from the University of California its home in Berkeley. The university and city are reputed to be a hotbed for civil rights protests and activism in general of the 60s. It makes sense that such a license would originate from Berkley. The first of such licenses was written for Unix in 1969.

Anyway, enough of the history lesson. Still, it's nice to look back on where the impetus for such a license originated. I'm sure there's more to it, but I'll hazard a guess that the prevailing zeitgeist of the time probably, at the very least, inspired the creation of the BSD.

In any case, whatever influenced the creation of the BSD, I directly benefitted from it today. Without it an inexperienced dev like me would've spent many hours, probably days, writing a small library to send buffered logs to CloudWatch - via an API Gateway endpoint - in the background of a React app without blocking any processes.

But it's not just writing the code that would've taken me days. I would've had to understand what would've be needed in a logging. It's a great idea for a logger to be non-blocking (that's why we have callbacks, promises, async/await) and to buffer the sending of the logs. But I'm not sure if I would've thought about that if I didn't know these were important aspects of a logger. I would've done some research and stumbled across such features but I doubt if I would've considered them myself.

Then I would've had to think about how to architect the library. How would've I implemented the buffering and non-blocking? I'm not sure off the top of my head, it's something I would've had to do more research to understand and then architect. This would've taken me more time.

All up I can imagine I would've had to do a few days of research to understand these concepts in a rudimentary manner, then architect the library, then write the actual code to implement the functionality. I could easily see all this taking around 10 days working around 5-6hrs a day to get it to the point where I'd be comfortable using it.

However, using standing on the shoulders of ordinary, regular people I was able to do it in half the time. Given I don't really know if this is the ideal base for a logging library. I could always have a look at [Winston](https://github.com/winstonjs/winston) to see how they structure their logging library. However, I'm not going to at the moment because this library is suitable for me.

I didn't change much of the library. I took out one of the functions, made sure the messages weren't being stringified because that caused a serialisation error in CloudWatch, removed the method to create an AWS4 signed call, and a few other smaller things.

[This](https://github.com/ckckchoudhary/aws-cloudwatch-logger-browser) is the library I forked and used, while [this](https://github.com/nicolasdao/aws-cloudwatch-logger) is that it was forked from.

Another great part of this was learning about how to implement these kind of features and thinking about how to improve it. One of the first things I would do would write it in Typescript and then create it as a class object.
