defmodule StaticBlogWeb.BlogLive.Show do
  use StaticBlogWeb, :live_view

  alias StaticBlog.Posts

  def mount(%{"slug" => slug}, _session, socket) do
    case Posts.get_post_by_slug(slug) do
      nil ->
        {:ok, redirect(socket, to: "/")}

      post ->
        socket =
          socket
          |> assign(:post, post)
          |> assign(:recent_posts, Posts.recent_posts(limit: 3))
          |> assign(:posts_by_author, Posts.posts_by_author(post.author))

        {:ok, socket}
    end
  end
end
