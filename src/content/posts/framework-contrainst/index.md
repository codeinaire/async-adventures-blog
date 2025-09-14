---
title: To React and beyond
published: 2019-11-20
description: Realising there is always much to learn.
tags: ['modals', 'class', 'functional', 'react']
---

Today, I started writing very basic functionality to display either a success or failure message for the `DynamicForm` component. It started to get a bit complicated and it was here that I realised I needed more functionality for this component than I initially foresaw. I wasn't able to clearly imagine how to make the display disappear once the user had encountered either a successful or unsuccessful submission.

I had the idea to create a modal so the user will be able to close it to resubmit the form. I imagined it'd be something like the Ruby on Rails messages that rendered after the user had submitted a form. It makes it clear for the user that there has been a success or failure and they can close it themselves.

Of course, the first thing I did was to ask the all knowing and benevolent Google for advice on how to build such a modal. I found [this](https://programmingwithmosh.com/javascript/create-modal-using-react/) tutorial on the subject. It looked to be a comprehensive explanation of building a modal in react with the added bonus of making it accessible, which is important for me.

Instead of following the tutorial I went straight to the code sandbox and did a bit of copy-pastaring _sic_. Without any modification to the code it worked! Yay! Thank-you, Krissanawat Kaewsanmuang for the tutorial! However, I wanted to make some modifications. I wanted it to be in TypeScript, I wanted to use functional components, and I wanted to use React Hooks.

I started on the converting the two child components that were used by the parent Modal component. This was relatively straight forward. All I needed to do was to create a couple of interfaces for the props and turn them into functional components.

The harder part came about when I started to convert the parent Modal component. This component was the "Smart Component" as it contained the state. It also contained a bunch of functions to change the behaviour of the modal. This was all familiar to me and converting it to how I wanted it wasn't difficult.

However, it started to get more difficult when I needed to convert some of the function calls inside the behaviour functions. There were many calls that used the `this` object. There was even a function that directly manipulated the DOM. It does the job, but it isn't ideal to do that in react. We want React to do all the manipulation of the DOM while we just interact with the virtual DOM created by React.

This is what made it hard converting it to a functional component. A functional component's `this` object is undefined whereas a class component's `this` object contains a bunch of properties and methods that can be used. I checked it out for myself by creating a functional and class component and console logging `this`.

Furthermore, the parent modal class's `this` contained the methods that were being used in the behaviour functions, but I didn't know how they got there!

This conversion process helped me see that there is so much to learn about not just React, but also how Javascript works. I've got a broad understanding of how `this` works, but in regards to the intricacies that I came across in the modal components there's still much to learn!
