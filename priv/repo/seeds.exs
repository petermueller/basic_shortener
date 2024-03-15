# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Short.Repo.insert!(%Short.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _short_link} = Short.ShortenedLinks.create_short_link(%{long_url: "https://google.com"})
{:ok, _short_link} = Short.ShortenedLinks.create_short_link(%{long_url: "https://example.com"})
{:ok, _short_link} = Short.ShortenedLinks.create_short_link(%{long_url: "https://example.com"})
{:ok, _short_link} = Short.ShortenedLinks.create_short_link(%{long_url: "https://1.1.1.1"})
