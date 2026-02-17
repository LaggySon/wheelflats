defmodule Wheelflats.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :line, Ecto.Enum, values: [:orange, :blue, :red, :green]
    field :severity, Ecto.Enum, values: [:"1", :"2", :"3", :"4"]
    field :train, :integer
    field :location, :string
    field :comments, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(report, attrs, user_scope) do
    report
    |> cast(attrs, [:line, :severity, :train, :location, :comments])
    |> validate_required([:line, :severity, :train, :location, :comments])
    |> put_change(:user_id, user_scope.user.id)
  end
end
