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

      <%!-- Mobile card list --%>
      <div id="reports-mobile" class="sm:hidden divide-y divide-base-300" phx-update="stream">
        <div :for={{id, report} <- @streams.reports} id={"mobile-#{id}"}
          class="py-4 flex flex-col gap-1 cursor-pointer hover:bg-base-200 px-2 rounded"
          phx-click={JS.navigate(~p"/reports/#{report}")}
        >
          <div class="flex items-center justify-between">
            <span class="font-black uppercase tracking-wider text-sm">{report.line}</span>
            <span class="badge badge-sm">{report.severity}</span>
          </div>
          <div class="text-sm text-base-content/70">{report.train} · {report.location}</div>
          <div :if={report.comments} class="text-xs text-base-content/50 truncate">{report.comments}</div>
          <div class="flex gap-4 mt-1 text-xs font-semibold" phx-click={nil}>
            <.link navigate={~p"/reports/#{report}/edit"} class="link">Edit</.link>
            <.link
              phx-click={JS.push("delete", value: %{id: report.id}) |> hide("#mobile-#{id}")}
              data-confirm="Are you sure?"
              class="link link-error"
            >Delete</.link>
          </div>
        </div>
      </div>

      <%!-- Desktop table --%>
      <.table
        id="reports"
        rows={@streams.reports}
        row_click={fn {_id, report} -> JS.navigate(~p"/reports/#{report}") end}
        class="max-sm:hidden"
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
