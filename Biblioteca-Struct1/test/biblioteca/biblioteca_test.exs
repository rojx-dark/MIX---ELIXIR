defmodule Biblioteca.BibliotecaTest do
  use ExUnit.Case

  alias Biblioteca.Biblioteca, as: Bib

  describe "agregar_libro/6" do
    test "agrega un libro al estado" do
      estado = Bib.nuevo()
      {:ok, estado} = Bib.agregar_libro(estado, "978-01", "Test", "Autor", 2020, "Novela")
      assert map_size(estado.libros) == 1
    end

    test "no permite ISBN duplicado" do
      estado = Bib.nuevo()
      {:ok, estado} = Bib.agregar_libro(estado, "978-01", "Test", "Autor", 2020, "Novela")
      assert {:error, :isbn_duplicado} = Bib.agregar_libro(estado, "978-01", "Otro", "Autor", 2021, "Novela")
    end
  end

  describe "agregar_usuario/4" do
    test "agrega un usuario al estado" do
      estado = Bib.nuevo()
      {:ok, estado} = Bib.agregar_usuario(estado, "U001", "Juan", "juan@mail.com")
      assert map_size(estado.usuarios) == 1
    end

    test "rechaza email sin arroba" do
      estado = Bib.nuevo()
      assert {:error, :email_invalido} = Bib.agregar_usuario(estado, "U001", "Juan", "sin-arroba")
    end
  end

  describe "registrar_prestamo/4" do
    test "registra un préstamo correctamente" do
      estado = Bib.nuevo()
      {:ok, estado} = Bib.agregar_libro(estado, "978-01", "Test", "Autor", 2020, "Novela")
      {:ok, estado} = Bib.agregar_usuario(estado, "U001", "Juan", "juan@mail.com")
      {:ok, estado} = Bib.registrar_prestamo(estado, "PR01", "978-01", "U001")
      assert map_size(estado.prestamos) == 1
      libro = Map.get(estado.libros, "978-01")
      assert libro.disponible == false
    end
  end
end
