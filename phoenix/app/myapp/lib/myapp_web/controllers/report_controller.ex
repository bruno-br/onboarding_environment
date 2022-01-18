defmodule MyappWeb.ReportController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  alias Myapp.Management
  alias Myapp.Management.Product
  alias Myapp.Services.ProductsReportsService

  action_fallback(MyappWeb.FallbackController)

  def index(conn, _params) do
    response = ProductsReportsService.request_report()

    case response do
      {:ok, report} ->
        send_download(conn, {:binary, report}, filename: "products_report.csv")

      {:accepted, message} ->
        send_resp(conn, :accepted, message)

      {:service_unavailable, message} ->
        send_resp(conn, :service_unavailable, message)

      _ ->
        send_resp(conn, :bad_request, "")
    end
  end
end
