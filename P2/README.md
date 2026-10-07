# Práctica 2: Modelo E/R - Viveros (Tajinaste S.A.)

**Asignatura:** Administración y Diseño de Bases de Datos (ADBD)  
**Grado:** Grado en Ingeniería Informática  
**Universidad:** Universidad de La Laguna  

---

## 1. Descripción de las Entidades

En el modelo conceptual para la empresa Tajinaste S.A., se han identificado y definido las siguientes entidades principales:

* **`VIVERO`**: Representa cada uno de los centros o establecimientos de venta de plantas, productos de jardinería y decoración pertenecientes a Tajinaste S.A.
  * **Atributos**: `id_vivero` (PK), `nombre`, `latitud`, `longitud`.
* **`ZONA`**: Representa las distintas áreas o divisiones internas que componen cada vivero (por ejemplo: almacén, zona exterior, sección de decoración, etc.). Es una **entidad débil** con respecto a `VIVERO`, ya que la existencia e identificación de una zona dependen intrínsecamente del vivero al que pertenece.
  * **Atributos**: `id_zona` (PK parcial), `nombre`, `latitud`, `longitud`.
* **`PRODUCTO`**: Artículos comercializados por Tajinaste S.A. (plantas, herramientas, decoración).
  * **Atributos**: `id_producto` (PK), `nombre`, `tipo`, `precio`.
* **`EMPLEADO`**: Trabajadores pertenecientes a la plantilla de la empresa.
  * **Atributos**: `id_empleado` (PK), `dni`, `nombre`, `apellidos`, `telefono`.
* **`CLIENTE_PLUS`**: Clientes adheridos formalmente al programa de fidelización *Tajinaste Plus*.
  * **Atributos**: `id_cliente` (PK), `dni`, `nombre`, `email`, `fecha_ingreso`, `volumen_compras_mensual`, `bonificaciones`.
* **`PEDIDO`**: Compras o encargos realizados por los clientes Tajinaste Plus y que son gestionados individualmente por un empleado.
  * **Atributos**: `id_pedido` (PK), `fecha`, `monto_total`.

---

## 2. Descripción y Ejemplos de Dominio de los Atributos

### Atributos de Entidades

| Entidad | Atributo | Tipo de Datos / Dominio | Ejemplo |
| :--- | :--- | :--- | :--- |
| **`VIVERO`** | `id_vivero` | Cadena alfanumérica (Código único) | `"VIV-001"`, `"VIV-002"` |
| | `nombre` | Cadena de texto | `"Vivero Anaga"`, `"Vivero Central"` |
| | `latitud` | Decimal (`FLOAT` / `DOUBLE`, Coordenada WGS84) | `28.481234` |
| | `longitud` | Decimal (`FLOAT` / `DOUBLE`, Coordenada WGS84) | `-16.321456` |
| **`ZONA`** | `id_zona` | Alfanumérico o secuencial entero | `"Z1"`, `"Z2"` |
| | `nombre` | Cadena de texto | `"Zona Exterior"`, `"Almacén A"` |
| | `latitud` | Decimal (`FLOAT` / `DOUBLE`, Coordenada WGS84) | `28.481300` |
| | `longitud` | Decimal (`FLOAT` / `DOUBLE`, Coordenada WGS84) | `-16.321500` |
| **`PRODUCTO`** | `id_producto` | Cadena alfanumérica | `"PROD-0045"` |
| | `nombre` | Cadena de texto | `"Palmera Canaria"`, `"Maceta Cerámica"` |
| | `tipo` | Cadena de texto (`ENUM`: Planta, Jardinería, Decoración) | `"Planta"` |
| | `precio` | Decimal mayor que 0 (€) | `19.99` |
| **`EMPLEADO`** | `id_empleado` | Cadena alfanumérica o Entero | `"EMP-102"` |
| | `dni` | Cadena de texto (8 dígitos + letra) | `"12345678X"` |
| | `nombre` | Cadena de texto | `"Laura"` |
| | `apellidos` | Cadena de texto | `"Gómez Pérez"` |
| | `telefono` | Cadena de texto (9 dígitos) | `"612345678"` |
| **`CLIENTE_PLUS`** | `id_cliente` | Cadena alfanumérica o Entero | `"CLI-0089"` |
| | `dni` | Cadena de texto (8 dígitos + letra) | `"87654321Y"` |
| | `nombre` | Cadena de texto | `"Carlos"` |
| | `email` | Cadena de texto con formato email | `"carlos@example.com"` |
| | `fecha_ingreso` | Fecha (`DATE`) | `"2025-03-15"` |
| | `volumen_compras_mensual` | Decimal no negativo (€) | `250.75` |
| | `bonificaciones` | Decimal no negativo (€ o Puntos acumulados) | `12.50` |
| **`PEDIDO`** | `id_pedido` | Cadena alfanumérica o Entero | `"PED-2026-001"` |
| | `fecha` | Fecha y hora (`DATETIME`) | `"2026-05-10 11:30:00"` |
| | `monto_total` | Decimal mayor que 0 (€) | `89.50` |

