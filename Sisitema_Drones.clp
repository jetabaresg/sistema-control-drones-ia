(deftemplate angulo -30 30 grados
    ((inclinado_atras (-15 1) (0 0))
    (nivelado (-10 0) (0 1) (10 0))
    (inclinado_adelante (0 0) (15 1))))

(deftemplate viento -50 50 Km/h   
    ((fuerte_atras (-30 1) (-10 0))
    (brisa_ligera (-20 0) (-10 1) (0 1) (20 0))
    (nulo (-10 0) (0 1) (10 0))
    (fuerte_adelante (10 0) (20 1))))

(deftemplate potencia 0 100 Porcentaje
    ((baja (20 1) (40 0))
    (media (30 0) (40 1) (50 1) (70 0))
    (alta (60 0) (80 1))))

(deftemplate alerones -40 40 grados
    ((inclinado_abajo (-30 1) (0 0))
    (neutro (-20 0) (0 1) (20 0))
    (inclinado_arriba (0 0) (30 1))))

(deftemplate Dron
    (slot sensor-inclinacion-crisp (type FLOAT) (default 0.0))
    (slot sensor-viento-crisp (type FLOAT) (default 0.0))
    (slot mom-potencia-crisp (type FLOAT) (default 0.0))
    (slot max-potencia-crisp (type FLOAT) (default 0.0))
    (slot mom-alerones-crisp (type FLOAT) (default 0.0))
    (slot max-alerones-crisp (type FLOAT) (default 0.0)))
    (deffacts estado-inicial
    (Dron)
    (datos-pendientes))

(deffunction fuzzify (?fztemplate ?value ?delta)
    (bind ?low (get-u-from ?fztemplate))
    (bind ?hi (get-u-to ?fztemplate))

    (if (<= ?value ?low)
        then
            (assert-string
                (format nil "(%s (%g 1.0) (%g 0.0))" ?fztemplate ?low ?delta))
        else
            (if (>= ?value ?hi)
                then
                    (assert-string
                        (format nil "(%s (%g 0.0) (%g 1.0))"
                            ?fztemplate (- ?hi ?delta) ?hi))
                else
                    (assert-string
                        (format nil "(%s (%g 0.0) (%g 1.0) (%g 0.0))"
                            ?fztemplate (max ?low (- ?value ?delta))
                            ?value (min ?hi (+ ?value ?delta)) ))
    )))

(defrule inicializar-y-pedir-datos
    (declare (salience 100)) 
    ?d <- (Dron)
    ?p <- (datos-pendientes)   ; <-- Condición extra
    =>
    (retract ?p)               ; <-- Consumimos el hecho para que no se repita
    (printout t "Angulo de inclinacion (grados): ")
    (bind ?inc (read))
    (printout t "Velocidad del viento (km/h): ")
    (bind ?viento (read))
    (modify ?d (sensor-inclinacion-crisp (float ?inc))
                (sensor-viento-crisp (float ?viento)))
    (fuzzify angulo ?inc 0)
    (fuzzify viento ?viento 0))

(defrule inclinado_atras_fuerte_atras
    (viento fuerte_atras)
    (angulo inclinado_atras)
    =>
    (assert (potencia alta))
    (assert (alerones inclinado_abajo)))

(defrule inclinado_atras_brisa_ligera
    (viento brisa_ligera)
    (angulo inclinado_atras)
    =>
    (assert (potencia media))
    (assert (alerones somewhat inclinado_abajo)))

(defrule inclinado_atras_nulo
    (viento nulo)
    (angulo inclinado_atras)
    =>
    (assert (potencia baja))
    (assert (alerones inclinado_arriba)))

(defrule nivelado_fuerte_atras
    (viento fuerte_atras)
    (angulo nivelado)
    =>
    (assert (potencia media))
    (assert (alerones inclinado_abajo)))

(defrule nivelado_brisa_ligera
    (viento brisa_ligera)
    (angulo nivelado)
    =>
    (assert (potencia somewhat media))
    (assert (alerones neutro)))

(defrule nivelado_nulo
    (viento nulo)
    (angulo nivelado)
    =>
    (assert (potencia media))
    (assert (alerones somewhat neutro)))

(defrule nivelado_fuerte_adelante
    (viento fuerte_adelante)
    (angulo nivelado)
    =>
    (assert (potencia alta))
    (assert (alerones very inclinado_arriba)))

(defrule inclinado_adelante_fuerte_atras
    (viento fuerte_atras)
    (angulo inclinado_adelante)
    =>
    (assert (potencia very baja))
    (assert (alerones neutro)))
    
(defrule inclinado_adelante_brisa_ligera
    (viento brisa_ligera)
    (angulo inclinado_adelante)
    =>
    (assert (potencia baja))
    (assert (alerones neutro)))

(defrule inclinado_adelante_nulo
    (viento nulo)
    (angulo inclinado_adelante)
    =>
    (assert (potencia alta))
    (assert (alerones very inclinado_abajo)))

(defrule inclinado_adelante_fuerte_adelante
    (viento fuerte_adelante)
    (angulo inclinado_adelante)
    =>
    (assert (potencia extremely alta))
    (assert (alerones inclinado_arriba)))

(defrule P1
    (angulo inclinado_atras)
    (angulo nivelado)
    (viento fuerte_atras)
    =>
    (assert (potencia media))
    (assert (alerones neutro)))

(defrule P2
    (angulo inclinado_adelante)
    (viento fuerte_adelante)
    =>
    (assert (potencia alta))
    (assert (alerones inclinado_arriba)))

(defrule P3
    (angulo inclinado_atras)
    (viento fuerte_atras)
    =>
    (assert (potencia alta))
    (assert (alerones inclinado_abajo)))
(defrule defusificar-y-mostrar    (declare (salience -100))
    ?d <- (Dron)
    ?f-pow <- (potencia ?)     
    ?f-aler <- (alerones ?)   
    =>
    (bind ?mom-pow (moment-defuzzify ?f-pow))
    (bind ?max-pow (maximum-defuzzify ?f-pow))
    (bind ?mom-aler (moment-defuzzify ?f-aler))
    (bind ?max-aler (maximum-defuzzify ?f-aler))
    
    (modify ?d (mom-potencia-crisp ?mom-pow)
                (max-potencia-crisp ?max-pow)
                (mom-alerones-crisp ?mom-aler)
                (max-alerones-crisp ?max-aler))
                
    (printout t "--- RESULTADOS ---" crlf)
    (printout t "Potencia (mom): " ?mom-pow " %" crlf)
    (printout t "Potencia (max): " ?max-pow " %" crlf)
    (printout t "Alerones (mom): " ?mom-aler " grados" crlf)
    (printout t "Alerones (max): " ?max-aler " grados" crlf)
    
    (halt))