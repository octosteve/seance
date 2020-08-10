defmodule Seance.Blog.EditablePostTest do
  use ExUnit.Case
  alias Seance.Blog.Post
  alias Seance.Blog.EditablePost
  alias Seance.Blog.BodyTypes.Markdown
  alias Seance.Blog.BodyTypes.Code

  test "can have a code node added" do
    editable_post = %EditablePost{
      title: "My cool post",
      tags: ["tag1"],
      body: [
        %Markdown{
          id: "123",
          content: "# hello"
        }
      ]
    }

    gist = %Github.Gist{
      id: "456",
      language: "elixir",
      filename: "hello.ex"
    }

    assert %{
             body: [
               %Markdown{
                 id: "123",
                 content: "# hello"
               },
               %Code{
                 gist_id: "456",
                 language: "elixir",
                 filename: "hello.ex"
               },
               %Markdown{
                 content: ""
               }
             ]
           } = EditablePost.add_code_node(editable_post, 0, gist)
  end

  describe "loading from database record" do
    test "loads types for body nodes" do
      db_post = %Post{
        title: "the title",
        tags: ["tag1", "tag2"],
        body: [
          %{"id" => "123", "type" => "markdown", "content" => "# hello"},
          %{
            "id" => "456",
            "type" => "code",
            "language" => "elixir",
            "gist_id" => "aa5a315d61ae9438b18d",
            "content" => ~s{IO.puts("Sup")}
          }
        ]
      }

      editable_post = EditablePost.from_db(db_post)
      assert editable_post.title == db_post.title
      assert editable_post.tags == db_post.tags

      assert [
               %Markdown{
                 id: "123",
                 content: "# hello"
               },
               %Code{
                 id: "456",
                 language: "elixir",
                 gist_id: "aa5a315d61ae9438b18d",
                 content: ~s{IO.puts("Sup")}
               }
             ] ==
               editable_post.body
    end
  end

  describe "dumping to DB record" do
    test "it converts it to the shape the db expects" do
      %Post{
        title: title,
        tags: tags,
        body: body
      } =
        %EditablePost{
          title: "the title",
          tags: ["tag1", "tag2"],
          body: [
            %Markdown{
              id: "123",
              content: "# hello"
            },
            %Code{
              id: "456",
              language: "elixir",
              gist_id: "aa5a315d61ae9438b18d",
              content: ~s{IO.puts("Sup")},
              filename: "test"
            }
          ]
        }
        |> EditablePost.for_db()

      assert title == "the title"
      assert tags == ["tag1", "tag2"]

      assert body == [
               %{"id" => "123", "type" => "markdown", "content" => "# hello"},
               %{
                 "id" => "456",
                 "type" => "code",
                 "language" => "elixir",
                 "gist_id" => "aa5a315d61ae9438b18d",
                 "content" => ~s{IO.puts("Sup")},
                 "filename" => "test"
               }
             ]
    end
  end

  describe "remove_post_node/3" do
    test "merges markdown nodes if they touch" do
      post = %EditablePost{
        title: "the title",
        tags: ["tag1", "tag2"],
        body: [
          %Markdown{
            id: "123",
            content: "# hello"
          },
          %Code{
            id: "456",
            language: "elixir",
            gist_id: "aa5a315d61ae9438b18d",
            content: ~s{IO.puts("Sup")},
            filename: "test"
          },
          %Markdown{
            id: "789",
            content: "and goodbye"
          }
        ]
      }

      assert %{body: [%Markdown{content: "# hello\nand goodbye"}]} =
               EditablePost.remove_post_node(post, 1)
    end

    test "handles merge when first markdown has no content" do
      post = %EditablePost{
        title: "the title",
        tags: ["tag1", "tag2"],
        body: [
          %Markdown{
            id: "123",
            content: nil
          },
          %Code{
            id: "456",
            language: "elixir",
            gist_id: "aa5a315d61ae9438b18d",
            content: ~s{IO.puts("Sup")},
            filename: "test"
          },
          %Markdown{
            id: "789",
            content: "and goodbye"
          }
        ]
      }

      assert %{body: [%Markdown{content: "and goodbye"}]} = EditablePost.remove_post_node(post, 1)
    end

    test "handles merge when second markdown has no content" do
      post = %EditablePost{
        title: "the title",
        tags: ["tag1", "tag2"],
        body: [
          %Markdown{
            id: "123",
            content: "# hello"
          },
          %Code{
            id: "456",
            language: "elixir",
            gist_id: "aa5a315d61ae9438b18d",
            content: ~s{IO.puts("Sup")},
            filename: "test"
          },
          %Markdown{
            id: "789",
            content: nil
          }
        ]
      }

      assert %{body: [%Markdown{content: "# hello"}]} = EditablePost.remove_post_node(post, 1)
    end
  end
end
