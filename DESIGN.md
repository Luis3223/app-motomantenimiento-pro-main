---
name: Moto Mantenimiento Pro
description: App Android de mantenimiento de motos ligada a Casa Racing — taller premium en el bolsillo.
colors:
  casa-racing-red: "#E50914"
  pit-shadow-red: "#9B000E"
  night-garage: "#121212"
  bay-surface: "#1E1E1E"
  matte-panel: "#252525"
  signal-white: "#FFFFFF"
  exhaust-grey: "#B3B3B3"
  chassis-line: "#2D2D2D"
  contact-green: "#25D366"
typography:
  display:
    fontFamily: "Roboto, sans-serif"
    fontSize: "28sp"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Roboto, sans-serif"
    fontSize: "24sp"
    fontWeight: 700
    lineHeight: 1.25
  title:
    fontFamily: "Roboto, sans-serif"
    fontSize: "16sp"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "Roboto, sans-serif"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Roboto, sans-serif"
    fontSize: "12sp"
    fontWeight: 400
    lineHeight: 1.3
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
components:
  button-primary:
    backgroundColor: "{colors.casa-racing-red}"
    textColor: "{colors.signal-white}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "12px 16px"
  button-outlined:
    backgroundColor: "transparent"
    textColor: "{colors.signal-white}"
    rounded: "{rounded.md}"
    height: "48px"
    padding: "12px 16px"
  button-whatsapp-fab:
    backgroundColor: "{colors.contact-green}"
    textColor: "{colors.signal-white}"
    rounded: "28px"
    size: "56px"
  input-field:
    backgroundColor: "{colors.matte-panel}"
    textColor: "{colors.signal-white}"
    rounded: "{rounded.md}"
    padding: "16px"
  card-panel:
    backgroundColor: "{colors.matte-panel}"
    textColor: "{colors.signal-white}"
    rounded: "{rounded.lg}"
    padding: "16px"
  nav-bar:
    backgroundColor: "{colors.bay-surface}"
    textColor: "{colors.exhaust-grey}"
    height: "80px"
  alert-banner:
    backgroundColor: "{colors.bay-surface}"
    textColor: "{colors.signal-white}"
    rounded: "{rounded.lg}"
    padding: "14px"
---

# Design System: Moto Mantenimiento Pro

## Overview

**Creative North Star: "Casa Racing en el bolsillo"**

La interfaz es la extensión digital del mostrador de Casa Racing: oscura, mate, legible a la luz del día y de noche, con el rojo de marca como señal de acción — no como decoración. La atmósfera es **Taller Premium**: confiable, densa, sin teatro visual. Material 3 estructura navegación e interacción; la marca vive en la paleta, los headers en degradado y el ritmo compacto de cards.

Profundidad: capas tonales (Night Garage → Bay Surface → Matte Panel). Sin lift por sombra en reposo. El rojo aparece en AppBar, CTA filled, indicadores activos y estados vencidos; el verde de WhatsApp solo en el canal de contacto.

**Key Characteristics:**
- Dark-only Material 3, tipografía Roboto del sistema
- Rojo de marca escaso y decisivo
- Densidad de taller: padding 16/24, targets ≥48dp
- Navigation bar inferior de 3 destinos + FAB de contacto
- Anti-ruido: sin look genérico, sin muro de texto, sin bosque de botones

## Colors

Paleta nocturna mate con un solo acento de marca y un canal de contacto externo.

### Primary
- **Casa Racing Red** (`#E50914`): acción primaria, AppBar, indicadores seleccionados, acento de iconos de marca, borde de focus en inputs, estados de aceite vencido.
- **Pit Shadow Red** (`#9B000E`): extremo oscuro del degradado de headers (login, perfil). No usar solo como fill de pantalla.

### Secondary
- **Contact Green** (`#25D366`): exclusivo del FAB / canal WhatsApp. Nunca como color de marca del producto.

### Neutral
- **Night Garage** (`#121212`): scaffold / fondo de app.
- **Bay Surface** (`#1E1E1E`): NavigationBar, bandejas y alertas flotantes.
- **Matte Panel** (`#252525`): cards, campos filled, paneles de contenido.
- **Signal White** (`#FFFFFF`): texto primario y foreground sobre rojo.
- **Exhaust Grey** (`#B3B3B3`): texto secundario, labels en reposo, subtítulos.
- **Chassis Line** (`#2D2D2D`): bordes de input y track de progreso.

### Named Rules
**The One Red Rule.** Casa Racing Red ocupa ≤ ~10% de cualquier pantalla; su rareza marca la acción.

**The Channel Green Rule.** Contact Green no sustituye al rojo de marca ni aparece en tipografía, AppBar o cards de producto.

## Typography

**Display Font:** Roboto (sistema Android / Material)
**Body Font:** Roboto
**Label/Mono Font:** Roboto (sin mono dedicado)

**Character:** Tipografía de sistema clara y densa. La jerarquía se logra con peso y tamaño Material, no con display ornamentales. Sin fuentes custom en el repo.

