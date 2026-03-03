defmodule Wheelflats.ReportsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wheelflats.Reports` context.
  """

  @doc """
  Generate a report.
  """
  def report_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        comments: "some comments",
        line: :orange,
        location: "some location",
        severity: :"1",
        train: 42
      })

    {:ok, report} = Wheelflats.Reports.create_report(scope, attrs)
    report
  end
end
