defmodule Seance.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Seance.Repo

  alias Seance.Blog.Post
  alias Seance.Blog.EditablePost

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id) |> EditablePost.from_db()

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post_node(%EditablePost{} = post, id, content) do
    body =
      post
      |> EditablePost.update_post_node(id, content)

    {:ok, post} =
      post
      |> EditablePost.for_db()
      |> Ecto.Changeset.change(%{body: body})
      |> Repo.update()

    {:ok, EditablePost.from_db(post)}
  end

  def remove_post_node(%EditablePost{} = post, id) do
    body =
      post
      |> EditablePost.remove_post_node(id)

    {:ok, post} =
      post
      |> EditablePost.for_db()
      |> Ecto.Changeset.change(%{body: body})
      |> Repo.update()

    {:ok, EditablePost.from_db(post)}
  end

  def add_code_to_post(%EditablePost{} = post, insert_after, gist) do
    %{body: body} =
      post =
      post
      |> EditablePost.add_code_node(insert_after, gist)
      |> EditablePost.for_db()

    {:ok, post} =
      post
      |> Ecto.Changeset.change(%{body: body})
      |> Repo.update()

    {:ok, EditablePost.from_db(post)}
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(post, attrs \\ %{})

  def change_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
  end

  def change_post(%EditablePost{} = post, attrs) do
    post
    |> EditablePost.for_db()
    |> Post.changeset(attrs)
  end
end
