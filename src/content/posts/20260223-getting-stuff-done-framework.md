---
title: GSD - An AI Orchestration Tool
published: 2026-03-10
description: Exploring GSD by building out a simple RSVP browser extension an
tags:
  [
    'developers',
    'productivity',
    'claude code',
    'rust',
    'web assembly',
    'artificial intelligence',
    'rsvp reader',
    'rapid serial visual presentation',
    'orchestration',
    'framework'
  ]
---

## TLDR

I tried out the [GSD agent orchestration development system](https://github.com/gsd-build/get-shit-done?tab=readme-ov-file) and built a [RSVP progressive web app and browser extension](https://github.com/codeinaire/rsvp-reader-pwa) to test out its capabilities. It's a streamlined, straightforward framework that makes decisions about a project easy to make though at the cost of deeper understanding. It builds fast, thanks to parallellisation, though at a higher cost and, for my project, it missed out on end-to-end tests. I find these crucial for Cladue Code's (CC) verification step. Overall, GSD is worth trying especially for prototyping and feature spikes.

## Intro

Recently, I've been experimenting with CC by building out various tools. The first was a [CC usage tracker](https://asyncadventures.com/posts/20260206-claude-code-tracker/) and it was entirely vibe coded. Second, I built a very basic, for now, [image conversion tool](https://asyncadventures.com/posts/20260211-rust-image-tools/) and I intentionally chose to do more upfront planning and implement skills and memories. While doing this I came across agent orchestration frameworks and wanted to give them a go. For this blog I choose the [GSD "development system"](https://github.com/gsd-build/get-shit-done?tab=readme-ov-file) as it seemed the most straight forward and required the least upfront learning.

## Getting Stuff Explained

Essentially, GSD is a choose-your-own-adventure prompting engine. It was created in response to the chaos and scaling limitations of vibe coding and describes itself as such:

> It's the context engineering layer that makes Claude Code reliable. Describe your idea, let the system extract everything it needs to know, and let Claude Code get to work.

When initiating it in a project it goes through the following phases:

- Questions — Asks until it understands your idea completely (goals, constraints, tech preferences, edge cases)
- Research — Spawns parallel agents to investigate the domain (optional but recommended)
- Requirements — Extracts what's v1, v2, and out of scope
- Roadmap — Creates phases mapped to requirements

To produce the following documents:

- PROJECT.md
- REQUIREMENTS.md
- ROADMAP.md
- STATE.md
- .planning/research/
  - architect
  - features
  - pitfalls
  - stack
  - summary

When I worked on the image conversion tool the very first thing I did was work with CC to create a comprehensive planning document that covered the MVP requirements and stretch goals. Essentially, in comparison to docs produced by GSD, it was the project, requirements, roadmap document, and research documents all rolled into one.

When I started to build the image conversion tool I broke the planning document down into individuals plans. When each plan was implemented I would be able to create an appropriately scoped and understandable pull request to make it easy to review. Each planning document had the implementation details, verification, a bunch of others things, and the state it was in.

GSD's equivalent is a looping system that I ran through after the initial setup. I ran through each of the following steps per the phases in `ROAADMAP.md` and requirements in `REQUIREMENTS.md`:

- Discuss: this is where I shaped the implementation. It presented a multiple choice list of questions that were mutually exclusive answers and a freeform field where I could give more detail instruction. For example, phase 1 of my project was `01-wasm-pipeline-document-service`. It'd ask different sets of questions related to functionality, typically with a recommended implementation, until it had gotten enough info.
- Plan: it researches how to implement whatever phase I'm on that had been created in the initialisation questioning.
- Execute: this is point where the previously created plan for the functionality is implemented.
- Verify: this is where I'd check the work that has been implemented. Most of the time I'd have to verify it manually.

After all those steps were done for a particular phase I'd go through it all again with the next phase. The requirements were typically logically ordered and scoped and there wasn't any issue with conflicting code.

## GSD Breakdown

Overall it was an interesting process that required very little from me. The questions always had 3 or 4 answers that I could select from, one of which was recommended, with a free text field for a custom answer. The majority of the time I selected the recommended answer. It was pretty close to my desired functionality and I wanted to follow the path of least resistance to test GSD default capabilities.

In the initialisation process the very first question it asked was what I wanted to build. This was my answer:

> I want to build a Rapid Serial Visual Presentation progressive web app or a native app. I want to be able to share websites into it or document files like pdf, epub, doc, and other formats. I want to use rust for the backend processing if needed and typescript for the frontend, possibly using react.

Next, it asked clarifying questions that contributed to creating the `PROJECT.md` doc. After working through all the initial project defining questions it went through a bunch of standard questions the answers of which defined how GSD was configured to work. They were:

- `Mode: How do I want to work?`: I choose the recommended YOLO mode which is auto-approving. Though I'm not sure what this actually means in practice because there was a lot of tool uses I had to approve. The constant asking got so much that I decided to use, with the help of docker, the `dangerously-skip-permissions` flag.
- `Depth: How thorough should the planning be?`: these were the number of planning steps to be created for each phase of the project. Each of these steps were executed to implement the desired functionality of each phase. For example, my project originally had 4 phases: 01-wasm-pipeline-document-service, 02-rsvp-playback-engine, 03-import-ui-reading-view, and 04-pwa-web-share-target. Inside each of these were 4-6 plans each this is because I choose the standard which was 5-8 phases with 3-5 plans each. For every plan there was a summary of what was done, the decisions made, verifications, etc
- `Execution: Runs plans in parallel?`: this is how the plans would be run. I chose the recommended parallel execution.
- `Git Tracking: Commit planning docs to git?`: I chose the recommended commit to git.
- `Research: Research before planning each phase?`: I chose the recommended research as it helps GSD best understand a particular phase.
- `Plan check: Verify plans will achieve their goals?`: I went with the recommended yes to help find gaps in the plan.
- `Verifier: Verify work satisfies requirements after each phase?`: I went with the recommended yes as it matches requirements with each phases' plan.
- `AI Models: Which AI models for planning agents?`: I went with the recommended balance which is mostly using Sonnet.

After that it went onto researching the project itself which it fed into the defining requirements phase. It'd ask a bunch more project specific questions and produce a list of requirements. Once that was done the project was initialised. It was after this the loop discuss, plan, execute, and verify loop could start and move through the 4 phases.

## Calculating the Costs

Below is the estimated cost. I had a feeling it was costing more compared to the [Rust Based Image Converter Site](https://asyncadventures.com/posts/20260211-rust-image-tools/) project. All the steps in the loop ran for much longer and the more phases the longer each proceeding phase took. I was just guesstimating this based on how long I remembered CC ran for different plans and how quickly my subscription allocation was chewed up in the image converter project. As the numbers below show, my guesstimating was correct.

If I want to distill it into one metric I'd choose the all mighty dollar. This project cost `$46.87` while the image converter project cost `$22.11`.

That's 2.11x more!

| Category                     | Metric               | Value    | Detail                                                     |
| ---------------------------- | -------------------- | -------- | ---------------------------------------------------------- |
| **Input Token Stats**        | Total Input Tokens   | 97.56M   |                                                            |
|                              | Input Tokens         | 20.4K    | Base input tokens                                          |
|                              | Cache Write Tokens   | 4.39M    | 125% of input price                                        |
|                              | Cache Read Tokens    | 93.14M   | 10% of input price                                         |
| **Cost Stats**               | Estimated Cost       | $46.87   | $294.52 without caching                                    |
|                              | Money Saved          | $247.65  | 84.1% cheaper via caching                                  |
|                              | Cache Hit Rate       | 95.5%    | 93.14M reads / 97.54M total cached                         |
|                              | Cache Efficiency     | 95.5%    | Of all input served from cache                             |
| **Misc**                     | Output Tokens        | 173.6K   |                                                            |
|                              | Total Messages       | 1.9K     |                                                            |
|                              | Total Hours          | 12h 23m  | Claude: 1h 41m · You: 10h 41m                              |
|                              | Sessions             | 12       | 2026-02-22 to 2026-02-27                                   |
| **Subscription vs API Cost** | Pro ($20.00/mo)      | +$26.87  | Saved vs API over 1 month (API: $46.87 vs Sub: $20.00)     |
|                              | Max 5X ($100.00/mo)  | -$53.13  | Overpaid vs API over 1 month (API: $46.87 vs Sub: $100.00) |
|                              | Max 20X ($200.00/mo) | -$153.13 | Overpaid vs API over 1 month (API: $46.87 vs Sub: $200.00) |

Below is a chart comparing the image converter with this project. This project had more of everything except for unique input tokens, total hours, and total sessions. I think the image converter has more unique input tokens because I interacted with CC more. This correlates with the breakdown of total hours where my time for the image converter is 14h 41m compared to this project's 10h 41m. Whereas the big difference in costs and minor difference in total hours comes from GSD doing a lot of stuff in parallel.

So, GSD is true to its name... but not by that much!

| Category                     | Metric               | Image Converter | RSVP           |
| ---------------------------- | -------------------- | --------------- | -------------- |
| **Input Token Stats**        | Total Input Tokens   | 50.29M          | 97.56M         |
|                              | Input Tokens         | 38.4K           | 20.4K          |
|                              | Cache Write Tokens   | 1.72M           | 4.39M          |
|                              | Cache Read Tokens    | 48.53M          | 93.14M         |
| **Cost Stats**               | Estimated Cost       | $22.11          | $46.87         |
|                              | Cost Without Caching | $150.68         | $294.52        |
|                              | Money Saved          | $128.57         | $247.65        |
|                              | Savings %            | 85.3%           | 84.1%          |
|                              | Cache Hit Rate       | 96.6%           | 95.5%          |
|                              | Cache Efficiency     | 96.5%           | 95.5%          |
| **Misc**                     | Output Tokens        | 110.0K          | 173.6K         |
|                              | Total Messages       | 1.0K            | 1.9K           |
|                              | Total Hours          | 16h 53m         | 12h 23m        |
|                              | Claude Time          | 2h 13m          | 1h 41m         |
|                              | Your Time            | 14h 41m         | 10h 41m        |
|                              | Sessions             | 24              | 12             |
|                              | Date Range           | Feb 11–19 2026  | Feb 22–27 2026 |
| **Subscription vs API Cost** | Pro ($20.00/mo)      | +$2.11          | +$26.87        |
|                              | Max 5X ($100.00/mo)  | -$77.89         | -$53.13        |
|                              | Max 20X ($200.00/mo) | -$177.89        | -$153.13       |

## More Data Points

I've got another chart to add some more naunce to this analysis. I asked CC to analyse code complexity to get a sense of the correlation between cost and complexity. My intuition was that the image converter was of slightly more or equal complexity to this project. This was CC's verdict:

> rust-image-tools is slightly more complex in the ways that are hard to get right — the Rust/WASM layer, memory optimization, and performance engineering. rsvp-reader-pwa is broader (more moving parts, more browser APIs), but each individual piece is more straightforward.

But, after doing some steel manning with CC, also:

> **your intuition is well-calibrated, but it's closer than it looks.** The verdict depends heavily on _which dimension of complexity_ you care about. Neither project clearly dominates the other — they're complex in fundamentally different ways.

Below is a breakdown of the code in each project. I don't think lines of code (LOC) contribute much towards determining complexity as there can be lots of code that's easily understandable such as an api routing file or not that much code that's dense and difficult to understand like advanced TypeScripts type conversions. But it's a starting point.

For example, the image tools project has more Rust code due to the core functionality using the image crate and managing the memory constraints around WASM when converting images. Whereas, this project has very little as it's only one part of the core functionality which leans more heavily into browser functionality. That's why it has more TypeScript code compared to the image tools project.

| Metric         | rust-image-tools                         | rsvp-reader-pwa |
| -------------- | ---------------------------------------- | --------------- |
| Total LOC      | 4,229                                    | 3,261           |
| Rust LOC       | 1,539 (36%)                              | 49 (1.5%)       |
| TypeScript LOC | 2,690                                    | 3,212           |
| Source Files   | 31                                       | 37              |
| Testing Depth  | Unit + WASM + E2E + Criterion benchmarks | Unit + E2E      |

A lot more could be said about the complexity of both but I think CC sumarised it nicely:

> The most defensible answer is: **they are approximately equal in complexity, with rust-image-tools winning on technical depth and rsvp-reader-pwa winning on architectural breadth.** If forced to pick one as "slightly more complex overall," the choice depends on whether you weight depth or breadth more — and that's a values judgment, not a fact.

Basically, it's too close to call but I could argue for one being more or less complex depending on what's valued as important: the broad or deep complexity.

This brings me to the actual point: complexity's relationship to time and cost. There doesn't seem to be any, at least in this case. The obvious relationship is between time and cost, that is the faster it gets done (thanks to GSD's parallelling of agents) the more costlier it is. This isn't a new insight. Startups and scaleups are all too familiar with it. So, it's not surprising to see the same thing play out here. This may be fine for now, while token usage is subsidised by all the bags of cash, but will it always be this way?

If we consider the example of Uber. If that is anything to go by in its capture-market-share phase it subsidised fares by 59% below cost until it reached market share and then [jacked them up by 92%](https://tinyml.substack.com/p/the-unsustainable-economics-of-llm). This isn't even considering the decrease in the drivers payout during this period.

## The Good

Overall I thought GSD was a really helpful context engineering layer whose reality matches the claims on the box. The multiple choice steps with the recommended option really sped up development though took away from deeply understanding the intricacies of the project.

Whereas with the image conversion tool I actively took part fleshing out the requirements, thinking about what was missing, what to add, and how to implement. This process was far more engaging than selecting a multiple choice option. I could've interacted more by using the freeform option but the multiple choice options make it too easy to select an option even if it didn't fit 100% what I was thinking, it was close enough. Also, I wanted to see what it could produce when primarily selecting the recommended option and partly because the recommended option was actually pretty good.

It seemed like the power of GSD was to get stuff done fast and the multiple choice based steps catalysed that process, especially with the recommened option. This makes it an amazing tool for spiking a feature or prototyping.

## The Not So Good

A glaring omission was comprehensive testing. The best way I found for CC to confirm the validity of the work was through comprehensive tests. The [testing trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications) builds on the [testing pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) concept. The former focuses more on integration testing and introduces static tests as the foundation that was previously just unit tests.

When the testing trophy idea was created E2E tests were more time consuming, however, a few years later [Playwright](https://github.com/microsoft/playwright) was created. It makes E2E testing much faster as it's headless and can run Chromium, Firefox, and WebKit (Safari) browsers through a single API. Its adoption is recommended by [thoughtworks Technology Radar](https://www.thoughtworks.com/radar/languages-and-frameworks/playwright). However, even though its faster than previous E2E testing frameworks, it's still not as fast as integration testing. The recommendation is to implement E2E testing on critical paths only.

I found that GSD didn't really implement the comprehensive testing as laid out by the testing trophy. I found this to be very important, especially in AI powered development, as it gives the LLM direct and immediate feedback that, most of the time, can be actioned. It's what I used to make sure everything is working correctly. Like in regular development doing it this way gave me confidence that if any regression was caused by the LLM it'd be picked up when the test are run. And I made sure to have appropriate unit, integration, and E2E tests. But, unfortunately, most of the verification done by GSD I had to do manually.

Another, minor, thing that I didn't like about GSD was the ridiculous amount of permission I had to give. It seemed extraneous (maybe it wasn't?), compared to when I was working on the image toolz project. So, to get around that and prevent it was nuking my entire computer I ran it in a docker contain with this command:

```
docker run -it --rm \
-v /Users/nousunio/Repos/Learnings/claude-code/rsvp-reader-pwa:/workspace \
-v /Users/nousunio/.claude:/home/node/.claude \
-v /Users/nousunio/Repos/Learnings/claude-code/claude-code-usage-tracker:/home/node/Repos/Learnings/claude-code/claude-code-usage-tracker \
-w /workspace \
claude-sandbox \
claude --dangerously-skip-permissions
```

The image is built from this docker file

```
FROM node:20
RUN npm install -g @anthropic-ai/claude-code
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv
RUN pip3 install langfuse --break-system-packages
RUN mkdir -p /home/node/.claude && chown -R node:node /home/node/.claude
USER node
WORKDIR /workspace
```

It's a pretty standard docker command running a node image with dependencies for a local langfuse setup, claude code, and creating a claude folder in the container. The mount arguments are for the project (`rsvp-reader-pwa`), for the top level CC setup, and for the CC tracker so that when the CC session is finished it can run the server and save the session details in the trackers db.

This limits the blast radius to the mounted volumes if GSD decided to go rouge and do some `rm -rf`ing. Though it's probably overkill as CC can only write to the [folder it was started and its sub folders](https://code.claude.com/docs/en/security#built-in-protections).

But I got a feeling I probably don't really need to use this. And it is! [GSD recommends running the dangerously-skip-permissions flag](https://github.com/gsd-build/get-shit-done?tab=readme-ov-file)

## Conclusion

It's a straight forward framework to use and recommend anyone give it a go. I've trying it out again for a coding quiz project after doing technical assessment and realising how average my comprehension is of React. This is one of the awesome things, as I'm sure you and many others have already realised, it's so easy to implement almost any idea with CC or any other coding AI tool.
