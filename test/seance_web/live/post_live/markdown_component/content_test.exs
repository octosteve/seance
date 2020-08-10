defmodule SeanceWeb.PostLive.MarkdownComponent.ContentTest do
  alias SeanceWeb.PostLive.MarkdownComponent.Content
  use ExUnit.Case

  test "identifying code change" do
    assert %Content{body: "test\n", inserting_code_block: true} = Content.update("test\n```")
  end

  test "identifying unsplash slash command" do
    assert %Content{body: "test\n", unsplash_slash_command: true} =
             Content.update("test\n/unsplash")
  end

  test "identifying buffer updates" do
    assert %Content{body: "test\nmore things", buffer_update: true} =
             Content.update("test\nmore things")
  end

  describe "line break for body" do
    test "it adds a new line break on the 61st character" do
      body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit leo x"
      body_with_new_line = "Lorem ipsum dolor sit amet, consectetur adipiscing elit leo\nx"
      assert body |> String.length() == 61
      assert Content.update(body).body == body_with_new_line
    end

    test "preserves older new lines if they are present" do
      body =
        "hello\n\n\nthis should also be preserved\nLorem ipsum dolor sit amet, consectetur adipiscing elit leo x"

      expected =
        "hello\n\n\nthis should also be preserved\nLorem ipsum dolor sit amet, consectetur adipiscing elit leo\nx"

      assert Content.update(body).body == expected
    end
  end

  test "row count for nil body" do
    assert Content.new(nil) |> Content.row_count() == 1
  end

  test "row count for body with 3 lines" do
    assert Content.new("hello\nworld\nnew line") |> Content.row_count() == 3
  end
end
