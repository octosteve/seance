defmodule Seance.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :tags, :map, null: false
      add :body, :map, null: false

      timestamps()
    end
  end
end
