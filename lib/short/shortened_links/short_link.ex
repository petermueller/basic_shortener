defmodule Short.ShortenedLinks.ShortLink do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "short_link" do
    field :status, Ecto.Enum, values: [:unpublished, :published, :deleted], default: :published
    field :slug, :string, autogenerate: {Short.ShortenedLinks.Slug, :generate, []}
    field :long_url, :string
    field :times_used, :integer, default: 0

    timestamps(type: :utc_datetime_usec)
  end

  @type t() :: %__MODULE__{
          id: binary(),
          status: :unpublished | :published | :deleted,
          slug: Short.ShortenedLinks.Slug.t(),
          long_url: String.t(),
          times_used: non_neg_integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @scheme_and_domain_re ~r/^https?:\/\/.+\..+$/

  @doc false
  def changeset(short_link, attrs) do
    short_link
    |> cast(attrs, [:slug, :long_url, :status])
    |> validate_required([:long_url])
    # Not "great", but good enough
    |> validate_format(:long_url, @scheme_and_domain_re,
      message: "must start with http(s):// and be a valid domain"
    )
    |> validate_format(:slug, ~r/^[[:alnum:]]+$/)
    |> unique_constraint(:slug)
  end

  def initial_statuses, do: [:unpublished, :published]
end
