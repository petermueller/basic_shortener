defmodule Short.ShortenedLinks.Slug do
  @moduledoc """
  A minimal module for generating slugs.
  """

  use Puid, total: 10.0e5, risk: 1.0e12, chars: :wordSafe32
end
