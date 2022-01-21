defmodule Myapp.Services.ProductsReportsServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.ProductsReportsService
  alias Myapp.Services.ReportsService

  import Mock

  describe "request_report/0" do
    test_with_mock("calls reports service with correct data", ReportsService,
      request_report: fn _title, _get_list_function -> {:ok, "csv"} end
    ) do
      report_title = "products_report"

      get_products_function = %{
        "module" => Myapp.Management,
        "function_name" => :list_products,
        "args" => []
      }

      assert ProductsReportsService.request_report() == {:ok, "csv"}
      assert_called(ReportsService.request_report(report_title, get_products_function))
    end
  end
end
