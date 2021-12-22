defmodule Myapp.RedisApiTest do
  use Myapp.DataCase

  alias Myapp.RedisApi

  @set_params %{
    key: "key1",
    value: "value1"
  }
  @get_params %{
    key: "key2",
    value: "value2"
  }

  describe "set/1" do
    test "saves on cache if params are valid" do
      client = RedisApi.start()
      assert RedisApi.set(client, @set_params.key, @set_params.value, 1) == :ok
    end
  end

  describe "get/1" do
    test "gets correct value when key is valid" do
      client = RedisApi.start()
      assert RedisApi.set(client, @get_params.key, @get_params.value, 1) == :ok
      assert RedisApi.get(client, @get_params.key) == {:ok, @get_params.value}
    end
  end
end
