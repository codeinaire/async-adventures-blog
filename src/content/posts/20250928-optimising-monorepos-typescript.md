---
title: Optimising a Monorepo's TypeScript Config
published: 2025-09-28
description: Learning to how optimise typescript config for a monorepo
tags:
  [
    'developers',
    'productivity',
    'typescript',
    'configuration',
    'monorepo',
    'compilation'
  ]
---

# This's What's Up

I've been working with the global team at Antler, [a global VC](https://www.antler.co/), for close to a year now. A couple months ago I introduced the idea of a sprint dedicated to quality of life improvements for Antler's internal platform, Hub. Feature work would be put aside and us engineers would focus on bugfixes, tech debt, performance improvements, etc. I called it the platform investment sprint, aka the 🥧 sprint, but it goes by other names such as stabilisation/tech debt/refinement sprint.

There was broad interest within the tech team. We dogfood our own product and have received feedback from end users so know the pain points that could do with a soothing touch from us engineers. However, to noone's surprise, there were competing priorities and a seemingly endless list of features that we wanted to build so it wasn't a priority. Eventually, I was able to persuade the broader tech team (think PMs, VP of Engineering, and the principle engineer) of its benefits and after finishing a bunch of big features we decided to finish the quarter with such a sprint.

It was the first sprint of its kind we'd done and us developers wanted to improve the quality of life for end users as a way prove the benefit of having a 🥧 sprint. With that in mind we wanted to focus on cleaning up the frontend code (reducing bundle size, lazy loading, code minimisation, etc), optimising backend query performance, and optimising the TypeScript (TS) configuration for the Hub's monorepo, something I wanted to do since starting at Antler.

I'm no expert at TS but the way the various TS configuration files were setup, with minimal inheritance and duplicate config keys throughout the projects, gave me the feeling a refactoring was long overdue. However, the most annoying issue, from a developer point of view, was the fact the IDE's TS engine kept crashing and the IDE's TS functionality wasn't consistently available. Though I also saw the potential to get some wins for our end users by, hopefully, reducing the bundle size that, in turn, would improve load times.

I was certain I could fix the IDE issue, important for developer productivity, but not sure if I could reduce the bundle sizes enough to have a noticable impact. I had a working knowledge of TS and minimal experience tinkering with TS configuration though I certainly wasn't an expert in refactoring and optimising the configuration of a monorepo. The challenges I had with understanding TS config was the number of configuration options, understanding how each option was relevant, and how they related to one another. But with my questionably trustworthy LLM pals I dove into the refactor with a clear mind and hopeful to achieve the goals I set out!

# Getting into the Weeds

My primary goal was to make sure that after I refactored the TS config files everything worked like it did before the refactor but better! Essentially, I didn't want to break anything while, at the same time, unbreaking the IDE TS functionality and reducing bundle size.

The first thing I had to do was understand the structure of the various `tsconfig` files and what they were used for. The basic structure of Hub's monorepo is as follows:

- Frontend
  - Main app - Next.js
  - Other app - Next.js
- Backend - Express.js
- Hub frontend component library
- Shared folder - utilities, types, enums, etc

There were 13 tsconfig files:

- 6 were straight `tsconfig.ts` files
- 6 were build related
- 1 was used for type checking

Even though all these TS config files were being used it seemed excessive. But what was most confusing were the structure and organisation of the configs files. I figured there must be a way to centralise the common options (of course, there was!) and have the leaf configs that implement more specific options for the different projects in the monorepo.

I mapped out the current set up, chucked it into Windsurf and, using Claude 4.1, had a chat. These were the recommendations it spat out which all made sense:

- **Use a single TS version**: there was no discernable reason why the different monorepo projects used different TS version except that it just evolved that way and hadn't been updated..
- **Centralise common compiler options**: well, yeah, duh-doy. It recommended using a `tsconfig.base.json` file in the root dir which I was, wrongly, unsure about.
- **Simplified path mapping**: it recommended using `baseUrl` with `paths`. Later, I learned using `baseUrl` wasn't recommended and I also came across some confusing behaviour using it.
- **Use TS project references**: this is the first I'd heard of these config options but apparently it came with improved build times and IDE integration.

Out of curiousity, I went full vibe mode and got Windsurf to implement all the recommendations across the entirety of the repo. Wave of errors appeared and I began surfing them one after another hoping each newly resolved error brought me closer to the shore of full functionality. It didn't. I got caught in a riptide of similar errors and kept getting pulled out, away from the shore.

