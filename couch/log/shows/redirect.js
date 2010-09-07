function(doc, req){
  // <form method="get" action="/tiny_cdr/_design/log/_list/report/call_detail">

  start({
    code: 302,
    headers: {'Location': '/tiny_cdr/_design/log/_list/report/call_detail'}
  });
}
