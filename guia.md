(reset)

```
(run)

```
Gestión de Prioridades (salience):
salience 100 en inicializar-y-pedir-datos: Fuerza que la lectura de sensores y fusificación ocurra primero, antes de evaluar reglas difusas.
salience -100 en defusificar-y-mostrar: Garantiza que la defusificación y muestra de resultados ocurra al final, cuando todas las reglas hayan aportado su grado de verdad.
Control de Flujo con Hecho de Control:
Se usa el hecho (datos-pendientes) y se retira con (retract ?p) en la lectura para evitar un bucle infinito de petición de datos.
Modificadores Lingüísticos (Hedges):
Se emplean modificadores como somewhat, very y extremely (ej. very inclinado_arriba, extremely alta) para afinar la respuesta de los alerones y la potencia sin multiplicar el número de reglas.
Doble Defusificación Simultánea:
El código calcula y almacena tanto el método del Momento / Centro de Gravedad (moment-defuzzify) como el del Máximo (maximum-defuzzify) para comparar el control suave frente al control reactivo.


Cambio A: Añadir o modificar un término en un deftemplate
Si pide añadir un término lingüístico nuevo (ej. un estado fuerte_atras más acentuado o cambiar los límites):
(deftemplate potencia 0 100 Porcentaje
    ((baja (20 1) (40 0))
    (media (30 0) (40 1) (50 1) (70 0))
    (alta (60 0) (80 1))
    (critica (75 0) (90 1)))  ;; <-- Término nuevo
Cambio B: Añadir una regla difusa nueva
Si pide añadir una nueva combinación de control (ej. "Si el viento es nulo y el ángulo está inclinado adelante, pon la potencia media"):
(defrule inclinado_adelante_nulo_custom
    (viento nulo)
    (angulo inclinado_adelante)
    =>
    (assert (potencia media))
    (assert (alerones neutro)))
Cambio C: Modificar el método de defusificación por defecto
Si pide mostrar únicamente la defusificación por el Centro de Gravedad (Momento) o cambiar la función, edita la regla defusificar-y-mostrar:
;; Para obtener solo el valor por Centro de Gravedad:
(bind ?mom-pow (moment-defuzzify ?f-pow))
Cambio D: Probar valores límite (Casos de prueba típicos)
En la prueba te pedirán introducir valores para comprobar las salidas:
Caso 1 (Inclinado Atrás + Viento Fuerte Atrás): Ángulo: -20, Viento: -35.
Resultado esperado: Potencia Alta, Alerones Inclinados Abajo.
Caso 2 (Nivelado + Viento Nulo): Ángulo: 0, Viento: 0.
Resultado esperado: Potencia Media, Alerones Neutro