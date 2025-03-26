defmodule StaticBlog.Blog.Post do
  @posts_directory "priv/posts"

  defstruct [:title, :author, :content, :draft, :published_at, :slug]

  @type t :: %__MODULE__{
          title: String.t(),
          author: String.t(),
          content: String.t(),
          draft: boolean(),
          published_at: Date.t(),
          slug: String.t()
        }

  @doc """
  Lists all blog posts.
  Options:
    - :include_drafts - when true, includes draft posts (default: false)
    - :sort_by - field to sort by (default: :published_at)
    - :sort_order - :asc or :desc (default: :desc)
  """
  @spec list(keyword()) :: [t()]
  def list(opts \\ []) do
    include_drafts = Keyword.get(opts, :include_drafts, false)
    sort_by = Keyword.get(opts, :sort_by, :published_at)
    sort_order = Keyword.get(opts, :sort_order, :desc)

    @posts_directory
    |> File.ls!()
    |> Enum.map(&load_post/1)
    |> filter_drafts(include_drafts)
    |> sort_posts(sort_by, sort_order)
  end

  @doc """
  Gets a single post by slug.
  Returns nil if post is not found or is a draft (unless include_drafts: true).
  """
  @spec get_by_slug(String.t(), keyword()) :: t() | nil
  def get_by_slug(slug, opts \\ []) do
    include_drafts = Keyword.get(opts, :include_drafts, false)

    @posts_directory
    |> File.ls!()
    |> Enum.map(&load_post/1)
    |> Enum.find(fn post ->
      post.slug == slug && (include_drafts || !post.draft)
    end)
  end

  defp load_post(filename) do
    path = Path.join(@posts_directory, filename)
    {:ok, content} = File.read(path)

    {metadata, body} = parse_front_matter(content)

    %__MODULE__{
      title: metadata["title"],
      author: metadata["author"],
      draft: metadata["draft"] || false,
      published_at: parse_date(metadata["published_at"]),
      slug: metadata["slug"],
      content: Earmark.as_html!(body)
    }
  end

  defp parse_front_matter(content) do
    case String.split(content, ~r/---\n/, parts: 3) do
      ["", front_matter, body] ->
        {YamlElixir.read_from_string!(front_matter), body}

      _ ->
        raise "Invalid blog post format. Expected YAML front matter between --- markers."
    end
  end

  defp parse_date(nil), do: nil

  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> raise "Invalid date format in blog post. Expected ISO8601 (YYYY-MM-DD)."
    end
  end

  defp filter_drafts(posts, true), do: posts
  defp filter_drafts(posts, false), do: Enum.reject(posts, & &1.draft)

  defp sort_posts(posts, field, order) do
    Enum.sort_by(posts, &Map.get(&1, field), {order, Date})
  end
end