### Atributos de Relaciones (Pertenecientes a enlaces N:M)

| Relación | Atributo | Tipo de Datos / Dominio | Ejemplo Ilustrativo |
| :--- | :--- | :--- | :--- |
| **`Tener_Stock`** | `stock` | Entero mayor o igual que 0 | `45` (unidades disponibles en esa zona) |
| **`Asignacion_Historico`** | `fecha_inicio` | Fecha (`DATE`) | `"2026-01-01"` |
| | `fecha_fin` | Fecha (`DATE`, puede ser nulo si está activo) | `"2026-06-30"` |
| | `productividad` | Decimal o porcentaje ($0.0 - 100.0$) | `92.5` |

---

## 3. Descripción de las Relaciones y Cardinalidades

1. **`VIVERO` — `Pertenece` — `ZONA`**
   * **Descripción**: Asocia un vivero con sus correspondientes subdivisiones o zonas físicas. Es una relación de identificación para la entidad débil `ZONA`.
   * **Tipo**: $1:N$
   * **Cardinalidades**:
     * `VIVERO` $\rightarrow$ `ZONA`: $(1, N)$ — Un vivero contiene al menos $1$ zona y puede subdividirse en $N$ zonas.
     * `ZONA` $\rightarrow$ `VIVERO`: $(1, 1)$ — Cada zona pertenece de forma única y obligatoria a $1$ único vivero.

2. **`ZONA` — `Tener_Stock` — `PRODUCTO`**
   * **Descripción**: Registra la cantidad en stock disponible de cada producto en una zona específica de un vivero.
   * **Tipo**: $N:M$
   * **Atributo de relación**: `stock`
   * **Cardinalidades**:
     * `ZONA` $\rightarrow$ `PRODUCTO`: $(0, N)$ — En una zona puede haber almacenados $0$ o $N$ productos diferentes.
     * `PRODUCTO` $\rightarrow$ `ZONA`: $(0, N)$ — Un producto puede estar disponible/asignado a $0$ o $N$ zonas distintas.

3. **`EMPLEADO` — `Asignacion_Historico` — `ZONA`**
   * **Descripción**: Registra el historial de puestos y destinos desempeñados por los empleados en las distintas zonas de los viveros según la época del año, así como el seguimiento de la productividad en dicho período.
   * **Tipo**: $N:M$
   * **Atributos de relación**: `fecha_inicio`, `fecha_fin`, `productividad`
   * **Cardinalidades**:
     * `EMPLEADO` $\rightarrow$ `ZONA`: $(1, N)$ — Un empleado ha sido destinado históricamente a $1$ o $N$ zonas.
     * `ZONA` $\rightarrow$ `EMPLEADO`: $(0, N)$ — Una zona ha tenido destinados a $0$ o $N$ empleados a lo largo del tiempo.

4. **`CLIENTE_PLUS` — `Realiza` — `PEDIDO`**
   * **Descripción**: Controla las compras o pedidos efectuados por los clientes miembros del programa de fidelización desde su ingreso.
   * **Tipo**: $1:N$
   * **Cardinalidades**:
     * `CLIENTE_PLUS` $\rightarrow$ `PEDIDO`: $(0, N)$ — Un cliente Tajinaste Plus puede realizar $0$ o $N$ pedidos.
     * `PEDIDO` $\rightarrow$ `CLIENTE_PLUS`: $(1, 1)$ — Cada pedido está asociado exactamente a $1$ cliente Tajinaste Plus.

5. **`EMPLEADO` — `Gestiona` — `PEDIDO`**
   * **Descripción**: Asocia el pedido realizado con el empleado que actuó como responsable directo de su gestión, utilizado para evaluar el cumplimiento de objetivos de venta.
   * **Tipo**: $1:N$
   * **Cardinalidades**:
     * `EMPLEADO` $\rightarrow$ `PEDIDO`: $(0, N)$ — Un empleado puede gestionar de $0$ a $N$ pedidos.
     * `PEDIDO` $\rightarrow$ `EMPLEADO`: $(1, 1)$ — Cada pedido es gestionado por exactamente $1$ único empleado responsable.

---

## 4. Restricciones Semánticas

1. **Destino Único Simultáneo**: Un empleado nunca puede tener dos destinos asignados simultáneamente. En la relación `Asignacion_Historico`, para un mismo empleado no pueden existir dos registros cuyos intervalos de fechas $[fecha\_inicio, fecha\_fin]$ se solapen temporalmente.
2. **Dependencia de Existencia e Identificación**: La entidad `ZONA` no posee clave primaria propia por sí sola; depende de la existencia y la clave primaria (`id_vivero`) del `VIVERO` al que pertenece.
3. **No Negatividad de Stock**: El atributo `stock` en la relación `Tener_Stock` debe ser siempre mayor o igual a cero ($\ge 0$).
4. **Responsabilidad Unívoca del Pedido**: Todo pedido tramitado por un cliente Tajinaste Plus debe tener asignado obligatoriamente a un único empleado responsable de su gestión.
