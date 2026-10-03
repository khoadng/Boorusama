/// Request `extra` flag for requests that change server state, such as adding
/// a favorite through a GET endpoint. Infrastructure that may replay a request
/// elsewhere, like a challenge browser, must not replay these.
const stateChangingRequestKey = 'coreutils.state_changing_request';

const stateChangingRequestExtra = <String, Object?>{
  stateChangingRequestKey: true,
};
