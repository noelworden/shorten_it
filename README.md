# ShortenIt - Your Handy URL Shortener

## Requirements
- Install [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)
- Install [asdf](https://asdf-vm.com/guide/getting-started.html)

## Startup steps
1. Clone down the repo and navigate to it in the terminal
1. Install languages via `asdf`:
    - `asdf plugin add erlang`
    - `asdf plugin add elixir`
    - `asdf install`
1. Open the Docker Desktop app
1. Open a second terminal tab and start the database
    - Create a a `postgres` instance with a volume (to persist the data)
        ```
        docker container run --name postgres -p 5432:5432 \
        -e POSTGRES_PASSWORD=postgres \
        -v shorten_it_postgres:/var/lib/postgresql/data \
        --rm postgres:15.4
        ```
1. Back in the first tab, setup the app:
    - `mix setup`
1. Execute the test suite with:
    - `mix test`
1. Finally, spin up the server:
    - `mix phx.server`


## How to use the app
### Short URL Creation
- Navigate to [http://localhost:4000](http://localhost:4000) and enter a URL to be shortened
- After submitting the form, you will be shown the generated short URL, ie: `localhost:4000/AvzXx6zwPE~`
- Copy the entire URL and past into the address bar of your browser
- You will be redirected to the URL you originally provided
### Stats
- There is an option to view a list of all shortened URLs and their respective view counts, it can be found at: [http://localhost:4000/stats](http://localhost:4000/stats)
- That page also gives the option to download the data as a CSV
