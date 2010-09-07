function(doc, req){
  start({code: 200, headers: {'Content-Type': 'text/html'}});

  return("<!DOCTYPE html>\n" + (
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>TinyCDR - FreeSWITCH CDR Reporting</title>
    <link type="text/css" rel="stylesheet" href="/tiny_cdr/jquery-datepicker/jquery-ui-1.8.4.custom.css" />
    <style><![CDATA[
      label, input { display: block; }
    ]]></style>
    <script type="text/javascript" src="/tiny_cdr/jquery-datepicker/jquery-1.4.2.min.js"><![CDATA[]]></script>
    <script type="text/javascript" src="/tiny_cdr/jquery-datepicker/jquery-ui-1.8.4.custom.min.js"><![CDATA[]]></script>
    <script type="text/javascript"><![CDATA[
      $(function(){
        $('.datepicker').datepicker({
          minDate: '-1Y',
          maxDate: '+0D',
          dateFormat: 'd M, yy',
        });
      });
    ]]></script>
  </head>
  <body>
    <h1>TinyCDR - FreeSWITCH CDR Reporting</h1>
    <form method="get" action="/tiny_cdr/_design/log/_show/redirect">
      <fieldset>
        <legend>Query</legend>
        <label for="date_start">Start Date:</label>
        <input type="text" id="date_start" name="date_start" class="datepicker" />

        <label for="date_end">End Date:</label>
        <input type="text" id="date_end" name="date_end" class="datepicker" />

        <label for="username">Username (Extension):</label>
        <input type="text" id="username" name="username" />

        <label for="phone_number">Phone Number:</label>
        <input type="text" id="phone_number" name="phone_number" />

        <label for="avoid_locals">Ignore Local (extension to extension) Calls?</label>
        <input type="checkbox" id="avoid_locals" name="avoid_locals" />

        <input type="submit" />
      </fieldset>
    </form>
  </body>
</html>
  ).toXMLString());
}
