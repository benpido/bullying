# bulling
Aplicación móvil diseñada para registrar, documentar y generar alertas automáticas o manuales en situaciones de bullying, facilitando la intervención oportuna y conocimiento de cada caso. Al activarse, envía la ubicación, teléfono y el nombre del usuario a sus contactos de emergencia, junto con iniciar una grabación de audio en segundo plano y habilitar una burbuja discreta para cancelar la emergencia en caso de error. Si el envío de notificaciones falla, se informa al usuario sin comprometer su seguridad. Además, la aplicación se camufla como una aplicación común (calendario, calculadora, notas, etc.), asegurando que no se revele su función de emergencia en caso de que la víctima esté siendo observada. Solo los administradores pueden visualizar y monitorear las grabaciones y alertas activadas (A traves del portal web). El objetivo es brindar a las personas una herramienta rápida, discreta y efectiva para solicitar ayuda y registrar evidencia ante situaciones de acoso o bullying.

## Requerimientos Funcionales

### Módulo 1: Acceso y Control de Usuarios  
- El registro de usuarios será gestionado únicamente por un Administrador desde una plataforma web.  
- No se permite el registro libre de usuarios desde la aplicación.  
- El acceso a configuraciones sensibles (como contactos de emergencia) estará protegido por clave o patrón secreto.  
- El usuario debe tener la capacidad de definir hasta dos contactos de emergencia.  
- El administrador se debe definir como un contacto de emergencia.

### Módulo 2: Activación y Detección de Emergencias  
- La aplicación debe detectar agitaciones bruscas del dispositivo y activar el modo Escucha.  
- La aplicación debe detectar en segundo plano niveles elevados de decibelios y activar el modo Escucha.  
- Al activar el modo Escucha, se mostrará una notificación silenciosa durante 5 segundos con la opción de cancelar.  
- La grabación de audio debe tener una duración de 30 segundos.  
- No se debe iniciar una nueva grabación si ya hay una en curso.

### Módulo 3: Envío y Almacenamiento  
- Al finalizar una grabación, se debe enviar a los contactos de emergencia configurados:  
  - Nombre del usuario  
  - Número de teléfono del dispositivo  
  - Ubicación GPS en tiempo real (si no está disponible, indicar “NO DISPONIBLE”)  
  - Grabación de audio  
  - Fecha y hora de activación  
- Si no hay conexión a internet, los datos se deben almacenar cifrados localmente y enviarse automáticamente al restablecer la conexión.  
- El sistema debe verificar espacio disponible antes de grabar.  
- El usuario será notificado en caso de un fallo en el envío.  

### Módulo 4: Interfaz de Usuario  
- Pantalla inicial disfrazada con apariencia de otra aplicación común (calendario, calculadora, notas, etc.).  
- El usuario podrá elegir desde las configuraciones qué tipo de pantalla falsa desea utilizar.  
- En la pantalla falsa habrá:  
  - Un botón discreto para iniciar una grabación de emergencia manual.  
  - Un botón para gestionar las configuraciones de la aplicación.  
- No se podrá usar la aplicación sin al menos un contacto configurado.  
- La ventana para cancelar el modo Escucha debe aparecer durante los primeros 5 segundos tras la activación.

### Módulo 5: Ubicación y Contexto  
- El sistema debe capturar la ubicación GPS en tiempo real al activarse una emergencia.  
- Si no es posible obtener ubicación, debe registrarse como “NO DISPONIBLE”.

### Módulo 6: Plataforma Web del Administrador  
- Panel web para gestionar usuarios 
- Visualización del historial de activaciones y acceso exclusivo a grabaciones recibidas.   
- Opción para ajustar remotamente la duración de grabación (entre 30 y 60 segundos).  
- Posibilidad de descargar grabaciones.

### Módulo 7: Seguridad y Privacidad  
- Todos los audios y ubicaciones se deben almacenar y transmitir cifrados.  
- Ningún usuario final podrá escuchar sus propias grabaciones; solo los contactos de emergencia reciben el audio.  
- Se deben mantener logs internos invisibles para auditoría de uso, errores y eventos críticos.

## Requerimientos No Funcionales  
- Compatibilidad: únicamente dispositivos Android.  
- Funcionamiento continuo en segundo plano con bajo consumo de batería.  
- Tiempo de respuesta ante detección de movimiento o decibelios menor a 2 segundos.  
- Operatividad offline con almacenamiento local cifrado y reenvío automático.  
- Diseño intuitivo y accesible para usuarios sin conocimientos técnicos.  
- Permisos necesarios: micrófono, ubicación, contactos, almacenamiento y ejecución en background.  
- Interfaz con botones grandes y legibles para cancelar emergencias.
