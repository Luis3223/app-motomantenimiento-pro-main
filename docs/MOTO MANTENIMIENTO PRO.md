![][image1]  
MOTO MANTENIMIENTO PRO  
APLICACIÓN MÓVIL PARA LA GESTIÓN Y TRAZABILIDAD DE MANTENIMIENTOS PREVENTIVOS DE MOTOCICLETAS

FASE 2: AJUSTES Y DESARROLLO AVANZADO DEL PROYECTO

LUIS ÁNGEL OLIVERA HERNÁNDEZ   
SERGIO ESTEBAN VELOZA GONZÁLEZ 

VAIRON JESÚS VÁSQUEZ DÍAZ

CORPORACIÓN UNIFICADA NACIONAL DE EDUCACIÓN SUPERIOR – CUN  
INGENIERÍA DE SISTEMAS  
SINCELEJO 2026  
**Tabla de contenido**

[**Título del Proyecto	3**](#título-del-proyecto)

[**Introducción	3**](#introducción)

[**Planteamiento del problema	4**](#planteamiento-del-problema)

[**Formulación o pregunta de investigación	5**](#formulación-o-pregunta-de-investigación)

[**Objetivos	5**](#objetivos)

[Objetivo general	5](#objetivo-general)

[Objetivos específicos	5](#objetivos-específicos)

[**Justificación	5**](#justificación)

[**Alcances y limitaciones del proyecto	5**](#alcances-y-limitaciones-del-proyecto)

[**Marco referencial	5**](#marco-referencial)

[Antecedentes	5](#antecedentes)

[Marco teórico	5](#marco-teórico)

[Marco conceptual	6](#marco-conceptual)

[Marco contextual	6](#marco-contextual)

[Marco legal	6](#marco-legal)

[**Metodología	6**](#metodología)

[**Conclusiones	6**](#conclusiones)

[**Referencias	6**](#referencias)

# **Título del Proyecto** {#título-del-proyecto}

Moto Mantenimiento Pro: Aplicación móvil para la gestión y trazabilidad de mantenimientos preventivos de motocicletas  
Moto Mantenimiento Pro es una aplicación móvil para Android, vinculada al proveedor Casa Racing, orientada al registro y la consulta del historial de mantenimientos de motocicletas (cambio de aceite, ajuste de cadena, cambio de llantas, revisión de frenos y servicio general) y al seguimiento del ciclo de cambio de aceite. Está concebida y desarrollada aplicando los fundamentos, arquitecturas y buenas prácticas de la programación de apps móviles, y construida sobre el framework Flutter.

# **Introducción** {#introducción}

La motocicleta es el vehículo predominante en Colombia: al cierre de 2025 representaba el 63 % del parque automotor, con 13.528.164 unidades activas en el Registro Único Nacional de Tránsito (Registro Único Nacional de Tránsito [RUNT], 2026). Su uso está estrechamente ligado a la economía de los hogares: el 90 % de los hogares con motocicleta pertenece a estratos bajos, y cerca de un tercio de los compradores la adquiere para trabajar (12,9 %) o para trabajar y transportarse (20,9 %) (Asociación Nacional de Empresarios de Colombia [ANDI], 2024). Sin embargo, la vida útil, el desempeño mecánico y la seguridad de este tipo de vehículo dependen en gran medida de la constancia con la que su propietario realiza los mantenimientos preventivos recomendados por el fabricante, entre los que se destacan el cambio periódico de aceite, la revisión del sistema de frenos, la lubricación y tensión de la cadena, y el estado de las llantas (Cycles Worldwide, s.f.). En la práctica, es frecuente que los propietarios no lleven un registro sistemático de estos mantenimientos y se apoyen en la memoria, en anotaciones informales o en las calcomanías que algunos talleres adhieren al vehículo, mecanismos que resultan insuficientes para garantizar la trazabilidad del historial mecánico a lo largo del tiempo. No existen estadísticas públicas sobre cuántos propietarios llevan ese registro, pero las cifras de cumplimiento de otras obligaciones periódicas del vehículo apuntan a un problema de constancia: al cierre de 2025, la evasión de la revisión técnico-mecánica alcanzaba el 56 % y la motocicleta fue la clase de vehículo con mayor incumplimiento del SOAT (RUNT, 2026).  
Frente a esta problemática, se propone el desarrollo de Moto Mantenimiento Pro, una aplicación móvil que permite a los propietarios de motocicletas registrar cada mantenimiento realizado (tipo de servicio, fecha, kilometraje, categoría y notas), consultar su historial completo, conocer el estado del ciclo de cambio de aceite y contactar a Casa Racing por WhatsApp o visitar su tienda virtual desde la misma aplicación. El presente documento corresponde a la Fase 2 (Ajustes y desarrollo avanzado del proyecto) en el marco de la asignatura de Programación de Apps Móviles, y tiene como propósito exponer la necesidad de una solución tecnológica portable que acompañe al usuario en todo momento, así como el estado actual de su desarrollo. La aplicación está construida sobre el framework Flutter y el lenguaje Dart (Google, s.f.-a, s.f.-c) para ofrecer una experiencia de usuario (UX) fluida, interfaces gráficas intuitivas (UI) y el aprovechamiento de recursos del dispositivo, como el almacenamiento local en una base de datos SQLite, lo cual guarda coherencia directa con los objetivos y contenidos propios de la asignatura.

# **Planteamiento del problema** {#planteamiento-del-problema}

El mantenimiento preventivo de una motocicleta, particularmente el cambio de aceite, pero también la revisión de frenos, llantas, cadena y demás componentes sujetos a desgaste, debe realizarse conforme a intervalos definidos por el fabricante, en función del kilometraje recorrido o del tiempo transcurrido desde el último servicio, lo que ocurra primero. Por ejemplo, para sus motocicletas de bajo cilindraje, Honda recomienda cambiar el aceite cada 3.000 km o cada 3 meses (Honda Motos Colombia, s.f.-b). El incumplimiento o la postergación de estos mantenimientos tiene consecuencias mecánicas y de seguridad: el aceite pierde con el tiempo las propiedades aditivas que protegen el motor, aunque la moto recorra pocos kilómetros (Honda Motos Colombia, s.f.-b), y el líquido de frenos absorbe humedad, lo que reduce la eficacia del frenado y oxida los componentes internos del sistema (Honda Motos Colombia, s.f.-a). A esto se suma que, sin un historial de mantenimiento documentado, el propietario carece de un respaldo para demostrar el estado del vehículo, por ejemplo, al momento de venderlo.

A pesar de la relevancia de este seguimiento, muchos propietarios de motocicletas no cuentan con una herramienta dedicada para registrar y consultar su historial de mantenimientos. Las alternativas que suelen emplear son agendas físicas, recordatorios genéricos en el teléfono, hojas de cálculo improvisadas o, simplemente, la memoria. Ninguna de ellas ofrece una estructura de datos adecuada para relacionar la motocicleta con sus múltiples mantenimientos, cada uno con su propio tipo, fecha y kilometraje, ni permite calcular de manera automática cuándo corresponde el próximo cambio de aceite.  
Esta limitación evidencia la necesidad de una solución móvil. El desarrollo de una app aborda el problema al poner la herramienta de gestión directamente en el bolsillo del usuario (el smartphone). A través de la Programación de Apps Móviles, es posible estructurar un sistema que permita la persistencia de datos en el dispositivo (historial de mantenimientos en SQLite), el diseño de interfaces adaptadas a las pantallas de los teléfonos Android, la gestión de estado para que la información se actualice en cuanto el usuario registra un servicio, y alertas dentro de la aplicación que avisan cuando el cambio de aceite está próximo o vencido. En su versión actual, la aplicación calcula el ciclo del aceite con un intervalo fijo de 30 días a partir del último cambio registrado y guarda los datos únicamente en el dispositivo, sin sincronización en la nube; incorporar los intervalos por kilometraje del fabricante es uno de los ajustes por evaluar en esta fase. En este sentido, Moto Mantenimiento Pro no solo resuelve una necesidad práctica cotidiana, sino que constituye un caso de estudio idóneo para aplicar el ciclo de vida del desarrollo móvil, el manejo de interfaces y la experiencia de usuario vistos en la asignatura.

# **Formulación o pregunta de investigación** {#formulación-o-pregunta-de-investigación}

¿De qué manera una aplicación móvil desarrollada en Flutter puede permitir a los propietarios de motocicletas registrar, consultar y anticipar sus mantenimientos preventivos?

# **Objetivos** {#objetivos}

## **Objetivo general** {#objetivo-general}

Desarrollar una aplicación móvil para Android, construida en Flutter, que permita a los propietarios de motocicletas vinculados al proveedor Casa Racing registrar, consultar y anticipar sus mantenimientos preventivos mediante un historial de servicios almacenado en el dispositivo y el seguimiento del ciclo de cambio de aceite.

## **Objetivos específicos** {#objetivos-específicos}

1. Implementar el registro y la consulta del historial de mantenimientos de cada usuario (tipo de servicio, fecha, kilometraje, categoría y notas), con persistencia local en una base de datos SQLite.
2. Calcular el estado del ciclo de cambio de aceite a partir del último cambio registrado y avisar al usuario, mediante alertas dentro de la aplicación, cuando el cambio esté próximo o vencido.
3. Reorganizar la aplicación bajo una arquitectura MVVM por funcionalidad y validar su comportamiento con pruebas automatizadas unitarias y de widget.

# **Justificación** {#justificación}

El proyecto se justifica en primer lugar por la necesidad práctica de quienes usan la motocicleta como medio de transporte y de trabajo. En Colombia este vehículo concentra la mayor parte del parque automotor y, en una proporción alta, pertenece a hogares de estratos bajos que lo adquieren para laborar o para laborar y movilizarse (ANDI, 2024; RUNT, 2026). En ese contexto, postergar el mantenimiento preventivo no es un descuido menor: el aceite pierde con el tiempo las propiedades que protegen el motor, y el líquido de frenos absorbe humedad y reduce la eficacia del frenado (Honda Motos Colombia, s.f.-a, s.f.-b). Las agendas, los recordatorios genéricos y la memoria no relacionan cada servicio con su fecha y su kilometraje, ni calculan cuándo corresponde el siguiente cambio de aceite. Una aplicación en el teléfono que el propietario ya lleva consigo ofrece un lugar único para guardar ese historial y consultar el estado del ciclo sin depender de anotaciones sueltas.

Desde lo tecnológico, la solución se justifica porque el problema exige persistencia de datos, cálculo del intervalo y una interfaz usable en el teléfono, y no un registro aislado. Moto Mantenimiento Pro concentra el historial de servicios en el dispositivo, muestra el estado del ciclo de aceite a partir del último cambio registrado y deja a un paso el contacto con Casa Racing, el proveedor real al que está ligada la aplicación. Así, el usuario no solo anota lo que ya hizo: puede ver si el cambio está próximo o vencido y pasar de ese aviso a agendar o consultar el taller. Los datos permanecen en el teléfono; esta fase no depende de un servicio en la nube para cumplir esa función.

En lo académico, el proyecto se justifica como caso de aplicación de la asignatura Programación de Apps Móviles. Desarrollar la aplicación en Flutter obliga a integrar interfaz, gestión de estado, almacenamiento local con SQLite y una arquitectura por funcionalidades, y a comprobar ese comportamiento con pruebas automatizadas. El resultado atiende una necesidad cotidiana del motociclista y, al mismo tiempo, permite ejercer el ciclo de desarrollo móvil que la asignatura exige.

# **Alcances y limitaciones del proyecto** {#alcances-y-limitaciones-del-proyecto}

**Alcances**

El proyecto comprende el desarrollo de una aplicación móvil para Android, construida en Flutter, que al cierre de la Fase 2 ofrece las siguientes funciones:

1. **Cuentas y roles.** Registro e inicio de sesión locales con dos roles: usuario (propietario de la motocicleta) y administrador de Casa Racing. Al registrarse, el usuario ingresa los datos de su motocicleta: modelo, placa, año y número de identificación del vehículo (VIN).
2. **Historial de mantenimientos.** Registro de servicios con tipo (cambio de aceite, ajuste de cadena, cambio de llantas, revisión de frenos o servicio general), fecha, kilometraje, categoría (preventivo, urgente o garantía) y notas; consulta del historial con filtro por categoría, detalle de cada servicio y eliminación de registros.
3. **Seguimiento del ciclo de aceite.** Panel principal que muestra el estado del ciclo de cambio de aceite, calculado a partir del último cambio registrado, y alertas dentro de la aplicación cuando el cambio está próximo o vencido.
4. **Perfil.** Consulta y edición de los datos del usuario y de su motocicleta.
5. **Contacto con Casa Racing.** Acceso directo al WhatsApp del proveedor y a su tienda virtual desde la aplicación.
6. **Panel de administración.** Vista restringida al rol administrador para consultar los usuarios y servicios registrados en el dispositivo y enviar avisos dentro de la aplicación.
7. **Calidad del software.** Reorganización progresiva del código hacia una arquitectura MVVM por funcionalidad y verificación del comportamiento con pruebas automatizadas unitarias y de widget.

**Limitaciones**

1. **Solo Android.** La aplicación se desarrolla y prueba únicamente para Android; no se contempla una versión para iOS ni para la web.
2. **Datos solo en el dispositivo.** La información se almacena en una base de datos SQLite local. No hay servidor ni sincronización en la nube, por lo que los datos no se comparten entre teléfonos y se pierden si se desinstala la aplicación. Por la misma razón, el panel de administración solo ve los usuarios registrados en ese mismo teléfono.
3. **Regla de aceite simplificada.** El ciclo se calcula con un intervalo fijo de 30 días. No considera el kilometraje ni los intervalos que cada fabricante define para su modelo (por ejemplo, 3.000 km o 3 meses en motocicletas Honda de bajo cilindraje; Honda Motos Colombia, s.f.-b), y esta regla aún no está confirmada como definitiva por Casa Racing.
4. **Alertas solo dentro de la aplicación.** Los avisos se muestran mientras la aplicación está abierta; no se envían notificaciones del sistema ni notificaciones push, de modo que el usuario no recibe el aviso si no abre la aplicación.
5. **Seguimiento centrado en el aceite.** Los demás servicios (cadena, llantas, frenos) se registran en el historial, pero la aplicación no calcula cuándo corresponde su próxima revisión.
6. **Una motocicleta por cuenta.** Cada usuario registra una sola motocicleta.
7. **Prototipo académico.** La autenticación es local y las contraseñas se guardan sin cifrar, por lo que la aplicación no está preparada para un despliegue en producción con datos reales. El agendamiento y las compras no ocurren dentro de la aplicación: se hacen por WhatsApp o en la tienda virtual de Casa Racing.

# **Marco referencial** {#marco-referencial}

El marco referencial sitúa a Moto Mantenimiento Pro frente a trabajos previos, a los fundamentos con los que se construye y al entorno en el que se usa. Se organiza en antecedentes, marco teórico, marco conceptual, marco contextual y marco legal.

## **Antecedentes** {#antecedentes}

La revisión de antecedentes se centró en aplicaciones móviles para registrar y hacer seguimiento al mantenimiento de vehículos, con prioridad en las orientadas a motocicletas, e incluye trabajos de Colombia, Ecuador, Perú e Indonesia.

**Antecedentes internacionales**

Chasiluisa Chicaiza y Jiménez Ramírez (2017) desarrollaron, en la Universidad Técnica de Cotopaxi (Ecuador), una aplicación Android para el taller mecánico GAB Motors. Con ella, los clientes gestionan la información de sus vehículos y su perfil, reservan citas y reciben notificaciones en el teléfono sobre el próximo chequeo, mientras el taller administra clientes, vehículos y mantenimientos desde un portal web. El trabajo se construyó con la metodología Mobile-D. Su aporte al presente proyecto es el modelo de una aplicación ligada a un taller concreto, como ocurre con Moto Mantenimiento Pro y Casa Racing; a diferencia de aquel sistema, que depende de servicios web y de un portal del taller, Moto Mantenimiento Pro funciona sin servidor y deriva el agendamiento al WhatsApp del proveedor.

Contreras Garay (2018), en la Universidad César Vallejo (Lima, Perú), desarrolló con Scrum una aplicación móvil para gestionar el mantenimiento de las unidades de transporte de carga pesada de la empresa Transermir S.A.C. La aplicación registra los eventos de mantenimiento y calcula indicadores como el tiempo medio entre fallas y el tiempo medio de reparación. En un diseño preexperimental con 28 registros de vehículos, el tiempo medio entre fallas pasó de 50,18 a 57,64 horas y el tiempo promedio de reparación bajó de 29,33 a 21,07 minutos. Aunque se enfoca en una flota empresarial y no en propietarios individuales, este antecedente aporta evidencia medible de que registrar el mantenimiento en una aplicación móvil mejora su gestión.

Driesa y Somya (2023), en Indonesia, diseñaron una aplicación Android de recordatorio de servicio para motocicletas, orientada a los propietarios que olvidan con frecuencia el mantenimiento rutinario de las piezas de su vehículo. La aplicación se construyó con React Native, un framework multiplataforma, y con la base de datos en la nube Firebase, siguiendo el modelo de programación extrema (XP), y se validó con pruebas de caja negra. Es el antecedente internacional más cercano al presente proyecto por la población atendida y por el uso de un framework multiplataforma; Moto Mantenimiento Pro, en cambio, se construye con Flutter, almacena los datos en el dispositivo y valida su comportamiento con pruebas automatizadas.

**Antecedentes nacionales**

Lugo Jiménez y Roa Afanador (2019), en la Universidad Distrital Francisco José de Caldas, elaboraron una aplicación móvil para la gestión y el mantenimiento preventivo de vehículos y motocicletas. El usuario ingresa el kilometraje total, la placa y otros datos del vehículo, y la aplicación le avisa con anticipación qué mantenimiento está por cumplirse, además de los vencimientos de los documentos del vehículo y del conductor; incluye también guías en PDF para resolver fallas mecánicas comunes. El proyecto se desarrolló con Scrum. Es el antecedente más cercano en cuanto a la población atendida, e ilustra el valor de anticipar el mantenimiento en lugar de solo registrarlo, que corresponde al segundo objetivo específico de este proyecto.

Mosquera Capera y Medina Rojas (2021) presentaron una aplicación Android para gestionar el mantenimiento en un taller de motocicletas de Neiva. El sistema tiene tres módulos: el cliente recibe recomendaciones de motocicletas mediante filtrado colaborativo, el mecánico registra los mantenimientos preventivos y correctivos, y el administrador registra clientes y vehículos y envía notificaciones de servicio. Los autores organizaron el código con Clean Architecture, separando la interfaz, la lógica y el acceso a datos. Este trabajo es un referente directo para el tercer objetivo específico, que busca reorganizar Moto Mantenimiento Pro en capas bajo una arquitectura MVVM, y para su panel de administración.

**Síntesis**

Los antecedentes coinciden en que el historial de mantenimientos y los avisos anticipados son el núcleo de este tipo de aplicaciones, y en el uso de metodologías ágiles (Mobile-D, Scrum y XP) y de arquitecturas por capas. Varios de ellos dependen de un servidor, de un servicio en la nube o de un portal web del taller. Moto Mantenimiento Pro se diferencia por centrarse en la motocicleta del propietario, funcionar con almacenamiento local y conectar al usuario con un proveedor real, Casa Racing, sin intermediar el agendamiento ni las compras. A la vez, los antecedentes señalan funciones que la versión actual todavía no tiene y que sirven como referencia para su evolución: los avisos calculados a partir del kilometraje y las notificaciones del sistema.

## **Marco teórico** {#marco-teórico}

El proyecto se apoya en dos campos: la teoría del mantenimiento, que explica por qué y cuándo intervenir un vehículo, y la ingeniería de aplicaciones móviles, que orienta cómo construir la herramienta que acompaña al propietario en ese seguimiento.

**Mantenimiento preventivo y correctivo**

En términos generales, el mantenimiento es el conjunto de trabajos periódicos, programados y no programados, que se realizan para conservar un bien en condiciones adecuadas durante su vida útil. La literatura distingue dos tipos básicos: el mantenimiento preventivo, que se anticipa a las fallas y tiene la ventaja de poder programarse en el tiempo, y el mantenimiento correctivo, que atiende las averías cuando ya se han presentado (Arencibia Fernández, 2007). En la gestión del mantenimiento, el enfoque preventivo se considera la base de la confiabilidad de los equipos, porque busca las causas de los problemas antes de que se conviertan en paradas (Pillado Portillo et al., 2022).

En la motocicleta, el mantenimiento preventivo se programa según el uso o el tiempo, lo que ocurra primero: por ejemplo, el cambio de aceite cada 3.000 km o cada 3 meses en motocicletas Honda de bajo cilindraje (Honda Motos Colombia, s.f.-b), o el cambio del líquido de frenos por periodos, porque este absorbe humedad aunque el vehículo se use poco (Honda Motos Colombia, s.f.-a). Programar el mantenimiento exige, por tanto, conocer la fecha y el kilometraje del último servicio. Moto Mantenimiento Pro aplica este principio al guardar el historial de servicios y calcular a partir de él el estado del ciclo de aceite; la categoría de cada registro (preventivo, urgente o garantía) retoma la distinción entre intervenciones planificadas e intervenciones que responden a una falla.

**Desarrollo móvil multiplataforma con Flutter**

Flutter es un conjunto de herramientas de interfaz de usuario de Google que permite reutilizar el mismo código en Android, iOS, la web y el escritorio. Las aplicaciones se escriben en Dart (Google, s.f.-a) y, en su versión de producción, se compilan a código de máquina nativo; además, Flutter dibuja sus propios componentes visuales en lugar de depender de los controles del sistema operativo. Toda la interfaz se construye componiendo *widgets*, piezas pequeñas y de propósito único que se anidan para formar pantallas completas (Google, s.f.-b). En este proyecto, esa base tecnológica permite construir la aplicación para Android con un solo código fuente y conservar la posibilidad de llevarla a otras plataformas en el futuro.

**Interfaz declarativa y gestión de estado**

Flutter sigue un paradigma declarativo, que su documentación resume en la expresión *UI = f(state)*: la interfaz es una función del estado de la aplicación, de modo que cuando el estado cambia, el framework reconstruye solo los *widgets* afectados (Google, s.f.-b). La documentación distingue entre el estado efímero, propio de un único *widget* (por ejemplo, el valor de un campo de formulario), y el estado de la aplicación, que se comparte entre varias pantallas (Google, s.f.-f). En Moto Mantenimiento Pro, la sesión del usuario, su historial de servicios y el estado del ciclo de aceite forman parte del estado de la aplicación: cuando el usuario registra un servicio, el panel principal y el historial se actualizan sin que tenga que recargarlos.

**Arquitectura por capas y patrón MVVM**

La guía de arquitectura de Flutter señala la separación de responsabilidades como el principio más importante al diseñar una aplicación y recomienda el patrón Modelo-Vista-Modelo de vista (MVVM). La aplicación se divide en una capa de interfaz, formada por las vistas (composiciones de *widgets* sin lógica de negocio) y los modelos de vista (que transforman los datos en estado de la interfaz y exponen las acciones del usuario), y una capa de datos, formada por los repositorios, fuente única de verdad de los datos, y los servicios, que encapsulan el acceso a cada fuente de datos (Google, s.f.-d). Esta separación facilita probar cada parte por separado y modificar una capa sin afectar a las demás. Es el fundamento del tercer objetivo específico: la aplicación concentra hoy su estado en un único controlador y se reorganiza de forma progresiva en modelos de vista y repositorios por funcionalidad.

**Persistencia local con SQLite**

SQLite es una biblioteca que implementa un motor de base de datos SQL autocontenido, sin servidor, sin configuración y transaccional; una base de datos completa, con varias tablas e índices, se guarda en un único archivo del dispositivo, y sus transacciones cumplen las propiedades ACID incluso ante cierres inesperados o cortes de energía (SQLite, s.f.). Para aplicaciones que deben guardar y consultar volúmenes importantes de datos en el dispositivo, la documentación de Flutter recomienda una base de datos antes que un archivo o un almacén de clave-valor, y ofrece acceso a SQLite mediante el complemento sqflite, disponible para Android, iOS y macOS (Google, s.f.-e). Moto Mantenimiento Pro usa este enfoque para almacenar usuarios y servicios en el teléfono, lo que permite que la aplicación funcione sin conexión y sin un servidor propio.

**Pruebas automatizadas**

La documentación de Flutter distingue tres tipos de pruebas automatizadas. Las pruebas unitarias verifican la lógica de una sola función, método o clase; las pruebas de *widget* comprueban que un componente de la interfaz se vea y responda como se espera; y las pruebas de integración verifican que la aplicación completa, o una parte amplia de ella, funcione en conjunto. Las primeras son rápidas y económicas de mantener, mientras que las últimas dan mayor confianza a un costo más alto, por lo que una aplicación bien probada combina muchas pruebas unitarias y de *widget* con las pruebas de integración necesarias para los casos de uso importantes (Google, s.f.-g). El proyecto adopta las pruebas unitarias y de *widget* como mecanismo para validar su comportamiento, en línea con el tercer objetivo específico.

## **Marco conceptual** {#marco-conceptual}

Los términos siguientes se usan con el sentido que el proyecto les da. Cuando el término proviene de una fuente, se indica.

**Mantenimiento.** Conjunto de trabajos periódicos, programados o no, para conservar un bien en condiciones adecuadas durante su vida útil. Se distingue el mantenimiento preventivo, que se anticipa a la falla y puede programarse, del correctivo, que atiende la avería cuando ya ocurrió (Arencibia Fernández, 2007).

**Intervalo de mantenimiento.** Criterio de tiempo o de uso, lo que ocurra primero, con el que el fabricante indica cuándo repetir un servicio. En motocicletas Honda de bajo cilindraje, el cambio de aceite se indica cada 3.000 km o cada 3 meses (Honda Motos Colombia, s.f.-b).

**Historial de mantenimientos.** Registro ordenado de los servicios de una motocicleta. En la aplicación cada registro guarda tipo de servicio, fecha, kilometraje, categoría (preventivo, urgente o garantía) y notas.

**Trazabilidad.** Posibilidad de consultar ese historial y reconstruir qué se le hizo a la moto, cuándo y con qué kilometraje.

**Ciclo de cambio de aceite.** Estado que la aplicación calcula a partir de la fecha del último cambio registrado. En esta fase el intervalo es fijo de 30 días y el resultado se muestra como vigente, próximo o vencido.

**Estado de la aplicación.** Datos que varias pantallas comparten y que, al cambiar, actualizan la interfaz. En Flutter la interfaz se describe como función de ese estado (Google, s.f.-b, s.f.-f). Aquí comprende la sesión, el historial y el estado del ciclo de aceite.

**Modelo de vista (ViewModel).** Componente de la capa de interfaz que transforma los datos en estado presentable y expone las acciones del usuario, sin dibujar la pantalla. Junto con la vista y la capa de datos (repositorios y servicios) forma el patrón MVVM que recomienda la guía de arquitectura de Flutter (Google, s.f.-d).

**Persistencia local.** Almacenamiento de la base de datos en un archivo del propio teléfono, mediante SQLite, sin un proceso servidor (SQLite, s.f.).

## **Marco contextual** {#marco-contextual}

El proyecto se inscribe en el uso masivo de la motocicleta en Colombia. Al cierre de 2025 este vehículo representaba el 63 % del parque automotor, con 13.528.164 unidades activas, y la motocicleta fue la clase con mayor incumplimiento del SOAT; la evasión de la revisión técnico-mecánica alcanzaba el 56 % (RUNT, 2026). El 90 % de los hogares con motocicleta pertenece a estratos bajos, y una parte relevante de los compradores la adquiere para trabajar o para trabajar y transportarse (ANDI, 2024). En ese entorno, olvidar un servicio no es un dato menor: el vehículo es medio de transporte y, con frecuencia, de ingreso.

El entorno inmediato de la aplicación es el del propietario que mantiene su moto con el proveedor Casa Racing. La aplicación se desarrolla en la Corporación Unificada Nacional de Educación Superior (CUN), sede Sincelejo, dentro de la asignatura Programación de Apps Móviles, como prototipo para Android. El uso previsto es el teléfono del motociclista: consultar el ciclo de aceite, registrar el servicio y abrir el WhatsApp o la tienda virtual de Casa Racing. Los datos permanecen en ese teléfono. El panel de administración solo alcanza a los usuarios registrados en el mismo dispositivo, porque no hay un servidor que los reúna.

## **Marco legal** {#marco-legal}

La aplicación recoge datos que identifican a una persona: nombre, correo y contraseña, además de los datos de su motocicleta (modelo, placa, año y VIN). La Ley 1581 de 2012 desarrolla el derecho a conocer, actualizar y rectificar la información personal registrada en bases de datos, y aplica a los datos personales susceptibles de tratamiento por entidades públicas o privadas. La misma ley excluye de su régimen las bases de datos mantenidas en un ámbito exclusivamente personal o doméstico (Ley 1581, 2012).

En la versión actual los datos no salen del teléfono ni se tratan en un servidor. Mientras el almacenamiento siga siendo local y no circule hacia terceros, ese tratamiento se acerca a la excepción doméstica de la ley. El proyecto no se presenta, por eso, como un sistema en producción sometido a los deberes plenos del responsable del tratamiento (autorización, política de privacidad y medidas de seguridad). La limitación ya declarada apunta en el mismo sentido: las contraseñas se guardan sin cifrar y la autenticación es local. Si una fase posterior sincroniza los datos o los comparte con Casa Racing, la excepción deja de cubrir ese tratamiento y la Ley 1581 de 2012 pasa a exigirse de forma completa.

La aplicación no sustituye obligaciones de tránsito del vehículo, como el SOAT o la revisión técnico-mecánica. Esas obligaciones siguen a cargo del propietario; el alcance de esta fase es el historial de servicios y el ciclo de aceite.

# **Metodología** {#metodología}

**Tipo de proyecto**

Se trata de un proyecto de desarrollo tecnológico de carácter aplicado: su resultado es una aplicación móvil funcional que responde a la pregunta de investigación mediante la construcción y verificación de la herramienta. En esta fase la validación es técnica; no incluye encuestas, entrevistas ni pruebas de uso con motociclistas o con Casa Racing, lo que se reconoce como una limitación del trabajo.

**Modelo de desarrollo: iterativo e incremental**

El desarrollo sigue un modelo iterativo e incremental. En lugar de recorrer una sola vez, de forma secuencial, las etapas de requisitos, diseño, implementación y pruebas, el trabajo avanza en ciclos cortos; cada ciclo produce un incremento funcional que se revisa y sirve de base para el siguiente. Este enfoque se aplica desde mediados de la década de 1950 y es la base de los métodos ágiles actuales (Larman y Basili, 2003). Se eligió porque el proyecto parte de un prototipo que ya funciona y lo mejora por partes, sin detener la aplicación para reescribirla.

El proyecto se organiza en dos fases. En la Fase 1 (idea de proyecto) se formuló el problema y se construyó el prototipo inicial en Flutter con almacenamiento en SQLite. En la Fase 2 (ajustes y desarrollo avanzado), que corresponde a este documento, se analizó el código del prototipo, se registraron sus fallas y mejoras en un *backlog* priorizado y se atienden en iteraciones sucesivas.

**Ciclo de cada iteración**

Cada iteración recorre cinco actividades:

1. **Análisis y priorización.** Las tareas se registran en un *backlog* con un problema, una tarea y un criterio de aceptación verificable, y se ordenan por prioridad: P0 (crítico), P1 (fallas funcionales), P2 (datos y veracidad del producto), P3 (seguridad), P4 (servidor real) y P5 (calidad y plataforma). Se atiende primero lo que compromete los datos o la seguridad del usuario.
2. **Diseño y decisiones.** Las decisiones que afectan la estructura del sistema se documentan como registros de decisiones de arquitectura (ADR), textos breves que recogen el contexto, la decisión tomada, su estado y sus consecuencias (Nygard, 2011). La primera de ellas establece la migración incremental a MVVM: cada cambio que toca una funcionalidad la migra, y no se añaden responsabilidades nuevas al controlador central.
3. **Implementación.** El código se escribe, con apoyo de modelos de inteligencia artificial (ver el apartado siguiente), siguiendo la separación en capas descrita en el marco teórico (Google, s.f.-d) y los principios de diseño SOLID y DRY que el equipo adoptó como reglas del proyecto.
4. **Verificación.** Cada cambio pasa una verificación automática: formato del código, análisis estático sin advertencias (`flutter analyze`) y la batería de pruebas unitarias y de *widget* (Google, s.f.-g). La misma verificación se ejecuta en integración continua con GitHub Actions en cada envío a la rama principal y en cada solicitud de cambios. Las reglas del proyecto exigen acompañar cada corrección de una falla con una prueba que evite que reaparezca; las correcciones que dependen de la base de datos real, como las migraciones, quedan sin prueba automática hasta incorporar una base de datos de pruebas.
5. **Documentación.** Al cerrar la tarea, se marca como hecha en el *backlog* con su fecha y se registra el cambio en el historial de versiones del proyecto.

En lo que va de la Fase 2 se completaron, entre otras, las siguientes iteraciones: la restricción de la ruta de administración a usuarios con ese rol, la sustitución de una migración de base de datos que borraba los datos por migraciones incrementales, la pantalla de detalle de cada servicio, la eliminación de alertas repetidas, la confirmación antes de borrar un servicio y la normalización del correo electrónico en el inicio de sesión y el registro.

**Uso de inteligencia artificial en el desarrollo**

En el desarrollo se emplearon tres modelos de lenguaje de gran tamaño como asistentes de programación: Claude Opus 5.5 (Anthropic, 2026), Grok 4.7 (xAI, 2026) y GPT-5.6 (OpenAI, 2026). Se usaron a través de agentes de programación integrados en el entorno de desarrollo, como Claude Code y Cursor, para analizar el código del prototipo, proponer y redactar cambios, escribir pruebas automatizadas y revisar el código antes de darlo por terminado.

Su uso quedó sujeto a las mismas reglas que el resto del trabajo. Las instrucciones para los agentes están escritas en el propio repositorio y los obligan a respetar la arquitectura, los principios SOLID y DRY y la definición de terminado del proyecto. Todo cambio propuesto por un modelo pasa la misma verificación automática que el código escrito a mano (formato, análisis estático y pruebas), y ningún cambio se incorpora al repositorio sin la revisión y la aprobación explícita de un integrante del equipo. Las decisiones de producto y de arquitectura, así como la responsabilidad sobre el resultado, corresponden al equipo; los modelos actúan como herramienta de apoyo y no como autores del proyecto.

**Relación entre objetivos y actividades**

| Objetivo específico | Actividades | Evidencia de cumplimiento |
|---|---|---|
| 1. Registro y consulta del historial con persistencia en SQLite | Corregir y completar el alta, la consulta, el detalle y la eliminación de servicios; migraciones de base de datos que conserven los datos. | Criterios de aceptación de cada tarea y pruebas de las pantallas del historial. |
| 2. Cálculo del ciclo de aceite y alertas | Aislar el cálculo del ciclo en una función que reciba la fecha actual como parámetro; evitar alertas duplicadas. | Pruebas unitarias del cálculo para los casos sin servicios, al día, próximo y vencido. |
| 3. Arquitectura MVVM y pruebas automatizadas | Separar el acceso a datos en repositorios y crear un modelo de vista por funcionalidad, según el ADR de migración. | Ninguna pantalla depende del controlador central; cada modelo de vista tiene pruebas con repositorios simulados; la verificación automática en verde. |

**Técnicas e instrumentos**

- **Revisión documental:** estadísticas del sector (RUNT, ANDI), recomendaciones de fabricantes, trabajos previos y documentación oficial de Flutter y SQLite.
- **Análisis del código fuente:** revisión del prototipo para identificar fallas, riesgos y deuda técnica, registrados en el *backlog*.
- **Pruebas automatizadas:** pruebas unitarias del controlador y pruebas de *widget* de las pantallas y del enrutamiento, ejecutadas con un repositorio simulado en memoria que sustituye a la base de datos real.
- **Análisis estático:** reglas de estilo y detección de errores de `flutter_lints`.
- **Control de versiones:** Git y GitHub, con integración continua.

**Herramientas**

| Herramienta | Uso en el proyecto |
|---|---|
| Flutter y Dart | Framework y lenguaje de la aplicación (Google, s.f.-a, s.f.-c). |
| SQLite y `sqflite` | Base de datos local y su acceso desde Flutter (SQLite, s.f.; Google, s.f.-e). |
| `provider` | Distribución del estado de la aplicación a las pantallas. |
| `go_router` | Navegación entre pantallas y control de acceso a la ruta de administración. |
| `url_launcher` | Apertura del WhatsApp y de la tienda virtual de Casa Racing. |
| `flutter_test` y `flutter_lints` | Pruebas automatizadas y análisis estático. |
| Git, GitHub y GitHub Actions | Control de versiones e integración continua. |
| Claude Opus 5.5, Grok 4.7 y GPT-5.6 | Asistencia en el análisis del código, la implementación, las pruebas y la revisión (Anthropic, 2026; OpenAI, 2026; xAI, 2026). |
| Dispositivo o emulador Android | Ejecución y revisión funcional de la aplicación. |

# **Conclusiones** {#conclusiones}

El problema que motiva el proyecto tiene peso real en Colombia. La motocicleta es el 63 % del parque automotor, es medio de trabajo para una parte importante de sus propietarios y es la clase de vehículo que más incumple sus obligaciones periódicas (ANDI, 2024; RUNT, 2026). Como los fabricantes definen el mantenimiento por tiempo o por kilometraje (Honda Motos Colombia, s.f.-b), cumplirlo exige conocer la fecha y el kilometraje del último servicio. Por eso un historial confiable en el teléfono del propietario es una respuesta pertinente a esa necesidad, y no un simple registro adicional.

Frente a la pregunta de investigación, el prototipo muestra que una aplicación en Flutter puede cubrir las tres acciones planteadas. **Registrar** y **consultar** quedan resueltos con un historial persistente en SQLite, que funciona sin conexión ni servidor. **Anticipar** se cubre solo en parte: la aplicación avisa cuando el cambio de aceite está próximo o vencido, pero con una regla fija de 30 días que no considera el kilometraje ni los intervalos de cada fabricante, y únicamente mientras la aplicación está abierta.

Al cierre de este documento, los objetivos específicos presentan avances distintos:

- **Objetivo 1 (historial con persistencia local): cumplido.** La aplicación permite registrar, consultar, filtrar, ver en detalle y eliminar servicios, y en esta fase se reemplazó una migración de base de datos que borraba la información por migraciones incrementales que la conservan.
- **Objetivo 2 (ciclo de aceite y alertas): cumplido en lo básico.** El cálculo y las alertas funcionan y se eliminaron los avisos repetidos. Queda pendiente aislar el cálculo en una función con sus propias pruebas y revisar la regla de 30 días con Casa Racing frente a las recomendaciones del fabricante.
- **Objetivo 3 (arquitectura MVVM y pruebas): en curso.** La decisión de migrar de forma incremental está tomada y documentada, y la aplicación ya cuenta con pruebas unitarias y de *widget* que se ejecutan de forma automática en cada cambio. Sin embargo, el estado todavía se concentra en un único controlador; la separación en repositorios y modelos de vista por funcionalidad es el trabajo principal que resta en la fase.

El modelo iterativo e incremental resultó adecuado para un prototipo que ya funcionaba. El *backlog* priorizado permitió atender primero lo que ponía en riesgo los datos y la seguridad del usuario, y la verificación automática, junto con la integración continua, redujo el riesgo de romper funciones existentes al corregir otras. El análisis del código también expuso deudas que un revisor externo notaría: contraseñas guardadas sin cifrar, textos de la interfaz que anuncian una sincronización en la nube que no existe y ausencia de validación con usuarios reales.

Frente a los antecedentes revisados, varios de ellos apoyados en un servidor o en servicios en la nube, Moto Mantenimiento Pro ocupa un lugar propio: una aplicación centrada en la motocicleta del propietario, que funciona con almacenamiento local y lo conecta con un proveedor real. Las líneas de trabajo que se desprenden son, en orden de prioridad: retirar los mensajes de sincronización simulada, completar la migración a MVVM, guardar las contraseñas cifradas, incorporar el kilometraje al cálculo de los intervalos, programar notificaciones del sistema que avisen aunque la aplicación esté cerrada y validar la aplicación con motociclistas y con Casa Racing. Sincronizar los datos con un servidor queda para una etapa posterior, que además obligaría a cumplir plenamente la Ley 1581 de 2012.

# **Referencias** {#referencias}

Anthropic. (2026). *Claude Opus 5.5* [Modelo de lenguaje de gran tamaño]. [https://www.anthropic.com/claude](https://www.anthropic.com/claude)   
Arencibia Fernández, J. M. (2007). Conceptos fundamentales sobre el mantenimiento de edificios. *Revista de Arquitectura e Ingeniería*, *1*(1), 1–8. [https://www.redalyc.org/articulo.oa?id=193915927005](https://www.redalyc.org/articulo.oa?id=193915927005)   
Asociación Nacional de Empresarios de Colombia. (2024, 12 de septiembre). *Nuevo estudio de las motocicletas en Colombia*. Recuperado el 29 de septiembre de 2026, de [https://www.andi.com.co/Home/Noticia/17736-nuevo-estudio-de-las-motocicletas-en-co](https://www.andi.com.co/Home/Noticia/17736-nuevo-estudio-de-las-motocicletas-en-co)   
Chasiluisa Chicaiza, M. V., y Jiménez Ramírez, L. A. (2017). *Aplicación móvil para el control del mantenimiento de los vehículos que ingresan al taller mecánico integral GAB Motors* [Tesis de pregrado, Universidad Técnica de Cotopaxi]. Repositorio Digital UTC. [http://repositorio.utc.edu.ec/handle/27000/4404](http://repositorio.utc.edu.ec/handle/27000/4404)   
Contreras Garay, E. D. (2018). *Aplicación móvil para la gestión de mantenimiento de las unidades de transporte de carga pesada en la empresa Transermir S.A.C* [Tesis de pregrado, Universidad César Vallejo]. Repositorio de la Universidad César Vallejo. [https://hdl.handle.net/20.500.12692/21229](https://hdl.handle.net/20.500.12692/21229)   
Cycles Worldwide. (s.f.). *Motorcycle maintenance: Essential guide for every rider*. Recuperado el 2 de septiembre de 2026, de [https://cyclesworldwide.com/motorcycle-maintenance-essential-guide-for-every-rider/](https://cyclesworldwide.com/motorcycle-maintenance-essential-guide-for-every-rider/)   
Driesa, Y. K., y Somya, R. (2023). Perancangan aplikasi service reminder sepeda motor berbasis Android mobile [Diseño de una aplicación Android de recordatorio de servicio para motocicletas]. *JATISI (Jurnal Teknik Informatika dan Sistem Informasi)*, *10*(1), 287–297. [https://doi.org/10.35957/jatisi.v10i1.2705](https://doi.org/10.35957/jatisi.v10i1.2705)   
Google. (s.f.-a). *The Dart language tour*. Dart. Recuperado el 2 de septiembre de 2026, de [https://dart.dev/language](https://dart.dev/language)   
Google. (s.f.-b). *Flutter architectural overview*. Flutter. Recuperado el 29 de septiembre de 2026, de [https://docs.flutter.dev/resources/architectural-overview](https://docs.flutter.dev/resources/architectural-overview)   
Google. (s.f.-c). *Flutter documentation*. Recuperado el 2 de septiembre de 2026, de [https://docs.flutter.dev/](https://docs.flutter.dev/)   
Google. (s.f.-d). *Guide to app architecture*. Flutter. Recuperado el 29 de septiembre de 2026, de [https://docs.flutter.dev/app-architecture/guide](https://docs.flutter.dev/app-architecture/guide)   
Google. (s.f.-e). *Persist data with SQLite*. Flutter. Recuperado el 29 de septiembre de 2026, de [https://docs.flutter.dev/cookbook/persistence/sqlite](https://docs.flutter.dev/cookbook/persistence/sqlite)   
Google. (s.f.-f). *State management*. Flutter. Recuperado el 29 de septiembre de 2026, de [https://docs.flutter.dev/data-and-backend/state-mgmt/intro](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)   
Google. (s.f.-g). *Testing Flutter apps*. Flutter. Recuperado el 29 de septiembre de 2026, de [https://docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)   
Honda Motos Colombia. (s.f.-a). *¿Cada cuánto debo cambiar el líquido de frenos de mi moto?* Recuperado el 29 de septiembre de 2026, de [https://motos.honda.com.co/honda-te-cuenta/blog/cada-cuanto-debo-cambiar-el-liquido-de-frenos-de-mi-moto](https://motos.honda.com.co/honda-te-cuenta/blog/cada-cuanto-debo-cambiar-el-liquido-de-frenos-de-mi-moto)   
Honda Motos Colombia. (s.f.-b). *Descubre cómo y cuándo cambiar el aceite de tu moto*. Recuperado el 29 de septiembre de 2026, de [https://motos.honda.com.co/honda-te-cuenta/blog/descubre-como-y-cuando-cambiar-el-aceite-de-tu-moto](https://motos.honda.com.co/honda-te-cuenta/blog/descubre-como-y-cuando-cambiar-el-aceite-de-tu-moto)   
Larman, C., y Basili, V. R. (2003). Iterative and incremental development: A brief history. *Computer*, *36*(6), 47–56. [https://doi.org/10.1109/MC.2003.1204375](https://doi.org/10.1109/MC.2003.1204375)   
Ley 1581 de 2012. (2012, 17 de octubre). *Por la cual se dictan disposiciones generales para la protección de datos personales*. Diario Oficial No. 48.587. [https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=49981](https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=49981)   
Lugo Jiménez, R. A., y Roa Afanador, O. G. (2019). *Aplicación móvil para la gestión y mantenimiento preventivo de vehículos y motocicletas* [Trabajo de grado, Universidad Distrital Francisco José de Caldas]. Repositorio Institucional UD. [https://repository.udistrital.edu.co/handle/11349/15919](https://repository.udistrital.edu.co/handle/11349/15919)   
Mosquera Capera, J. S., y Medina Rojas, F. (2021). Aplicación móvil Android para la gestión de mantenimiento creada con Clean Architecture. *Revista Colombiana de Tecnologías de Avanzada*, *1*(37), 23–28. [https://doi.org/10.24054/rcta.v1i37.974](https://doi.org/10.24054/rcta.v1i37.974)   
Nygard, M. (2011, 15 de noviembre). *Documenting architecture decisions*. Cognitect. [https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)   
OpenAI. (2026). *GPT-5.6* [Modelo de lenguaje de gran tamaño]. [https://openai.com](https://openai.com)   
Pillado Portillo, M., Castillo Pérez, V. H., y de la Riva Rodríguez, J. (2022). Metodología de administración para el mantenimiento preventivo como base de la confiabilidad de las máquinas. *RIDE. Revista Iberoamericana para la Investigación y el Desarrollo Educativo*, *12*(24), Artículo e055. [https://doi.org/10.23913/ride.v12i24.1218](https://doi.org/10.23913/ride.v12i24.1218)   
Registro Único Nacional de Tránsito. (2026, 27 de febrero). *Balance del sector de tránsito y transporte* (Boletín de Prensa 001 de 2026). Recuperado el 29 de septiembre de 2026, de [https://www.runt.gov.co/sites/default/files/Bolet%C3%ADn%20001%20de%202026.pdf](https://www.runt.gov.co/sites/default/files/Bolet%C3%ADn%20001%20de%202026.pdf)   
SQLite. (s.f.). *About SQLite*. Recuperado el 29 de septiembre de 2026, de [https://www.sqlite.org/about.html](https://www.sqlite.org/about.html)   
xAI. (2026). *Grok 4.7* [Modelo de lenguaje de gran tamaño]. [https://x.ai/grok](https://x.ai/grok) 

[image1]: <data:image/png;base64,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>