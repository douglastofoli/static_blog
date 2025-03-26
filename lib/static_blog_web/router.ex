defmodule StaticBlogWeb.Router do
  use StaticBlogWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/api", StaticBlogWeb do
    pipe_through(:api)
  end

  scope "/", StaticBlogWeb do
    pipe_through(:browser)

    # Blog routes
    live("/", BlogLive.Index, :index)
    live("/page/:page", BlogLive.Index, :index)
    live("/posts/:slug", BlogLive.Show, :show)
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:static_blog, :dev_routes) do
    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
