defmodule Biblioteca.Biblioteca do
  @moduledoc "Lógica de negocio para la gestión de la biblioteca."

  alias Biblioteca.{Libro, Usuario, Prestamo}

  def nuevo, do: %{libros: %{}, usuarios: %{}, prestamos: %{}}

  # === LIBROS ===

  def agregar_libro(estado, isbn, titulo, autor, anio, genero) do
    case Libro.nuevo(isbn, titulo, autor, anio, genero) do
      {:ok, libro} ->
        if Map.has_key?(estado.libros, isbn) do
          {:error, :isbn_duplicado}
        else
          {:ok, %{estado | libros: Map.put(estado.libros, isbn, libro)}}
        end
      {:error, razon} -> {:error, razon}
    end
  end

  def eliminar_libro(estado, isbn) do
    if Map.has_key?(estado.libros, isbn) do
      {:ok, %{estado | libros: Map.delete(estado.libros, isbn)}}
    else
      {:error, :libro_no_encontrado}
    end
  end

  def listar_libros(estado), do: Map.values(estado.libros)

  def obtener_libro(estado, isbn) do
    case Map.get(estado.libros, isbn) do
      nil -> {:error, :libro_no_encontrado}
      libro -> {:ok, libro}
    end
  end

  # === USUARIOS ===

  def agregar_usuario(estado, id, nombre, email) do
    case Usuario.nuevo(id, nombre, email) do
      {:ok, usuario} ->
        if Map.has_key?(estado.usuarios, id) do
          {:error, :id_duplicado}
        else
          {:ok, %{estado | usuarios: Map.put(estado.usuarios, id, usuario)}}
        end
      {:error, razon} -> {:error, razon}
    end
  end

  def eliminar_usuario(estado, id) do
    if Map.has_key?(estado.usuarios, id) do
      {:ok, %{estado | usuarios: Map.delete(estado.usuarios, id)}}
    else
      {:error, :usuario_no_encontrado}
    end
  end

  def listar_usuarios(estado), do: Map.values(estado.usuarios)

  def obtener_usuario(estado, id) do
    case Map.get(estado.usuarios, id) do
      nil -> {:error, :usuario_no_encontrado}
      usuario -> {:ok, usuario}
    end
  end

  # === PRÉSTAMOS ===

  def registrar_prestamo(estado, prestamo_id, isbn, usuario_id) do
    with {:ok, libro} <- obtener_libro(estado, isbn),
         {:ok, usuario} <- obtener_usuario(estado, usuario_id),
         true <- libro.disponible || {:error, :libro_no_disponible},
         true <- Usuario.puede_prestar?(usuario) || {:error, :limite_prestamos_alcanzado},
         {:ok, libro_prestado} <- Libro.prestar(libro),
         {:ok, usuario_act} <- Usuario.agregar_prestamo(usuario, isbn),
         {:ok, prestamo} <- Prestamo.nuevo(prestamo_id, isbn, usuario_id) do
      estado_nuevo =
        estado
        |> Map.update!(:libros, &Map.put(&1, isbn, libro_prestado))
        |> Map.update!(:usuarios, &Map.put(&1, usuario_id, usuario_act))
        |> Map.update!(:prestamos, &Map.put(&1, prestamo_id, prestamo))
      {:ok, estado_nuevo}
    end
  end

  def registrar_devolucion(estado, prestamo_id) do
    case Map.get(estado.prestamos, prestamo_id) do
      nil -> {:error, :prestamo_no_encontrado}
      prestamo ->
        case Prestamo.registrar_devolucion(prestamo) do
          {:ok, prestamo_dev} ->
            isbn = prestamo.libro_isbn
            uid = prestamo.usuario_id
            libro = Map.get(estado.libros, isbn)
            usuario = Map.get(estado.usuarios, uid)
            {:ok, libro_dev} = Libro.devolver(libro)
            {:ok, usuario_act} = Usuario.quitar_prestamo(usuario, isbn)

            estado_nuevo =
              estado
              |> Map.update!(:libros, &Map.put(&1, isbn, libro_dev))
              |> Map.update!(:usuarios, &Map.put(&1, uid, usuario_act))
              |> Map.update!(:prestamos, &Map.put(&1, prestamo_id, prestamo_dev))
            {:ok, estado_nuevo}
          {:error, razon} -> {:error, razon}
        end
    end
  end

  def listar_prestamos(estado), do: Map.values(estado.prestamos)

  # === REPORTES ===

  def libros_mas_prestados(estado) do
    estado.prestamos
    |> Map.values()
    |> Enum.group_by(& &1.libro_isbn)
    |> Enum.map(fn {isbn, ps} ->
      libro = Map.get(estado.libros, isbn)
      titulo = if libro, do: libro.titulo, else: "Desconocido"
      {isbn, titulo, length(ps)}
    end)
    |> Enum.sort_by(fn {_, _, c} -> c end, :desc)
  end

  def usuarios_con_prestamos_vencidos(estado) do
    estado.prestamos
    |> Map.values()
    |> Enum.filter(&Prestamo.vencido?/1)
    |> Enum.map(fn p ->
      usuario = Map.get(estado.usuarios, p.usuario_id)
      libro = Map.get(estado.libros, p.libro_isbn)
      %{
        usuario: if(usuario, do: usuario.nombre, else: "Desconocido"),
        usuario_id: p.usuario_id,
        libro: if(libro, do: libro.titulo, else: "Desconocido"),
        dias_retraso: Prestamo.dias_de_retraso(p)
      }
    end)
    |> Enum.sort_by(& &1.dias_retraso, :desc)
  end

  def libros_por_genero(estado) do
    estado.libros |> Map.values() |> Enum.group_by(& &1.genero)
  end

  def disponibilidad_libros(estado) do
    estado.libros
    |> Map.values()
    |> Enum.map(fn l -> {l.isbn, l.titulo, if(l.disponible, do: "Disponible", else: "Prestado")} end)
    |> Enum.sort_by(fn {isbn, _, _} -> isbn end)
  end

  def libros_clasicos(estado) do
    estado.libros |> Map.values() |> Enum.filter(&Libro.es_clasico?/1)
  end
end