It was at that point I realised I'd have to understand the TS config options if I were to confidently refactor the monorepo's TS config. This option was definitely the better option as, due to the idiosyncracies of Hub's monorepo, it got to the point where Windsurf actually got in the way and having an understanding of the TS config helped to clearly solve issues more relevant to Hub.

Even with the help of Windsurf it was still challenging and time consuming, but I learned a lot along the way that deepened my understanding of TS.

# Hand in Hands

My faithful companion in this journey was the TS config reference[^1]. I referred to this a lot. It helped clear confusion about specific config options and the relationship some had to others. That and the various LLMs I had access to through Windsurf that wrote code and catalysed my understanding. What follows are some of the learnings I took away from this project.

### One Bite at a Time

After I experimented with full vibe mode I realised I needed to some problem decomposition, break the problem down into independent and manageable chunks. The number of errors I was getting when in full vibe mode was overwhelming and, due to my lack of understanding the TS config, it was hard to effectively guide Windsurf to resolve them.

Instead, I broke the process down into the different monorepo projects. First I tackled the backend, as it had so many configuration files, 5 in total. Once I had a basic setup for this I moved onto the frontend projects which were relatively easier as they were Next.js projects and the build setup was handled by Next.js. The shared folder was a bit confusing, mainly due to the way Google Cloud Run functions are deployed[^2]. Hub's had a work around for this but it wasn't optimal.

### False Starts

Windsurf's suggestion of using `references`, on the face of it, seemed like a good one. It creates a logical separation between the different projects in the monorepo, improved build times, improved speed of typechecking and compiling, and reduces editor memory usage[^3]. Yes, please! The TS team recommand this method when there are many `tsconfig.json` files, like in a monorepo. The TS github repo uses this pattern, as per the root `tsconfig.json`[^4], and a `tsconfig.base.json` file like Windsurf suggested[^5].

However, when I started to implement this pattern I was having compilation problems and errors that were, at the time, outside my comprehension. I referred to the Turborepo guidance on how to set TS up as we are using it to run the various workflows that we need to run to start, implement, build, and deploy. They recommended against using TS project references[^6]. I decided to follow this guidance instead and removed `references` which made it easier to move forward.

I was looking towards a best practice guide as it's my preference to setup that way then customise as necessary so I continued with this and installed a couple base configs for node and node with typescript[^7]. However, I had an issue with using the array argument in `extends` to inherit multiple tsconfig files. There was a package dependency that didn't correctly parse the array in `extends` and I was overriding a lot of the config in the bases. I decided to uninstall them and move the necessary config into the files itself.

It was around this time that I started to dig more deeply and frequently into the TSConfig reference and lean more heavily on that instead of the LLMs. The various LLMs available in Windsurf didn't seem to really understand what I trying to do and kept suggesting changes that weren't helpful. Later on when I better understood the config options myself I was able to guide Windsurf, though at this point it was easier to just update the config manually.

### Testing Time

Finally, I had a TS config in the monorepo that was working for the frontend, backend, and shared packages. I had a `tsconfig.base.ts` file setup in the root that the backend, shared, and frontend configs inherited from. With this done I started testing the build time and size.

I got Windsurf to create JS scripts to analyse the build time and size. When I compared the optimised branch to the dev branch I was disappointed to see that the build size had actually gone up! I naively expected there to be a decrease simply because I had updated TS config options like `target`, `module`, `moduleResolution`, and a few others to more modern and updated values.

Nope!

I dug into the backend build folder and noticed `.d.ts` and `.js.map` were being built amongst the `.js` files. I referred to the trusty TSConfig reference and these are actually not needed for use in production builds for a private project. I set `declaration` and `declarationMap` to `false` in the `tsconfig.build.json` file. When I ran the analysis again there was a 3.2% drop in build time and a 28% drop in build size. I couldn't believe it was that big of a decrease.

This also put me onto the path of using the `exclude` option more aggressively. I excluded test, seed, mocks folders as well as local config files. It didn't reduce it as much as removing the declaration configs did but I felt better being clearer as to what files were actually needed for a production build.

### MOAR OPTIMISING!! MOAR!

High on the massive reduction of the backend build I wondered what else could be removed. I noticed that in the shared package we had lots of type definitions but also enums whose value was being used in the code. I thought I could kill two birds with one stone by using a bundler for the backend code.

So, I gave myself a generouse timebox and dove into vibing out the ability to bundle and minify using esbuild[^8]. I was even more ignorant of the specifics of bundling and minification than I was of TS, yet I was able to get pretty far riding the wave of errors. I thought the biggest challenged would've been resolving the problem of Hub's TypeORM setup of using globbing to get the entities and migrations. But I figured that I could just build them outside of the bundler workflow and it seemed to work.

