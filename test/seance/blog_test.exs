defmodule Seance.BlogTest do
  use Seance.DataCase

  alias Seance.Blog
  alias Seance.Blog.BodyTypes.{Markdown, Image, Code}
  alias Unsplash.Image, as: UnsplashImage
  alias Github.Gist

  describe "posts" do
    alias Seance.Blog.Post

    @valid_attrs %{
      body: [%{"type" => "markdown", "content" => "# Hello", "id" => "an_id"}],
      tags: ["tag1", "tag2"],
      title: "some title"
    }
    @invalid_attrs %{body: nil, tags: nil, title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blog.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture() |> Seance.Blog.EditablePost.from_db()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Blog.create_post(@valid_attrs)
      assert post.body == [%{"type" => "markdown", "content" => "# Hello", "id" => "an_id"}]
      assert post.tags == ["tag1", "tag2"]
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "update_post_node/3" do
    test "updates content by id on post" do
      %{id: post_id, body: [%Markdown{id: node_id}]} = post = Blog.get_post!(post_fixture().id)
      Blog.update_post_node(post, node_id, "This is the new content of the node")

      assert %{body: [%Markdown{content: "This is the new content of the node"}]} =
               Blog.get_post!(post_id)
    end
  end

  describe "add_code_to_post/3" do
    test "updates content by id on post" do
      %{id: post_id} = post = Blog.get_post!(post_fixture().id)
      gist = %Gist{}
      Blog.add_code_to_post(post, 0, gist)

      assert %{body: [_markdown, %Code{id: code_id}, %Markdown{id: mk2_id}]} =
               Blog.get_post!(post_id)

      assert mk2_id
      assert code_id
    end
  end

  describe "add_image_to_post/3" do
    test "updates content by id on post" do
      %{id: post_id} = post = Blog.get_post!(post_fixture().id)

      image = %UnsplashImage{
        id: "123",
        url: "theurl",
        thumb_url: "thumb_url",
        creator_name: "ralph",
        creator_username: "ralph_the_guy"
      }

      Blog.add_image_to_post(post, 0, image)

      assert %{body: [_markdown, %Image{id: image_id}, %Markdown{id: mk2_id}]} =
               Blog.get_post!(post_id)

      assert mk2_id
      assert image_id
    end
  end

  describe "remove_post_node/2" do
    test "joins markdown nodes if they touch" do
      post = Blog.get_post!(post_fixture().id)
      gist = %Gist{}
      Blog.add_code_to_post(post, 0, gist)
      {:ok, post} = Blog.remove_post_node(post, 1)
      assert %{body: [%Markdown{}]} = post
    end
  end
end
