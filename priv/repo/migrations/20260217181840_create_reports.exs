defmodule Wheelflats.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :line, :string
      add :train, :integer
      add :severity, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
