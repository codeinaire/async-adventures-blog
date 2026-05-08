---
title: Iterating on Agentic Codeflow
published: 2026-03-19
description: An article discussing state machines
tags: ['langfuse', 'agents', 'agentic coding', 'technical', 'concept', 'architecture', 'experiment']
draft: true
---

A recruiter reached out to me for a position with a legal company working in an AI startupy type team inside the main company. I expressed my concerns about having limited experience developing AI functionality on a production level. He didn't think that was a problem as they wanted someone who has worked in startups (all my exprience has been working at startups) and had informed opinions about new and emerging trends with AI in software development. Well, you know what they say about opinions!

If you've been reading any of my previous blog posts I've been writing about my explorations with AI. In [my last post](https://asyncadventures.com/posts/20260317-automating-subagent-workflow/) I wrote about defining coding agents and a basic, linear workflow in which they'd operate. So, I've been developing opinions about AI agentic coding based on my own experience using agents on various coding projects. This [particular project](https://github.com/codeinaire/langfuse-with-legal-exploration) has helped me again refine the agents and workflow I originally created over the course of working with Claude Code (CC).

I'll go through my current agentic codeflow setup, the iterations I made to iron out the issues, an overview of the common and unique features amongst agents, the issues I experienced iterating their definitions, and how I solved them.


## Current Setup

This is an overview of my current setup.  

```
scout ─────────┐
               ├──→ roadmapper ──→ feature roadmap
investigator ──┘         │
                   orchestrator (per feature)
                         │
                         │ skill as subagent
                         │
                   researcher ──→ planner ──→ implementer ──→ shipper ──→ code reviewer
                                    │
                                    │ skill
                                    │
                                 fact checker
```

The whole process is:

1. Create a roadmap: this is done by the roadmapper agent, which, depending on the project, is fed a report from either the scout or the investigator. The scout is used for greenfield project's to map out the initial territory whereas the investigator is for an existing project. The output for either of these is fed into the roadmapper which create's a feature roadmap.
2. Orchestrator loop: this is the agent that runs the whole process. I feed it a title from the feature roadmap document and it triggers the appropriate agent at the appropriate step by invoking a skill and running the agent. 
3. Researcher: it answers the questions "What do I need to know to plan this work well?" by investigating the technical domain; identifying patterns, pitfalls, pros/cons, architectural design options with pros/cons of each and code examples; assesses infrastructure and identify gaps. At the end it produces a report with confidence levels for answers to the questions it has asked.
4. Planner: the orchestrator feeds the research report file path into the planner agent. It answers the question "How do we build this?" by converting the research findings into specific decisions so that everything in the document produced is implementable. It will resolve any question automatically and batch those it can for me to answer. It has a small fact checker skill for it resolve any confusion it might have regarding open questions.
5. Implementer: this builds exactly what the plan describes. The plan document has steps that the implementer follows, in order, along with verification checks. It'll report what was done, skipped, deferred, and any deviations with deferred items being addressed by me.
6. Shipper: a small and simple agent that uses git butler to commit, ship, and create a PR.
7. Code reviewer: an agent to review the code by understanding the difference in behaviour. It'll review for bugs, security vulnerabilities, correctness, and convention violation providing concrete fixes for every finding flagging issues that it's >80% confident about.

## The Iterations


### Uninvokable Agents

The first issue I had was that CC wouldn't invoke the agents for the task it was defined for but instead it would perform the action itself. The orchestration agent ran fine and it'd be able to implement the entire codeflow on its own from plan to code reviewer, however, that's not what I wanted as the agents I defined had important context that helped the agent with the task it was defined for.

At first the error wasn't clear. I thought it had to do with the tools that it had available to used and it was getting carried away, doing tasks that it wasn't meant to do. I removed the inappropriate tools and it kept happening. I looked a little deeper and [in the docs](https://code.claude.com/docs/en/subagents#restrict-which-subagents-can-be-spawned) I found that a subagent, in this case the Orchestrator, couldn't run subagents of its own.

There were a couple options that I had to solve this issue

1. [Agent Teams](https://code.claude.com/docs/en/agent-teams): this is a way to run multiple parallel CC instances each with their own context and ability to communicate between each other with one session coordinating, assigning tasks, and synthesizing results. This was overkill for the codeflow that I was working on. It would've added unnecessary complexity and increase my token usage by a lot. It might be good in the research and planning phase so the different agents can bounce ideas off of each other and create better research and planning documents though I'd have to trial it to see if it's worth the complexity and extra token usage.
2. [Skills](https://code.claude.com/docs/en/skills): this is a way to extend CC's capabilities, give prompts some consistency, and DRY them up for those you use regularly. Another good thing about skills it that it's possible to run them [as subagents in a fresh context separate to the main context](https://code.claude.com/docs/en/skills#run-skills-in-a-subagent).

The skill option was the best way to capture the codeflow. So, I created a set of lightweight `run-<agent name>` skills that took in an argument of the document it was meant to look at with sentence saying to use that document to run itself. That seemed to work pretty well




fix w

https://ai-sdk.dev/docs/ai-sdk-core/tools-and-tool-calling
The way it works is that my server sends a request to the llm with the system message and user message and what tools are available and processes that api call and if it needs a tool call it'll send a request to whatever
tool it needs to call and this will go to my server if it needs to do a tool call it'll run the async function, kind of like a callback I guess, then it send data back to the llm and if it needs another call it'll do that
in a loop, that's where the `stopWhen: stepCountIs(5)` comes into play to stop when the loop count reaches 5


The real diagnosis

  Your ~/.claude/agents/researcher.md line 4 declares:
  tools: Read, Write, Bash, Grep, Glob, WebSearch, WebFetch, mcp__context7__*, mcp__github__*, mcp__sequential-thinking__*

  I confirmed by reading the actual subagent transcript (agent-ad5e829d10993424d.jsonl — the Feature #4 researcher run): it only ever called Read, Write, Grep, Glob, Edit. Bash, WebSearch, WebFetch, and every
  MCP tool were missing from its toolset entirely.

  Three things converged:

  1. Deferred-tool registry — In recent Claude Code versions, WebSearch, WebFetch, and all mcp__* tools are loaded on demand via ToolSearch (you can see this in the system reminder I received at the top of
  this conversation — they're listed as "deferred tools"). Subagents don't get ToolSearch, so anything that needs deferral never materializes for them, even if the agent's tools: allowlist names it.
  1. Glob entries silently fail to expand — mcp__context7__* etc. are not concrete tool names. At subagent-spawn time the resolver tries to match those globs against the deferred registry, finds nothing
  already-loaded, and drops them.
  1. Bash is gated by your permissions.allow — your ~/.claude/settings.json only allows two narrow Bash patterns (Bash(npx tsc:*) and one ls). Subagents can't show permission prompts, so the harness doesn't
  hand them the generic Bash tool when there's no broad allow rule. Hence Bash also being absent.

  The "context7" system reminder mystery

  The subagent saw the ## context7 block ("Use this server to fetch current documentation…") because MCP server-instructions are broadcast to every session where the server is connected, regardless of whether
  the agent has any mcp__context7__* tool in its allowlist. So the agent was told "use context7" but had no context7 tool to call. Hence the apologetic disclosure in the research doc.

  Fix options (no changes made yet — your call)

  ┌────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬──────────────────────────────────────┐
  │ Option │                                                                          Change                                                                          │                Effect                │
  ├────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┤
  │ A      │ Replace mcp__context7__* with the two concrete names (mcp__context7__resolve-library-id, mcp__context7__query-docs) and similarly enumerate the github   │ Forces concrete registration — most  │
  │        │ and sequential-thinking tools you actually use                                                                                                           │ reliable                             │
  ├────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┤
  │ B      │ Add a broad Bash allow (e.g. Bash(*) or scope it to read-only patterns) to ~/.claude/settings.json                                                       │ Gets Bash back into subagents        │
  ├────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┤
  │ C      │ Both A + B                                                                                                                                               │ Researcher gets the full intended    │
  │        │                                                                                                                                                          │ toolset back                         │
  └────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────────────────────────────┘

  Want me to apply the fixes? If yes, I'll invoke the update-config skill to do it properly. If you'd like to verify the diagnosis first, I can spawn a one-shot researcher with a tiny test prompt and have it
  report which tools it can see.

# limitations of agents when they are limited too much or not given correct context

The honest answer to "why is this in here": the ship skill auto-generated it without checking whether the feature is actually visually testable.

  When I invoked ship, I passed it a brief that included the full keymap (WASD/arrows/Q/E/F/Tab/M/Esc/Enter/Space) for context. The skill turned those bindings into "Manual smoke: confirm they all map" — a
  templated checklist item. It treated the feature as if it were end-user-facing, like Feature #2's F9 cycler ("press F9, see state change in console") which IS visually testable. But Feature #5 has no
  consumers yet, so the manual smoke test is aspirational, not executable.

  This is a real process gap in how I'm using the ship skill:

  1. The plan file (project/plans/20260502-...) — doesn't claim a manual smoke test. It only lists 5 automated tests under verification.
  2. The implemented file — doesn't claim it either. The deviations and test counts are accurate.
  3. The PR description does, because the ship skill autogenerated it from the keymap detail in my brief.

  So the test isn't "in" the codebase — it's in the PR's GitHub description, where it doesn't belong.

  How to fix

  Three options, increasing effort:

  1. Edit the PR description to remove both unchecked items. They're misleading — they imply work that the reviewer would expect to be done before merge, when actually neither can be done until Feature #7.
  Quick gh pr edit 5 --body ....
  2. Replace them with accurate items — e.g. [ ] Defer manual smoke to Feature #7 — input dispatch verified by automated tests in src/plugins/input/mod.rs::tests. Keeps the line item visible but flags it as
  known-deferred.
  3. Make them testable — add the dev-only debug logger I mentioned earlier (~30 LOC). Then the manual smoke checklist actually means something: launch, press keys, watch console.

  And the lesson for next time

  When briefing the ship skill, I should explicitly say: "this feature has no end-user-visible consumers yet — generate test plan items that match what's actually testable in isolation." That would have
  stopped the templated "Manual smoke" item from appearing. I'll do that for feature #6 onward.

THE FIX

You're right, I wasn't. Here's the concrete proposal.

  Where the fix should go

  ~/.claude/skills/ship/SKILL.md is the authoritative file for the ship skill. The relevant section is currently just:

  ## Test plan
  <bulleted checklist of how to verify the changes>

  That's too vague — it lets the shipper template anything that sounds verification-shaped, including the two bad items we just saw on PR #5.

  Proposed edit

  I'd add explicit guidance under step 6, right where the PR template is defined:

     ## Test plan
     <bulleted checklist of executable verification steps>

     ### Test plan rules — apply when generating items

     Each item must be **executable** against the current state of the
     codebase AND must be a **test**, not a code-review task.

     Reject items that fail either rule:

     - **Aspirational (not executable yet)**: "Manual smoke: press W and
       confirm forward movement" — fails when no system reads the input
       yet. If the feature adds infrastructure with no consumer in the
       same PR, do NOT include manual-smoke items. Use deferral language
       instead: `[ ] (Deferred to Feature #N) Manual smoke — no consumer
       yet; dispatch verified by <test name>`.
     - **Code review masquerading as test**: "Verify keymap matches
       docstring" — that's reading code, not running it. The code-review
       step covers this. Don't duplicate it here.
     - **Redundant with automated checks**: don't restate cargo check /
       clippy / test as separate items beyond the standard 6 if they're
       already in the list.

     Self-check before writing each item: "Could a reviewer actually do
     this against the current codebase, and is it distinct from what the
     reviewer agent will do?" If the answer to either is no, fix or drop
     the item.

  What this changes

  Going forward, when the shipper assembles a PR description, it'll have explicit rules to refuse aspirational items. The two bad items on PR #5 wouldn't have been generated — the shipper would have written
  something like:

  - [x] cargo check / clippy / test (default + dev) — all green
  - [x] 5 new automated tests in src/plugins/input/mod.rs (1 smoke + 4 message-injection)
  - [ ] (Deferred to Feature #7) Manual in-game smoke — no consumer reads
        ActionState<T> yet; dispatch verified end-to-end by the 4
        message-injection tests via Buttonlike::press

  Which is what should have been there originally.

  Apply it?

  This is an edit to your global Claude Code config (~/.claude/skills/ship/SKILL.md), so it persists across all your projects, not just druum. Two questions before I apply:

  1. Approve the wording? I can tweak — e.g. shorter, less prescriptive, different example, etc.
  2. Apply globally (the edit above), or also clean up the existing PR #5 description so it stops being a counter-example to the new rule?
