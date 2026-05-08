---
title: What Are State Machine
published: 2026-03-19
description: An article discussing state machines
tags: ['state machine', 'technical', 'concept', 'architecture']
draft: true
---

I recently had a technical interview where they asked me what it'd look like if documents with different file types went through a process of `parse → validate → associate → generate → display`. They wanted me to discuss what it'd look like if it was a state machine. They asked if I knew what a state machine was and I gave them an indirect definition that was using an example of a state machine that I came across when working at a previous role.

Basically, I said that we had a state machine associated with the orders. The order could be in a particular state such as "submitted" and when it was in that state it was only able to go to a subset of states depending on what happened to the order. When it moved into one of those states it had a different subset of states that it could move to. Eventually, it'd move through a bunch of different states and reach the final state.

It's not really a definition at all, but it does show that I understand the concepts of state machines. This is more of a definition

> A state machine is a system that has a finite number of states and will be in exactly one of those states at any given time. It can receive an input and, when combined with the current state, will always produce the same result: either a transition to a new state or remaining in the current state.
