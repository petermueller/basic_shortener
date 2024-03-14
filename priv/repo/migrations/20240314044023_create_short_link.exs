defmodule Short.Repo.Migrations.CreateShortLink do
  use Ecto.Migration

  def change do
    create table(:short_link, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :long_url, :string, null: false
      add :times_used, :integer, default: 0
      add :status, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:short_link, [:slug])

    create index(:short_link, [:status])
  end
end
