defmodule Myapp.Services.ReportsServiceTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Services.ReportsService
  alias Myapp.Services.RedisService

  @valid_key "report1"
  @invalid_key "report2"
  @report_data "report_data"
  @get_list_function ["module", :function_name, []]

  setup_with_mocks([
    {RedisService, [], start: fn -> "redis_client" end},
    {RedisService, [],
     get: fn _redis_client, key ->
       if key == @valid_key,
         do: {:ok, %{status: :completed, data: @report_data}},
         else: {:error, :not_found}
     end},
    {RedisService, [], set: fn _redis_client, _key, _data -> :ok end},
    {Exq, [], enqueue: fn _exq, _queue, _worker, _args -> :ok end}
  ]) do
    :ok
  end

  describe "request_report/2" do
    test "returns report if it already exists" do
      expected_response = {:ok, @report_data}
      assert ReportsService.request_report(@valid_key, @get_list_function) == expected_response
    end

    test "generates report as a background job if it does not exist" do
      expected_response = {:accepted, "The report will be generated"}
      assert ReportsService.request_report(@invalid_key, @get_list_function) == expected_response
    end
  end
end
