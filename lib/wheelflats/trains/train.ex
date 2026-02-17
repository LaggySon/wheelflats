defmodule Wheelflats.Trains.Train do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trains" do
    field :line, Ecto.Enum,
      values: [
        :red,
        :orange,
        :green,
        :blue
      ]

    field :number, :integer
    field :severity, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(train, attrs) do
    train
    |> cast(attrs, [:line, :number, :severity])
    |> validate_required([:line, :number, :severity])
    |> validate_format(:number, ~r/\b\d{4}\b/)
  end
end
