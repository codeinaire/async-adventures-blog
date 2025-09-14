---
title: Testing Times
published: 2019-10-21
description: A musing on the lack of knowing and understand as to the problem and the solution.
tags: ['jest', 'musing', 'testing library', 'react']
---

Yesterday I was having some problems testing sign-up and sign-in forms I created using [Formik](https://github.com/jaredpalmer/formik). It's a great library to implement React forms quickly and easily. They have a built in support for [Yup](https://github.com/jquense/yup), an object validation library. This is a really easy way to implement form validation. A year or so ago I remember testing out form validation using code from a random github repo, I don't remember the details. It seemed very complicated and I thought it'd be a hassle this time, but it wasn't.

The main issue I was having with Formik was the implementation of accessibility compliant input. Formik lets us use HTML native elements that have implicit support for accessibility features used by accessibility devices like screen readers. However, these conflict with the custom validation. I found when I used the `required` argument for an input the custom validation via Yup would be not work correctly. It'd be triggered out of sync or all of them would be triggered.

I basically had to stop using that and decided to go with the `Field` component. This reduces the amount of boilerplate used to implement the change of values and updating state. I found that very useful. I added a bunch of `aria-` labels to this so as to make it more accessible to screen readers. However, I also found out the `aria-required` label still interrupts the custom validation.

I tried to use the `ErrorMessage` component, but that doesn't seem to have an easily identifiable HTML element to identify with. I needed one because I wanted to implement the `aria-errormessage` label. Instead I had to use the more verbose implementation. This was fine as I created a dynamic form component that took care of implementing my sign-up and sign-in components.
