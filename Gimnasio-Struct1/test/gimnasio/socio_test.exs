defmodule Gimnasio.SocioTest do
  use ExUnit.Case

  alias Gimnasio.Socio

  describe "Socio.nuevo/3" do
    test "crea un socio válido con cédula, nombre y edad" do
      assert {:ok, %Socio{cedula: "123", nombre: "Juan", edad: 30, clases: []}} =
               Socio.nuevo("123", "Juan", 30)
    end

    test "rechaza edad negativa o cero" do
      assert {:error, :edad_invalida} = Socio.nuevo("123", "Juan", 0)
      assert {:error, :edad_invalida} = Socio.nuevo("123", "Juan", -5)
    end

    test "rechaza cédula vacía" do
      assert {:error, :cedula_vacia} = Socio.nuevo("", "Juan", 25)
    end

    test "rechaza nombre vacío" do
      assert {:error, :nombre_vacio} = Socio.nuevo("123", "", 25)
    end
  end

  describe "Socio.inscribir_clase/2" do
    test "inscribe al socio en una clase nueva" do
      {:ok, socio} = Socio.nuevo("123", "Juan", 30)
      assert {:ok, %Socio{clases: ["Yoga"]}} = Socio.inscribir_clase(socio, "Yoga")
    end

    test "no permite inscribir en una clase duplicada" do
      {:ok, socio} = Socio.nuevo("123", "Juan", 30)
      {:ok, socio} = Socio.inscribir_clase(socio, "Yoga")
      assert {:error, :ya_inscrito} = Socio.inscribir_clase(socio, "Yoga")
    end
  end

  describe "Socio.desinscribir_clase/2" do
    test "desinscribe al socio de una clase existente" do
      {:ok, socio} = Socio.nuevo("123", "Juan", 30)
      {:ok, socio} = Socio.inscribir_clase(socio, "Yoga")
      assert {:ok, %Socio{clases: []}} = Socio.desinscribir_clase(socio, "Yoga")
    end

    test "retorna error si no está inscrito en la clase" do
      {:ok, socio} = Socio.nuevo("123", "Juan", 30)
      assert {:error, :no_inscrito} = Socio.desinscribir_clase(socio, "Yoga")
    end
  end
end
