defmodule Seance.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :tags, :array, default: [], null: false
      add :body, :map, default: [], null: false

      timestamps()
    end
  end
end
