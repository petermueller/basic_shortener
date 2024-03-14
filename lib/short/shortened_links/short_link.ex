defmodule Short.ShortenedLinks.ShortLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "short_link" do
    field :status, Ecto.Enum, values: [:unpublished, :published, :deleted], default: :published
    field :slug, :string
    field :long_url, :string
    field :times_used, :integer, default: 0

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(short_link, attrs) do
    short_link
    |> cast(attrs, [:slug, :long_url, :times_used, :status])
    |> validate_required([:slug, :long_url])
    |> unique_constraint(:slug)
  end

  def initial_statuses, do: [:unpublished, :published]
end
