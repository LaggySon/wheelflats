defmodule WheelflatsWeb.ReportHTML do
  use WheelflatsWeb, :html

  embed_templates "report_html/*"

  @doc """
  Renders a report form.

  The form is defined in the template at
  report_html/report_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def report_form(assigns)
end
