#  AsyncCoordinators

This is an experiment to see how async/await can make coordinator logic readable and versatile.

### Readable

It should be possible to start reading the code at the root of the app in the @main function,
and follow the explicit connections to each sub-flow. Each flow has a `run` function that
linearly describes the entire flow.

### Versatile

Flows can be run from many different contexts if needed (see LoginFlow). Flows are also easy to
change by editing the `run` function.

## Design

Each flow is made up of two parts:
 * an ObservableObject that holds the imperative flow logic in its `run` function;
 * and a FlowView that reactively displays/navigates according to the published flow state.

In some cases the `run` function may simply run from top to bottom (e.g., showing a splash
screen then showing a home screen), or it may loop while various actions happen (e.g., button
taps). It may complete with a value (e.g., the LoginFlow lets a user log in and then returns
the associated `User` object), or it may run forever and/or spawn other sub-flows. Async/await
permits a very natural linear expression of these flows even though there is a lot of concurrency
going on.

The FlowView is really a bridge from SwiftUI to the flow object; it avoids UI styling and is a
minimal adapter to the "real" views which are extracted to separate structs. The real views
ideally know nothing about flows so they can reused in various contexts.
