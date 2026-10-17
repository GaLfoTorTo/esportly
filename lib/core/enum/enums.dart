//VISIBILIDADE GERAL
enum Privacy { Public, Private }
//MODALIDADE DE EVENTO
enum Modality { Football, Basketball, Volleyball }
//CATEGORIAS 
enum Category { Futebol, Fut7, Futsal, Volei, Volei_de_Praia, Fut_volei, Basquete, Streetball }
//PERMISSÕES DE COLABORADORES DO EVENTO
enum Permissions { Add, Remove, Edit }
//REGRAS DE PARTICIPAÇÃO DO EVENTO
enum Roles { Organizator, Colaborator, Refereer, Player, Manager }
//STATUS DE PARTIDAS
enum GameStatus { Scheduled, InProgress, Completed, Cancelled }
//STATUS DE PARTICIPANTES DO EVENTO
enum PlayerStatus { Avaliable, Out, Doubt, None }
//TIPO DE ACHIVMENT
enum AchievementType { Single, Progressive }
//TIPOS DE SNAPSHOT
enum SnapshotType { snapshot, action, unknown }
//STATUS DE CONEXÃO DO WEBSOCKET
enum ConnectionState { disconnected, connecting, connected, error }
//TIPOS DE EVENTO DA SALA DE STREAM
enum RoomEventType { open, close, join, exit }
//TIPO DE EVENTO NA PARTIDA
enum GameEvent {
  //TIME
  StartGame,
  EndGame,
  HalfTimeEnd,
  ExtraTime,
  ExtraTimeStart,
  ExtraTimeEnd,
  Penalties,

  //FINALIZAÇÕES — FUTEBOL
  Goal,
  Assist,
  ShotOnPost,
  ShotSaved,
  ShotMissed,
  FoulTaken,
  Defense,
  CleanSheet,
  PenaltySave,
  GoalkeeperSave,
  GoalkeeperFail,
  Penalty,
  PenaltyMissed,
  OwnGoal,
  WrongPass,

  //BOLA PARADA
  Corner,
  FreeKick,
  GoalKick,

  //IMPEDIMENTO
  Offside,

  //FALTA E DISCIPLINA
  Foul,
  YellowCard,
  RedCard,

  //SUBSTITUIÇÃO
  Substitution,

  //INTERCEPTAÇÕES
  Interception,

  //OUTROS
  Injury,
  VARCheck,

  //BASQUETE
  Point2,
  Point3,
  BasketAssist,
  Rebound,
  Steal,
  BlockShot,
  Turnover,
  PersonalFoul,

  //VOLEIBOL
  Ace,
  VolleyPoint,
  Block,
  DefensiveSave,
  ServingError,
  Fault,
}
//TIPO DE NOTICIAS DO EVENTO
enum NewsType { 
  EventRegister,
  EventUpdate,
  EventLocation,
  EventConfig,
  EventGameDay,
  EventGame,
  EventNewRule,
  EventAlterRule,
  EventRemoveRule,
  ParticipantAdd,
  ParticipantRemove,
  ParticipantLeft,
  ParticipantChange,
}