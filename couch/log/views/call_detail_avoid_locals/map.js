function(doc) {
  if(doc.type != 'Log'){ return }

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

  var seen = [],
      valid = /^\\d{4}\\d+$/,
      elements = [profile.username];

  if(valid.test(profile.caller_id_number)){ elements.push(profile.caller_id_number); }
  if(valid.test(profile.destination_number)){ elements.push(profile.destination_number); }

  elements.forEach(function(element){
    if(seen.indexOf(element) == -1){
      seen.push(element);
      emit([element, variables.start_epoch], value);
    }
  });
}
