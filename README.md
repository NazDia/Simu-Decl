# Proyecto de Simulción - Programación Declarativa

## Descripción general
### • Ambiente:
El ambiente está dado por un espacio de tamaño N × M con N y M decididas por el usuario. Debido a que en todo momento se puede acceder y obtener todos los datos del ambiente (que esta dado por la clase Board), se puede decir que es un ambiente de información completa, elemento tomado en cuenta por los agentes. Ocurren cambios en el ambiente de forma aleatoria cada t unidades de tiempo con t conocido, que es fácilmente divisible en turnos. Un turno es dividido en dos fases: Cambio por los agentes y Cambio del ambiente. En la primera fase los agentes son los unicos que modifican el ambiente y éste no cambia a menos que sea por resultado de tal acción. En la siguiente fase varían el ambiente y los elementos que lo componen. Tanto la fase de agente como la fase de ambiente ocurren en una unidad de tiempo. Como elementos del ambiente se tienen: Corral, Obstaculos, Niños y Suciedad, también se tienen los agentes que serían los Robots de Casa.
#### Obstáculos:
Estos ocupan una única casilla en el ambiente. Ellos pueden ser movidos, empujándolos, por los niños, una única casilla. El Robot de Casa sin embargo no puede moverlo. No pueden ser movidos ninguna de las casillas ocupadas por cualquier otro elemento del ambiente.
#### Suciedad:
La suciedad es por cada casilla del ambiente. Solo puede aparecer en casillas que previamente estuvieron vacías. Esta, o aparece en el estado inicial o es creada por los niños.
#### Corral:
El corral ocupa casillas adyacentes en número igual al del total de niños presentes en el ambiente. El corral no puede moverse. En una casilla del corral solo puede coexistir un niño. En una casilla del corral, que esté vacía, puede entrar un robot. En una misma casilla del corral pueden coexistir un niño y un robot solo si el robot lo carga, o si acaba de dejar al niño.
#### Niños:
Los niños ocupan solo una casilla. Ellos en el turno del ambiente se mueven, si es posible (si la casilla no está ocupada: no tiene suciedad, no está el corral, no hay un Robot de Casa), y aleatoriamente (puede que no ocurra movimiento), a una de las casilla adyacentes. Si esa casilla está ocupada por un obstáculo este es empujado por el niño, si en la dirección hay más de un obstáculo, entonces se desplazan todos. Si el obstáculo está en una posición donde no puede ser empujado y el niño lo intenta, entonces el obstáculo no se mueve y el niño ocupa la misma posición. Los niños son los responsables de que aparezca suciedad. Si en una cuadrícula de 3 por 3 hay un solo niño, entonces, luego de que él se mueva aleatoriamente, una de las casillas de la cuadrícula anterior que esté vacía puede haber sido ensuciada. Si hay dos niños se pueden ensuciar hasta 3. Si hay tres niños o más pueden resultar sucias hasta 6. Los niños cuando están en una casilla del corral, ni se mueven ni ensucian. Si un niño es capturado por un Robot de Casa tampoco se mueve ni ensucia.
## Modelación de Agentes:
Se tomaron dos formas de modelar los agentes, los cuales serían los Robots de Casa, se debe tomar en cuenta de que en general son agentes puramente reactivos, pués éstos actúan usando la información del ambiente en el momento sin tener registro de las acciones previamente realizadas, también son agentes proactivos, ya que tienen una meta trazada, la cuál es mantener la casa lo más limpia posible (ya sea limpiando o poniendo niños en el corral para evitar que se genere más suciedad). Éste patrón se usó en un modelo multiagente (varios robots). Se tomaron dos formas de implementar el modelo, si bien tienen una pequeña diferencia, ambos tienen en común que siempre buscarán el elemento del ambiente objetivo mas cercano y su acción dependerá de cuál sea el elemento alcanzado, si es un niño procederá a llevarlo al corral, si es suciedad, lo limpiará.

Diferencias entre los modelos:
	• En el primer modelo se toma la acción base tal y como fue definida sin ningún cambio, cada robot perseguirá el objetivo mas cercano.

	• En el segundo modelo los robots ignorarán los objetivos de otros robots e irán a por el siguiente objetivo libre. Si un robot no tiene objetivo, no se moverá.

## Experimentos:
Para realizar los experimentos, en el archivo 'config.cfg' se fijan los valores:
	• Semilla (El programa funciona aleatoriamente, pero depende de la semilla que se pase de parametro)

	• Dimensiones del tablero (Primero la X y después la Y, en líneas distintas)

	• Cantidad de niños

	• Cantidad de obstáculos

	• Cantidad de suciedad que hay al inicio de la simulación

	• Cantidad de robots

	• Cantidad de robots

	• El modelo a usar (0 para que no exista comunicación, cualquier
otro número para que exista)

	• Cantidad de turnos que ocurrirán en la simulación

Con los datos pasados como argumentos se simula el comportamiento de un ambiente creado aleatoriamente con la semilla pasada, a partir de aqui se ejecutan los cambios por los agentes y los cambios del ambiente en los turnos dados, imprimiendo en consola los estados por los que va pasando el tablero, de forma que los elementos del tablero son simbolizados de la siguiente manera:
	• Niño libre -> '@'

	• Casilla en la cuál hay un robot con un niño cargado -> '&' (tiene mayor prioridad para mostrarse)

	• Niño en corral -> 'Q' (tiene menor prioridad que el robot cargando un niño, pero mayor que el resto)

	• Suciedad -> '?'

	• Obstáculo -> 'X'

	• Corral libre -> '#'

	• Robot de casa -> '$'

	• Espacio libre -> '_'

Por lo general se ve como cuando la cantidad de niños supera la can-
tidad de robots, el porciento de suciedad va creciendo al inicio de la
simulación, más cuando éstos se concentran en limpiar y los niños solo
terminan alejandose (aunque ésta situación tampoco es tan frecuente).
En ocasiones es fácil para los robots alcanzar los niños puesto que éstos
terminan sin poder moverse debido a que terminan rodeados de su-
ciedad. También ocurre en ocasiones que los robots no pueden llevar a
un niño a una casilla de corral porque ésta se encuentra bloqueada (una
posible estrategia para solucionar éste problema sería priorizar llevar
a los niños a las casillas de corral que mayor 'corral vecindad' tenga,
pero debido a la escasez de tiempo he decidido no implementarla).
El cambio de comportamiento entre los resultados obtenidos por los
modelos, en muchos casos no es tan notable y en otros, el segundo
3es, de hecho, peor solución que el primero, ejemplo, en caso de que
algunos robots escojan un camino mas largo (a veces necesitando tam-
bién rodear otros robots) debido a que estaba en un lugar mas lejano
en la lista para asignar objetivo.

## Uso de la aplicación:
La aplicación se compila usando ghc con el comando:
'ghc main.hs interfaces.hs utils.hs board_work.hs'
Una vez compilada se ejecuta la aplicación, la cual extraerá los argu-
mentos necesarios del archivo 'config.cfg' en el mismo directorio que el
archivo ejecutable, a falta de 'config.cfg' se lanzará un error. El archivo
'config.cfg' se construye de la forma que fue descrito previamente en el
documento.
