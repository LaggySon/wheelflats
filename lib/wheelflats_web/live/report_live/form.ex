defmodule WheelflatsWeb.ReportLive.Form do
  use WheelflatsWeb, :live_view

  alias Wheelflats.Reports
  alias Wheelflats.Reports.Report

  # options={Ecto.Enum.values(Wheelflats.Reports.Report, :severity)}

  defp severity_classes("green") do
    "has-[:checked]:bg-green-200 has-[:checked]:border-green-600 bg-green-100 border-green-300"
  end

  defp severity_classes("orange") do
    "has-[:checked]:bg-orange-200 has-[:checked]:border-orange-600 bg-orange-100 border-orange-300"
  end

  defp severity_classes("yellow") do
    "has-[:checked]:bg-yellow-200 has-[:checked]:border-yellow-600 bg-yellow-100 border-yellow-300"
  end

  defp severity_classes("red") do
    "has-[:checked]:bg-red-200 has-[:checked]:border-red-600 bg-red-100 border-red-300"
  end

  def severity_selector(assigns) do
    ~H"""
    <.input
      field={@field}
      type="radio"
      label={@label}
      label_class={"border-default border-1 hover:cursor-pointer rounded p-3 text-black font-bold text-wrap " <> severity_classes(@color)}
      class="hidden peer radio radio-sm"
      value={@value}
    />
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Report a new wheel flat</:subtitle>
      </.header>

      <.form for={@form} id="report-form" phx-change="validate" phx-submit="save" class="flex flex-col m-3 max-w-full">

        <%!-- Severity Options --%>
        <.severity_selector
          field={@form[:severity]}
          label="No Flats - Smooth, quiet ride"
          color="green"
          value={1}
        />
        <.severity_selector
          field={@form[:severity]}
          label="Minor - Small amount of bumpiness/thumping noise"
          color="yellow"
          value={2}
        />
        <.severity_selector
          field={@form[:severity]}
          label="Moderate - Noticeable bumpiness/thumping noise, audible over conversation"
          color="orange"
          value={3}
        />
        <.severity_selector
          field={@form[:severity]}
          label="Severe - Significant bumpiness/thumping noise, feels unsafe"
          color="red"
          value={4}
        />
        <%!-- End Severity Options --%>

        <.input
          field={@form[:line]}
          type="select"
          label="Line"
          prompt="Choose a value"
          options={Ecto.Enum.values(Wheelflats.Reports.Report, :line)}
        />
        <.input field={@form[:train]} type="number" label="Car Number - Find this at the front/rear interior or exterior of the train carriage" />
        <.input field={@form[:location]} required={false} type="text" label="Location (Optional) - Where in the train car do you hear the noise coming from?" />
        <.input field={@form[:comments]} required={false} type="text" label="Comments (Optional) - Any additional information you want to add" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Report</.button>
          <.button navigate={return_path(@current_scope, @return_to, @report)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    report = Reports.get_report!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Report")
    |> assign(:report, report)
    |> assign(:form, to_form(Reports.change_report(socket.assigns.current_scope, report)))
  end

  defp apply_action(socket, :new, _params) do
    report = %Report{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Report")
    |> assign(:report, report)
    |> assign(:form, to_form(Reports.change_report(socket.assigns.current_scope, report)))
  end

  @impl true
  def handle_event("validate", %{"report" => report_params}, socket) do
    changeset =
      Reports.change_report(socket.assigns.current_scope, socket.assigns.report, report_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"report" => report_params}, socket) do
    save_report(socket, socket.assigns.live_action, report_params)
  end

  defp save_report(socket, :edit, report_params) do
    case Reports.update_report(socket.assigns.current_scope, socket.assigns.report, report_params) do
      {:ok, report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, report)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_report(socket, :new, report_params) do
    case Reports.create_report(socket.assigns.current_scope, report_params) do
      {:ok, report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, report)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _report), do: ~p"/reports"
  defp return_path(_scope, "show", report), do: ~p"/reports/#{report}"
end
