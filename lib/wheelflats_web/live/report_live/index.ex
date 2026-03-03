defmodule WheelflatsWeb.ReportLive.Index do
  use WheelflatsWeb, :live_view

  alias Wheelflats.Reports

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Reports
        <:actions>
          <.button variant="primary" navigate={~p"/reports/new"}>
            <.icon name="hero-plus" /> New Report
          </.button>
        </:actions>
      </.header>

      <.table
        id="reports"
        rows={@streams.reports}
        row_click={fn {_id, report} -> JS.navigate(~p"/reports/#{report}") end}
      >
        <:col :let={{_id, report}} label="Line">{report.line}</:col>
        <:col :let={{_id, report}} label="Severity">{report.severity}</:col>
        <:col :let={{_id, report}} label="Train">{report.train}</:col>
        <:col :let={{_id, report}} label="Location">{report.location}</:col>
        <:col :let={{_id, report}} label="Comments">{report.comments}</:col>
        <:action :let={{_id, report}}>
          <div class="sr-only">
            <.link navigate={~p"/reports/#{report}"}>Show</.link>
          </div>
          <.link navigate={~p"/reports/#{report}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, report}}>
          <.link
            phx-click={JS.push("delete", value: %{id: report.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Reports.subscribe_reports(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Reports")
     |> stream(:reports, list_reports(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    report = Reports.get_report!(socket.assigns.current_scope, id)
    {:ok, _} = Reports.delete_report(socket.assigns.current_scope, report)

    {:noreply, stream_delete(socket, :reports, report)}
  end

  @impl true
  def handle_info({type, %Wheelflats.Reports.Report{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :reports, list_reports(socket.assigns.current_scope), reset: true)}
  end

  defp list_reports(current_scope) do
    Reports.list_reports(current_scope)
  end
end
