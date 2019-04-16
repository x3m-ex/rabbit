defmodule X3m.RabbitTest do
  use ExUnit.Case
  doctest X3m.Rabbit

  test "greets the world" do
    assert X3m.Rabbit.hello() == :world
  end
end
