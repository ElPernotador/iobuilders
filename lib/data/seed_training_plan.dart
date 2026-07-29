import '../core/models/workout.dart';

const List<Exercise> strengthAExercises = [
  Exercise(
    id: 'incline_pushup',
    name: 'Flexión inclinada',
    sets: 3, reps: '8-12', restSeconds: 60,
    instructions: 'Manos en superficie elevada, cuerpo recto, baja el pecho hasta la superficie',
    safetyNote: 'No bloquees codos al extender; si hay dolor de hombro, sube más la inclinación',
    easierVariant: 'Flexión de rodillas',
    harderVariant: 'Flexión en suelo',
    tags: ['push', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'db_floor_press',
    name: 'Press de suelo con mancuerna',
    sets: 3, reps: '8-12', restSeconds: 60,
    instructions: 'Tumbado en suelo, codos a 45°, sube las mancuernas hasta extensión parcial',
    safetyNote: 'Rango reducido protege hombro; no empujes si hay clic doloroso',
    easierVariant: 'Menos peso o solo un brazo',
    harderVariant: 'Pausa 2 segundos abajo',
    tags: ['push', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'one_arm_row',
    name: 'Remo unilateral con mancuerna',
    sets: 3, reps: '10-12', restSeconds: 60,
    instructions: 'Rodilla y mano en banco, tira la mancuerna hacia cadera, codo pegado',
    safetyNote: 'Espalda plana; no rotar el tronco',
    easierVariant: 'Remo de banda sentado',
    harderVariant: 'Pausa 1 segundo arriba',
    tags: ['pull', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'dead_bug',
    name: 'Dead bug',
    sets: 3, reps: '8 por lado', restSeconds: 45,
    instructions: 'Tumbado boca arriba, baja brazo y pierna opuestos manteniendo lumbar pegada al suelo',
    safetyNote: 'La lumbar no debe despegarse; si lo hace, reduce el rango',
    easierVariant: 'Solo mover piernas',
    harderVariant: 'Con peso ligero en manos',
    tags: ['core', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'plank',
    name: 'Plancha frontal',
    sets: 3, reps: '20-40s', restSeconds: 45,
    instructions: 'Codos en suelo, cuerpo recto como tabla, respira lento',
    safetyNote: 'No dejes caer las caderas; para si lumbar duele',
    easierVariant: 'Plancha de rodillas',
    harderVariant: 'Plancha con elevación de pie alternos',
    tags: ['core', 'shoulder_safe', 'knee_safe'],
  ),
];

const List<Exercise> strengthBExercises = [
  Exercise(
    id: 'band_pull_apart',
    name: 'Apertura de banda (hombros)',
    sets: 3, reps: '15', restSeconds: 45,
    instructions: 'Sostén banda a la altura del pecho, tira hacia atrás separando brazos hasta que toque el pecho',
    safetyNote: 'Movimiento controlado; si el hombro cruje, reduce tensión de banda',
    easierVariant: 'Banda más suave',
    harderVariant: 'Banda más fuerte o 3 segundos de pausa',
    tags: ['pull', 'shoulder_safe', 'knee_safe', 'hombro_rehab'],
  ),
  Exercise(
    id: 'db_curl',
    name: 'Curl de bíceps con mancuerna',
    sets: 3, reps: '10-12', restSeconds: 45,
    instructions: 'De pie o sentado, codo fijo, sube mancuerna con supinación',
    safetyNote: 'No balancear la espalda; reducir peso si hay dolor de hombro',
    easierVariant: 'Curl alternado',
    harderVariant: 'Curl concentrado en banco inclinado',
    tags: ['pull', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'triceps_extension',
    name: 'Extensión de tríceps con mancuerna',
    sets: 3, reps: '10-12', restSeconds: 45,
    instructions: 'Sentado o de pie, mancuerna sobre cabeza con dos manos, baja detrás de la cabeza con codos quietos',
    safetyNote: 'Si hay dolor de hombro al subir, usa press de tríceps en cable o tumbado',
    easierVariant: 'Extensión tumbado con codo a 90°',
    harderVariant: 'Con pausa 1s abajo',
    tags: ['push', 'knee_safe'],
  ),
  Exercise(
    id: 'rear_delt_raise',
    name: 'Elevación posterior de deltoides',
    sets: 3, reps: '12-15', restSeconds: 45,
    instructions: 'Inclinado hacia adelante, brazos colgando, eleva mancuernas a los lados hasta altura de hombros',
    safetyNote: 'Peso muy ligero; fundamental para salud del manguito rotador',
    easierVariant: 'Con banda desde abajo',
    harderVariant: 'Pausa 2s arriba',
    tags: ['pull', 'shoulder_safe', 'knee_safe', 'hombro_rehab'],
  ),
  Exercise(
    id: 'external_rotation',
    name: 'Rotación externa de hombro',
    sets: 3, reps: '15', restSeconds: 30,
    instructions: 'Tumbado de lado, codo doblado 90°, mancuerna ligera, rota antebrazo hacia arriba',
    safetyNote: 'Ejercicio de rehabilitación; usa peso mínimo (0.5-1kg)',
    easierVariant: 'Sin peso',
    harderVariant: 'Banda de resistencia suave',
    tags: ['shoulder_safe', 'knee_safe', 'hombro_rehab'],
  ),
  Exercise(
    id: 'side_plank',
    name: 'Plancha lateral',
    sets: 2, reps: '20-30s por lado', restSeconds: 45,
    instructions: 'Codo en suelo, cuerpo recto lateral, cadera elevada',
    safetyNote: 'Si el hombro duele al apoyar, apoya en la mano extendida',
    easierVariant: 'Con rodilla apoyada',
    harderVariant: 'Elevar cadera arriba y abajo',
    tags: ['core', 'shoulder_safe', 'knee_safe'],
  ),
];

const List<Exercise> strengthCExercises = [
  Exercise(
    id: 'romanian_deadlift',
    name: 'Peso muerto rumano adaptado',
    sets: 3, reps: '10-12', restSeconds: 60,
    instructions: 'De pie, mancuernas delante de muslos, bisagra de cadera sin doblar mucho rodillas, espalda recta',
    safetyNote: 'No doblar rodillas más de 30°; espalda siempre neutra. Para si hay dolor lumbar',
    easierVariant: 'Bisagra sin peso con pausa',
    harderVariant: 'Más peso con control',
    tags: ['pull', 'knee_safe'],
  ),
  Exercise(
    id: 'hip_hinge_drill',
    name: 'Ejercicio de bisagra de cadera',
    sets: 2, reps: '10', restSeconds: 45,
    instructions: 'De pie, palo/banda detrás de espalda, empuja caderas hacia atrás hasta sentir tensión isquiotibiales',
    safetyNote: 'Movimiento de movilidad, no de fuerza; muy seguro para rodilla',
    easierVariant: 'Frente al espejo para feedback',
    harderVariant: 'Añadir pausa 3s abajo',
    tags: ['knee_safe', 'mobility'],
  ),
  Exercise(
    id: 'scapular_retraction',
    name: 'Retracción escapular',
    sets: 3, reps: '15', restSeconds: 30,
    instructions: 'De pie o sentado, junta escápulas como si quisieran tocarse, mantén 2s',
    safetyNote: 'Básico para salud del hombro; sin dolor posible',
    easierVariant: 'Con banda de resistencia mínima',
    harderVariant: 'Con remo de baja carga',
    tags: ['pull', 'shoulder_safe', 'knee_safe', 'hombro_rehab'],
  ),
  Exercise(
    id: 'bird_dog',
    name: 'Bird dog',
    sets: 3, reps: '8 por lado', restSeconds: 45,
    instructions: 'A cuatro patas, extiende brazo opuesto a pierna manteniendo columna neutra',
    safetyNote: 'Muñeca puede molestar; si es así, usa puños cerrados',
    easierVariant: 'Solo mover pierna',
    harderVariant: 'Pausa 3s en extensión',
    tags: ['core', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'lateral_raise_light',
    name: 'Elevación lateral ligera',
    sets: 3, reps: '12-15', restSeconds: 45,
    instructions: 'Mancuernas muy ligeras, levanta brazos a los lados solo hasta altura del hombro',
    safetyNote: 'No subir por encima de 90°; si cruje el hombro, baja el peso',
    easierVariant: 'Banda de resistencia mínima',
    harderVariant: 'Pausa 2s arriba',
    tags: ['push', 'shoulder_safe', 'knee_safe'],
  ),
  Exercise(
    id: 'mobility_block',
    name: 'Bloque de movilidad',
    sets: 1, reps: '5-8 por lado', restSeconds: 30,
    instructions: 'Rotación torácica, apertura de cadera, estiramiento de pecho; fluido y sin rebote',
    safetyNote: 'Sin dolor; si el hombro duele en algún movimiento, omítelo',
    easierVariant: 'Reducir rango de movimiento',
    harderVariant: 'Mayor rango y más repeticiones',
    tags: ['mobility', 'shoulder_safe', 'knee_safe'],
  ),
];

const Workout workoutA = Workout(
  id: 'strength_a',
  name: 'Fuerza A – Empuje + Remo + Core',
  type: 'strength_a',
  exercises: strengthAExercises,
  estimatedMinutes: 25,
);

const Workout workoutB = Workout(
  id: 'strength_b',
  name: 'Fuerza B – Tracción + Hombro + Brazos',
  type: 'strength_b',
  exercises: strengthBExercises,
  estimatedMinutes: 25,
);

const Workout workoutC = Workout(
  id: 'strength_c',
  name: 'Fuerza C – Full Upper + Posterior + Movilidad',
  type: 'strength_c',
  exercises: strengthCExercises,
  estimatedMinutes: 30,
);

Workout? getWorkoutForType(String type) {
  switch (type) {
    case 'strength_a': return workoutA;
    case 'strength_b': return workoutB;
    case 'strength_c': return workoutC;
    default: return null;
  }
}

List<Exercise> filterExercisesForPain({
  required List<Exercise> exercises,
  required int shoulderPain,
  required int kneePain,
}) {
  return exercises.where((e) {
    if (shoulderPain >= 6 && !e.tags.contains('shoulder_safe')) return false;
    if (kneePain >= 6 && !e.tags.contains('knee_safe')) return false;
    return true;
  }).toList();
}
