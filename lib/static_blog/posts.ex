defmodule StaticBlog.Posts do
  @moduledoc """
  The Posts context.
  This module serves as the main interface for blog post operations.
  """

  alias StaticBlog.Blog.Post

  @doc """
  Returns a list of posts based on the given options.

  ## Options

    * `:include_drafts` - when true, includes draft posts (default: false)
    * `:sort_by` - field to sort by (default: :published_at)
    * `:sort_order` - :asc or :desc (default: :desc)
    * `:limit` - limit the number of posts returned (default: nil)
    * `:offset` - number of posts to skip (default: 0)

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

      iex> list_posts(include_drafts: true, sort_by: :title)
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    opts
    |> Keyword.put_new(:include_drafts, false)
    |> Keyword.put_new(:sort_by, :published_at)
    |> Keyword.put_new(:sort_order, :desc)
    |> Post.list()
    |> maybe_paginate(opts)
  end

  @doc """
  Gets a single post by slug.

  Returns `nil` if the post doesn't exist or is a draft (unless include_drafts: true).

  ## Examples

      iex> get_post_by_slug("welcome-post")
      %Post{}

      iex> get_post_by_slug("non-existent")
      nil

  """
  def get_post_by_slug(slug, opts \\ []) do
    Post.get_by_slug(slug, opts)
  end

  @doc """
  Returns the total number of posts.

  ## Options

    * `:include_drafts` - when true, includes draft posts in the count (default: false)

  ## Examples

      iex> count_posts()
      10

      iex> count_posts(include_drafts: true)
      12

  """
  def count_posts(opts \\ []) do
    opts
    |> list_posts()
    |> length()
  end

  @doc """
  Returns a list of recent posts.

  ## Options

    * `:limit` - number of posts to return (default: 5)
    * `:include_drafts` - when true, includes draft posts (default: false)

  ## Examples

      iex> recent_posts()
      [%Post{}, ...]

      iex> recent_posts(limit: 3)
      [%Post{}, ...]

  """
  def recent_posts(opts \\ []) do
    limit = Keyword.get(opts, :limit, 5)

    opts
    |> Keyword.put(:limit, limit)
    |> list_posts()
  end

  @doc """
  Returns a list of posts by author.

  ## Examples

      iex> posts_by_author("John Doe")
      [%Post{}, ...]

  """
  def posts_by_author(author, opts \\ []) do
    opts
    |> list_posts()
    |> Enum.filter(&(&1.author == author))
  end

  @doc """
  Returns a map of posts grouped by year.

  ## Examples

      iex> posts_by_year()
      %{
        2025 => [%Post{}, ...],
        2024 => [%Post{}, ...]
      }

  """
  def posts_by_year(opts \\ []) do
    opts
    |> list_posts()
    |> Enum.group_by(&get_year(&1.published_at))
  end

  @doc """
  Returns all unique authors.

  ## Examples

      iex> list_authors()
      ["John Doe", "Jane Smith"]

  """
  def list_authors(opts \\ []) do
    opts
    |> list_posts()
    |> Enum.map(& &1.author)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp maybe_paginate(posts, opts) do
    limit = Keyword.get(opts, :limit)
    offset = Keyword.get(opts, :offset, 0)

    posts
    |> Enum.drop(offset)
    |> maybe_take(limit)
  end

  defp maybe_take(posts, nil), do: posts
  defp maybe_take(posts, limit), do: Enum.take(posts, limit)

  defp get_year(nil), do: nil
  defp get_year(date), do: date.year
end
