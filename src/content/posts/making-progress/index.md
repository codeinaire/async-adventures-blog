---
title: Ambiguity into clarity
published: 2019-12-22
description: A look at the development of understanding an ERD
tags: ['ERD', 'database', 'design', 'ambiguity', 'clarity']
---

The past few days I've been working on a key component for The Project™. It's a create-or-update function in the challenge datasource. It stores a challenge entity - I'm using [TypeORM's](https://typeorm.io/#/) definition - that contains all the information about what challenge the user has attempted. Currently, there is only one type of challenge available, a recipe challenge. If a user completes all of the sections in a challenge an entity is added to the completed challenge table, if they don't an entity is added to the uncompleted challenge table.

The un/complete challenge tables are made up of the foreign keys from the challenge and user profile table. They are a way to easily store the challenges that a user has either completed or left uncompleted. I don't think they'll stay that way for now as I think I need to add more columns when I start adding functionality to work with the user's challenge goals, which is stored in the user profile table.

The challenge table has foreign keys for recipe and user profile entities. I only added this today because I realised that if I wanted the, originally, create challenge function to be able to update as well I needed to know which challenge to update. Therefore, I needed to find it in the database. The recipe id allowed me to find that, but there will be many challenge entities with the same recipe id, but only one challenge entity with a particular recipe id _and_ user profile id.

The most interesting part of the ERD is how it has changed as The Project™ has developed over time. Today I made changes to it, which brings it up to v5.

It hasn't changed all that much. The core tables from v1 remain - recipe, recipe attribution, challenge, user profile, and completed challenge. Some of them have had their names changed and columns added or deleted as I got a clearer picture as to the functionality of The Project™.

I expanded on the extracted some columns from the recipe attribution table into their own table, but realised that was redundant so removed it. I added another table for uncompleted challenges as I realised a user might forget to complete a challenge or just not want to do certain aspects of it so there must be a way to store them. All in all the tables and what they represent have remained consistent through-out the development process with tweaks to the columns.

What was more challenging to keep consistent was the relations between the tables. It was a challenge clearly understanding what they meant. I wrote about this in a previous post, but basically I had the idea in my mind that the tables are singular entities. This made it difficult for me to understand how the different types of relations worked. However, once I understood the singular entities to have instances of themselves it made it a bit easier to understand.

It also helped to think about the directionality of the relationship. Where was the many coming from and going to? Where was the one coming from and going to? Even today I incorrectly applied a relation. I wanted the challenge entity to have the foreign key for the user profile. I drew out the user profile entity have many challenge entities. I thought this meant the many relation started at the user profile. It doesn't make sense to me now as to why that would be the case or how that would work. But that's what I was thinking.

It was only when I looked at the code and noticed where the foreign key was for other entities that had the relation that I wanted did I realise that I had it wrong. The many is coming from the challenge entity because there will be many challenges associated with the user profile while the one is coming from the user profile because there will only be one user profile associated with each of these challenges.

Even now explaining it like this there is ambiguity. I'm thinking "there won't be only one user profile associated with the challenge entity, there will be multiple user profiles associated with the challenge entity". However, now that I write it out I can see that the statement means there will be multiple user profile ids stored on one challenge entity. This is not what I want. There will only be one user profile id stored on any challenge entity, but any one challenge entity can have a different user profile id stored on it and any one user profiles can have multiple challenge entities associated with it.

I'm not entirely sure why these relations were ambiguous to me. Just thinking about them keeps them in the realm of abstraction. It is only when they become concrete through the implementation of code that a clearer understanding forms.
