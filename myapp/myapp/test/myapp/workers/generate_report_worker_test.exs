defmodule Myapp.Workers.GenerateReportWorkerTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Services.{RedisService, CsvFormatService, ReportsMailerService}
  alias Myapp.Workers.GenerateReportWorker

  @valid_list [%{a: 1}, %{a: 2}]
  @csv_formated "list_csv"

  def get_list_function_mock(), do: @valid_list

  setup_with_mocks([
    {RedisService, [],
     set: fn _key, _data -> :ok end,
     set: fn _key, _data, _expiration -> :ok end,
     del: fn _key -> :ok end},
    {CsvFormatService, [],
     get_csv_string: fn
       @valid_list -> {:ok, @csv_formated}
       _invalid_list -> {:error, "invalid_list"}
     end},
    {File, [], write: fn _path, _data -> :ok end},
    {ReportsMailerService, [],
     send_email: fn _title, _attachment -> {:ok, "Email sent successfully"} end}
  ]) do
    :ok
  end

  describe "perform/2" do
    test "returns :ok if report was sucessfully generated" do
      {report_title, get_list_function} = get_report_mock_data()
      assert GenerateReportWorker.perform(report_title, get_list_function) == :ok
    end

    test "converts list to csv format" do
      {report_title, get_list_function} = get_report_mock_data()
      list = get_list_function_mock()

      GenerateReportWorker.perform(report_title, get_list_function)
      assert_called(CsvFormatService.get_csv_string(list))
    end

    test "updates report status on redis" do
      {report_title, get_list_function} = get_report_mock_data()
      report_status_key = "#{report_title}_status"
      expiration_time = 60

      GenerateReportWorker.perform(report_title, get_list_function, expiration_time)

      assert_called(RedisService.set(report_status_key, :generating, expiration_time))

      assert_called(RedisService.set(report_status_key, :completed, expiration_time))
    end

    test "deletes key from redis if there is an error generating the report" do
      report_title = "any_title"
      report_status_key = "any_title_status"

      GenerateReportWorker.perform(report_title, "invalid_arg")

      assert_called(RedisService.del(report_status_key))
    end

    test "creates new csv file with correct name and data" do
      {report_title, get_list_function} = get_report_mock_data()
      expected_file_name = "#{report_title}.csv"
      expected_file_data = @csv_formated

      GenerateReportWorker.perform(report_title, get_list_function)

      assert_called(File.write(expected_file_name, expected_file_data))
    end

    test "sends email with correct report title and data" do
      {report_title, get_list_function} = get_report_mock_data()

      attachment = %{
        content_type: "text/csv",
        filename: "#{report_title}.csv",
        data: @csv_formated
      }

      GenerateReportWorker.perform(report_title, get_list_function)

      assert_called(ReportsMailerService.send_email(report_title, attachment))
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
