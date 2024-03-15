defmodule ShortWeb.ShortLinkHTML do
  use ShortWeb, :html

  embed_templates "short_link_html/*"

  @doc """
  Renders a short_link form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def short_link_form(assigns)
end
