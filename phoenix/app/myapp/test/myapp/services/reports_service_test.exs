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
    {RedisService, [],
     start: fn -> "redis_client" end,
     get: fn
       _client, "#{@key_completed}_status" -> {:ok, :completed}
       _client, "#{@key_generating}_status" -> {:ok, :generating}
       _client, "#{@key_nonexistent}_status" -> {:error, :not_found}
     end,
     set: fn _redis_client, _key, _data -> :ok end},
    {File, [], read: fn _path -> {:ok, @report_data} end}
  ]) do
    :ok
  end

  describe "request_report/2" do
    test_with_mock "returns report if it already exists", Exq,
      enqueue: fn _exq, _queue, _worker, _args -> {:ok, "job_id"} end do
      expected_response = {:ok, @report_data}

      assert ReportsService.request_report(@key_completed, @get_list_function) ==
               expected_response
    end

    test_with_mock "generates report as a background job if it does not exist", Exq,
      enqueue: fn _exq, _queue, _worker, _args -> {:ok, "job_id"} end do
      expected_response = {:accepted, "The report will be generated"}

      assert ReportsService.request_report(@key_nonexistent, @get_list_function) ==
               expected_response
    end

    test_with_mock "returns :too_early if report is being generated", Exq,
      enqueue: fn _exq, _queue, _worker, _args -> {:ok, "job_id"} end do
      expected_response = {:too_early, "This report is still being generated"}

      assert ReportsService.request_report(@key_generating, @get_list_function) ==
               expected_response
    end

    test_with_mock "returns error message when there is an error enqueing the job", Exq,
      enqueue: fn _exq, _queue, _worker, _args -> {:error, "error_reason"} end do
      expected_response = {:error, "There was an error trying to generate the report"}

      assert ReportsService.request_report(@key_nonexistent, @get_list_function) ==
               expected_response
    end
  end
end
