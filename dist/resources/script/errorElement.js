var errorElement, errorName;

window.ERROR_ELEMENT = {
  REFERENCIA_MULTIPLE_ELIMINACION_CONJUNCION: {
    content: ['La eliminacion de la conjunción debe tener una única referencia']
  },
  REFERENCIA_A_LINEA_POSTERIOR: {
    content: ['Deben utilizarse referencias a lineas anteriores a la actual']
  },
  INTRODUCCION_CONJUNCION_CONECTOR_INCORRECTO: {
    content: ['La intruducción de la conjunción permite generar una formula con un conector Λ']
  },
  INTRODUCCION_DISYUNCION_CONECTOR_INCORRECTO: {
    content: ['La intruducción de la disyunción permite generar una formula con un conector V']
  },
  INTRODUCCION_CONDICIONAL_CONECTOR_INCORRECTO: {
    content: ['La intruducción del condicional permite generar una formula con un conector →']
  },
  INTRODUCCION_CONDICIONAL_FALTA_ITERACION: {
    content: ['La introducción de un condicional debe suceder a un contexto de suposición']
  },
  INTRODUCCION_NEGACION_FALTA_NAGACION: {
    content: ['La intruducción de la negación permite generar una formula con un simbolo ¬']
  },
  INTRODUCCION_NEGACION_FALTA_ITERACION: {
    content: ['La introducción de la negación debe suceder a un contexto de suposición']
  },
  ELIMINACION_NEGACION_NO_CONTRADICCION: {
    content: ['La eliminación de la negación genera una contradicción (⊥)']
  },
  ELIMINACION_NEGACION_REFERENCIAS_INVALIDAS: {
    content: ['La eliminación de la negación espera dos elementos opuestos, Por ejemplo: ', '1:(pVq)', '2:¬(pVq)', '3:⊥ E¬(1,2)', 'Asegurece también de indicar las referencias correctamente']
  },
  ELIMINACION_CONDICIONAL_REFERENCIAS_INVALIDAS: {
    content: ['La eliminación del condicional espera dos elementos, de los cuales, ' + 'uno es una implicación y el otro el antecedente del primero. Por ejemplo:', '1:(pVq)→p premisa', '2:(pVq) premisa', '3:p E→(1,2)', 'Asegurece también de indicar las referencias correctamente']
  },
  ELIMINACION_DISYUNCION_REFERENCIAS_INVALIDAS: {
    content: ['La eliminación de la disyunción espera tres elementos, de los cuales,' + 'uno es una disyunción y los otros dos, son condicionales que tienen como premisa las' + 'partes del primero. Y permite extraer el consecuente de los últimos. Por ejemplo:', '1:pVq premisa', '2:p→s premisa', '3:q→s premisa', '4:s EV(1,2,3)', 'Asegurece también de indicar las referencias correctamente']
  },
  DOBLE_NEGACION_REFERENCIAS_MULTIPLES: {
    content: ['La eliminacion de la negación doble debe tener una única referencia']
  },
  DOBLE_NEGACION_TIPO_REFERENCIAS_INVALIDAS: {
    content: ['La regla de la doble negación espera un elemento negado dos veces. Por ejemplo:', '1:¬¬(pVq) premisa', '2:(pVq) ¬¬(1)', 'Asegurece también de indicar las referencias correctamente']
  },
  REPETICION_REFERENCIAS_MULTIPLES: {
    content: ['La repetición espera una única referencia']
  },
  REPETICION_REFERENCIAS_INVALIDAS: {
    content: ['La repetición espera una referencia a un elemento equivalente']
  },
  EFSQ_REFERENCIAS_MULTIPLES: {
    content: ['EFSQ espera una única referencia']
  },
  EFSQ_REFERENCIAS_INVALIDAS: {
    content: ['EFSQ espera una contradicción como referencia']
  },
  CIERRE_ITERACION_SIN_SUPUESTO: {
    content: ['Para cerrar una iteracion con << se debe partir de un supuesto']
  },
  DOBLE_NEGACION_RESULTADO_INVALIDO: {
    content: ['Eliminar la doble negación en', '${dobleNegacionReferida}', 'produce', '${referenciaDespejado}']
  }
};

for (errorName in window.ERROR_ELEMENT) {
  errorElement = window.ERROR_ELEMENT[errorName];
  errorElement.name = errorName;
  errorElement.type = 'ERROR';
}
