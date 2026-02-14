defmodule WheelflatsWeb.PageController do
  use WheelflatsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
