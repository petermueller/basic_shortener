defmodule Short.Repo.Migrations.CreateShortLink do
  use Ecto.Migration

  def change do
    create table(:short_link, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string
      add :long_url, :string
      add :times_used, :integer
      add :status, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:short_link, [:slug])
  end
end
