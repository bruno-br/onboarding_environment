defmodule Myapp.RedisApiTest do
  use Myapp.DataCase

  alias Myapp.RedisApi

  @valid_key "key"
  @valid_value "value"
  @client RedisApi.start()

  describe "set/1" do
    test "saves on cache if params are valid" do
      client = RedisApi.start()
      assert RedisApi.set(client, @valid_key, @valid_value) == :ok
    end
  end

  describe "get/1" do
    test "gets correct value when key is valid" do
      client = RedisApi.start()
      assert RedisApi.get(client, @valid_key) == {:ok, @valid_value}
    end
  end
end
