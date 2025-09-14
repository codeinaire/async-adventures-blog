---
title: Bumbling through learning something new
published: 2019-11-04
description: At first there's excitement then there's hair pulling
tags: ['typeorm', 'sequelize', 'hassle']
---

Today I made the tough decision to switch ORM's (Object relational mapping) from [Sequelize](https://github.com/sequelize/sequelize) to [TypeORM](https://github.com/typeorm/typeorm). Well, it wasn't _that_ tough, but I was in purgatory for a moment. I couldn't decide the better option for myself and my project. Eventually TypeORM ~~slaughtered~~ gently put my indecision to rest.

How? You ask.

Well, I'm glad you asked! It basically came down to two things:

1. TypeScriptness
2. Automated migrations

But Sequelize, you may be wailing, has TypeScript! Indeed it does but it seems to be an after-thought. Who can blame the contributors for this? After all the first release of Sequelize was back in [2014](https://github.com/sequelize/cli/releases?after=v0.2.2), over 5 years ago. Typescript on the other hand was released [7 years ago](https://en.wikipedia.org/wiki/TypeScript) so how can we expect - wait a minute 7 years ago!? Typescript was around **before** Sequelize! It was even at v1.3.0 in November 2014.

Geez, come on Sequelize peeps why didn't you start building it in Typescript then!?

Still, I don't blame them. Back in 2014 whodda thunk a superset of JavaScript created by Microsoft would've taken the developer world by storm. They probably weren't seen as a bastion of open source goodness. Well, not that I know of. I'm no authority I wasn't even thinking of getting into web development 5 years ago!

In any case, Sequelize started including their own TypesScript definitions in v5 and 98.9% of it is written in JavaScript. Ew! Whereas only 0.3% of TypeORM is written in JavaScript and the rest is written in the beautifully delicious TypeScript! I'm not sure if it has anything to do with the fact that TypeORM's very first release was in [2016](https://github.com/typeorm/typeorm/releases?after=0.1.0). I haven't looked deeply enough to see if they started to use TypeScript at that point, the version of which would've been v2.1.0. That's the start of a major jump in versions.

Regardless, I don't have to do any fluffing around to get TypeScript to work with TypeORM - it works out of the box. That's great! Whereas Sequelize I had to find examples and fiddle around and be confused about whether to use the `.define` or `.init` and the cli creating models as `.define` but majority of examples being in `.init` and... well, it was just a _hassle_. We all know developers want to minimise hassle at all costs.

This is where Automated migrations come into it. Well, they don't do the migration for you but they create the migrations for you. I found that to be pretty cool and thought it was a standard feature for any ORMs, but it didn't come with Sequelize.

So it's for those reasons that I decided to jump ship into Typeorm, however I may have to take back what I said about Sequelize being a hassle!

I was working with TypeORM today, attempting to get a connection setup, and I couldn't do it! I tried a bunch of different ways but I kept circling around a similar error `Connection "default" was not found`. I had no idea what was going on. I was following the guides as closely as I could. I did a bit of research and found this [article](https://medium.com/safara-engineering/wiring-up-typeorm-with-serverless-5cc29a18824f). There's a comment about how a project the author is working on uses the [Serverless](https://serverless.com/) framework and how there's an assumption that one connection to the DB is made and maintain and it won't need to be made again.

This helped me connect a bunch of intuitions I was having about what the problem _could_ be. I wondered if using a lambda would be different to using an app with a server such as with express. I wondered if I'd have to use the [`ConnectionManager`](https://typeorm.io/#/connection/using-connectionmanager) class and then I went back to banging my head against the error wall.

I've yet to test out the potential solution in the above article, but the fact that I was wondering these things myself has me curious as to knowing _when_ to follow a different track for a potential solution? Is it just experience? Or is there something else that can be used to fast-track the path to a potential solution?

It seems to me I was kind of stuck on the foreground of information that was presenting to me. I was looking at the examples on the TypeORM website and trying to get them to match my code. This is a clear sign I don't really _understand_ what is going on. I'm just trying to match a pattern of what I see in the examples to the pattern of what I see in my code. I've completely ignoring the context in which these two sets of code exists. The example code exists in the context of demonstrating how to use the library with an example for an Express app while my code is a lambda based code. Would there be differences? Surely! I don't know what they could be at the moment but the fact that a lambda doesn't run continuously is one indication of the difference. Even though the execution context is stored for a little bit by AWS Lambda.

Then I've got to be on the look out for pre-existing assumptions that I've carried over from using Sequelize. It was extremely easy to connect to use Sequelize to connect to the DB and to follow the datasources pattern laid out by Apollo Server. I'd assumed it would be just as easy with TypeORM, but it wasn't! This still doesn't make me want to switch back over to Sequelize. I think TypeORM will be a better developer experience in the long run. I've just hit a hurdle in learning it.
