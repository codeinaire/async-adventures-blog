---
title: Get our log on
published: 2019-10-23
description: Traversing through the forest looking for the perfect log.
tags: ['logging', 'winston', 'aws-cloudwatch-logger-browser']
---

<div style="width:75%;height:0;padding-bottom:75%;position:relative;"><iframe src="https://giphy.com/embed/4C6OdjHNzIlvW" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/time-ren-stimpy-4C6OdjHNzIlvW"></a></p>

Everyone's favourite: LOG! Unfortunately, not the beloved fictional play toy of kids in the Ren and Stimpy universe, but the equally beloved virtual after thought of a function: LOGGING!

Well, I don't really know if it's an after-thought. I've not really had enough experience in the industry as to know how much it is thought about. I do know I wasn't taught anything about logging and we **must** take our `console.logs()` out of our code before we push it to prod. How embarassing it'd be for us to leave a stray `console.log()` in our code, how unprofessional, are we even software developers!? Or are just one step above monkey's bashing a keyboard with a stick!?

In anycase, I'm not here to write about the intricacies of developer shame, but about what I did today. I explored a bunch of different options for logging. I came across [Winston](https://github.com/winstonjs/winston). It claims to be a logger for just about everything and they are right about that! It can't do any logging for React! Not even with the [Winston Transport BrowserConsole](https://www.npmjs.com/package/winston-transport-browserconsole) library. No sire, it doesn't want a bar of actually working as intended.

I was having an issue with both of these packages. With Winston the issue had to do with an attempt to call the file system library for node. Why you doing that for Winston!? Oh, because you want to run in a node environment and not the browser. Fair enough. This little speed hump was solved by adjusting the `next.config.js` file and asking it to change the webpack configure to exclude the `fs` (I'm guessing File System) library. Bonza! It worked.

Yet, I was presented with another confoundment: `Module not found: Can't resolve 'dns' in '/Users/nousunion/Repos/noMeatMayProject/client/node_modules/pac-resolver’`. I wasn't sure what this was about because I assumed the browser module I added would **work** in the browser. Nup. There was a nifty way around this thanks to [this](https://stackoverflow.com/questions/51541561/module-not-found-cant-resolve-dns-in-pg-lib) Stack Overflow post. Praise the geniuses on SO!!! Oh how they have saved me so many times. I didn't bother with this b/c it seemed a bit too hacky for me. I'm a legit coder remember!

I eventually decided to give this [logger](https://github.com/ckckchoudhary/aws-cloudwatch-logger-browser) a go. I was hesitant at first because it's only been around for 3 months and I don't feel experienced enough to determine whether there's some surprise hack buried deep in the codebase. I did give it a look around and it seemed legit, furthermore it's a fork of this (package)[https://www.npmjs.com/package/aws-cloudwatch-log]. This put my niggling concerns at ease so I dove straight in.

I bumped into the previous file system error and decided to succum to the dark side and get my hacky on. It worked! I setup the appropriate permissions on AWS and got it to send logs to CloudWatch. Oh yeah, that's what I wanted to do in the first place. Send logs to CloudWatch. Yay!

I also was able to remove the hackiness because... well, I don't know why. It started to work after I removed it. I like to do that. Take stuff out that doesn't seem necessary to see if it'd still work.
