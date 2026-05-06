# Inventario - Sistema de Gestión de Productos

## Descripción

Sistema de inventario de productos implementado en Elixir usando Mix con Application.
Permite gestionar productos con persistencia en JSON usando la librería Jason,
e incluye consultas avanzadas usando el módulo Enum.

### Funcionalidades
- CRUD de productos con validaciones (código máx 5 chars, nombre solo letras, precio ≥ 0, cantidad entero ≥ 0)
- Consultas: productos con 2+ vocales, misma letra inicio/fin, por precio, top 3 caros, entre precios, agrupados por rango
- Persistencia automática en `productos.json` con Jason
- Pruebas unitarias con ExUnit

### Estructura de módulos
- `Inventario.Producto` - Struct y validaciones
- `Inventario.Inventario` - Lógica de negocio y consultas Enum
- `Inventario.ArchivoJSON` - Persistencia JSON con Jason
- `Inventario.Menu` - Menú interactivo por consola

## Ejecución

```bash
cd inventario
mix deps.get
mix run --no-halt
```

## Pruebas

```bash
mix test
```

## Aprendizajes

- Uso de la librería Jason para serialización/deserialización JSON
- Consultas funcionales con Enum (filter, map, sort_by, group_by)
- Validaciones con expresiones regulares (`~r/regex/`)
- Pruebas unitarias con ExUnit incluyendo setup de datos
- Derive de protocolos para encoding JSON de structs

## Uso de IA

Se utilizó inteligencia artificial como apoyo para:
- Diseño de la arquitectura modular del proyecto Mix
- Implementación de persistencia JSON con Jason
- Consultas avanzadas con Enum y procesamiento funcional
- Escritura de pruebas unitarias con ExUnit
