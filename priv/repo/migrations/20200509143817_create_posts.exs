defmodule Seance.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :tags, :string
      add :body, :binary

      timestamps()
    end
  end
end
