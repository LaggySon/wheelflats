defmodule WheelflatsWeb.ReportLive.Show do
  use WheelflatsWeb, :live_view

  alias Wheelflats.Reports

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Report {@report.id}
        <:subtitle>This is a report record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/reports"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/reports/#{@report}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit report
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Line">{@report.line}</:item>
        <:item title="Severity">{@report.severity}</:item>
        <:item title="Train">{@report.train}</:item>
        <:item title="Location">{@report.location}</:item>
        <:item title="Comments">{@report.comments}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Reports.subscribe_reports(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Report")
     |> assign(:report, Reports.get_report!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Wheelflats.Reports.Report{id: id} = report},
        %{assigns: %{report: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :report, report)}
  end

  def handle_info(
        {:deleted, %Wheelflats.Reports.Report{id: id}},
        %{assigns: %{report: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current report was deleted.")
     |> push_navigate(to: ~p"/reports")}
  end

  def handle_info({type, %Wheelflats.Reports.Report{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
