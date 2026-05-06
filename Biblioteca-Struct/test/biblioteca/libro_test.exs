defmodule Biblioteca.LibroTest do
  use ExUnit.Case

  alias Biblioteca.Libro

  describe "Libro.nuevo/5" do
    test "crea un libro válido" do
      assert {:ok, %Libro{isbn: "978-01", titulo: "Test", disponible: true}} =
               Libro.nuevo("978-01", "Test", "Autor", 2020, "Novela")
    end

    test "rechaza ISBN vacío" do
      assert {:error, :isbn_vacio} = Libro.nuevo("", "Test", "Autor", 2020, "Novela")
    end
  end

  describe "Libro.prestar/1 y devolver/1" do
    test "presta y devuelve un libro" do
      {:ok, libro} = Libro.nuevo("978-01", "Test", "Autor", 2020, "Novela")
      {:ok, prestado} = Libro.prestar(libro)
      assert prestado.disponible == false
      {:ok, devuelto} = Libro.devolver(prestado)
      assert devuelto.disponible == true
    end

    test "no permite prestar un libro ya prestado" do
      {:ok, libro} = Libro.nuevo("978-01", "Test", "Autor", 2020, "Novela")
      {:ok, prestado} = Libro.prestar(libro)
      assert {:error, :libro_no_disponible} = Libro.prestar(prestado)
    end
  end
end
