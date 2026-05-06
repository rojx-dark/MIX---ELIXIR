defmodule Biblioteca.GestionArchivos do
  @moduledoc "Lectura y escritura de datos de la biblioteca en CSV."

  alias Biblioteca.{Libro, Usuario, Prestamo}

  def ruta(nombre), do: Path.join(File.cwd!(), nombre)

  # === CARGAR ===

  def cargar_estado do
    try do
      libros = leer_libros(ruta("libros.csv"))
      usuarios = leer_usuarios(ruta("usuarios.csv"))
      prestamos = leer_prestamos(ruta("prestamos.csv"))

      prestamos_activos = prestamos |> Map.values() |> Enum.filter(&Prestamo.activo?/1)

      libros =
        Enum.reduce(prestamos_activos, libros, fn p, acc ->
          case Map.get(acc, p.libro_isbn) do
            nil -> acc
            libro -> Map.put(acc, p.libro_isbn, %{libro | disponible: false})
          end
        end)

      usuarios =
        Enum.reduce(prestamos_activos, usuarios, fn p, acc ->
          case Map.get(acc, p.usuario_id) do
            nil -> acc
            usuario ->
              if p.libro_isbn in usuario.libros_prestados do
                acc
              else
                Map.put(acc, p.usuario_id, %{usuario | libros_prestados: [p.libro_isbn | usuario.libros_prestados]})
              end
          end
        end)

      {:ok, %{libros: libros, usuarios: usuarios, prestamos: prestamos}}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  # === GUARDAR ===

  def guardar_estado(estado) do
    with :ok <- guardar_libros(estado.libros, ruta("libros.csv")),
         :ok <- guardar_usuarios(estado.usuarios, ruta("usuarios.csv")),
         :ok <- guardar_prestamos(estado.prestamos, ruta("prestamos.csv")) do
      :ok
    else
      {:error, razon} -> {:error, razon}
    end
  end

  # === LECTURA CSV ===

  defp leer_libros(archivo) do
    leer_csv(archivo, fn linea ->
      case String.split(linea, ",") do
        [isbn, titulo, autor, anio_str, genero, _disp] ->
          case Integer.parse(anio_str) do
            {anio, _} ->
              {isbn, %Libro{isbn: isbn, titulo: titulo, autor: autor, anio: anio, genero: genero, disponible: true}}
            :error -> nil
          end
        _ -> nil
      end
    end)
  end

  defp leer_usuarios(archivo) do
    leer_csv(archivo, fn linea ->
      case String.split(linea, ",") do
        [id, nombre, email] ->
          {id, %Usuario{id: id, nombre: nombre, email: email, libros_prestados: []}}
        _ -> nil
      end
    end)
  end

  defp leer_prestamos(archivo) do
    leer_csv(archivo, fn linea ->
      case String.split(linea, ",") do
        [id, isbn, uid, fecha_str, dev_str] ->
          fecha = Date.from_iso8601!(fecha_str)
          dev = case String.trim(dev_str) do
            "" -> nil
            f -> Date.from_iso8601!(f)
          end
          {id, %Prestamo{id: id, libro_isbn: isbn, usuario_id: uid, fecha_prestamo: fecha, fecha_devolucion: dev}}
        _ -> nil
      end
    end)
  end

  defp leer_csv(archivo, parser_fn) do
    if File.exists?(archivo) do
      case File.read(archivo) do
        {:ok, contenido} ->
          contenido
          |> String.trim()
          |> String.split("\n")
          |> Enum.drop(1)
          |> Enum.reduce(%{}, fn linea, acc ->
            linea = String.trim(linea)
            case parser_fn.(linea) do
              {key, value} -> Map.put(acc, key, value)
              nil -> acc
            end
          end)
        {:error, _} -> %{}
      end
    else
      File.write(archivo, "")
      %{}
    end
  end

  # === ESCRITURA CSV ===

  defp guardar_libros(libros, archivo) do
    enc = "isbn,titulo,autor,anio,genero,disponible"
    lineas = libros |> Map.values() |> Enum.map(fn l ->
      "#{l.isbn},#{l.titulo},#{l.autor},#{l.anio},#{l.genero},#{l.disponible}"
    end)
    File.write(archivo, Enum.join([enc | lineas], "\n") <> "\n")
  end

  defp guardar_usuarios(usuarios, archivo) do
    enc = "id,nombre,email"
    lineas = usuarios |> Map.values() |> Enum.map(fn u -> "#{u.id},#{u.nombre},#{u.email}" end)
    File.write(archivo, Enum.join([enc | lineas], "\n") <> "\n")
  end

  defp guardar_prestamos(prestamos, archivo) do
    enc = "id,libro_isbn,usuario_id,fecha_prestamo,fecha_devolucion"
    lineas = prestamos |> Map.values() |> Enum.map(fn p ->
      dev = if p.fecha_devolucion, do: Date.to_iso8601(p.fecha_devolucion), else: ""
      "#{p.id},#{p.libro_isbn},#{p.usuario_id},#{Date.to_iso8601(p.fecha_prestamo)},#{dev}"
    end)
    File.write(archivo, Enum.join([enc | lineas], "\n") <> "\n")
  end
end
