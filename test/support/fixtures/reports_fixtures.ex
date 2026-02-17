defmodule Wheelflats.ReportsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wheelflats.Reports` context.
  """

  @doc """
  Generate a report.
  """
  def report_fixture(attrs \\ %{}) do
    {:ok, report} =
      attrs
      |> Enum.into(%{
        line: :orange,
        severity: 42,
        train: 42
      })
      |> Wheelflats.Reports.create_report()

    report
  end
end
