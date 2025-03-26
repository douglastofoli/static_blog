defmodule StaticBlogWeb.BlogLive.Index do
  use StaticBlogWeb, :live_view

  alias StaticBlog.Posts

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:posts, Posts.list_posts())
      |> assign(:recent_posts, Posts.recent_posts(limit: 5))
      |> assign(:authors, Posts.list_authors())

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = 10

    paginated_posts =
      Posts.list_posts(
        limit: per_page,
        offset: (page - 1) * per_page
      )

    socket =
      socket
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:total_posts, Posts.count_posts())
      |> assign(:posts, paginated_posts)

    {:noreply, socket}
  end
end
