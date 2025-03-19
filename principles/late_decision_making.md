## Case Study: Incidents

Imagine we must design a system that allows users to monitor incidents
– alarm states in factory for example. The incidents live in an
external system (E) built by somebody else in our organisation. We can
access this external system via our own server (S). Users want to use
a browser application (C), which is also served by our little server
in the middle. An incident consists of at least a title, an
introduction date, a category, and a severity level. There might be
other data associated with an incident. At any point in time users
want to focus on the incidents corresponding to a certain
category. For this category, they want to see the full picture,
i.e. they want to quickly see the details of any event in this
category. For the other categories, they want to see an overview: How
many incidents are there currently, what's their highest severity
level etc. The users told us that they imagine the UI to be a tabbed
interface (see their scribble in Figure ...). The external system
purportedly "supports queries", but nobody is sure, what this means
exactly. There's hardly any documentation and the maintainers of the
external system are hard to locate. One kind of query is certainly
supported and that is: get all information about all currently active
incidents across all categories (`getAll`). As for the size of data
this global incident information amounts to we are only told that "the
data might potentially be huge". There are also rumors that in
addition to a pull-based mode, `E` also has some kind of push or
streaming interface.

The above paragraph is all we have in terms of requirements and
constraints. This is a prototypical situation we find ourselves in as
software architects: Uncertainty all around. Specifically, we have to
deal with uncertainty regarding these questions:

1. Is there a way to query `E` by category?
2. Does `E` support agreggate queries?
3. Does the amount of data allow us to simply call `getAll` on `E` and
   transfer the entire response to the client `C`, such that `C` could
   implement the necessary filtering by category and aggregation etc?
3. Is it ok to `getAll` from `E` and then implement some filtering and
   aggregation logic in `S` in order to lighten the load on `C`?
4. Can we leverage the rumored push/streaming interface of `E`?

These are all issues where we don't have any immediate influence.
Furthermore we have to tackle questions regarding our own subsystems
`C` and `S` and their communication:

5. When should the client `C` ask `S` for updates? Every x seconds?
6. Should we have different polling rates for different tabs?
7. Should these polling rates be fixed or dynamic?
8. Should these polling rates be user configurable?
7. Should we implement a websocket interface between `C` and `S`, so
   `S` can push information to `C` instead of `C` having to poll
   regularly?
8. Should `S` cache some information? Should `C` cache some
   information? If so: how, when and what exactly?
9. Is the suggestion of a tabbed interface the right solution? What
   are the alternatives?
10. If a user switches to another tab (and therefore another
    category), is it ok to poll for the related information at that
    point in time or should we prefetch some data such that
    they can look at some aggregated information in the meantime?

Classical software architecture lore would have you believe that it is
your job now to answer all of these questions by making
decisions. Naturally, good architects make the correct decisions,
i.e. they choose answers that are valid for the entire lifecycle of
the system. If software architects had perfect insight into the
future, this would be a viable approach. We have yet to find these
magical creatures, so we propose a different approach to software
architecture: late decision making.

Instead of trying to make the right decisions up front, we want to
design our system in such a way that it is easy to change our minds
later in the process. This shifts our focus from making decisions to
making decisions possible.

### How to start: A model of incidents

When designing for late decision making, we can start by modelling the
primary domain concepts. It is not always obvious what comprises the
primary domain concepts. In these cases you might be better served by
starting with a different approach. In this case our primary domain
concept is obviously an _incident._ So we start there.

In order to model incidents we should take to a number of different
knowledge sources. First, an incident is represented by the external
system `E` as a title, an introduction date, a category, and a
severity level. We can formalize this as a struct in Ocaml:

```ocaml
type incident_1 = {
    title : String;
    introduction_date : Date;
    severity : int;
    category : String;
}
```

Representations are often good starting points for models, but
representations aren't models themselves. We have to ask ourselves
what these representations mean. In order to figure out what a
representation means, we can ask potential users and other
stakeholders and observe them how they work with these concepts. For
example, an incident means that something bad happened at the factory:
A fire broke out and thus somebody reported an incident. Aha, so
really what our software-to-be is concerned with is not incidents per
se but rather information about incidents. Imagine a fire breaks out
at the plant, so there's definitely a state of alarm, but everybody is
busy handling the fire so nobody reports an incident. Our software
doesn't know of any incident but that doesn't necessarily mean that
there are no incidents. Similarly, after an alarm state was resolved,
somebody has to mark the incident in our system-to-be as resolved as
well. If they forget to mark the incident as resolved, our system will
think it to be active still.

We saw that incidents in the external system `E` only have an
`introduction_date`. Just by analyzing our domain, we found out that a
complete model of incidents needs a `resolved_date` as well. Since
some incidents are still active, they may not have a `resolved_date`
yet and so the type of this field is optional.

```ocaml
type incident_2 = {
    title : String;
    introduction_date : Date;
    resolved_date : Date option;
    severity : int;
    category : String;
}
```

Why does `E` not give us information about when an incident was
resolved? Well, it turns out that `E` only ever returns _active_
incidents. For these incidents, the `resolved_date` would always be
`None`. So `E` omits this information.

This is how incidents are introduced and marked as resolved. What is
this information for? A user of our system-to-be – lets call her the
operator – sits in front of a monitor and keeps track of active,
unresolved incidents. They then decide on the measures to
take. Usually they talk to someone on the phone to gather further
information on the issue. Then they may dispatch some workers to take
care of the problem.

Sometimes it happens that an incident gets reported while the operator
is away for an hour. Sometimes these incidents are resolved within
minutes. The operator never gets to know about these short-lived
incidents. Is this ok? We don't know for certain, but for our current
system, the operator is mainly interested in active incidents
anyway. We may want to keep these situations in mind, but for now we
can happily design our way around them.

An operator is actually not concerned with individual incidents but
rather with _all_ incidents relating to a factory – or at least the
subset of these incidents with respect to a given category. This makes
quite a difference. For example, if an operator knows that there are
currently no active incidents at all, they are happy. This happiness
can obviously not be attributed to any particular incident. It's the
absence of incidents that's of importance here. Furthermore, in order
to get to know whether there are any active incidents, we don't have
to ask for all details of all incidents. It suffices to ask for a
simple aggregate: give me the number of active incidents. Similarly,
an operator may want to know if there are any active incidents with a
severity level of 5 or higher. We can answer this question simply by
telling him the highest severity level of all currently active
incidents. If this number is less than 5, there are no severe
incidents, if it's higher, there are.

![moinle](/logo.jpeg)
...

The model we arrived at may look like we employed the pattern of Event
Sourcing. This is not true. The actual data moving through our system
is dictated by the external system `E` and `E` is not event sourced;
it just stores the current state of incidents. However, it _is_ true
that we made time explicit in our model, just as you would in event
sourcing. The model is not the implementation however. Our
implementation might never mention events and is therefore not event
sourced either.

`incident_2` is still a representation and not the essence of our model.
