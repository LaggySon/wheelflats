defmodule Wheelflats.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :line, :string
      add :severity, :string
      add :train, :integer
      add :location, :string
      add :comments, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reports, [:user_id])
  end
end
