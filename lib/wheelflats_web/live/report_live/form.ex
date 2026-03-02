defmodule WheelflatsWeb.ReportLive.Form do
  use WheelflatsWeb, :live_view

  alias Wheelflats.Reports
  alias Wheelflats.Reports.Report

  # options={Ecto.Enum.values(Wheelflats.Reports.Report, :severity)}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage report records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="report-form" phx-change="validate" phx-submit="save">
        <%!-- Severity Options --%>
        <%!-- <.input
          field={@form[:severity]}
          type="radio"
          label={option}
          prompt="Choose a value"
          :for={option <- Ecto.Enum.values(Wheelflats.Reports.Report, :severity)}
        /> --%>
        <.input
          field={@form[:severity]}
          type="radio"
          label="No Flats"
          class="radio radio-sm bg-green-100 border-green-300 checked:bg-green-200 checked:text-green-600 checked:border-green-600"
          value={1}
        />
        <.input
          field={@form[:severity]}
          type="radio"
          label="Small amount of bumpiness/thumping noise"
          class="radio radio-sm bg-yellow-100 border-yellow-300 checked:bg-yellow-200 checked:text-yellow-600 checked:border-yellow-600"
          value={2}
        />
        <.input
          field={@form[:severity]}
          type="radio"
          label="Noticeable bumpiness/thumping noise, audible over conversation"
          class="radio radio-sm bg-orange-100 border-orange-300 checked:bg-orange-200 checked:text-orange-600 checked:border-orange-600"
          value={3}
        />
        <.input
          field={@form[:severity]}
          type="radio"
          label="Significant bumpiness/thumping noise, feels unsafe, hard/impossible to hear conversation"
          label_class="border-default border-1 hover:cursor-pointer rounded p-3 has-[:checked]:bg-red-200 has-[:checked]:text-red-600 has-[:checked]:border-red-600 bg-red-100 border-red-300"
          class="hidden peer radio radio-sm"
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
        <.input field={@form[:train]} type="number" label="Train" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:comments]} type="text" label="Comments" />
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
