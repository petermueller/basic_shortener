# Short
> A basic URL Shortener

****## Setup
- Start a Postgres DB:
  - `docker run -d -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust --name=short_db postgres`
- `mix setup`

## Run
- w/ iex console
  - `iex -S mix phx.server`
- for load testing
  - `MIX_ENV=prod DATABASE_URL=ecto://postgres:postgres@localhost/short_dev SECRET_KEY_BASE=ZkgY71i21heqrNTge2P04wBR180ItBba2pchU4r7s/Prnza4qT+qyFSXk7LGTKK4 PHX_HOST=localhost mix do phx.digest, phx.server`

## Test
- `mix test`

To start "Short":
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:8080`](http://localhost:8080) from your browser.

# Setup

# Design Decisions/Notes
## Slug generation
  - avoid getting tied to the database/datastore
  - winner for now: `puid`
  - wants
    - [ ] **compact**
    - [ ] **ideally indexes well**
  - Options
    - UUIDv7?
      - [ ] **compact**
        - no control for compactness
      - [x] **ideally indexes well**
    - puid?
      - [x] **compact**
        - highly configurable
      - [ ] **ideally indexes well**
        - unsure on index performance
        - does not seem to have a time-based component prefixing it, just pure
        - could maybe be partially modified to prefix w/ epoch
    - typeid-elixir?
      - [ ] **compact**
        - no control for compactness
      - [x] **ideally indexes well**
    - uxid-ex?
      - [x] **compact**
      - [x] **ideally indexes well**
      - probably fits the bill
      - no control for character set
    - nanoid?
      - [x] **compact**
      - [x] **ideally indexes well**
      - there's better options
  - mitigations for negatives
    - If we want super-short strings, without having to code "retry" logic, can just have a bunch of pregenerated IDs in some data-structure/datastore that we pop off as we need them
    - not concerned about this
- datastore is mostly a write-cache
## Stats
  - for stats, start dumb (ets counters), maybe make better (events per redirect, storing client info, periodic aggregation)
  - winner for now: `Counter` GenServer combined w/ SQL (`UPDATE ... SET times_used + $1`)
    - a lot of the process lifecycle would be reused anyway even w/ `:counters` or periodic DB aggregate approach
    - **I'm assuming this interview is to also see if I understand OTP, so might as well**
  - wants
    - [ ] speedy collection/broadcast of increments
    - [ ] accuracy of increments
  - **not** important
    - synchronous updates
  - Options
    - `:counters.new(1, [:write_concurrency])` & and ets table or registry
      - periodically write back to database
      - hydrate counters from database at startup
        - if we want the numbers to match "perfect" we can `put` the counter
        - if distributed we can just create the counters, and always read from DB
      - a bit overkill to start
      - reading the counts on a distributed cluster is more involved if not reading from the DB
    - events store (just postgres table to start) with fast inserts
      - periodically aggregated
      - stats could read from aggregated table/column
      - naturally limited by performance of event store
      - could still be combined with other options anyway
    - Counter GenServer "short link" w/ DynamicSupervisor/PartitionSupervisor & Registry
      - simple
      - `GenServer.cast` will take you a long way
      - naturally limited by bandwidth of the process, even w/ `cast`
      - causing a supervision crash of supervisor will kill all counters in naive case
      - `DynamicSupervisor` will avoid *typical* supervision crashes (it's `:one_for_one`)
      - w/ a proper interface could be replaced w/ the `:counters` approach w/ minimal client changes
    - `UPDATE` SQL statement
      - super simple
      - limited by throughput characteristics of DB & connections
  - mitigations for negatives
    - if using OTP constructs, and distribution is wanted, we should use `Pogo`, not `Horde`
      - No `:via` support in `Horde`
      - Testing is harder in `Horde` (ask me how I know :D)
      - Horde issue: https://github.com/derekkraan/horde/issues/234
    - simple, async-first `Counters` context module
      - `slug` is always the "key" regardless of whether it points to a GenServer, a `:counter`, or DB row
      - `increment/1`


## Requirements
- [x] Form on root
  - [x] validate invalid URL schemes
- [x] slug auto-generates
- [x] redirect slug to original
- [x] Stats page
- [?] Performance capabilities
  - [ ] Form @ 5 req/sec
  - [ ] `/{slug}` @ 25 req/sec
  - I don't see why not, especially w/ `MIX_ENV=prod`, but it's later and I didn't want to put the work in to figure out how to validate responses that are not 200s. Could probably use `wrk` or `vegeta`
