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
   implement the neccessary filtering by category and aggregation etc?
3. Is it ok to `getAll` from `E` and then implement some filtering and
   aggregation logic in `S` in order to lighten the load on `C`?
4. Can we leverage the rumored push/streaming interface of `E`?

These are all issues where we don't have any immediate influence.
Furthermore we have to tackle questions regarding our own subsystems
`C` and `S` and their communication:

5. When should the client `C` ask `S` for updates? Every x seconds?
6. Should this polling rate be user configurable, should it be dynamic?
7. Should we implement a websocket interface between `C` and `S`, so
   `S` can push information to `C` instead of `C` having to poll
   regularly?
8. Should `S` cache some information? Should `C` cache some
   information? If so: how, when and what exactly?
9. Is the suggestion of a tabbed interface the right solution? What are the alternatives?
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
magical creatures, so we suppose a different approach to software
architecture: late decision making.

Instead of trying to make the right decisions up front, we want to
design our system in such a way that it is easy to change our minds
later in the process. This shifts our focus from making decisions to
making decisions possible.

TODO
