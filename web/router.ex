defmodule Kdb.Router do
  use Kdb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Kdb do
    pipe_through :browser # Use the default browser stack

    get "/", KafkaInstanceController, :index

    resources "/instances", KafkaInstanceController do
      get "/export", KafkaInstanceActionController, :export, as: "action"

      resources "/topics", TopicController, only: [:index, :show]
    end
    post "/instances/import", KafkaInstanceActionController, :import, as: "kafka_instance_action"

  end

  # Other scopes may use custom stacks.
  # scope "/api", Kdb do
  #   pipe_through :api
  # end
end
