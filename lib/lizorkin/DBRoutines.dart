

class DBRoutines
{

  static final DBRoutines _instance = DBRoutines._internal();

  DBRoutines._internal() {
    //TODO DB init
  }

  factory DBRoutines() {
    return _instance;
  }

}