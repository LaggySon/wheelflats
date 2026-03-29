defmodule WheelflatsWeb.PageController do
  use WheelflatsWeb, :controller

  alias Wheelflats.Reports

  def home(conn, _params) do
    reports = Reports.list_all_reports()

    # stats = %{
    #   orange: 0,
    #   green: 0,
    #   red: 0,
    #   blue: 0
    # }

    stats =
      reports
      |> Enum.group_by(& &1.line)
      |> Map.new(fn {line, line_reports} ->
        score = Enum.sum(Enum.map(line_reports, fn r -> String.to_integer(Atom.to_string(r.severity)) end))
        {line, score}
      end)

    conn
    |> assign(:reports, reports)
    |> assign(:stats, stats)
    |> render()
  end
end
