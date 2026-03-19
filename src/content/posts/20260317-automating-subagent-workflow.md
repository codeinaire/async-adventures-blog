---
title: Automating Subagent Workflow
published: 2026-03-18
description: Creating Agents to automate implementation of roadmap features
tags:
  [
    'developers',
    'productivity',
    'claude code',
    'artificial intelligence',
    'utility',
    'orchestration'
  ]
---

## TLDR

While playing around with GSD for smaller, one-off projects and building an image tools site I decided to create my own custom subagents. I created a researcher, planner, implementer, code-reviewer, and, as that which to bind them all, an orchestrator. I'm know for sure using this workflow will reduce the amount of work I'm doing connecting the different steps but I'm not sure if it'll be an overall improvement to how Claude Code writes code. Only time will tell!

## Welcome to the Machine

I've continued to use the [GSD agent orchestration tool](https://asyncadventures.com/posts/20260223-getting-stuff-done-framework/) to build simple apps. I built a [React quiz app](https://github.com/codeinaire/react-concept-quiz) after an online React quiz highlighted a gap between my knowledge and experience of React. Another is a [webm audio trimmer](https://github.com/codeinaire/webm-trimmer) after needing to trim a webm audio file but not being able to find any online.

At the same time I've been continued to implement features for my [image tools site](https://imagetoolz.app/) from the [roadmap doc](https://github.com/codeinaire/rust-image-tools/blob/main/ROADMAP.md). So, it'll come as no surprise that I've started to create my own agents.

