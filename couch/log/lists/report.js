function(head, req){
  start({code: 200, headers: {'Content-Type': 'text/html'}});

  var row;

  send('<table>');
  send(
    <tr>
      <th>Username</th>
      <th>CID Num</th>
      <th>CID Name</th>
      <th>Dest Num</th>
      <th>Channel</th>
      <th>Context</th>
      <th>Start</th>
      <th>End</th>
      <th>Duration</th>
      <th>Bill Secs</th>
    </tr>
  );

  while(row = getRow()){
    var doc = row.value;
    send(
      <tr>
        <td>{doc.username}</td>
        <td>{doc.caller_id_number}</td>
        <td>{doc.caller_id_name}</td>
        <td>{doc.destination_number}</td>
        <td>{doc.chan_name}</td>
        <td>{doc.context}</td>
        <td>{doc.start}</td>
        <td>{doc.end}</td>
        <td>{doc.duration}</td>
        <td>{doc.billsec}</td>
      </tr>
    );
  }

  send('</table>');
}
