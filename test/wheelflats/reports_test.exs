defmodule Wheelflats.ReportsTest do
  use Wheelflats.DataCase

  alias Wheelflats.Reports

  describe "reports" do
    alias Wheelflats.Reports.Report

    import Wheelflats.AccountsFixtures, only: [user_scope_fixture: 0]
    import Wheelflats.ReportsFixtures

    @invalid_attrs %{line: nil, location: nil, comments: nil, severity: nil, train: nil}

    test "list_reports/1 returns all scoped reports" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      report = report_fixture(scope)
      other_report = report_fixture(other_scope)
      assert Reports.list_reports(scope) == [report]
      assert Reports.list_reports(other_scope) == [other_report]
    end

    test "get_report!/2 returns the report with given id" do
      scope = user_scope_fixture()
      report = report_fixture(scope)
      other_scope = user_scope_fixture()
      assert Reports.get_report!(scope, report.id) == report
      assert_raise Ecto.NoResultsError, fn -> Reports.get_report!(other_scope, report.id) end
    end

    test "create_report/2 with valid data creates a report" do
      valid_attrs = %{line: :orange, location: "some location", comments: "some comments", severity: :"1", train: 42}
      scope = user_scope_fixture()

      assert {:ok, %Report{} = report} = Reports.create_report(scope, valid_attrs)
      assert report.line == :orange
      assert report.location == "some location"
      assert report.comments == "some comments"
      assert report.severity == :"1"
      assert report.train == 42
      assert report.user_id == scope.user.id
    end

    test "create_report/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Reports.create_report(scope, @invalid_attrs)
    end

    test "update_report/3 with valid data updates the report" do
      scope = user_scope_fixture()
      report = report_fixture(scope)
      update_attrs = %{line: :blue, location: "some updated location", comments: "some updated comments", severity: :"2", train: 43}

      assert {:ok, %Report{} = report} = Reports.update_report(scope, report, update_attrs)
      assert report.line == :blue
      assert report.location == "some updated location"
      assert report.comments == "some updated comments"
      assert report.severity == :"2"
      assert report.train == 43
    end

    test "update_report/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      report = report_fixture(scope)

      assert_raise MatchError, fn ->
        Reports.update_report(other_scope, report, %{})
      end
    end

    test "update_report/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      report = report_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Reports.update_report(scope, report, @invalid_attrs)
      assert report == Reports.get_report!(scope, report.id)
    end

    test "delete_report/2 deletes the report" do
      scope = user_scope_fixture()
      report = report_fixture(scope)
      assert {:ok, %Report{}} = Reports.delete_report(scope, report)
      assert_raise Ecto.NoResultsError, fn -> Reports.get_report!(scope, report.id) end
    end

    test "delete_report/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      report = report_fixture(scope)
      assert_raise MatchError, fn -> Reports.delete_report(other_scope, report) end
    end

    test "change_report/2 returns a report changeset" do
      scope = user_scope_fixture()
      report = report_fixture(scope)
      assert %Ecto.Changeset{} = Reports.change_report(scope, report)
    end
  end
end
