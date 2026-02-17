defmodule Wheelflats.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :line, Ecto.Enum, values: [:orange, :blue, :red, :green]
    field :train, :integer
    field :severity, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:line, :train, :severity])
    |> validate_required([:line, :train, :severity])
  end
end
