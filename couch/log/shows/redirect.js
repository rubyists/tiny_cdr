function(doc, req){
  var date_start = Date.parse(req.query.date_start) / 1000,
      date_end = Date.parse(req.query.date_end) / 1000,
      username = req.query.username;

  var query =
    '?startkey=' + encodeURIComponent('["' + username + '",' + date_start + ']') +
    '&endkey=' + encodeURIComponent('["' +  username + '",' + date_end + ']');

  var url = '/tiny_cdr/_design/log/_list/report/call_detail' + query;

  return {code: 302, body: 'See ' + url, headers: {'Location': url}}
}
