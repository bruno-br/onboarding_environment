defmodule MyappWeb.ReportControllerTest do
  use MyappWeb.ConnCase, async: false

  import Mock
  alias Myapp.Services.ProductsReportsService

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/1" do
    test_with_mock("returns csv if report was created", %{conn: conn}, ProductsReportsService, [],
      request_report: fn -> {:ok, "csv"} end
    ) do
      conn = get(conn, Routes.report_path(conn, :index))
      assert response(conn, 200) == "csv"
    end

    test_with_mock(
      "returns 202 if report does not exist and will be created",
      %{conn: conn},
      ProductsReportsService,
      [],
      request_report: fn -> {:accepted, ""} end
    ) do
      conn = get(conn, Routes.report_path(conn, :index))
      response(conn, 202)
    end

    test_with_mock(
      "returns 425 if report is still being generated",
      %{conn: conn},
      ProductsReportsService,
      [],
      request_report: fn -> {:too_early, ""} end
    ) do
      conn = get(conn, Routes.report_path(conn, :index))
      response(conn, 425)
    end

    test_with_mock(
      "returns 400 if there is an error getting the report",
      %{conn: conn},
      ProductsReportsService,
      [],
      request_report: fn -> {:error, ""} end
    ) do
      conn = get(conn, Routes.report_path(conn, :index))
      response(conn, 400)
    end
  end
end
