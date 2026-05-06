defmodule Inventario.Menu do
  @moduledoc """
  Módulo de menú interactivo por consola para el sistema de inventario.
  Todas las funcionalidades son accesibles desde consola.
  """

  alias Inventario.Inventario, as: Inv
  alias Inventario.GestionArchivos

  @doc """
  Inicia el menú interactivo.
  Carga datos al iniciar y guarda después de cada operación.
  """
  def iniciar do
    IO.puts("\n=====================================")
    IO.puts("   SISTEMA DE INVENTARIO DE PRODUCTOS")
    IO.puts("=====================================\n")

    case GestionArchivos.cargar_productos() do
      {:ok, inventario} ->
        IO.puts("Datos cargados exitosamente. #{map_size(inventario)} producto(s) encontrado(s).\n")
        loop(inventario)

      {:error, _razon} ->
        IO.puts("Error al cargar datos. Iniciando con datos vacíos.\n")
        loop(%{})
    end
  end

  defp loop(inventario) do
    mostrar_menu()
    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1"  -> inventario |> agregar_producto() |> loop()
      "2"  -> inventario |> actualizar_producto() |> loop()
      "3"  -> inventario |> eliminar_producto() |> loop()
      "4"  -> inventario |> listar_productos() |> loop()
      "5"  -> inventario |> consulta_dos_vocales() |> loop()
      "6"  -> inventario |> consulta_misma_letra() |> loop()
      "7"  -> inventario |> consulta_debajo_precio() |> loop()
      "8"  -> inventario |> consulta_tres_caros() |> loop()
      "9"  -> inventario |> consulta_entre_precios() |> loop()
      "10" -> inventario |> consulta_por_rango() |> loop()
      "0"  ->
        IO.puts("\n¡Hasta luego!")
        :ok

      _ ->
        IO.puts("\nOpción no válida. Intente de nuevo.\n")
        loop(inventario)
    end
  end

  defp mostrar_menu do
    IO.puts("--- MENÚ PRINCIPAL ---")
    IO.puts("1.  Agregar producto")
    IO.puts("2.  Actualizar producto")
    IO.puts("3.  Eliminar producto")
    IO.puts("4.  Listar productos")
    IO.puts("--- CONSULTAS ---")
    IO.puts("5.  Productos con al menos 2 vocales")
    IO.puts("6.  Nombre comienza y termina con misma letra")
    IO.puts("7.  Productos por debajo de un precio")
    IO.puts("8.  Los 3 productos más caros")
    IO.puts("9.  Productos entre dos precios")
    IO.puts("10. Agrupar por rango de precio")
    IO.puts("0.  Salir")
    IO.puts("----------------------")
  end

  # --- Operaciones CRUD ---

  defp agregar_producto(inventario) do
    codigo = IO.gets("Ingrese el código (máx 5 caracteres): ") |> String.trim()
    nombre = IO.gets("Ingrese el nombre (solo letras): ") |> String.trim()
    precio_str = IO.gets("Ingrese el precio: ") |> String.trim()
    cantidad_str = IO.gets("Ingrese la cantidad: ") |> String.trim()

    with {precio, _} <- Float.parse(precio_str),
         {cantidad, _} <- Integer.parse(cantidad_str) do
      precio = if precio == trunc(precio), do: trunc(precio), else: precio

      case Inv.agregar_producto(inventario, codigo, nombre, precio, cantidad) do
        {:ok, inventario_actualizado} ->
          guardar_y_confirmar(inventario_actualizado, "Producto agregado exitosamente.")

        {:error, :codigo_duplicado} ->
          IO.puts("\nError: Ya existe un producto con ese código.\n")
          inventario

        {:error, :codigo_muy_largo} ->
          IO.puts("\nError: El código no puede tener más de 5 caracteres.\n")
          inventario

        {:error, :nombre_invalido} ->
          IO.puts("\nError: El nombre solo puede contener letras.\n")
          inventario

        {:error, razon} ->
          IO.puts("\nError: #{inspect(razon)}\n")
          inventario
      end
    else
      :error ->
        IO.puts("\nError: Precio o cantidad no válidos.\n")
        inventario
    end
  end

  defp actualizar_producto(inventario) do
    codigo = IO.gets("Ingrese el código del producto a actualizar: ") |> String.trim()
    nombre = IO.gets("Ingrese el nuevo nombre: ") |> String.trim()
    precio_str = IO.gets("Ingrese el nuevo precio: ") |> String.trim()
    cantidad_str = IO.gets("Ingrese la nueva cantidad: ") |> String.trim()

    with {precio, _} <- Float.parse(precio_str),
         {cantidad, _} <- Integer.parse(cantidad_str) do
      precio = if precio == trunc(precio), do: trunc(precio), else: precio

      case Inv.actualizar_producto(inventario, codigo, nombre, precio, cantidad) do
        {:ok, inventario_actualizado} ->
          guardar_y_confirmar(inventario_actualizado, "Producto actualizado exitosamente.")

        {:error, :no_encontrado} ->
          IO.puts("\nError: No se encontró un producto con ese código.\n")
          inventario

        {:error, :nombre_invalido} ->
          IO.puts("\nError: El nombre solo puede contener letras.\n")
          inventario

        {:error, razon} ->
          IO.puts("\nError: #{inspect(razon)}\n")
          inventario
      end
    else
      :error ->
        IO.puts("\nError: Precio o cantidad no válidos.\n")
        inventario
    end
  end

  defp eliminar_producto(inventario) do
    codigo = IO.gets("Ingrese el código del producto a eliminar: ") |> String.trim()

    case Inv.eliminar_producto(inventario, codigo) do
      {:ok, inventario_actualizado} ->
        guardar_y_confirmar(inventario_actualizado, "Producto eliminado exitosamente.")

      {:error, :no_encontrado} ->
        IO.puts("\nError: No se encontró un producto con ese código.\n")
        inventario
    end
  end

  defp listar_productos(inventario) do
    lista = Inv.listar_productos(inventario)

    if Enum.empty?(lista) do
      IO.puts("\nNo hay productos en el inventario.\n")
    else
      IO.puts("\n=== Inventario de Productos (#{length(lista)}) ===")

      Enum.each(lista, fn p ->
        IO.puts("  [#{p.codigo}] #{p.nombre} - Precio: $#{p.precio} | Cantidad: #{p.cantidad}")
      end)

      IO.puts("")
    end

    inventario
  end

  # --- Consultas ---

  defp consulta_dos_vocales(inventario) do
    resultado = Inv.productos_con_dos_vocales(inventario)

    IO.puts("\n=== Productos con al menos 2 vocales ===")

    if Enum.empty?(resultado) do
      IO.puts("  No se encontraron productos.\n")
    else
      Enum.each(resultado, fn {codigo, nombre} ->
        IO.puts("  {#{codigo}, #{nombre}}")
      end)

      IO.puts("")
    end

    inventario
  end

  defp consulta_misma_letra(inventario) do
    resultado = Inv.productos_misma_letra_inicio_fin(inventario)

    IO.puts("\n=== Productos que comienzan y terminan con la misma letra ===")

    if Enum.empty?(resultado) do
      IO.puts("  No se encontraron productos.\n")
    else
      Enum.each(resultado, fn p ->
        IO.puts("  [#{p.codigo}] #{p.nombre}")
      end)

      IO.puts("")
    end

    inventario
  end

  defp consulta_debajo_precio(inventario) do
    precio_str = IO.gets("Ingrese el precio máximo: ") |> String.trim()

    case Float.parse(precio_str) do
      {precio, _} ->
        resultado = Inv.productos_por_debajo_de_precio(inventario, precio)

        IO.puts("\n=== Productos con precio menor a $#{precio} ===")

        if Enum.empty?(resultado) do
          IO.puts("  No se encontraron productos.\n")
        else
          Enum.each(resultado, fn p ->
            IO.puts("  [#{p.codigo}] #{p.nombre} - $#{p.precio}")
          end)

          IO.puts("")
        end

      :error ->
        IO.puts("\nError: Precio no válido.\n")
    end

    inventario
  end

  defp consulta_tres_caros(inventario) do
    resultado = Inv.tres_productos_mas_caros(inventario)

    IO.puts("\n=== Los 3 productos más caros ===")

    if Enum.empty?(resultado) do
      IO.puts("  No hay productos.\n")
    else
      Enum.with_index(resultado, 1)
      |> Enum.each(fn {p, idx} ->
        IO.puts("  #{idx}. [#{p.codigo}] #{p.nombre} - $#{p.precio}")
      end)

      IO.puts("")
    end

    inventario
  end

  defp consulta_entre_precios(inventario) do
    min_str = IO.gets("Ingrese el precio mínimo: ") |> String.trim()
    max_str = IO.gets("Ingrese el precio máximo: ") |> String.trim()

    with {precio_min, _} <- Float.parse(min_str),
         {precio_max, _} <- Float.parse(max_str) do
      resultado = Inv.productos_entre_precios(inventario, precio_min, precio_max)

      IO.puts("\n=== Productos entre $#{precio_min} y $#{precio_max} ===")

      if resultado == "" do
        IO.puts("  No se encontraron productos.\n")
      else
        IO.puts("  #{resultado}\n")
      end
    else
      :error ->
        IO.puts("\nError: Valores no válidos.\n")
    end

    inventario
  end

  defp consulta_por_rango(inventario) do
    reporte = Inv.agrupar_por_rango_precio(inventario)

    IO.puts("\n=== Productos agrupados por rango de precio ===")

    Enum.each(reporte, fn {rango, productos} ->
      IO.puts("  #{rango}:")

      if Enum.empty?(productos) do
        IO.puts("    (vacío)")
      else
        Enum.each(productos, fn p ->
          IO.puts("    - #{p.nombre} ($#{p.precio})")
        end)
      end
    end)

    IO.puts("")
    inventario
  end

  # --- Utilidades ---

  defp guardar_y_confirmar(inventario, mensaje) do
    case GestionArchivos.guardar_productos(inventario) do
      :ok ->
        IO.puts("\n#{mensaje}")
        IO.puts("Datos guardados en productos.csv.\n")

      {:error, _} ->
        IO.puts("\n#{mensaje}")
        IO.puts("Advertencia: No se pudieron guardar los datos.\n")
    end

    inventario
  end
end
