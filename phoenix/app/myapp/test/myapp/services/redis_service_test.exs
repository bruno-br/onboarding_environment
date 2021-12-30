defmodule Myapp.Services.RedisServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.RedisService

  import Exredis
  import Mock

  setup_all do
    %{
      client: "valid_client",
      key: "valid_key",
      value: "valid_value",
      invalid_key: "invalid_key"
    }
  end

  describe "set/1" do
    test "saves on cache if params are valid", %{client: client, key: key, value: value} do
      with_mock(Exredis,
        query: fn
          _client, ["SET", _key, _value] -> "OK"
          _client, ["EXPIRE", _key, _value] -> "1"
        end
      ) do
        assert RedisService.set(client, key, value) == :ok
      end
    end
  end

  describe "get/1" do
    test "gets correct value when key is valid", %{client: client, key: key, value: value} do
      encoded_value = Base.encode16(:erlang.term_to_binary(value))

      with_mock(Exredis,
        query: fn
          _client, ["GET", _key] -> encoded_value
        end
      ) do
        assert RedisService.get(client, key) == {:ok, value}
      end
    end

    test "returns error when key is not found", %{client: client, invalid_key: invalid_key} do
      with_mock(Exredis,
        query: fn
          _client, ["GET", _invalid_key] -> :undefined
        end
      ) do
        assert RedisService.get(client, invalid_key) == {:error, :not_found}
      end
    end
  end

  describe "del/1" do
    test "deletes key when params are valid", %{client: client, key: key} do
      with_mock(Exredis,
        query: fn
          _client, ["DEL", _key] -> "1"
        end
      ) do
        assert RedisService.del(client, key) == :ok
      end
    end

    test "returns error when key is not found", %{
      client: client,
      invalid_key: invalid_key
    } do
      with_mock(Exredis,
        query: fn
          _client, ["DEL", _key] -> "0"
        end
      ) do
        assert RedisService.del(client, invalid_key) == :error
      end
    end
  end
end
