enum NoteState {
  /// Note was loaded from server and hasn't been modified
  unchanged,

  /// Note was created locally and needs to be sent to server
  added,

  /// Note exists on server but has been modified locally
  modified,

  /// Note exists on server and should be deleted
  deleted,
}
