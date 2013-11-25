$(document).ready(function() {
  $('#user_calls').dataTable({
    "sDom": 'r<"clear">T<"clear">lftip',
    "oTableTools": {
      "sSwfPath": "/swf/copy_csv_xls_pdf.swf",
      "aButtons": [
                {
                    "sExtends": "csv",
                    "sButtonText": "CSV",
                    "mColumns": [ 0, 1, 2, 3, 4, 5 ]
                },
                {
                    "sExtends": "print",
                    "sButtonText": "Print",
                    "mColumns": [ 0, 1, 2, 3, 4, 5]
                },
                {
                    "sExtends": "pdf",
                    "sButtonText": "PDF - Reporting columns",
                    "mColumns": [ 0, 1, 2, 3, 4, 5 ]
                },
                {
                    "sExtends": "pdf",
                    "sButtonText": "PDF - All",
                    "mColumns": "visible"
                }
            ]
    }
  });
});
