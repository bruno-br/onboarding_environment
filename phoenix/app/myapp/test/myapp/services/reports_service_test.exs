defmodule Myapp.Services.ReportsServiceTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Services.ReportsService
  alias Myapp.Services.RedisService

  @key_completed "report1"
  @key_generating "report2"
  @key_nonexistent "report3"
  @get_list_function ["module", :function_name, []]
  @report_data "csv_data"

  setup_with_mocks([
    {RedisService, [], start: fn -> "redis_client" end},
    {RedisService, [],
     get: fn _redis_client, key ->
       (key == "#{@key_completed}_status" && {:ok, :completed}) ||
         (key == "#{@key_generating}_status" && {:ok, :generating}) ||
         {:error, :not_found}
     end},
    {RedisService, [], set: fn _redis_client, _key, _data -> :ok end},
    {Exq, [], enqueue: fn _exq, _queue, _worker, _args -> :ok end},
    {File, [], read: fn _path -> {:ok, @report_data} end}
  ]) do
    :ok
  end

  describe "request_report/2" do
    test "returns report if it already exists" do
      expected_response = {:ok, @report_data}

      assert ReportsService.request_report(@key_completed, @get_list_function) ==
               expected_response
    end

    test "generates report as a background job if it does not exist" do
      expected_response = {:accepted, "The report will be generated"}

      assert ReportsService.request_report(@key_nonexistent, @get_list_function) ==
               expected_response
    end

    test "returns 503 if report is being generated" do
      expected_response = {:service_unavailable, "This report is still being generated"}

      assert ReportsService.request_report(@key_generating, @get_list_function) ==
               expected_response
    end
  end
end
