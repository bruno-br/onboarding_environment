defmodule Myapp.Workers.GenerateReportWorkerTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Services.RedisService
  alias Myapp.Services.CsvFormatService
  alias Myapp.Workers.GenerateReportWorker

  def get_list_function_mock(), do: [%{a: 1}, %{a: 2}]

  @csv_formated "list_csv"

  setup_with_mocks([
    {RedisService, [], start: fn -> "redis_client" end},
    {RedisService, [], set: fn _redis_client, _key, _data -> :ok end},
    {CsvFormatService, [], get_csv_string: fn _list -> @csv_formated end}
  ]) do
    :ok
  end

  describe "perform/2" do
    test "returns :ok if report was sucessfully generated" do
      {report_title, get_list_function} = get_report_mock_data()
      assert GenerateReportWorker.perform(report_title, get_list_function) == :ok
    end

    test "updates report status and data on redis" do
      {report_title, get_list_function} = get_report_mock_data()
      GenerateReportWorker.perform(report_title, get_list_function)

      report_value_generating = %{data: "", status: :generating}
      assert_called(RedisService.set("redis_client", report_title, report_value_generating))

      report_value_completed = %{data: @csv_formated, status: :completed}
      assert_called(RedisService.set("redis_client", report_title, report_value_completed))
    end
  end

  defp get_report_mock_data() do
    report_title = "report1"

    get_list_function = %{
      "module" => Atom.to_string(Myapp.Workers.GenerateReportWorkerTest),
      "function_name" => Atom.to_string(:get_list_function_mock),
      "args" => []
    }

    {report_title, get_list_function}
  end
end