### Hierarchy
- **Display** (700, 28sp): título de producto en login.
- **Headline** (700, 24sp): cabeceras de garage / marca en AppBar custom.
- **Title** (700, 16–20sp): títulos de card, secciones, nombre en perfil.
- **Body** (400, 13–14sp): mensajes, subtítulos, tip Casa Racing.
- **Label** (400–600, 11–12sp): labels de NavigationBar, metadatos, hints demo.

### Named Rules
**The System Face Rule.** No introducir tipografías display ni stacks web; mapear a roles Material (display / headline / title / body / label) en sp.

## Layout

Modelo de pantalla móvil compacta, una columna, listados verticales.

- Padding de pantalla habitual: 16dp; formularios de auth: 24dp.
- Ritmo vertical: 8 / 12 / 16 / 24dp entre bloques.
- Shell: NavigationBar inferior con 3 destinos (Mi Garage, Historial, Mi Perfil).
- Headers de marca: bloque full-bleed rojo o degradado rojo → Pit Shadow, con SafeArea / inset superior generoso (~48–72dp).
- Un FAB por pantalla cuando hay acción de contacto (WhatsApp en Garage).
- Targets táctiles mínimos 48×48dp (botones filled a altura 48).

### Named Rules
**The Three-Door Rule.** La shell fija tres destinos; no añadir pestañas de navegación primaria sin decisión de producto.

## Elevation & Depth

Sistema **plano por defecto**: la profundidad es tonal (Night Garage / Bay Surface / Matte Panel), no sombra estructural. AppBar elevation 0. La única elevación observada es el banner de alerta (Material elevation 8) como overlay temporal.

### Named Rules
**The Flat Bay Rule.** En reposo, sin drop shadows en cards ni botones. Sombra solo en overlays/alertas que deben flotar sobre el contenido.

## Shapes

Esquinas suaves de taller, no cápsulas ni sharp industrial extremo.

- **sm (8px):** tracks de progreso / ClipRRect internos.
- **md (12px):** botones filled, inputs, banners de aviso inline.
- **lg (16px):** cards, banner de notificación, header de perfil.

Bordes: Chassis Line 1dp en inputs; borde de color (rojo/naranja) en avisos de aceite. Focus de input: Casa Racing Red 2dp.

### Named Rules
**The Soft Chassis Rule.** Preferir 12–16px en controles interactivos; no pills full-round salvo el FAB circular Material.

## Components

Filosofía: **Premium contenido — redondeados, densos, el rojo solo en la acción.**

### Buttons
- **Shape:** 12px (`rounded.md`), altura mínima 48dp.
- **Primary (Elevated):** Casa Racing Red fill, texto Signal White. Una CTA filled dominante por bloque.
- **Outlined:** borde sobre fondo oscuro para acciones secundarias (Tienda, WhatsApp en fila).
- **Text:** acciones terciarias (Crear cuenta).
- **FAB WhatsApp:** Contact Green, icono chat, una sola instancia por pantalla de garage.

### Cards / Containers
- **Corner Style:** 16px
- **Background:** Matte Panel
- **Shadow Strategy:** ninguna en reposo (ver Elevation)
- **Border:** opcional; avisos de aceite usan borde semántico
- **Internal Padding:** 16dp (stat cards y ciclo de aceite)

### Inputs / Fields
- **Style:** filled Matte Panel, borde Chassis Line, radio 12px, iconos prefix
- **Focus:** borde Casa Racing Red 2dp
- **Label:** Exhaust Grey

### Navigation
- **NavigationBar** sobre Bay Surface; indicador rojo al 25% de opacidad; label seleccionada Casa Racing Red w600 12sp; no seleccionada Exhaust Grey.
- Destinos: Mi Garage (two_wheeler), Historial (history), Mi Perfil (person).

### Alert Banner (signature)
- Overlay superior animado (slide 280ms easeOutCubic), Bay Surface, radio 16, elevation 8.
- Icono en contenedor rojo al 20% de opacidad; título bold; cuerpo Exhaust Grey 13sp.

### Oil Status Card (signature)
- Card Matte Panel con título “Ciclo de aceite (30 días)”, LinearProgress 10dp alto, radio 8 en el track.
- Colores de progreso: verde (al día) / naranja (aviso) / Casa Racing Red (vencido).

## Do's and Don'ts

### Do:
- **Do** tratar la UI como extensión de Casa Racing: headers de marca, tip de servicio, CTAs hacia taller/tienda/WhatsApp.
- **Do** reservar Casa Racing Red para acción, navegación activa y urgencia de mantenimiento.
- **Do** preferir densidad premium: pocas cards escaneables, copy corto, una acción filled clara.
- **Do** respetar Material 3 en Android (NavigationBar, FAB, SnackBar, diálogos del sistema).

### Don't:
- **Don't** diseñar genérico (plantilla SaaS clara, cards blancas, acento púrpura, o “app de motos” de stock sin Casa Racing).
- **Don't** saturar con mucho texto ni muchos botones en el primer viewport de una pantalla.
- **Don't** usar neones, look gaming, ni glassmorphism.
- **Don't** usar Contact Green fuera del canal WhatsApp.
- **Don't** afirmar sync/Firebase visualmente con indicadores “online” mientras el backend no exista (honestidad de producto).
- **Don't** introducir tipografías display ni elevaciones decorativas en cards en reposo.
