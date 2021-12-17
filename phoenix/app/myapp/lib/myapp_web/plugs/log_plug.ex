defmodule MyappWeb.Plugs.LogPlug do
  import Plug.Conn

  import Tirexs.HTTP

  def init(props) do
    props
  end

  def call(conn, _opts) do
    Task.async(fn -> post_log(conn) end)
    conn
  end

  defp post_log(conn), do: post("/my_index/logs", generate_log(conn))

  defp generate_log(conn) do
    date = DateTime.to_iso8601(DateTime.utc_now())

    [
      date: date,
      method: conn.method,
      request_path: conn.request_path,
      req_headers: conn.req_headers,
      body_params: conn.body_params
    ]
  end
end
