function(doc) {
  var profile = doc.callflow.caller_profile,
      variables = doc.variables;

  var value = {
    username:           profile.username,
    caller_id_number:   profile.caller_id_number,
    caller_id_name:     profile.caller_id_name,
    destination_number: profile.destination_number,
    chan_name:          profile.chan_name,
    context:            profile.context,
    start:    variables.start_epoch,
    end:      variables.end_epoch,
    duration: variables.duration,
    billsec:  variables.billsec,
  }

  var seen = [];
  [ profile.username,
    profile.caller_id_number,
    profile.destination_number
  ].forEach(function(element){
    if(seen.indexOf(element) == -1){
      seen.push(element);
      emit([element, variables.start_epoch], value);
    }
  });
}
