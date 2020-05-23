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

    assert %{
             body: [
               %Markdown{
                 id: "123",
                 content: "# hello"
               },
               %Code{
                 content: "IO.puts(\"Hello there\")",
                 gist_id: nil,
                 language: "elixir"
               }
             ]
           } = EditablePost.add_code_node(editable_post)
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
              content: ~s{IO.puts("Sup")}
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
                 "content" => ~s{IO.puts("Sup")}
               }
             ]
    end

    test "converts attrs to include a full update of the body" do
      editable_post = %EditablePost{
        title: "My cool post",
        tags: ["tag1"],
        body: [
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
        ]
      }

      attrs = %{
        "body" => %{
          "123" => "# Goodbye",
          "456" => ~s{IO.inspect("Sup")}
        }
      }

      assert %{
               "body" => [
                 %{"content" => "# Goodbye", "id" => "123", "type" => "markdown"},
                 %{
                   "content" => "IO.inspect(\"Sup\")",
                   "gist_id" => "aa5a315d61ae9438b18d",
                   "id" => "456",
                   "language" => "elixir",
                   "type" => "code"
                 }
               ]
             } = EditablePost.update_attrs(editable_post, attrs)
    end
  end
end
