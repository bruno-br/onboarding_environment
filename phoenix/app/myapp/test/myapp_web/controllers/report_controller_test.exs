defmodule MyappWeb.ReportControllerTest do
  use MyappWeb.ConnCase, async: false

  import Mock

  alias MyappWeb.ReportController
  alias Myapp.Services.ProductsReportsService

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/1" do
    test "returns csv if report was created", %{conn: conn} do
      with_mock(ProductsReportsService, [], request_report: fn -> {:ok, "csv"} end) do
        conn = get(conn, Routes.report_path(conn, :index))
        assert response(conn, 200) == "csv"
      end
    end

    test "returns 202 if report is being created", %{conn: conn} do
      with_mock(ProductsReportsService, [], request_report: fn -> {:accepted, ""} end) do
        conn = get(conn, Routes.report_path(conn, :index))
        response(conn, 202)
      end
    end

    test "returns 400 if there is an error getting the report", %{conn: conn} do
      with_mock(ProductsReportsService, [], request_report: fn -> {:error, ""} end) do
        conn = get(conn, Routes.report_path(conn, :index))
        response(conn, 400)
      end
    end
  end
end