I got to the point where I had a bundled and minified file though when I started the backend server it crashed. I was able to solve that error by adding another config option in the esbuild file that "took care" of an external package that was causing the error. After doing this many more times I seemed to be going around in circles.

Eventually I reached my timeboxed limit and realised, like with the TS config reference above, that LLMs can only take me so far. At a certain point I'd be way more productive and the LLMs more helpful if I had specific knowledge and understanding about what I'm working on. But didn't have the time to dig into the depths of esbuild.

However, there was still hope in more optimisations. I moved onto finding everywhere in the backend code where a type was being used and "type-only" imported them all[^9]. At the same time I imported all the enums into a single export file in the shared package and imported them into the backend code from there. Windsurf did a good job in creating a script that did a lot of the work, however, there was still a lot that had to be done.

I spent the next couple of hours going through a list of console errors. I manually updated a lot while putting in a couple hundred in Windsurf at a time. But I could see another massive reduction in build size at the end of the horizon and had to get this done.

When I finished I analysed the frontend build. The parsed size of the shared code for the frontend went from 1.1mb to 33.7kb, a whopping ~96% reduction in the size of the frontend bundle. There would also be a similar reduction in the backend as the shared code was being used a lot there. This was even more of a surprise. I'm glad I did it!

### When the Rubber Hits the Road

Thanks to a diligent work colleague thoroughly reviewing and testing my TS config changes locally I eventually merged the code into our staging branch. To no ones surprise there were issues.

All the issues seemed to relate to the `paths` config option[^10] but it was difficult to understand in what way. Due to the inheritance I couldn't intuit what the final config output would be. This is where the command `tsc --showConfig` came in handy. Using this command I was able to see what `paths` were being used for a specific tsconfig file. This helped debug what tsconfig file was having an issue.

The biggest confusion I had was when using `paths` in the backend build tsconfig to refer to the `.ts` files in the shared folder. This was the way it was meant to be done but Hub's previous TS config had it referring to the built shared code. When the new config was deployed to the Google Cloud Run functions it broke.

After a bunch of debugging I noticed the new setup resulted in `tsc` compiling the shared folders and pulling them into the compilation `out` directory of the backend folder. The uncompiled backend code was in the `functions/src` directory and that got compiled into the `build` directory. So, the functions build directory looked like this `build/shared` and `build/functions/src`. Yet, the entry point for the cloud function was `build/src/index.js`. All I had to do was update the folder the entrypoint was being accessed from to `build/functions/src/index.js`.

I didn't realise that's how `tsc` worked when compiling so it was a good learning for me.

# In the End it Does Really Matter

The majority of my 🥧 sprint was consumed with optimising Hub's TS config. I'm definitely glad I took on the project, not only did I learn a lot about TS, its configuration, and how it compiles but I was also able to get some wins by reducing our build size and speeding up build time. Also, I was very glad that the IDE TS engine stopped crashing!

I went from being in a haze of config overwhelm to understanding how different config options worked and how best to use them to optimise not just the build but also IDE functionality and type checking. I still wouldn't call myself a TS expert but I'm definitely more confident in working with and customising TS config.

Even though there were some challenges during the deployment and short-term blockage to local and staging I think the transition to a optimised TS config setup was well worth it. However, this is just the start. There's still a lot more optimisation to go!

# Footnotes

[^1]: TSConfig Reference - https://www.typescriptlang.org/tsconfig/

[^2]: Firebase functions in a monorepo? A challenging pile of hacks - https://www.codejam.info/2023/04/firebase-functions-monorepo.html

[^3]: Project References - https://www.typescriptlang.org/docs/handbook/project-references.html#what-is-a-project-reference

[^4]: TS repo - https://github.com/microsoft/TypeScript/blob/main/src/tsconfig.json

[^5]: Project References: Guidance - https://www.typescriptlang.org/docs/handbook/project-references.html#guidance

[^6]: Turborepo: TypeScript Setup - https://turborepo.com/docs/guides/tools/typescript#you-likely-dont-need-typescript-project-references

[^7]: TSConfig Bases - https://github.com/tsconfig/bases?tab=readme-ov-file

[^8]: Esbuild - https://esbuild.github.io/getting-started/

[^9]: Type-Only Imports - https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html

[^10]: TSConfig - paths - https://www.typescriptlang.org/tsconfig/#paths
