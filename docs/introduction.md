This is a step by step walkthrough following the construction of a simple webapplication using RoR to demonstrate the Object Oriented Programming style in Rails. Although Rails is already Object-Oriented, there are aspects of conventional Rails Application development which depart significantly from OO practices. Because the not-so-OO parctices - such as models which violatinf the Single Responsibility Principle (SRP), it might refer to fat model, or putting complex business logic in helpers - are common sourceof development delays in maturing Rails Apps.

###What this is not

- **This is not a Rails tutorial**

- **This is not comprehensive**: this text doesn't capture every possible application of OO partenrs or SOLID principles to rails development.

- **This is not a rule book or a best practices manual**

###The approach

This is a walkthrough style text. We'll build an app step-by-step using TDD (Test Driven Design), at most steps presenting test code followed by implementation code.

###Why OOP?

Why bother with these technique? What's wrong with the "Rails way"?

The biggest reason is to make apps easier to change. Markets change, requriements change, external dependencies change, and platform change. When a project starting to mature, it is hard to modify if it constructed with the "Rails way".

But attemps to predict which parts of a codebase will need to change, and to structured it accordingingly, have ended badly, more often than not. Part of the nature of change is that you don't often don't know beforehand what is going to be changed. Premature optimization is the root of all evil.

Amongst all this uncertainly, there are some basic principles that have proven, over decades of OO development, to make software generally more flexible and amenable to change. Such as:

- Small objects with a single, well-defined responsbility.

- Small methods that do only one thing.

- Limiting the number of the types an object collaborates with.

- Strictly limiting the use of globla state and singletons (includes limiting the use of class level methods).

- Small object interfaces with simple method signatures.

- Preferring composition over inheritance.

These rules of thumb, praticed habitually, tend to lead to more flexible codebase which can adapt to any type of change; whether the change is a data model which better resembles the problem domain; a new data storage backend; or a restructuring of the app into a half-dozen mini apps

So the answer to the why OOP question is "because things change". Some good habits and sound architectural guidance early on in a project can save a lot of headaches down the road.