Actually, for anyone working with AI coding tools for any meaningful length of time I'd say it's a natural and necessary progression to create agents. Natural because when I (and I'll assume any engineer) work with a tool, codebase, process, or whatever long enough it becomes easier to see patterns of friction and repetitive processes that can be abstracted away for easy reuse. In the case of coding agents to subagents or skills. Necessary because time is finite and if I have a tool that I can use to customise an automation process, why wouldn't I use it to reduce the amount of time I spend on a task and, hopefully, improve its consistency.

Thankfully, creating subagents to automate coding tasks is minimally fraught, unlike automating software development tasks. As highlighted by [this xkcd comic](https://xkcd.com/1319/).

![The fraughtness of automation](https://imgs.xkcd.com/comics/automation.png)

## A Not-so-secret Agent

Unless you've been living under a rock for the past year or so you've probably heard of, and used (gasp!), [agents](https://en.wikipedia.org/wiki/AI_agent), particularly coding agents like Claude Code! You also probably already know that coding agents can spawn baby agents (babegents anyone??), or [subagents](https://code.claude.com/docs/en/subagents), that are designed to run specific and specialised tasks outside of the main session.

Why do coding agents do this? Well, it helps to **preserve context** of the main session and reduce **context bloat** in the subagent by having their own context, it **enforce constraints** by limiting the tools a subagent can use, it **specilises behaviour** by having focused system prompts, it **control costs** by using models appropriate for the complexity of the task, and, every programmers favourite, it [dries everything up](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) by **enabling reuseability** across projects.

So, besides the pragmatic reasons I stated at the start, there are also these important technical reasons for creating and using subagents. In other words, it's a no-brainer!

## The Anatomy of a subagent

A subagent definition is saved to a markdown file. At the start of the file is the frontmatter, a [YAML block that is used for configuration](https://code.claude.com/docs/en/subagents#write-subagent-files). It contains the name, model to use, tools to use, description, skills, memory, and even colour, amongst other options. Another cool config option is limiting what [subagents can be spawned by another subagents](https://code.claude.com/docs/en/subagents#restrict-which-subagents-can-be-spawned). Is it subagents all the way down!? The configuration block can become pretty sophisticated with conditionals used in permissions, tools, agents, etc though I didn't need any of that for these subagents.

After the configuration block the rest of the file is the system prompt in Markdown. Anthropic recommends breaking the prompt down into clearly defined, unambigious sections by [using XML tags](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#structure-prompts-with-xml-tags). [There's a debate](https://www.reddit.com/r/ClaudeAI/comments/1psxuv7/anthropics_official_take_on_xmlstructured/) as to how helpful that is though, for now, I'm going to follow Anthropic's suggestion. Apparently, it helps Claude Code parse complex prompts. There's no predefined list of XML tags to use; Anthropic recommend using "consistent, descriptive tag names across prompts". I'll go into more detail about the tags I've added to the different subagents.

Also, much like [memories](https://code.claude.com/docs/en/memory#determine-memory-type), [subagents can be put in different places where claude](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope) is used depending on how you want to use them. My subagents are currently in the image tools repo (`.claude/agents`) where they are second in line for invocation (CLI use is first in line) but I think I'll eventually move them to my top-level `.claude` directory in the users folder. Here, they'll be useable by all projects though will be 3rd in line for invocation use.

## My subagents

I didn't create all my subagents at once. I added each subagent when it seemed appropriate until I had a pretty obvious workflow and then created an orchestration agent. These are the agents I created, in order of when they were created:

- Researcher: does the high-level research and analysis of a feature I want to implement.
- Planner: takes in the research document created by the researcher and creates a detailed implementation plan.
- Implementer: implements a plan document step-by-step.
- Code Reviewer: reviews the code and posts a review comment on the PR.
- Orchestrator: acts like the glue to bring all the subagents together by passing output docs to the next subagent.

### Researcher

The first agent I created was the [research subagent](https://github.com/codeinaire/rust-image-tools/blob/main/.claude/agents/researcher.md) as researching was always the first step I'd take when implementing a feature. I borrowed heavily from the [GSD research agent](https://github.com/gsd-build/get-shit-done/blob/main/agents/gsd-phase-researcher.md). I kept the core research methodology, removed any GSD specific references, and added the following:

- MCPs:
  - [`Context7`](https://context7.com/): this is used to get up-to-date documentation, in markdown, on a library used in the codebase. It helps avoid the outdated information on which an LLM was trained.
  - [`GitHub MCP`](https://github.com/github/github-mcp-server): it's used to check a library's repo on GitHub for security vulnerabilities, bugs, issues, performance, license, etc that may impact its use in the codebase.
  - [`Sequential Thinking`](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking): apparently this is a MCP that helps a subagent with "reflective problem-solving through a structured thinking process". It's being invoked in a couple of sections to structure the research plan before executing it.
  - Standard ones like `Read`, `Write`, `Bash`, `Grep`, `Glob`, `WebSearch`, `WebFetch`.
- Library assessment/health check: this is where the GitHub MCP is used.
- Architecture Options section: I think this was the biggest value add for me. This added a table to the research output that contained a few different ways to architect the solution with a description, pros, cons, and the context in which its best to use. Then an option is recommended with a rationale.

This subagent file is the biggest of all the subagents, coming in at 573 lines. It makes sense as it needs to do a lot of researching work. It contains a lot of directions about how best to research, giving confidence to findings and sources, various pitfalls when researching, assessing libraries, architecture options, designs, etc. It's the start of the flow so I want it to do a comprehensive dive into feature.

I broke the document up using these XML tags:

- `<role>`: a high level description of what the subagent is meant to do, its core responsibilities, and what it _shouldn't do_.
- `<project_context>`: lets the subagent known what project context is important for it to ingest before researching. It gives appropriate information about the project.
- `<research_principles>`: the "mindset" the subagent should take.
- `<tool_strategy>`: gives the subagent a criteria on what tools have priority and their trust level. As an example, the Context7 and GitHub MCP have the highest trust for documentation and WebSearch the lowest. But it's important to have both in case the more trusted ones don't have the information.
  - `<confidence_assignment>`: ranks the trust of the different sources and how to present the findings.
- `<verification_protocol>`: an important section as it is run before the final document is created. It contains known pitfalls in information retrieval, synthesis, red teaming the top recommendation to see if they break, etc
- `<execution_flow>`: pretty straight-forward. These are the steps the research agents runs through to do the thangs that it needs to do to produce the output document.
- `<output_format>`: how the research document should be structured.
- `<success_criteria>`: this is how the subagent defines whether it's a good boy or not!

### Planner

The [planner subagent](https://github.com/codeinaire/rust-image-tools/blob/main/.claude/agents/planner.md) was the next I created as the reseacher created a high level, abstracted document and I needed a subagent to take that research and convert it into a concrete plan with clear steps. It won't do research and it shouldn't need to as the researcher agent should've created a comprehensive document from which it can create a plan. Nor does it need to implement anything and there's a subagent for that. It's explicitly stated that it should have ordered concrete steps. It can have user interaction as well to handle any unresolved questions that couldn't be answered.

The size of this file is 284 lines, so half of the researcher.

The common XML tags I added were `<role>`, `<verification_protocol>`, `<execution_flow>`, `<output_format>`, `<success_criteria>`. I also added a tag specific to the planner named `<planning_principles>` which is essentially the same as `<research_principles>`.

This subagent doesn't contain any tools that allow it to reach outside of the research document it was passed. This is intentional as I don't want it to be tempted to deviated from the research that it has been presented with. I did, however, give it the ability to ask target fact checking type questions by using the `fact-check` skill. these are the tools I've allowed it to use: `Read`, `Write`, `Bash`, `Grep`, `Glob`, `Skill`, and `mcp__sequential-thinking__*`.

### Implementer

After the planner I needed a subagent to take the plan and implement it, so I created [the implementer](https://github.com/codeinaire/rust-image-tools/blob/main/.claude/agents/implementer.md). It takes the plan as an input, loads the project context, and executes each concrete step. It should have restraint and be strictly focused on implementation, if there's a disagreement between the plan and implementation it should follow the plan but note the disagreement. It's not for the implementer to decide, the decision can come later by another subagent or human.

The size of this file is 234 lines.

The common XML tags I added were `<role>`, `<implementation_principles>` (similar to the other "principles" tags), `<execution_flow>` and `<success_criteria>`. But it's a different beast with specific concerns and, for this reason, it contains some different XML tags:

- `<startup_protocol>`: essentially the same as step 1 in the researcher's and planner's `<execution_flow>` where the context is loaded. However, it doesn't make sense for it to be in the implementer's first step of the `<execution_flow>` because this tag encloses a set of steps that are looped through for each step of the plan.
- `<quality_gates>`: very similar to the `<verification_protocols>` of the planner, but it runs specific checks for this projects stack and used in the `<execution_flow>`. A future update to make this more generic is to call a skill instead and that skill has the specific checks for that project.
- `<ambiguity_resolution>`: there should be explicit concrete steps to implement but if it isn't clear there needs to be a way to handle that. There's an implementation step in the `<execution_flow>` that will call this if something isn't clear.
- `<blocker_handling>`: very similar to the `<ambiguity_resolution>` but on the other side of the scale. If something has been implemented but there's something stopping the subagent moving forward, it'll classify the blocker and take relevant action.
- `<security>`: sets some guidelines as to **not** what to introduce in the implementation process.
- `<completion_protocol>`: just like the `<startup_protocol>` this runs final checks to make sure everything was implemented correctly, updates the plan's status, updates the memory, and reports to user.

This subagent has been restricted to use the basics required to change read, find, and change code as well as access to the terminal for verification checks. These are the tools I've allowed it to use: `Read`, `Write`, `Bash`, `Grep`, and `Glob`.

### Code Reviewer

If code has been written and a PR created there **has** to be a review. That's why I created the [code review subagent](https://github.com/codeinaire/rust-image-tools/blob/main/.claude/agents/code-reviewer.md). It reviews code changes for quality, security, correctness, and adherence to project conventions. This common XML tags I added were `<role>`, `<review_principles>` (as per the previous ones), `<execution_flow>`, `<output_format>`, and `<success_criteria>`.

The size of this file is 233 lines.

The XML tags specific to this subagent are:

- `<review_checklist>`: is a list of steps to work through in a step in the `<execution_flow>`

These are the tools I've allowed this subagent to use: `Read`, `Bash`, `Grep`, `Glob`, `LSP`, and `mcp__github__*`. I've excluded `Write` as I don't want it to change code but just review and post the review onto the PR. LSP stands for Language Server Protocol and provides code intelligence for claude code.

### Orchestrator

Finally, the very last subagent I created was the orchestrator. I got tired of having to tell Claude Code to start the plan step and implement step and code review step and I figured I'll create an subagent to do all of it for me. When I want to implement a feature I start with this and describe what I want to build. But what I've typically been doing is referring to an item in the `ROADMAP.md` document.

The size of this file is 263 lines.

It contains some of the common tags like `<role>`, `<orchestration_principles>`, `<execution_flow>`, `<success_criteria>`. These are the tags unique to it:

- `<handoff_rules>`: the rules for passing the task to the next subagent.
- `<user_checkpoints>`: the rules for when to stop and ask the user for feedback or a decision.
- `<failure_recovery>`: what to do when there's a failure in the process.

These are the tools I've allowed this subagent to use: `Read`, `Bash`, `Grep`, `Glob`, `Skill`, and `Agent`.

### Fact Checker

I added this after doing a review of the subagents and their orchestration flow. It's a lightweight agent that is spun up by the `fact-check` skill. The skill uses `context: fork` and `agent: fact-checker` in the config. This [indicates it will spin up the subagent](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent) in a new context and won't use any context from the conversation. However, the subagent that uses this skill can pass in an argument. In this case it'd be the simple question it needs to ask.

This subagent contains `<role>`, `<execution_flow>`, and `<rules>`.

## Cost Analysis

I'm going to give a cost analysis, mainly because I like data and this is the only data I have at the moment. This is how much it cost me (time and dollar bills) to abstract out a bunch of workflows that I was repeating: $16.37. It's not really that much. I think the time it took is reflective of myself having to review the files and think about how each subagent should work.

| Title                          | Start Time       | Messages | Subagents | Est. Cost (USD) | Claude Active | Interaction Time | Total Duration |
| ------------------------------ | ---------------- | -------- | --------- | --------------- | ------------- | ---------------- | -------------- |
| `review-orchestrator-subagent` | 2026-03-18 08:24 | 69       | 0         | $3.03           | 18m           | 1h 27m           | 1h 27m         |
| `code-reviwer-subagent-review` | 2026-03-18 07:43 | 81       | 1         | $2.04           | 14m           | 38m              | 38m            |
| `refine-implementer-subagent`  | 2026-03-18 06:29 | 71       | 0         | $2.19           | 17m           | 1h 8m            | 1h 8m          |
| `design-planner-agent`         | 2026-03-06 22:03 | 89       | 0         | $3.37           | 22m           | 1h 20m           | 1h 30m         |
| `orchestration-agent`          | 2026-03-14 09:14 | 13       | 0         | $0.33           | 2m            | 7m               | 7m             |
| `code-review-agent`            | 2026-03-09 22:38 | 12       | 0         | $0.24           | 2m            | 4m               | 4m             |
| `create-researcher-agent`      | 2026-03-05 00:00 | 135      | 2         | $5.17           | 32m           | 2h 5m            | 2h 15m         |
| **Total**                      |                  | **470**  | **3**     | **$16.37**      | **1h 47m**    | **6h 49m**       | **7h 29m**     |

I think the value in this analysis is in relation to the future output of these, hopefully, upgraded and refined subagents and the workflow created with them. Ideally, there would've been a comparison metric for the older subagents but I don't have that.

I've set up the [Claude Code LangFuse template](https://github.com/doneyli/claude-code-langfuse-template) locally which has functionality to evalute prompts though I'll have to design the criteria for which to evaluate the subagents prompts. Though I need to fix up the costing feature.

## Thoughts

Here's a bunch of thoughts I had along the way.

### Will They be Better?

I've no idea if these new subagents definitions will work better than the previous. There's an expectation that they'll work and I most certainly _want_ it to work better. But, in the case of coding agents, was is better. I think the agents have gotten to the point where they perform exceptionally well at the vast majority of tasks they are asked to do. Perhaps, in this case better looks like minor refinements such as they code faster, they are more accurate, the consistently use coding the projects coding standards, less errors are introduced, etc. There's a totality of subtle things that I as a software developer can look at to come to a, mostly confident, conclusion that, yes, these subagent definitions are better.

Essentially, I just have to use them, make my assessments as I go, and adapt them in-situ if something doesn't seem to be working as expected or the **vibe** is off.

### Review Process of Subagents

While writing this article I used claude code opus with effort set to max to do a thorough review of all the subagents. I reviewed the entire subagent file, reviewed each individual XML block in each file, reviewed the entire file again, reviewed all the subagent files as a whole, and finally re-reviewed all the subagent files as a whole. My main aim was to find a consistent use, where appropriate, of the XML tags. This was mainly for me. It helped me know what patterns are common amongst the subagents which gave me a better understanding of them so I can refine them in the future.

I noticed that in every review I did claude code always picked up something to improve even though it did say a lot was good. I probably could've reviewed for much longer and continue to refine but I don't think that would've been useful. I just had to decide at some point they had been reviewed enough and the round of reviews that they went through, I believe, was enough.

### Configuration and XML Tags

The configuration for all of them is very similar except with some differences for the tools used and, obviously, different descriptions for all of them. For the implementer and code-review subagents the model I choose to use was sonnet as it's a [good balance of efficacy and cost](https://www.anthropic.com/news/claude-sonnet-4-5) though I might change that if I need to.

An interesting configuration option is [enabling memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory). There's a user (across every project), project (scoped to project but commited to git), and local (only save locally) scope. I added this after the review and updated the subagents to save to memory where it deemed appropriate. I'm interested in seeing what it saves to memory and how it impacts the performance.

I'm kind of surprised there's no list of recommended XML tags. I mean maybe it doesn't matter and the LLM is able to pick up what the tags will be used for and there's probably no way for there to be a deterministic set of XML tags. Like I said before I aimed for consistent use of the XML tags to capture common use patterns and then meaningful names for when a subagent needed a block of text that was specific to its use case. Previously, the subagents were referring to the headers of the text it needed for something but after the review I made sure when a a block of text was referred it used the XML tags instead.

## Conclusion

One of the big reasons I created and started working on the [image tools app](https://github.com/codeinaire/rust-image-tools) is to get a better understanding of how to use Claude Code. I wanted to by start on a greenfield project and to see how it goes with the increasing complexity that is introduced with each new feature added. It's not a complicated project, except in the sense that I'm learning how to use Rust along the way. The creation of custom subagents is a step in deepening my understanding of Claude Code and AI tooling in general and is influenced by this project. I'm not sure how these agents would work on far more complicated projects with more lines of code though I think starting at this more basic level is a good way to build up understanding though I'd definitely want to level up my understanding on more complicated and bigger codebases.
