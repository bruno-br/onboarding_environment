defmodule Myapp.Services.ProductsReportsService do
  alias Myapp.Services.ReportsService

  def request_report() do
    report_title = "products_report"

    get_products_function = %{
      "module" => Myapp.Management,
      "function_name" => :list_products,
      "args" => []
    }

    ReportsService.request_report(report_title, get_products_function)
  end
end
