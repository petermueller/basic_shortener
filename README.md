# Short
> A basic URL Shortener

Start a Postgres DB:
* `docker run -d -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust --name=short_db postgres`

To start "Short":
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:8080`](http://localhost:8080) from your browser.

# Design Decisions/Notes
- slug generation
  - compact
  - ideally indexes well
  - UUIDv7?
    - no control for compactness
  - puid?
    - unsure on index performance (not time-based)
  - typeid-elixir?
    - no control for compactness
  - uxid-ex?
    - probably fits the bill
  - nanoid?
    - there's better options
- datastore is mostly a write-cache
- for stats, start dumb (ets counters), maybe make better (events per redirect, storing client info, periodic aggregation)


## Requirements
- [ ] Form on root
  - [ ] validate invalid URL schemes
- [ ] slug auto-generates
- [ ] redirect slug to original
- [ ] Stats page
- [ ] Performance capabilities
  - [ ] Form @ 5 req/sec
  - [ ] `/{slug}` @ 25 req/sec
