# Mini TEA

Dart/Flutter reactive and functional state manager inspired by The Elm Architecture with respect to the Flutter.
The main idea is to separate pure business logic from side effects.

## Main Features

- __Unidirectional data flow__ – all data flows from the state to the view and back.
- __Pure logic__ – base idea of TEA is that our business logic can and _must_ be pure.
- __Explicit side effects__ – all side effects live in specific places called `EffectHandler`.
- __Everything is a data__ – every intention in our architecture is a data.

### Unidirectional data flow

The main idea of UDF is that current step of flow cannot affect previous steps.
So, intentions, like click on the button, just start some process, that will be go through the flow in just one direction.

Here, with mini_tea, we have two UDF at the same time:
1. From View to Feature and backward. Just like any other popular UDF architecture that you saw.
2. From Update to the Effect Handler.

### Pure logic

The update function should be pure and should not have any side effects.
At the end our update function will be just finite-state machine, that will update the state based on the incoming message.
But we all know that world around us is not pure. We can have side effects.
To handle them our update function can also return collection of effects, that should be handled.

### Explicit side effects

So, where we handle side effects? We have a special place called `EffectHandler`.
This is just an interface, that can do any dirty job and emit new messages to the update.

### Everything is a data

Just like Flutter with our favorite "Everything is a widget", our idea is to make things similar and consistent.
And just like "Everything is a widget" our idea of "Everything is a data" does not literally mean that everything is a data.
But any intention in our architecture is a data.

## Core concept

TEA is a pattern that helps you to write clean, testable and maintainable code.
It is a set of tools that help you to separate pure business logic from side effects.

There is a three main parts of the architecture:

- __State__: the current state of the feature.
- __Update__: a pure function that updates the state in response to a messages.
- __Effect Handler__: a class that handles side effects triggered during the update.

So, in this case, our business logic is easy to read, understand and test.
It is abstracted from data and its sources.